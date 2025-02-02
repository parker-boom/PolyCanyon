// DataStore.js
import React, { createContext, useContext, useState, useEffect } from "react";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { Structure } from "./Models";
import { useAppState } from "../States/AppState";

// Import JSON data (assumed to be an array of structure objects)
import structuresData from "./structuresList.json";

// Create context
const DataStoreContext = createContext(null);

// Keys for AsyncStorage
const STORAGE_KEYS = {
  DYNAMIC_DATA: "dynamicStructureData",
};

export const DataStoreProvider = ({ children }) => {
  const { showVisitedPopup } = useAppState();

  // Immediately initialize state with static JSON data.
  // This guarantees that our data is available synchronously.
  const [structures, setStructures] = useState(() =>
    structuresData.map((structureData) => new Structure(structureData))
  );
  const [visitCounter, setVisitCounter] = useState(0);

  // Since we have the static data immediately, we consider the data “loaded.”
  // (If you want to block UI until the dynamic merge is complete, you could
  // add another flag here—but for now, static data is enough.)
  const [isLoaded, setIsLoaded] = useState(true);

  // On mount, asynchronously load dynamic data and merge it with the static data.
  useEffect(() => {
    const loadDynamicData = async () => {
      try {
        const storedDynamicData = await AsyncStorage.getItem(
          STORAGE_KEYS.DYNAMIC_DATA
        );
        const dynamicData = storedDynamicData
          ? JSON.parse(storedDynamicData)
          : {};

        // Merge dynamic properties into the existing static structures.
        setStructures((current) =>
          current.map((structure) => {
            const dynamicProps = dynamicData[structure.number] || {};
            return Object.assign(
              Object.create(Object.getPrototypeOf(structure)),
              structure,
              dynamicProps
            );
          })
        );
      } catch (error) {
        console.error("DataStore - Error loading dynamic data:", error);
      }
    };

    loadDynamicData();
  }, []);

  // Save dynamic data to AsyncStorage whenever structures change.
  useEffect(() => {
    const saveDynamicData = async () => {
      try {
        const dynamicData = structures.reduce((acc, structure) => {
          // Persist only the dynamic properties
          acc[structure.number] = structure.toJSON();
          return acc;
        }, {});
        await AsyncStorage.setItem(
          STORAGE_KEYS.DYNAMIC_DATA,
          JSON.stringify(dynamicData)
        );
      } catch (error) {
        console.error("DataStore - Error saving dynamic data:", error);
      }
    };

    saveDynamicData();
  }, [structures]);

  // Helper to update a structure while preserving its prototype.
  const updateStructure = (number, updates) => {
    setStructures((current) =>
      current.map((structure) => {
        if (structure.number === number) {
          const updatedStructure = Object.assign(
            Object.create(Object.getPrototypeOf(structure)),
            structure,
            updates
          );
          return updatedStructure;
        }
        return structure;
      })
    );
  };

  const isVisited = (number) => {
    const structure = getStructure(number);
    return structure.isVisited;
  };

  // Structure operations
  const markStructureAsVisited = (number) => {
    const structure = getStructure(number);
    if (!structure) {
      console.log(`DataStore - Structure ${number} not found`);
      return;
    }

    if (structure.isVisited) {
      console.log(`DataStore - Structure ${number} already visited, skipping`);
      return;
    }

    const nextVisitCount = visitCounter + 1;
    setVisitCounter(nextVisitCount);
    updateStructure(number, {
      isVisited: true,
      recentlyVisited: nextVisitCount,
    });
    showVisitedPopup(number);
  };

  const markStructureAsOpened = (number) => {
    updateStructure(number, { isOpened: true });
  };

  const toggleStructureLiked = (number) => {
    const structure = structures.find((s) => s.number === number);
    if (structure) {
      updateStructure(number, { isLiked: !structure.isLiked });
    }
  };

  const dismissLastVisitedStructure = () => {
    // Assuming you may add logic later for lastVisitedStructure.
  };

  const resetStructures = async () => {
    setVisitCounter(0);
    // Reset dynamic properties while preserving the static data.
    setStructures((current) =>
      current.map((structure) =>
        Object.assign(
          Object.create(Object.getPrototypeOf(structure)),
          structure,
          {
            isVisited: false,
            isOpened: false,
            recentlyVisited: -1,
            isLiked: false,
          }
        )
      )
    );
    await AsyncStorage.removeItem(STORAGE_KEYS.DYNAMIC_DATA);
  };

  // Filter operations
  const getVisitedStructures = () => {
    return structures
      .filter((structure) => structure.isVisited)
      .sort((a, b) => b.recentlyVisited - a.recentlyVisited);
  };

  const getLikedStructures = () => {
    return structures.filter((structure) => structure.isLiked);
  };

  // Status checks
  const hasVisitedStructures = () =>
    structures.some((structure) => structure.isVisited);
  const hasLikedStructures = () =>
    structures.some((structure) => structure.isLiked);

  // Get structure by number
  const getStructure = (number) => {
    return structures.find((s) => s.number === number);
  };

  const value = {
    structures,
    isLoaded, // Now always true (since static data is there immediately)
    markStructureAsVisited,
    markStructureAsOpened,
    toggleStructureLiked,
    dismissLastVisitedStructure,
    resetStructures,
    getVisitedStructures,
    getLikedStructures,
    hasVisitedStructures,
    hasLikedStructures,
    getStructure,
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
    throw new Error("useDataStore must be used within a DataStoreProvider");
  }
  return context;
};
