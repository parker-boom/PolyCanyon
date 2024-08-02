// MARK: - DarkMode
/**
 * DarkMode
 * 
 * This file defines a context and provider for managing dark mode settings across the application.
 * It includes functions to load and save the dark mode state using AsyncStorage, and provides
 * a toggle function to switch between dark mode and light mode.
 * 
 * Features:
 * - Provides dark mode state and toggle function
 * - Persists dark mode setting using AsyncStorage
 * - Custom hook to access dark mode context
 */

import React, { createContext, useState, useContext, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';

// MARK: - Context Creation
const DarkModeContext = createContext();

// MARK: - Provider Component
export const DarkModeProvider = ({ children }) => {
  // State variable to manage dark mode
  const [isDarkMode, setIsDarkMode] = useState(false);

  // Load dark mode settings on component mount
  useEffect(() => {
    loadDarkModeSettings();
  }, []);

  // MARK: - Load Dark Mode Settings
  const loadDarkModeSettings = async () => {
    try {
      const darkModeValue = await AsyncStorage.getItem('isDarkMode');
      setIsDarkMode(darkModeValue === null ? false : JSON.parse(darkModeValue));
    } catch (error) {
      console.error('Failed to load dark mode settings', error);
    }
  };

  // MARK: - Toggle Dark Mode
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
export const useDarkMode = () => {
  const context = useContext(DarkModeContext);
  if (context === undefined) {
    throw new Error('useDarkMode must be used within a DarkModeProvider');
  }
  return context;
};
