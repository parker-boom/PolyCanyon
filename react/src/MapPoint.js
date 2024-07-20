import React, { createContext, useState, useContext, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import mapPointsData from './mapPoints.json';

const MapPointsContext = createContext();

export const useMapPoints = () => useContext(MapPointsContext);

const MAP_POINTS_STORAGE_KEY = 'MAP_POINTS_STORAGE_KEY';

export const MapPointsProvider = ({ children }) => {
    const [mapPoints, setMapPoints] = useState([]);

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
                }));
                setMapPoints(processedData);
            }
        } catch (error) {
            console.error('Failed to load map points', error);
        }
    };

    const saveMapPoints = async (points) => {
        try {
            await AsyncStorage.setItem(MAP_POINTS_STORAGE_KEY, JSON.stringify(points));
        } catch (error) {
            console.error('Failed to save map points', error);
        }
    };

    useEffect(() => {
        loadMapPoints();
    }, []);

    useEffect(() => {
        if (mapPoints.length > 0) {
            saveMapPoints(mapPoints);
        }
    }, [mapPoints]);

    return (
        <MapPointsContext.Provider value={{ mapPoints, setMapPoints }}>
            {children}
        </MapPointsContext.Provider>
    );
};
