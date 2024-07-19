import React, { createContext, useState, useContext, useEffect } from 'react';
import mapPointsData from './mapPoints.json';

const MapPointsContext = createContext();

export const useMapPoints = () => useContext(MapPointsContext);

export const MapPointsProvider = ({ children }) => {
    const [mapPoints, setMapPoints] = useState([]);

    useEffect(() => {
        // Process map points
        const processedData = mapPointsData.map(point => ({
            ...point,
            landmark: point.Landmark === null ? -1 : point.Landmark,
            latitude: point.Latitude,
            longitude: point.Longitude,
            pixelX: point["Pixel X"],
            pixelY: point["Pixel Y"],
        }));
        setMapPoints(processedData);
    }, []);

    return (
        <MapPointsContext.Provider value={{ mapPoints, setMapPoints }}>
            {children}
        </MapPointsContext.Provider>
    );
};