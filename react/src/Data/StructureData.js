// MARK: - StructureContext

/**
 * StructureContext
 * 
 * This file defines a context and provider for managing structure data within the application.
 * It handles loading, saving, and manipulating structure data, including visit and like status.
 * 
 * Key features:
 * - Load and save structure data using AsyncStorage
 * - Mark structures as visited or liked
 * - Reset visited or favorited structures
 * - Load and manage structure images
 * - Provide structure data and related functions to the app via context
 * - Handle data versioning to ensure up-to-date information
 */

import React, { createContext, useState, useContext, useEffect } from 'react';
import rawStructureData from './structures.json';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Create context and custom hook for accessing structure data
const StructureContext = createContext();
export const useStructures = () => useContext(StructureContext);

// Constants for storage keys and data versioning
const STRUCTURES_STORAGE_KEY = 'STRUCTURES_STORAGE_KEY_V4';
const DATA_VERSION_KEY = 'DATA_VERSION_KEY';
const CURRENT_DATA_VERSION = 3; // Increment this to force a reload

// MARK: - Image Management

// Object to store all required images
const images = {
  // Close-up images
  "C-1": require('../../assets/photos/Close/C-1.jpg'),
  "C-2": require('../../assets/photos/Close/C-2.jpg'),
  "C-3": require('../../assets/photos/Close/C-3.jpg'),
  "C-4": require('../../assets/photos/Close/C-4.jpg'),
  "C-5": require('../../assets/photos/Close/C-5.jpg'),
  "C-6": require('../../assets/photos/Close/C-6.jpg'),
  "C-7": require('../../assets/photos/Close/C-7.jpg'),
  "C-8": require('../../assets/photos/Close/C-8.jpg'),
  "C-9": require('../../assets/photos/Close/C-9.jpg'),
  "C-10": require('../../assets/photos/Close/C-10.jpg'),
  "C-11": require('../../assets/photos/Close/C-11.jpg'),
  "C-12": require('../../assets/photos/Close/C-12.jpg'),
  "C-13": require('../../assets/photos/Close/C-13.jpg'),
  "C-14": require('../../assets/photos/Close/C-14.jpg'),
  "C-15": require('../../assets/photos/Close/C-15.jpg'),
  "C-16": require('../../assets/photos/Close/C-16.jpg'),
  "C-17": require('../../assets/photos/Close/C-17.jpg'),
  "C-18": require('../../assets/photos/Close/C-18.jpg'),
  "C-19": require('../../assets/photos/Close/C-19.jpg'),
  "C-20": require('../../assets/photos/Close/C-20.jpg'),
  "C-21": require('../../assets/photos/Close/C-21.jpg'),
  "C-22": require('../../assets/photos/Close/C-22.jpg'),
  "C-23": require('../../assets/photos/Close/C-23.jpg'),
  "C-24": require('../../assets/photos/Close/C-24.jpg'),
  "C-25": require('../../assets/photos/Close/C-25.jpg'),
  "C-26": require('../../assets/photos/Close/C-26.jpg'),
  "C-27": require('../../assets/photos/Close/C-27.jpg'),
  "C-28": require('../../assets/photos/Close/C-28.jpg'),
  "C-29": require('../../assets/photos/Close/C-29.jpg'),
  "C-30": require('../../assets/photos/Close/C-30.jpg'),

  
  // Main images
  "M-1": require('../../assets/photos/Main/M-1.jpg'),
  "M-2": require('../../assets/photos/Main/M-2.jpg'),
  "M-3": require('../../assets/photos/Main/M-3.jpg'),
  "M-4": require('../../assets/photos/Main/M-4.jpg'),
  "M-5": require('../../assets/photos/Main/M-5.jpg'),
  "M-6": require('../../assets/photos/Main/M-6.jpg'),
  "M-7": require('../../assets/photos/Main/M-7.jpg'),
  "M-8": require('../../assets/photos/Main/M-8.jpg'),
  "M-9": require('../../assets/photos/Main/M-9.jpg'),
  "M-10": require('../../assets/photos/Main/M-10.jpg'),
  "M-11": require('../../assets/photos/Main/M-11.jpg'),
  "M-12": require('../../assets/photos/Main/M-12.jpg'),
  "M-13": require('../../assets/photos/Main/M-13.jpg'),
  "M-14": require('../../assets/photos/Main/M-14.jpg'),
  "M-15": require('../../assets/photos/Main/M-15.jpg'),
  "M-16": require('../../assets/photos/Main/M-16.jpg'),
  "M-17": require('../../assets/photos/Main/M-17.jpg'),
  "M-18": require('../../assets/photos/Main/M-18.jpg'),
  "M-19": require('../../assets/photos/Main/M-19.jpg'),
  "M-20": require('../../assets/photos/Main/M-20.jpg'),
  "M-21": require('../../assets/photos/Main/M-21.jpg'),
  "M-22": require('../../assets/photos/Main/M-22.jpg'),
  "M-23": require('../../assets/photos/Main/M-23.jpg'),
  "M-24": require('../../assets/photos/Main/M-24.jpg'),
  "M-25": require('../../assets/photos/Main/M-25.jpg'),
  "M-26": require('../../assets/photos/Main/M-26.jpg'),
  "M-27": require('../../assets/photos/Main/M-27.jpg'),
  "M-28": require('../../assets/photos/Main/M-28.jpg'),
  "M-29": require('../../assets/photos/Main/M-29.jpg'),
  "M-30": require('../../assets/photos/Main/M-30.jpg'),
};

// Functions to get image objects and paths
const getCloseImagePath = number => {
  const key = `C-${number}`;
  return { image: images[key], path: `../../assets/photos/Close/${key}.jpg` };
};

const getMainImagePath = number => {
  const key = `M-${number}`;
  return { image: images[key], path: `../../assets/photos/Main/${key}.jpg` };
};

// MARK: - StructureProvider

export const StructureProvider = ({ children }) => {
    // State management for structures and loading status
    const [structures, setStructures] = useState([]);
    const [isLoading, setIsLoading] = useState(true);

    // Load structures on component mount
    useEffect(() => {
        loadStructures();
    }, []);

    // MARK: - Data Loading and Management

    // Function to load structures from storage or initial JSON
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

    // Function to reload structures from JSON and merge with existing data
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

    // Helper function to merge new structure data with existing user data
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

    // Save structures to AsyncStorage whenever they change
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

    // MARK: - Structure Interaction Functions

    // Function to mark a structure as visited
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

    // Function to mark a structure as opened
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

    // Function to reset all visited structures
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

    // Function to reset all favorited structures
    const resetFavoritedStructures = async () => {
        const resetStructures = structures.map(structure => ({
            ...structure,
            isLiked: false
        }));
        setStructures(resetStructures);
        await AsyncStorage.setItem(STRUCTURES_STORAGE_KEY, JSON.stringify(resetStructures));
    };

    // Function to toggle the liked status of a structure
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

    // Function to count the number of liked structures
    const countLikedStructures = () => {
        return structures.filter(s => s.isLiked).length;
    };

    // Provide context value to children components
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
