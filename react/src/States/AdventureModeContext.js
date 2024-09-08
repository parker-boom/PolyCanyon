import React, { createContext, useState, useContext, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Create a new context for Adventure Mode
const AdventureModeContext = createContext();

// Provider component to wrap the app and provide Adventure Mode state
export const AdventureModeProvider = ({ children }) => {
  // State to hold the current Adventure Mode status
  const [adventureMode, setAdventureMode] = useState(true);

  // Load saved Adventure Mode status on component mount
  useEffect(() => {
    loadAdventureMode();
  }, []);

  // Function to load Adventure Mode status from AsyncStorage
  const loadAdventureMode = async () => {
    try {
      const value = await AsyncStorage.getItem('adventureMode');
      if (value !== null) {
        setAdventureMode(JSON.parse(value));
      }
    } catch (error) {
      console.log('Error loading adventure mode:', error);
    }
  };

  // Function to update Adventure Mode status and save to AsyncStorage
  const updateAdventureMode = async (newMode) => {
    setAdventureMode(newMode);
    try {
      await AsyncStorage.setItem('adventureMode', JSON.stringify(newMode));
    } catch (error) {
      console.log('Error saving adventure mode:', error);
    }
  };

  // Provide the Adventure Mode state and update function to children components
  return (
    <AdventureModeContext.Provider value={{ adventureMode, updateAdventureMode }}>
      {children}
    </AdventureModeContext.Provider>
  );
};

// Custom hook to easily access Adventure Mode context in other components
export const useAdventureMode = () => useContext(AdventureModeContext);
