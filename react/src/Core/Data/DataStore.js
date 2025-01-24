import React, { createContext, useContext, useState, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Structure, MapPoint } from './Models';

// Import JSON data
import structuresData from './structuresList.json';

// Create context
const DataStoreContext = createContext(null);

// Keys for AsyncStorage
const STORAGE_KEYS = {
  DYNAMIC_DATA: 'dynamicStructureData',
};

export const DataStoreProvider = ({ children }) => {
  // State management
  const [structures, setStructures] = useState([]);
  const [lastVisitedStructure, setLastVisitedStructure] = useState(null);
  const [visitCounter, setVisitCounter] = useState(0);

  // Initial load of data
  useEffect(() => {
    loadData();
  }, []);

  // Load data from JSON and AsyncStorage
  const loadData = async () => {
    try {
      // Load dynamic data from AsyncStorage
      const storedDynamicData = await AsyncStorage.getItem(STORAGE_KEYS.DYNAMIC_DATA);
      const dynamicData = storedDynamicData ? JSON.parse(storedDynamicData) : {};

      // Create Structure instances with merged static and dynamic data
      const loadedStructures = structuresData.map(structureData => {
        const dynamicProps = dynamicData[structureData.Number] || {};
        return new Structure({ ...structureData, ...dynamicProps });
      });

      setStructures(loadedStructures);
    } catch (error) {
      console.error('Error loading data:', error);
    }
  };

  // Save dynamic data to AsyncStorage
  const saveDynamicData = async () => {
    try {
      const dynamicData = structures.reduce((acc, structure) => {
        acc[structure.number] = structure.toJSON();
        return acc;
      }, {});
      
      await AsyncStorage.setItem(STORAGE_KEYS.DYNAMIC_DATA, JSON.stringify(dynamicData));
    } catch (error) {
      console.error('Error saving dynamic data:', error);
    }
  };

  // Helper to update a structure
  const updateStructure = (number, updates) => {
    setStructures(current => {
      const newStructures = current.map(structure => 
        structure.number === number ? { ...structure, ...updates } : structure
      );
      return newStructures;
    });
    saveDynamicData();
  };

  // Structure operations
  const markStructureAsVisited = (number) => {
    const nextVisitCount = visitCounter + 1;
    setVisitCounter(nextVisitCount);
    
    updateStructure(number, {
      isVisited: true,
      recentlyVisited: nextVisitCount
    });
    
    setLastVisitedStructure(number);
  };

  const markStructureAsOpened = (number) => {
    updateStructure(number, { isOpened: true });
  };

  const toggleStructureLiked = (number) => {
    const structure = structures.find(s => s.number === number);
    if (structure) {
      updateStructure(number, { isLiked: !structure.isLiked });
    }
  };

  const dismissLastVisitedStructure = () => {
    setLastVisitedStructure(null);
  };

  const resetStructures = async () => {
    setVisitCounter(0);
    setLastVisitedStructure(null);
    
    const resetStructures = structures.map(structure => ({
      ...structure,
      isVisited: false,
      isOpened: false,
      recentlyVisited: -1,
      isLiked: false
    }));
    
    setStructures(resetStructures);
    await AsyncStorage.removeItem(STORAGE_KEYS.DYNAMIC_DATA);
  };

  // Filter operations
  const getVisitedStructures = () => {
    return structures
      .filter(structure => structure.isVisited)
      .sort((a, b) => b.recentlyVisited - a.recentlyVisited);
  };

  const getLikedStructures = () => {
    return structures.filter(structure => structure.isLiked);
  };

  // Status checks
  const hasVisitedStructures = () => structures.some(structure => structure.isVisited);
  const hasLikedStructures = () => structures.some(structure => structure.isLiked);

  // Get structure by number
  const getStructure = (number) => structures.find(s => s.number === number);

  const value = {
    structures,
    lastVisitedStructure,
    markStructureAsVisited,
    markStructureAsOpened,
    toggleStructureLiked,
    dismissLastVisitedStructure,
    resetStructures,
    getVisitedStructures,
    getLikedStructures,
    hasVisitedStructures,
    hasLikedStructures,
    getStructure
  };

  return (
    <DataStoreContext.Provider value={value}>
      {children}
    </DataStoreContext.Provider>
  );
};

// Custom hook for using the data store
export const useDataStore = () => {
  const context = useContext(DataStoreContext);
  if (!context) {
    throw new Error('useDataStore must be used within a DataStoreProvider');
  }
  return context;
};
