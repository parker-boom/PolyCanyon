import React, { createContext, useState, useContext, useEffect } from "react";
import AsyncStorage from "@react-native-async-storage/async-storage";

// Create context
const AppStateContext = createContext();

// Keys for AsyncStorage
const STORAGE_KEYS = {
  MAP_STYLE: "mapStyle",
};

export const AppStateProvider = ({ children }) => {
  // Map style state
  const [mapStyle, setMapStyle] = useState("standard"); // standard, satellite

  // Structure and popup management
  const [visitedPopupVisible, setVisitedPopupVisible] = useState(false);
  const [selectedStructure, setSelectedStructure] = useState(null);

  // Load saved state on mount
  useEffect(() => {
    loadSavedState();
  }, []);

  const loadSavedState = async () => {
    try {
      const savedMapStyle = await AsyncStorage.getItem(STORAGE_KEYS.MAP_STYLE);
      if (savedMapStyle) setMapStyle(savedMapStyle);
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

  const showVisitedPopup = () => setVisitedPopupVisible(true);
  const hideVisitedPopup = () => setVisitedPopupVisible(false);

  const value = {
    mapStyle,
    toggleMapStyle,
    visitedPopupVisible,
    showVisitedPopup,
    hideVisitedPopup,
    selectedStructure,
    setSelectedStructure,
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
