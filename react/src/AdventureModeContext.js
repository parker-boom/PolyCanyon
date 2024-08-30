import React, { createContext, useState, useContext, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';

const AdventureModeContext = createContext();

export const AdventureModeProvider = ({ children }) => {
  const [adventureMode, setAdventureMode] = useState(true);

  useEffect(() => {
    loadAdventureMode();
  }, []);

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

  const updateAdventureMode = async (newMode) => {
    setAdventureMode(newMode);
    try {
      await AsyncStorage.setItem('adventureMode', JSON.stringify(newMode));
    } catch (error) {
      console.log('Error saving adventure mode:', error);
    }
  };

  return (
    <AdventureModeContext.Provider value={{ adventureMode, updateAdventureMode }}>
      {children}
    </AdventureModeContext.Provider>
  );
};

export const useAdventureMode = () => useContext(AdventureModeContext);
