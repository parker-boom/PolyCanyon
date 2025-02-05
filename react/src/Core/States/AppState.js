import React, { createContext, useState, useContext, useEffect } from "react";
import AsyncStorage from "@react-native-async-storage/async-storage";

// Create context
const AppStateContext = createContext();

// Keys for AsyncStorage
const STORAGE_KEYS = {
  MAP_STYLE: "mapStyle",
  VISITED_STRUCTURES: "visitedStructures",
  // (Optional: You can persist mapShowNumbers if desired, e.g. "mapNumbers")
};

export const AppStateProvider = ({ children }) => {
  // Visited structures
  const [visitedStructures, setVisitedStructures] = useState([]);
  const [mapStyle, setMapStyle] = useState("standard"); // "standard" or "satellite"

  // New state for map numbers: true = show numbers, false = no numbers
  const [mapShowNumbers, setMapShowNumbers] = useState(true);

  // Structure and popup management
  const [visitedPopupVisible, setVisitedPopupVisible] = useState(false);
  const [selectedStructure, setSelectedStructure] = useState(null);

  // Mode selection popup management
  const [isModeSelectionVisible, setIsModeSelectionVisible] = useState(false);

  // Onboarding management
  const [isOnboardingCompleted, setIsOnboardingCompleted] = useState(true); // Default to true

  // Load saved state on mount
  useEffect(() => {
    loadSavedState();
  }, []);

  useEffect(() => {
    console.log("AppState - visitedStructures updated:", visitedStructures);
  }, [visitedStructures]);

  const loadSavedState = async () => {
    try {
      // Load map style
      const savedMapStyle = await AsyncStorage.getItem(STORAGE_KEYS.MAP_STYLE);
      if (savedMapStyle) setMapStyle(savedMapStyle);

      // (Optional: load mapShowNumbers if persisting)
      // const savedMapNumbers = await AsyncStorage.getItem("mapNumbers");
      // if (savedMapNumbers !== null) setMapShowNumbers(savedMapNumbers === "true");

      // Load visited structures
      const savedVisitedStructures = await AsyncStorage.getItem(
        STORAGE_KEYS.VISITED_STRUCTURES
      );
      console.log("Loading saved structures:", savedVisitedStructures);
      if (savedVisitedStructures) {
        const parsedStructures = JSON.parse(savedVisitedStructures);
        console.log("Setting visited structures to:", parsedStructures);
        setVisitedStructures(parsedStructures);
      }

      // Load onboarding status
      const onboardingCompleted = await AsyncStorage.getItem("isFirstLaunchV2");
      setIsOnboardingCompleted(onboardingCompleted === "false");
    } catch (error) {
      console.error("Error loading app state:", error);
    }
  };

  // Map style management
  const toggleMapStyle = async () => {
    const newStyle = mapStyle === "standard" ? "satellite" : "standard";
    setMapStyle(newStyle);
    try {
      await AsyncStorage.setItem(STORAGE_KEYS.MAP_STYLE, newStyle);
    } catch (error) {
      console.error("Error saving map style:", error);
    }
  };

  // New: Toggle mapShowNumbers
  const toggleMapNumbers = () => {
    setMapShowNumbers((prev) => !prev);
    // (Optional: Persist this state)
    AsyncStorage.setItem("mapNumbers", (!mapShowNumbers).toString()).catch(
      (error) => console.error("Error saving map numbers state:", error)
    );
  };

  // Modified showVisitedPopup to use a functional state update
  const showVisitedPopup = (structureNumber) => {
    if (!isOnboardingCompleted) {
      console.log("Skipping visited popup during onboarding");
      return;
    }

    const numStructure = Number(structureNumber);
    setVisitedStructures((prevVisitedStructures) => {
      console.log(
        "Inside functional update. Previous visited structures:",
        prevVisitedStructures
      );
      if (prevVisitedStructures.includes(numStructure)) {
        console.log(
          `Structure ${numStructure} already visited, skipping popup`
        );
        return prevVisitedStructures;
      }
      const newVisitedStructures = [...prevVisitedStructures, numStructure];
      console.log("New visited structures:", newVisitedStructures);
      AsyncStorage.setItem(
        STORAGE_KEYS.VISITED_STRUCTURES,
        JSON.stringify(newVisitedStructures)
      ).catch((error) =>
        console.error("Error saving visited structures:", error)
      );
      setSelectedStructure(numStructure);
      setVisitedPopupVisible(true);
      return newVisitedStructures;
    });
  };

  const hideVisitedPopup = () => {
    console.log("AppState - Hiding visited popup");
    setVisitedPopupVisible(false);
    setSelectedStructure(null);
  };

  const resetVisitedStructures = async () => {
    setVisitedStructures([]);
    try {
      await AsyncStorage.removeItem(STORAGE_KEYS.VISITED_STRUCTURES);
      console.log("Visited structures reset");
    } catch (error) {
      console.error("Error resetting visited structures:", error);
    }
  };

  const showModeSelectionPopup = () => {
    setIsModeSelectionVisible(true);
  };

  const hideModeSelectionPopup = () => {
    setIsModeSelectionVisible(false);
  };

  const handleSetIsOnboardingCompleted = async (value) => {
    setIsOnboardingCompleted(value);
    try {
      await AsyncStorage.setItem("isFirstLaunchV2", value ? "false" : "true");
    } catch (error) {
      console.error("Error saving onboarding status:", error);
    }
  };

  const value = {
    // Map style and numbers
    mapStyle,
    toggleMapStyle,
    mapShowNumbers,
    toggleMapNumbers,
    // Visited popup
    visitedPopupVisible,
    showVisitedPopup,
    hideVisitedPopup,
    resetVisitedStructures,
    // Structure selection
    selectedStructure,
    setSelectedStructure,
    // Mode selection
    isModeSelectionVisible,
    showModeSelectionPopup,
    hideModeSelectionPopup,
    // Onboarding
    isOnboardingCompleted,
    setIsOnboardingCompleted: handleSetIsOnboardingCompleted,
  };

  return (
    <AppStateContext.Provider value={value}>
      {children}
    </AppStateContext.Provider>
  );
};

export const useAppState = () => {
  const context = useContext(AppStateContext);
  if (!context) {
    throw new Error("useAppState must be used within an AppStateProvider");
  }
  return context;
};
