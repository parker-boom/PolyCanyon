// MARK: - DarkMode
/**
 * DarkMode
 * 
 * This file implements a dark mode functionality for a React Native application using Context API.
 * It provides:
 * - A DarkModeProvider component to manage and persist dark mode state
 * - A toggle function to switch between dark and light modes
 * - AsyncStorage integration for persisting user preferences
 * - A custom hook (useDarkMode) for easy access to dark mode context
 * 
 * The implementation ensures consistent dark mode behavior across app sessions and components.
 */

import React, { createContext, useState, useContext, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';

// MARK: - Context Creation
// Create a new context for dark mode
const DarkModeContext = createContext();

// MARK: - Provider Component
export const DarkModeProvider = ({ children }) => {
  // State to track whether dark mode is active
  const [isDarkMode, setIsDarkMode] = useState(false);

  // Load saved dark mode settings when the component mounts
  useEffect(() => {
    loadDarkModeSettings();
  }, []);

  // MARK: - Load Dark Mode Settings
  // Retrieve dark mode preference from AsyncStorage
  const loadDarkModeSettings = async () => {
    try {
      const darkModeValue = await AsyncStorage.getItem('isDarkMode');
      setIsDarkMode(darkModeValue === null ? false : JSON.parse(darkModeValue));
    } catch (error) {
      console.error('Failed to load dark mode settings', error);
    }
  };

  // MARK: - Toggle Dark Mode
  // Switch dark mode state and save the new preference
  const toggleDarkMode = async () => {
    const newDarkModeValue = !isDarkMode;
    setIsDarkMode(newDarkModeValue);
    try {
      await AsyncStorage.setItem('isDarkMode', JSON.stringify(newDarkModeValue));
    } catch (error) {
      console.error('Failed to save dark mode settings', error);
    }
  };

  // Provide dark mode state and toggle function to children components
  return (
    <DarkModeContext.Provider value={{ isDarkMode, toggleDarkMode }}>
      {children}
    </DarkModeContext.Provider>
  );
};

// MARK: - Custom Hook
// Hook for consuming dark mode context in other components
export const useDarkMode = () => {
  const context = useContext(DarkModeContext);
  if (context === undefined) {
    throw new Error('useDarkMode must be used within a DarkModeProvider');
  }
  return context;
};
