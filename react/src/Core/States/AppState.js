import React, { createContext, useState, useContext, useEffect } from "react";
import AsyncStorage from "@react-native-async-storage/async-storage";

// Create context
const AppStateContext = createContext();

// Keys for AsyncStorage
const STORAGE_KEYS = {
  MAP_STYLE: "mapStyle",
  VISITED_STRUCTURES: "visitedStructures",
};

export const AppStateProvider = ({ children }) => {
  // Change Set to Array
  const [visitedStructures, setVisitedStructures] = useState([]);
  const [mapStyle, setMapStyle] = useState("standard"); // standard, satellite

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

      // Load visited structures
      const savedVisitedStructures = await AsyncStorage.getItem(
        STORAGE_KEYS.VISITED_STRUCTURES
      );
      console.log("Loading saved structures:", savedVisitedStructures); // Debug log
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

  // Modified showVisitedPopup to use a functional state update
  const showVisitedPopup = (structureNumber) => {
    if (!isOnboardingCompleted) {
      console.log("Skipping visited popup during onboarding");
      return;
    }

    const numStructure = Number(structureNumber);
    // Use a functional update to ensure we always have the latest state:
    setVisitedStructures((prevVisitedStructures) => {
      console.log(
        "Inside functional update. Previous visited structures:",
        prevVisitedStructures
      );
      if (prevVisitedStructures.includes(numStructure)) {
        console.log(
          `Structure ${numStructure} already visited, skipping popup`
        );
        // Return the current state unchanged if already included
        return prevVisitedStructures;
      }
      // Not present? Create the new array.
      const newVisitedStructures = [...prevVisitedStructures, numStructure];
      console.log("New visited structures:", newVisitedStructures);
      // Persist the updated list to AsyncStorage.
      AsyncStorage.setItem(
        STORAGE_KEYS.VISITED_STRUCTURES,
        JSON.stringify(newVisitedStructures)
      ).catch((error) =>
        console.error("Error saving visited structures:", error)
      );

      // Because this update function is run immediately when showVisitedPopup is called,
      // we can safely trigger the popup here knowing that we are updating based on the latest state.
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

  // Update resetVisitedStructures to clear AsyncStorage as well
  const resetVisitedStructures = async () => {
    setVisitedStructures([]);
    try {
      await AsyncStorage.removeItem(STORAGE_KEYS.VISITED_STRUCTURES);
      console.log("Visited structures reset");
    } catch (error) {
      console.error("Error resetting visited structures:", error);
    }
  };

  // Mode selection popup management
  const showModeSelectionPopup = () => {
    setIsModeSelectionVisible(true);
  };

  const hideModeSelectionPopup = () => {
    setIsModeSelectionVisible(false);
  };

  // Update setIsOnboardingCompleted to persist the value
  const handleSetIsOnboardingCompleted = async (value) => {
    setIsOnboardingCompleted(value);
    try {
      await AsyncStorage.setItem("isFirstLaunchV2", value ? "false" : "true");
    } catch (error) {
      console.error("Error saving onboarding status:", error);
    }
  };

  const value = {
    // Map style
    mapStyle,
    toggleMapStyle,

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
