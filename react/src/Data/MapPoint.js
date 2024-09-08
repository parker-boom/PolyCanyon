// MARK: - MapPointsContext
/**
 * MapPointsContext
 * 
 * This file manages map points data using React Context and AsyncStorage.
 * It provides functionality to:
 * - Load map points from AsyncStorage or initial JSON data
 * - Save map points to AsyncStorage
 * - Reset visited status of all map points
 * - Access map points data and functions via a custom hook
 * 
 * The context ensures consistent map point data across the application.
 */

import React, { createContext, useState, useContext, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import mapPointsData from './mapPoints.json';

// MARK: - Context Creation
const MapPointsContext = createContext();

// Custom hook for easy access to MapPoints context
export const useMapPoints = () => useContext(MapPointsContext);

// Storage keys for AsyncStorage
const MAP_POINTS_STORAGE_KEY = 'MAP_POINTS_STORAGE_KEY';
const MAP_POINTS_RELOADED_KEY = 'MAP_POINTS_RELOADED_KEY';

// MARK: - Provider Component
export const MapPointsProvider = ({ children }) => {
    // State for map points and reload status
    const [mapPoints, setMapPoints] = useState([]);
    const [mapPointsReloaded, setMapPointsReloaded] = useState(false);

    // MARK: - Load Map Points
    /**
     * Loads map points from AsyncStorage.
     * If no saved data is found, it processes and sets initial data from a JSON file.
     */
    const loadMapPoints = async () => {
        try {
            const reloaded = await AsyncStorage.getItem(MAP_POINTS_RELOADED_KEY);
            
            if (reloaded !== 'true') {
                // Process map points from JSON data if there's no saved data
                const processedData = mapPointsData.map(point => ({
                    ...point,
                    landmark: point.Landmark === null ? -1 : point.Landmark,
                    latitude: point.Latitude,
                    longitude: point.Longitude,
                    pixelX: point["Pixel X"],
                    pixelY: point["Pixel Y"],
                    isVisited: false,
                }));
                setMapPoints(processedData);
                await saveMapPoints(processedData);
                await AsyncStorage.setItem(MAP_POINTS_RELOADED_KEY, 'true');
                setMapPointsReloaded(true);
            } else {
                const storedMapPoints = await AsyncStorage.getItem(MAP_POINTS_STORAGE_KEY);
                if (storedMapPoints !== null) {
                    setMapPoints(JSON.parse(storedMapPoints));
                }
            }
        } catch (error) {
            console.error('Failed to load map points', error);
        }
    };

    // MARK: - Save Map Points
    /**
     * Saves the given map points to AsyncStorage.
     * 
     * @param {Array} points - The list of map points to save.
     */
    const saveMapPoints = async (points) => {
        try {
            await AsyncStorage.setItem(MAP_POINTS_STORAGE_KEY, JSON.stringify(points));
        } catch (error) {
            console.error('Failed to save map points', error);
        }
    };

    // Load map points when the component mounts
    useEffect(() => {
        loadMapPoints();
    }, []);

    // Save map points whenever they are updated
    useEffect(() => {
        if (mapPoints.length > 0) {
            saveMapPoints(mapPoints);
        }
    }, [mapPoints]);

    // MARK: - Reset Visited Map Points
    /**
     * Resets the visited status of all map points.
     */
    const resetVisitedMapPoints = () => {
        setMapPoints(prevMapPoints => 
            prevMapPoints.map(point => ({
                ...point,
                isVisited: false
            }))
        );
    };

    // Provide map points state and functions to children components
    return (
        <MapPointsContext.Provider value={{ mapPoints, setMapPoints, resetVisitedMapPoints }}>
            {children}
        </MapPointsContext.Provider>
    );
};
