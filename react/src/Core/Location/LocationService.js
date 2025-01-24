import React, { createContext, useContext, useState, useEffect } from 'react';
import { MapPoint } from '../Data/Models';
import { useDataStore } from '../Data/DataStore';
import mapPointsData from './mapPoints.json';

// Create context
const LocationServiceContext = createContext(null);

// Structure to MapPoint mapping for virtual tour
const structureToMapPointMapping = {
    1: 1, 2: 3, 3: 52, 4: 53, 5: 10,
    6: 11, 7: 196, 8: 13, 9: 76, 10: 16,
    11: 58, 12: 19, 13: 59, 14: 21, 15: 203,
    16: 24, 17: 88, 18: 91, 19: 35, 20: 113,
    21: 37, 22: 32, 23: 20, 24: 57, 25: 56,
    26: 44, 27: 55, 28: 60, 29: 68, 30: 199,
    31: 197
};

export const LocationServiceProvider = ({ children }) => {
    const [mapPoints, setMapPoints] = useState([]);
    const { markStructureAsVisited } = useDataStore();

    // Load map points on mount
    useEffect(() => {
        loadMapPoints();
    }, []);

    const loadMapPoints = () => {
        const points = mapPointsData.map(data => MapPoint.fromMapPointData(data));
        setMapPoints(points);
    };

    // Calculate distance between two coordinates
    const getDistanceFromCoordinates = (coord1, coord2) => {
        const R = 6371e3; // Earth's radius in meters
        const φ1 = (coord1.latitude * Math.PI) / 180;
        const φ2 = (coord2.latitude * Math.PI) / 180;
        const Δφ = ((coord2.latitude - coord1.latitude) * Math.PI) / 180;
        const Δλ = ((coord2.longitude - coord1.longitude) * Math.PI) / 180;

        const a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
                 Math.cos(φ1) * Math.cos(φ2) *
                 Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return R * c; // Distance in meters
    };

    // Find nearest map point to a given coordinate
    const findNearestMapPoint = (coordinate) => {
        if (!mapPoints.length) return null;

        let nearestPoint = null;
        let minDistance = Infinity;

        mapPoints.forEach(point => {
            const distance = getDistanceFromCoordinates(coordinate, point.coordinate);
            if (distance < minDistance) {
                minDistance = distance;
                nearestPoint = point;
            }
        });

        return nearestPoint;
    };

    // Find 3 closest structures (no duplicates)
    const findThreeClosestStructures = (coordinate) => {
        const structurePoints = mapPoints.filter(point => point.structure !== -1);
        
        const pointsWithDistance = structurePoints.map(point => ({
            point,
            distance: getDistanceFromCoordinates(coordinate, point.coordinate)
        }));

        // Sort by distance and filter duplicates by structure number
        const sortedUniqueStructures = [...new Map(
            pointsWithDistance
                .sort((a, b) => a.distance - b.distance)
                .map(item => [item.point.structure, item.point])
        ).values()];

        return sortedUniqueStructures.slice(0, 3);
    };

    // Get map point for virtual tour
    const getMapPointForStructure = (structureNumber) => {
        const mapPointIndex = structureToMapPointMapping[structureNumber];
        return mapPointIndex ? mapPoints[mapPointIndex - 1] : null;
    };

    // Handle structure visits from location
    const handleStructureVisit = (mapPoint) => {
        if (mapPoint && mapPoint.structure !== -1) {
            markStructureAsVisited(mapPoint.structure);
        }
    };

    const value = {
        mapPoints,
        findNearestMapPoint,
        findThreeClosestStructures,
        getMapPointForStructure,
        handleStructureVisit,
        getDistanceFromCoordinates
    };

    return (
        <LocationServiceContext.Provider value={value}>
            {children}
        </LocationServiceContext.Provider>
    );
};

// Custom hook for using the location service
export const useLocationService = () => {
    const context = useContext(LocationServiceContext);
    if (!context) {
        throw new Error('useLocationService must be used within a LocationServiceProvider');
    }
    return context;
};
