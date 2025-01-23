// MARK: - LocationManager
/**
 * LocationManager
 *
 * This module provides comprehensive location management for a React Native app.
 * It handles location permissions, real-time tracking, safe zone checks, and
 * integration with Firebase for location logging.
 *
 * Key features:
 * - Request and manage fine and background location permissions
 * - Track user location in foreground and background
 * - Check if coordinates are within a defined safe zone
 * - Find the nearest map point from current location
 * - Mark structures as visited based on proximity
 * - Log location data to Firebase when in adventure mode
 * - Adapt tracking behavior based on app state (active/background)
 */

import { useEffect, useState, useRef } from "react";
import { PermissionsAndroid, Platform, AppState } from "react-native";
import Geolocation from "@react-native-community/geolocation";
import { useAdventureMode } from "../Core/States/AdventureModeContext";
import FirebaseService from "../Core/States/FirebaseService";
import AsyncStorage from "@react-native-async-storage/async-storage";

// MARK: - Constants

// Safe zone coordinates
const safeZoneCorners = {
  bottomLeft: { latitude: 35.31214, longitude: -120.65529 },
  topRight: { latitude: 35.31813, longitude: -120.6511 },
};

// Tracking IDs
let foregroundWatchId = null;
let backgroundWatchId = null;

// MARK: - Permission Handling

/**
 * Requests fine and background location permissions.
 * Prompts the user with permission dialogs for both types.
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
        buttonPositive: "OK",
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
          buttonPositive: "OK",
        }
      );
    }
  } catch (err) {
    // Error handling can be implemented here if needed
  }
};

// MARK: - Location Utilities

/**
 * Checks if given coordinates are within the defined safe zone.
 *
 * @param {Object} coordinate - The coordinates to check.
 * @param {number} coordinate.latitude - The latitude of the coordinate.
 * @param {number} coordinate.longitude - The longitude of the coordinate.
 * @returns {boolean} - Returns true if within safe zone, otherwise false.
 */
const isWithinSafeZone = (coordinate) => {
  const { latitude, longitude } = coordinate;
  return (
    latitude >= safeZoneCorners.bottomLeft.latitude &&
    latitude <= safeZoneCorners.topRight.latitude &&
    longitude >= safeZoneCorners.bottomLeft.longitude &&
    longitude <= safeZoneCorners.topRight.longitude
  );
};

/**
 * Marks a structure as visited in the map points array.
 *
 * @param {number} landmarkId - The ID of the landmark to mark as visited.
 * @param {Array} mapPoints - The list of map points to update.
 * @returns {Array} - The updated list of map points.
 */
const markStructureAsVisited = (landmarkId, mapPoints) => {
  const updatedMapPoints = mapPoints.map((point) => {
    if (point.landmark === landmarkId) {
      return { ...point, isVisited: true };
    }
    return point;
  });

  return updatedMapPoints;
};

/**
 * Gets current location and processes it (safe zone check, nearest point, etc.)
 *
 * @param {Function} callback - The callback function to execute with the result.
 * @param {Array} mapPoints - The list of map points to search through.
 */
const getCurrentLocation = (callback, mapPoints) => {
  Geolocation.getCurrentPosition(
    (position) => {
      const { latitude, longitude } = position.coords;

      if (isWithinSafeZone({ latitude, longitude })) {
        const nearestPoint = findNearestMapPoint(
          { latitude, longitude },
          mapPoints
        );
        if (
          nearestPoint &&
          nearestPoint.landmark !== -1 &&
          !nearestPoint.isVisited
        ) {
          const updatedMapPoints = markStructureAsVisited(
            nearestPoint.landmark,
            mapPoints
          );
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
      maximumAge: 10000,
    }
  );
};

// MARK: - Location Tracking

/**
 * Starts tracking location with high accuracy.
 *
 * @param {Function} callback - The callback function to execute with the result.
 */
export const startLocationTracking = (callback) => {
  if (watchId !== null) {
    return;
  }

  watchId = Geolocation.watchPosition(
    (position) => callback(null, position),
    (error) => callback(error, null),
    {
      enableHighAccuracy: true,
      distanceFilter: 10,
      interval: 5000,
      fastestInterval: 2000,
    }
  );
};

/**
 * Starts foreground location tracking.
 * Initiates background tracking when entering safe zone.
 *
 * @param {Function} callback - The callback function to execute with the result.
 */
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
    {
      enableHighAccuracy: true,
      distanceFilter: 10,
      interval: 5000,
      fastestInterval: 2000,
    }
  );
};

/**
 * Starts background location tracking within safe zone.
 *
 * @param {Function} callback - The callback function to execute with the result.
 */
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

/**
 * Stops all location tracking.
 */
export const stopLocationTracking = () => {
  if (watchId !== null) {
    Geolocation.clearWatch(watchId);
    watchId = null;
  }
};

// Helper functions to stop specific tracking types
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

// MARK: - Map Point Utilities

/**
 * Finds the nearest map point to given coordinates.
 *
 * @param {Object} coordinate - The coordinates to find the nearest point for.
 * @param {number} coordinate.latitude - The latitude of the coordinate.
 * @param {number} coordinate.longitude - The longitude of the coordinate.
 * @param {Array} mapPoints - The list of map points to search through.
 * @returns {Object|null} - The nearest map point or null if not found.
 */
export const findNearestMapPoint = (coordinate, mapPoints) => {
  if (!mapPoints || !Array.isArray(mapPoints) || mapPoints.length === 0) {
    console.log("MapPoints is undefined or empty");
    return null;
  }

  let nearestPoint = null;
  let minDistance = Infinity;

  mapPoints.forEach((point) => {
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

// MARK: - Location Hook

/**
 * Custom hook for managing location tracking and updates.
 * Handles adventure mode, app state changes, and Firebase logging.
 *
 * @param {Function} callback - The callback function to execute with the result.
 * @param {Array} mapPoints - The list of map points to search through.
 * @returns {Object} - An object containing utility functions.
 */
export const useLocation = (callback, mapPoints) => {
  const { adventureMode } = useAdventureMode();
  const appState = useRef(AppState.currentState);
  const [userId, setUserId] = useState(null);
  const [lastLoggedMapPoint, setLastLoggedMapPoint] = useState(null);

  useEffect(() => {
    const initializeUser = async () => {
      const uid = await FirebaseService.getUserId();
      setUserId(uid);
    };
    initializeUser();

    const handleAppStateChange = (nextAppState) => {
      if (
        appState.current.match(/inactive|background/) &&
        nextAppState === "active"
      ) {
        if (adventureMode) {
          startForegroundTracking(handleLocationUpdate);
        }
      } else if (
        appState.current === "active" &&
        nextAppState.match(/inactive|background/)
      ) {
        stopForegroundTracking();
      }
      appState.current = nextAppState;
    };

    const appStateSubscription = AppState.addEventListener(
      "change",
      handleAppStateChange
    );

    const setupLocationTracking = async () => {
      if (adventureMode) {
        await requestLocationPermission();
        startForegroundTracking(handleLocationUpdate);
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
  }, [adventureMode, callback, mapPoints]);

  /**
   * Handles location updates and triggers Firebase logging if needed.
   *
   * @param {Object|null} error - The error object if an error occurred.
   * @param {Object|null} position - The position object containing location data.
   */
  const handleLocationUpdate = (error, position) => {
    if (error) {
      console.error("Location error:", error);
      callback(error, null);
      return;
    }

    callback(null, position);
    logLocationToFirebaseIfNeeded(position);
  };

  /**
   * Logs location to Firebase if conditions are met (adventure mode, in safe zone, etc.)
   *
   * @param {Object} position - The position object containing location data.
   */
  const logLocationToFirebaseIfNeeded = async (position) => {
    if (!adventureMode || !userId) {
      console.log("Not logging location: AdventureMode off or no UserID");
      return;
    }

    const { latitude, longitude } = position.coords;
    if (!isWithinSafeZone({ latitude, longitude })) {
      console.log("Not in safe zone, not logging location");
      return;
    }

    const newMapPoint = findNearestMapPoint({ latitude, longitude }, mapPoints);
    if (
      !newMapPoint ||
      (lastLoggedMapPoint &&
        newMapPoint.latitude === lastLoggedMapPoint.latitude &&
        newMapPoint.longitude === lastLoggedMapPoint.longitude)
    ) {
      console.log("Map point unchanged, not logging");
      return;
    }

    await FirebaseService.logLocation(newMapPoint, userId);
    setLastLoggedMapPoint(newMapPoint);
  };

  return {
    requestLocationPermission,
    getCurrentLocation,
    isWithinSafeZone,
  };
};

// Export utility functions
export { requestLocationPermission, getCurrentLocation, isWithinSafeZone };
