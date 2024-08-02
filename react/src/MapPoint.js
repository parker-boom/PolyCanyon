// MARK: - MapPointsContext
/**
 * MapPointsContext
 * 
 * This file defines a context and provider for managing map points within the application.
 * It includes functions to load and save map points using AsyncStorage, reset visited map points,
 * and provides the map points data to other components through context.
 * 
 * Features:
 * - Load map points from AsyncStorage or initial JSON data
 * - Save map points to AsyncStorage
 * - Reset visited status of all map points
 * - Custom hook to access map points context
 */

import React, { createContext, useState, useContext, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import mapPointsData from './mapPoints.json';

// MARK: - Context Creation
const MapPointsContext = createContext();

// Custom hook to access MapPoints context
export const useMapPoints = () => useContext(MapPointsContext);

const MAP_POINTS_STORAGE_KEY = 'MAP_POINTS_STORAGE_KEY';

// MARK: - Provider Component
export const MapPointsProvider = ({ children }) => {
    // State variable to manage map points
    const [mapPoints, setMapPoints] = useState([]);

    // MARK: - Load Map Points
    /**
     * Loads map points from AsyncStorage.
     * If no saved data is found, it processes and sets initial data from a JSON file.
     */
    const loadMapPoints = async () => {
        try {
            const storedMapPoints = await AsyncStorage.getItem(MAP_POINTS_STORAGE_KEY);
            if (storedMapPoints !== null) {
                setMapPoints(JSON.parse(storedMapPoints));
            } else {
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
