// MARK: - StructureContext
/**
 * StructureContext
 * 
 * This file defines a context and provider for managing structure data within the application.
 * It includes functions to load and save structure data using AsyncStorage, mark structures as visited,
 * reset visited structures, and keep track of visit statistics.
 * 
 * Features:
 * - Load structure data from AsyncStorage or initial JSON data
 * - Save structure data to AsyncStorage
 * - Mark structures as visited
 * - Reset visited structures
 * - Track visit statistics (total visits, days visited, last visit date)
 * - Custom hook to access structure context
 */

import React, { createContext, useState, useContext, useEffect } from 'react';
import rawStructureData from './structures.json';
import AsyncStorage from '@react-native-async-storage/async-storage';

const StructureContext = createContext();

export const useStructures = () => useContext(StructureContext);

const STRUCTURES_STORAGE_KEY = 'STRUCTURES_STORAGE_KEY_V4';
const DATA_VERSION_KEY = 'DATA_VERSION_KEY';
const CURRENT_DATA_VERSION = 3; // Increment this to force a reload

// Explicitly require each image
const images = {
  // Close-up images
  "C-1": require('../assets/photos/Close/C-1.jpg'),
  "C-2": require('../assets/photos/Close/C-2.jpg'),
  "C-3": require('../assets/photos/Close/C-3.jpg'),
  "C-4": require('../assets/photos/Close/C-4.jpg'),
  "C-5": require('../assets/photos/Close/C-5.jpg'),
  "C-6": require('../assets/photos/Close/C-6.jpg'),
  "C-7": require('../assets/photos/Close/C-7.jpg'),
  "C-8": require('../assets/photos/Close/C-8.jpg'),
  "C-9": require('../assets/photos/Close/C-9.jpg'),
  "C-10": require('../assets/photos/Close/C-10.jpg'),
  "C-11": require('../assets/photos/Close/C-11.jpg'),
  "C-12": require('../assets/photos/Close/C-12.jpg'),
  "C-13": require('../assets/photos/Close/C-13.jpg'),
  "C-14": require('../assets/photos/Close/C-14.jpg'),
  "C-15": require('../assets/photos/Close/C-15.jpg'),
  "C-16": require('../assets/photos/Close/C-16.jpg'),
  "C-17": require('../assets/photos/Close/C-17.jpg'),
  "C-18": require('../assets/photos/Close/C-18.jpg'),
  "C-19": require('../assets/photos/Close/C-19.jpg'),
  "C-20": require('../assets/photos/Close/C-20.jpg'),
  "C-21": require('../assets/photos/Close/C-21.jpg'),
  "C-22": require('../assets/photos/Close/C-22.jpg'),
  "C-23": require('../assets/photos/Close/C-23.jpg'),
  "C-24": require('../assets/photos/Close/C-24.jpg'),
  "C-25": require('../assets/photos/Close/C-25.jpg'),
  "C-26": require('../assets/photos/Close/C-26.jpg'),
  "C-27": require('../assets/photos/Close/C-27.jpg'),
  "C-28": require('../assets/photos/Close/C-28.jpg'),
  "C-29": require('../assets/photos/Close/C-29.jpg'),
  "C-30": require('../assets/photos/Close/C-30.jpg'),

  
  // Main images
  "M-1": require('../assets/photos/Main/M-1.jpg'),
  "M-2": require('../assets/photos/Main/M-2.jpg'),
  "M-3": require('../assets/photos/Main/M-3.jpg'),
  "M-4": require('../assets/photos/Main/M-4.jpg'),
  "M-5": require('../assets/photos/Main/M-5.jpg'),
  "M-6": require('../assets/photos/Main/M-6.jpg'),
  "M-7": require('../assets/photos/Main/M-7.jpg'),
  "M-8": require('../assets/photos/Main/M-8.jpg'),
  "M-9": require('../assets/photos/Main/M-9.jpg'),
  "M-10": require('../assets/photos/Main/M-10.jpg'),
  "M-11": require('../assets/photos/Main/M-11.jpg'),
  "M-12": require('../assets/photos/Main/M-12.jpg'),
  "M-13": require('../assets/photos/Main/M-13.jpg'),
  "M-14": require('../assets/photos/Main/M-14.jpg'),
  "M-15": require('../assets/photos/Main/M-15.jpg'),
  "M-16": require('../assets/photos/Main/M-16.jpg'),
  "M-17": require('../assets/photos/Main/M-17.jpg'),
  "M-18": require('../assets/photos/Main/M-18.jpg'),
  "M-19": require('../assets/photos/Main/M-19.jpg'),
  "M-20": require('../assets/photos/Main/M-20.jpg'),
  "M-21": require('../assets/photos/Main/M-21.jpg'),
  "M-22": require('../assets/photos/Main/M-22.jpg'),
  "M-23": require('../assets/photos/Main/M-23.jpg'),
  "M-24": require('../assets/photos/Main/M-24.jpg'),
  "M-25": require('../assets/photos/Main/M-25.jpg'),
  "M-26": require('../assets/photos/Main/M-26.jpg'),
  "M-27": require('../assets/photos/Main/M-27.jpg'),
  "M-28": require('../assets/photos/Main/M-28.jpg'),
  "M-29": require('../assets/photos/Main/M-29.jpg'),
  "M-30": require('../assets/photos/Main/M-30.jpg'),
};

// Update these functions to return both the image object and its file path
const getCloseImagePath = number => {
  const key = `C-${number}`;
  return { image: images[key], path: `../assets/photos/Close/${key}.jpg` };
};

const getMainImagePath = number => {
  const key = `M-${number}`;
  return { image: images[key], path: `../assets/photos/Main/${key}.jpg` };
};

export const StructureProvider = ({ children }) => {
    const [structures, setStructures] = useState([]);
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
        loadStructures();
    }, []);

    const loadStructures = async () => {
        setIsLoading(true);
        try {
            const storedDataVersion = await AsyncStorage.getItem(DATA_VERSION_KEY);
            const storedStructures = await AsyncStorage.getItem(STRUCTURES_STORAGE_KEY);

            if (storedDataVersion === null || parseInt(storedDataVersion) < CURRENT_DATA_VERSION) {
                // Reload from JSON if data version is outdated or not set
                await reloadStructuresFromJSON();
            } else if (storedStructures !== null) {
                // Load stored structures if available and data version is current
                setStructures(JSON.parse(storedStructures));
            } else {
                // Initial load if no stored structures
                await reloadStructuresFromJSON();
            }
        } catch (error) {
            console.error('Error loading structures:', error);
        } finally {
            setIsLoading(false);
        }
    };

    const reloadStructuresFromJSON = async () => {
        const newStructures = rawStructureData.map(s => ({
            ...s,
            closeUpImage: getCloseImagePath(s.number),
            mainImage: getMainImagePath(s.number),
            isVisited: false,
            isOpened: false,
            recentlyVisited: -1,
            isLiked: false // Add this line
        }));

        // Merge with existing data to preserve user-specific fields
        const mergedStructures = await mergeWithExistingData(newStructures);

        setStructures(mergedStructures);
        await AsyncStorage.setItem(STRUCTURES_STORAGE_KEY, JSON.stringify(mergedStructures));
        await AsyncStorage.setItem(DATA_VERSION_KEY, CURRENT_DATA_VERSION.toString());
    };

    const mergeWithExistingData = async (newStructures) => {
        const storedStructures = await AsyncStorage.getItem(STRUCTURES_STORAGE_KEY);
        if (storedStructures !== null) {
            const existingStructures = JSON.parse(storedStructures);
            return newStructures.map(newStruct => {
                const existingStruct = existingStructures.find(es => es.number === newStruct.number);
                if (existingStruct) {
                    return {
                        ...newStruct,
                        isVisited: existingStruct.isVisited,
                        isOpened: existingStruct.isOpened,
                        recentlyVisited: existingStruct.recentlyVisited,
                        isLiked: existingStruct.isLiked || false // Add this line
                    };
                }
                return newStruct;
            });
        }
        return newStructures;
    };

    useEffect(() => {
        const saveStructures = async () => {
            try {
                await AsyncStorage.setItem(STRUCTURES_STORAGE_KEY, JSON.stringify(structures));
            } catch (error) {
                console.error('Error saving structures:', error);
            }
        };

        if (structures.length > 0) {
            saveStructures();
        }
    }, [structures]);

    const markStructureAsVisited = (landmarkId) => {
        setStructures(prevStructures => {
            const updatedStructures = prevStructures.map(structure => 
                structure.number === landmarkId 
                    ? { ...structure, isVisited: true, recentlyVisited: Date.now() }
                    : structure
            );
            AsyncStorage.setItem(STRUCTURES_STORAGE_KEY, JSON.stringify(updatedStructures));
            return updatedStructures;
        });

        return structures.find(s => s.number === landmarkId);
    };

    // Mark structure as opened
    const markStructureAsOpened = (landmarkId) => {
        setStructures(prevStructures => {
            const updatedStructures = prevStructures.map(structure => 
                structure.number === landmarkId 
                    ? { ...structure, isOpened: true }
                    : structure
            );
            AsyncStorage.setItem(STRUCTURES_STORAGE_KEY, JSON.stringify(updatedStructures));
            return updatedStructures;
        });
    };

    // Reset visited structures
    const resetVisitedStructures = async () => {
        const resetStructures = structures.map(structure => ({
            ...structure,
            isVisited: false,
            isOpened: false,
            recentlyVisited: -1
        }));
        setStructures(resetStructures);
        await AsyncStorage.setItem(STRUCTURES_STORAGE_KEY, JSON.stringify(resetStructures));
    };

    // Reset favorited structures
    const resetFavoritedStructures = async () => {
        const resetStructures = structures.map(structure => ({
            ...structure,
            isLiked: false
        }));
        setStructures(resetStructures);
        await AsyncStorage.setItem(STRUCTURES_STORAGE_KEY, JSON.stringify(resetStructures));
    };

    // Toggle the liked status
    const toggleStructureLiked = (landmarkId, liked) => {
        setStructures(prevStructures => {
            const updatedStructures = prevStructures.map(structure => 
                structure.number === landmarkId 
                    ? { ...structure, isLiked: liked }
                    : structure
            );
            AsyncStorage.setItem(STRUCTURES_STORAGE_KEY, JSON.stringify(updatedStructures));
            return updatedStructures;
        });
    };

    const countLikedStructures = () => {
        return structures.filter(s => s.isLiked).length;
    };

    return (
        <StructureContext.Provider value={{ 
            structures, 
            setStructures, 
            isLoading,
            markStructureAsVisited,
            markStructureAsOpened,
            resetVisitedStructures,
            reloadStructuresFromJSON,
            toggleStructureLiked,
            countLikedStructures,
            resetFavoritedStructures 
        }}>
            {children}
        </StructureContext.Provider>
    );
};
