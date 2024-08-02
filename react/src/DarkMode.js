// DarkModeContext.js
import React, { createContext, useState, useContext, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';

const DarkModeContext = createContext();

export const DarkModeProvider = ({ children }) => {
  const [isDarkMode, setIsDarkMode] = useState(false);

  useEffect(() => {
    loadDarkModeSettings();
  }, []);

  const loadDarkModeSettings = async () => {
    try {
      const darkModeValue = await AsyncStorage.getItem('isDarkMode');
      setIsDarkMode(darkModeValue === null ? false : JSON.parse(darkModeValue));
    } catch (error) {
      console.error('Failed to load dark mode settings', error);
    }
  };

  const toggleDarkMode = async () => {
    const newDarkModeValue = !isDarkMode;
    setIsDarkMode(newDarkModeValue);
    try {
      await AsyncStorage.setItem('isDarkMode', JSON.stringify(newDarkModeValue));
    } catch (error) {
      console.error('Failed to save dark mode settings', error);
    }
  };

  return (
    <DarkModeContext.Provider value={{ isDarkMode, toggleDarkMode }}>
      {children}
    </DarkModeContext.Provider>
  );
};

export const useDarkMode = () => {
  const context = useContext(DarkModeContext);
  if (context === undefined) {
    throw new Error('useDarkMode must be used within a DarkModeProvider');
  }
  return context;
};