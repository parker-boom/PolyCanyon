// MARK: - LocationManager
/**
 * LocationManager
 * 
 * This module provides functions to handle location permissions and manage
 * geolocation-related operations within the app. It includes requesting location
 * permissions, checking if coordinates are within a defined safe zone, finding
 * the nearest map point, marking structures as visited, and getting the current location.
 * 
 * Features:
 * - Request fine and background location permissions
 * - Check if coordinates are within a safe zone
 * - Find the nearest map point from a given coordinate
 * - Mark a structure as visited
 * - Get the current location with high accuracy
 */

import { PermissionsAndroid, Platform, AppState } from 'react-native';
import Geolocation from '@react-native-community/geolocation';
import { useAdventureMode } from './AdventureModeContext';
import { useEffect, useRef } from 'react';

let foregroundWatchId = null;
let backgroundWatchId = null;

// Safe zone coordinates
const safeZoneCorners = {
  bottomLeft: { latitude: 35.31214, longitude: -120.65529 },
  topRight: { latitude: 35.31813, longitude: -120.65110 }
};

// MARK: - Request Location Permission
/**
 * Requests fine and background location permissions.
 */
const requestLocationPermission = async () => {
  try {
    const fineLocationGranted = await PermissionsAndroid.request(
      PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
      {
        title: "Location Access Required",
        message: "This app needs to access your location",
        buttonNeutral: "Ask Me Later",
        buttonNegative: "Cancel",
        buttonPositive: "OK"
      }
    );

    if (fineLocationGranted === PermissionsAndroid.RESULTS.GRANTED) {
      const backgroundLocationGranted = await PermissionsAndroid.request(
        PermissionsAndroid.PERMISSIONS.ACCESS_BACKGROUND_LOCATION,
        {
          title: "Background Location Access Required",
          message: "This app needs to access your location in the background",
          buttonNeutral: "Ask Me Later",
          buttonNegative: "Cancel",
          buttonPositive: "OK"
        }
      );
    }
  } catch (err) {
    // Error handling can be implemented here if needed
  }
};

// MARK: - Check Safe Zone
/**
 * Checks if the given coordinates are within the defined safe zone.
 * 
 * @param {Object} coordinate - The coordinates to check.
 * @param {number} coordinate.latitude - The latitude of the coordinate.
 * @param {number} coordinate.longitude - The longitude of the coordinate.
 * @returns {boolean} - Returns true if within safe zone, otherwise false.
 */
const isWithinSafeZone = (coordinate) => {
  const { latitude, longitude } = coordinate;
  return latitude >= safeZoneCorners.bottomLeft.latitude &&
         latitude <= safeZoneCorners.topRight.latitude &&
         longitude >= safeZoneCorners.bottomLeft.longitude &&
         longitude <= safeZoneCorners.topRight.longitude;
};

// MARK: - Find Nearest Map Point
/**
 * Finds the nearest map point to the given coordinates.
 * 
 * @param {Object} coordinate - The coordinates to compare.
 * @param {Array} mapPoints - The list of map points to search through.
 * @returns {Object|null} - The nearest map point, or null if no points are found.
 */
const findNearestMapPoint = (coordinate, mapPoints) => {
  let nearestPoint = null;
  let minDistance = Infinity;

  mapPoints.forEach(point => {
    const distance = Math.sqrt(
      Math.pow(coordinate.latitude - point.latitude, 2) +
      Math.pow(coordinate.longitude - point.longitude, 2)
    );
    if (distance < minDistance) {
      minDistance = distance;
      nearestPoint = point;
    }
  });

  return nearestPoint;
};

// MARK: - Mark Structure As Visited
/**
 * Marks a structure as visited by updating the map points.
 * 
 * @param {number} landmarkId - The ID of the landmark to mark as visited.
 * @param {Array} mapPoints - The list of map points to update.
 * @returns {Array} - The updated list of map points.
 */
const markStructureAsVisited = (landmarkId, mapPoints) => {
  const updatedMapPoints = mapPoints.map(point => {
    if (point.landmark === landmarkId) {
      return { ...point, isVisited: true };
    }
    return point;
  });

  return updatedMapPoints;
};

// MARK: - Get Current Location
/**
 * Gets the current location of the device and checks if it is within the safe zone.
 * If within the safe zone, it finds the nearest map point and marks it as visited if necessary.
 * 
 * @param {Function} callback - The callback function to execute with the result.
 * @param {Array} mapPoints - The list of map points to search through.
 */
const getCurrentLocation = (callback, mapPoints) => {
  Geolocation.getCurrentPosition(
    (position) => {
      const { latitude, longitude } = position.coords;

      if (isWithinSafeZone({ latitude, longitude })) {
        const nearestPoint = findNearestMapPoint({ latitude, longitude }, mapPoints);
        if (nearestPoint && nearestPoint.landmark !== -1 && !nearestPoint.isVisited) {
          const updatedMapPoints = markStructureAsVisited(nearestPoint.landmark, mapPoints);
          callback(null, position, updatedMapPoints);
        } else {
          callback(null, position, mapPoints);
        }
      } else {
        callback(null, position, mapPoints);
      }
    },
    (error) => {
      callback(error, null, mapPoints);
    },
    {
      enableHighAccuracy: true,
      timeout: 15000,
      maximumAge: 10000
    }
  );
};

let watchId = null;

// MARK: - Start Location Tracking
export const startLocationTracking = (callback) => {
  if (watchId !== null) {
    return;
  }

  watchId = Geolocation.watchPosition(
    (position) => callback(null, position),
    (error) => callback(error, null),
    { enableHighAccuracy: true, distanceFilter: 10, interval: 5000, fastestInterval: 2000 }
  );
};

const startForegroundTracking = (callback) => {
  if (foregroundWatchId !== null) {
    return;
  }

  foregroundWatchId = Geolocation.watchPosition(
    (position) => {
      callback(null, position);
      if (isWithinSafeZone(position.coords)) {
        startBackgroundTracking(callback);
      } else {
        stopBackgroundTracking();
      }
    },
    (error) => callback(error, null),
    { enableHighAccuracy: true, distanceFilter: 10, interval: 5000, fastestInterval: 2000 }
  );
};

const startBackgroundTracking = (callback) => {
  if (backgroundWatchId !== null) {
    return;
  }

  backgroundWatchId = Geolocation.watchPosition(
    (position) => {
      if (isWithinSafeZone(position.coords)) {
        callback(null, position);
      } else {
        stopBackgroundTracking();
      }
    },
    (error) => callback(error, null),
    { 
      enableHighAccuracy: true, 
      distanceFilter: 50, 
      interval: 60000, // Check every minute in background
      fastestInterval: 30000,
      forceRequestLocation: true,
      showLocationDialog: true,
    }
  );
};


// MARK: - Stop Location Tracking
export const stopLocationTracking = () => {
  if (watchId !== null) {
    Geolocation.clearWatch(watchId);
    watchId = null;
  }
};


const stopForegroundTracking = () => {
  if (foregroundWatchId !== null) {
    Geolocation.clearWatch(foregroundWatchId);
    foregroundWatchId = null;
  }
};

const stopBackgroundTracking = () => {
  if (backgroundWatchId !== null) {
    Geolocation.clearWatch(backgroundWatchId);
    backgroundWatchId = null;
  }
};




// MARK: - Use Location
export const useLocation = (callback) => {
  const { adventureMode } = useAdventureMode();
  const appState = useRef(AppState.currentState);

  useEffect(() => {
    const handleAppStateChange = (nextAppState) => {
      if (appState.current.match(/inactive|background/) && nextAppState === 'active') {
        // App has come to the foreground
        if (adventureMode) {
          startForegroundTracking(callback);
        }
      } else if (appState.current === 'active' && nextAppState.match(/inactive|background/)) {
        // App has gone to the background
        stopForegroundTracking();
        // Background tracking will continue if it was already started
      }
      appState.current = nextAppState;
    };

    const appStateSubscription = AppState.addEventListener('change', handleAppStateChange);

    const setupLocationTracking = async () => {
      if (adventureMode) {
        await requestLocationPermission(true);
        startForegroundTracking(callback);
      } else {
        stopForegroundTracking();
        stopBackgroundTracking();
      }
    };

    setupLocationTracking();

    return () => {
      stopForegroundTracking();
      stopBackgroundTracking();
      appStateSubscription.remove();
    };
  }, [adventureMode, callback]);
};

export { requestLocationPermission, getCurrentLocation, isWithinSafeZone };
