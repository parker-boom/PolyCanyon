import React, { createContext, useContext, useState, useEffect } from "react";
import { Platform } from "react-native";
import Geolocation from "@react-native-community/geolocation";
import { PermissionsAndroid } from "react-native";
import { useDataStore } from "../Data/DataStore";
import { useAdventureMode } from "../States/AdventureMode";
import mapPointsData from "./mapPoints.json";
import { MapPoint } from "../Data/Models";

// MARK: - Enums

const AdventureModeStatus = {
  NOT_VISITING: "notVisiting",
  ALMOST_THERE: "almostThere",
  EXPLORING: "exploring",
};

const LocationMode = {
  INITIAL: "initial",
  VIRTUAL_TOUR: "virtualTour",
  ADVENTURE: "adventure",
};

const TrackingState = {
  INACTIVE: "inactive",
  IN_APP_ONLY: "inAppOnly",
  BACKGROUND: "background",
};

// MARK: - Constants

const CANYON_CENTER = {
  latitude: 35.31583,
  longitude: -120.65347,
};

const CANYON_BOUNDS = {
  topLeft: { latitude: 35.31658611111111, longitude: -120.6560599752971 },
  topRight: { latitude: 35.31782413494509, longitude: -120.6541363709451 },
  bottomLeft: { latitude: 35.31307, longitude: -120.65235 },
  bottomRight: { latitude: 35.31431, longitude: -120.65065 },
};

const DISTANCE_THRESHOLDS = {
  ONBOARDING_RECOMMENDATION: 48280, // 30 miles in meters
  ALMOST_THERE: 370, // meters
  STRUCTURE_VISIT: 20, // meters
};

const UPDATE_INTERVALS = {
  MINIMUM_TIME: 1000, // 1 second between updates
  BACKGROUND: 60000, // 1 minute between background updates
  DISTANCE_FILTER: 10, // meters
};

// Create context
const LocationServiceContext = createContext(null);

// Structure to MapPoint mapping for virtual tour
const structureToMapPointMapping = {
  1: 1,
  2: 3,
  3: 52,
  4: 53,
  5: 10,
  6: 11,
  7: 196,
  8: 13,
  9: 76,
  10: 16,
  11: 58,
  12: 19,
  13: 59,
  14: 21,
  15: 203,
  16: 24,
  17: 88,
  18: 91,
  19: 35,
  20: 113,
  21: 37,
  22: 32,
  23: 20,
  24: 57,
  25: 56,
  26: 44,
  27: 55,
  28: 60,
  29: 68,
  30: 199,
  31: 197,
};

export const LocationServiceProvider = ({ children }) => {
  // Existing state from current implementation
  const [mapPoints, setMapPoints] = useState([]);
  const { markStructureAsVisited } = useDataStore();
  const { adventureMode } = useAdventureMode();

  // New state for location tracking
  const [trackingState, setTrackingState] = useState(TrackingState.INACTIVE);
  const [adventureModeStatus, setAdventureModeStatus] = useState(
    AdventureModeStatus.NOT_VISITING
  );
  const [currentLocation, setCurrentLocation] = useState(null);
  const [lastUpdateTime, setLastUpdateTime] = useState(0);
  const [watchId, setWatchId] = useState(null);

  // Load map points on mount
  useEffect(() => {
    loadMapPoints();
  }, []);

  // Handle adventure mode changes
  useEffect(() => {
    if (!adventureMode) {
      stopLocationTracking();
      setTrackingState(TrackingState.INACTIVE);
    } else {
      startAppropriateTracking();
    }
  }, [adventureMode]);

  // MARK: - Permission Handling

  const requestLocationPermission = async (requestBackground = false) => {
    try {
      if (Platform.OS === "ios") {
        // iOS permissions handled by Geolocation configuration
        return true;
      }

      const fineLocation = await PermissionsAndroid.request(
        PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
        {
          title: "Location Access Required",
          message: "This app needs to access your location",
          buttonNeutral: "Ask Me Later",
          buttonNegative: "Cancel",
          buttonPositive: "OK",
        }
      );

      if (
        fineLocation === PermissionsAndroid.RESULTS.GRANTED &&
        requestBackground
      ) {
        const backgroundLocation = await PermissionsAndroid.request(
          PermissionsAndroid.PERMISSIONS.ACCESS_BACKGROUND_LOCATION,
          {
            title: "Background Location Access Required",
            message: "This app needs to access your location in the background",
            buttonNeutral: "Ask Me Later",
            buttonNegative: "Cancel",
            buttonPositive: "OK",
          }
        );
        return backgroundLocation === PermissionsAndroid.RESULTS.GRANTED;
      }

      return fineLocation === PermissionsAndroid.RESULTS.GRANTED;
    } catch (err) {
      console.error("Error requesting location permission:", err);
      return false;
    }
  };

  // MARK: - Location Utilities

  const calculateDistance = (coord1, coord2) => {
    const R = 6371e3; // Earth's radius in meters
    const φ1 = (coord1.latitude * Math.PI) / 180;
    const φ2 = (coord2.latitude * Math.PI) / 180;
    const Δφ = ((coord2.latitude - coord1.latitude) * Math.PI) / 180;
    const Δλ = ((coord2.longitude - coord1.longitude) * Math.PI) / 180;

    const a =
      Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
      Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c; // Distance in meters
  };

  const isWithinCanyon = (coordinate) => {
    return (
      coordinate.latitude >= CANYON_BOUNDS.bottomLeft.latitude &&
      coordinate.latitude <= CANYON_BOUNDS.topRight.latitude &&
      coordinate.longitude >= CANYON_BOUNDS.bottomLeft.longitude &&
      coordinate.longitude <= CANYON_BOUNDS.topRight.longitude
    );
  };

  const getDistanceToCanyon = (coordinate) => {
    return calculateDistance(coordinate, CANYON_CENTER);
  };

  // MARK: - Location Tracking

  const handleLocationUpdate = (position) => {
    const now = Date.now();
    if (now - lastUpdateTime < UPDATE_INTERVALS.MINIMUM_TIME) {
      return;
    }

    setLastUpdateTime(now);
    setCurrentLocation(position);

    const distance = getDistanceToCanyon(position.coords);

    if (isWithinCanyon(position.coords)) {
      setAdventureModeStatus(AdventureModeStatus.EXPLORING);
      checkForStructureVisits(position.coords);
    } else if (distance <= DISTANCE_THRESHOLDS.ALMOST_THERE) {
      setAdventureModeStatus(AdventureModeStatus.ALMOST_THERE);
      startBackgroundTracking();
    } else {
      setAdventureModeStatus(AdventureModeStatus.NOT_VISITING);
      stopBackgroundTracking();
    }
  };

  const startAppropriateTracking = async () => {
    if (!adventureMode) return;

    const hasPermission = await requestLocationPermission(false);
    if (!hasPermission) return;

    startInAppTracking();
  };

  const startInAppTracking = () => {
    if (watchId) return;

    const newWatchId = Geolocation.watchPosition(
      handleLocationUpdate,
      (error) => console.error("Location error:", error),
      {
        enableHighAccuracy: true,
        distanceFilter: UPDATE_INTERVALS.DISTANCE_FILTER,
        interval: UPDATE_INTERVALS.MINIMUM_TIME,
      }
    );

    setWatchId(newWatchId);
    setTrackingState(TrackingState.IN_APP_ONLY);
  };

  const startBackgroundTracking = async () => {
    if (trackingState === TrackingState.BACKGROUND) return;

    const hasPermission = await requestLocationPermission(true);
    if (!hasPermission) return;

    stopLocationTracking(); // Clear existing watchers

    const newWatchId = Geolocation.watchPosition(
      handleLocationUpdate,
      (error) => console.error("Location error:", error),
      {
        enableHighAccuracy: true,
        distanceFilter: UPDATE_INTERVALS.DISTANCE_FILTER,
        interval: UPDATE_INTERVALS.BACKGROUND,
        forceRequestLocation: true,
      }
    );

    setWatchId(newWatchId);
    setTrackingState(TrackingState.BACKGROUND);
  };

  const stopLocationTracking = () => {
    if (watchId !== null) {
      Geolocation.clearWatch(watchId);
      setWatchId(null);
    }
  };

  const stopBackgroundTracking = () => {
    if (trackingState === TrackingState.BACKGROUND) {
      stopLocationTracking();
      startInAppTracking(); // Falls back to in-app only when outside canyon
    }
  };

  // MARK: - Structure Visit Detection

  const checkForStructureVisits = (coordinate) => {
    const nearestPoint = findNearestMapPoint(coordinate);
    if (!nearestPoint) return;

    const distance = calculateDistance(coordinate, {
      latitude: nearestPoint.latitude,
      longitude: nearestPoint.longitude,
    });

    if (
      distance <= DISTANCE_THRESHOLDS.STRUCTURE_VISIT &&
      nearestPoint.structure !== -1
    ) {
      markStructureAsVisited(nearestPoint.structure);
    }
  };

  // Existing map point functionality...
  const loadMapPoints = () => {
    const points = mapPointsData.map((data) => MapPoint.fromMapPointData(data));
    setMapPoints(points);
  };

  const findNearestMapPoint = (coordinate) => {
    if (!mapPoints.length) return null;

    let nearestPoint = null;
    let minDistance = Infinity;

    mapPoints.forEach((point) => {
      const distance = calculateDistance(coordinate, point.coordinate);
      if (distance < minDistance) {
        minDistance = distance;
        nearestPoint = point;
      }
    });

    return nearestPoint;
  };

  // Find 3 closest structures (no duplicates)
  const findThreeClosestStructures = (coordinate) => {
    const structurePoints = mapPoints.filter((point) => point.structure !== -1);

    const pointsWithDistance = structurePoints.map((point) => ({
      point,
      distance: getDistanceFromCoordinates(coordinate, point.coordinate),
    }));

    // Sort by distance and filter duplicates by structure number
    const sortedUniqueStructures = [
      ...new Map(
        pointsWithDistance
          .sort((a, b) => a.distance - b.distance)
          .map((item) => [item.point.structure, item.point])
      ).values(),
    ];

    return sortedUniqueStructures.slice(0, 3);
  };

  // Get map point for virtual tour
  const getMapPointForStructure = (structureNumber) => {
    const mapPointIndex = structureToMapPointMapping[structureNumber];
    return mapPointIndex ? mapPoints[mapPointIndex - 1] : null;
  };

  const value = {
    mapPoints,
    currentLocation,
    adventureModeStatus,
    trackingState,
    findNearestMapPoint,
    requestLocationPermission,
    startAppropriateTracking,
    stopLocationTracking,
    isWithinCanyon,
    getDistanceToCanyon,
  };

  return (
    <LocationServiceContext.Provider value={value}>
      {children}
    </LocationServiceContext.Provider>
  );
};

export const useLocationService = () => {
  const context = useContext(LocationServiceContext);
  if (!context) {
    throw new Error(
      "useLocationService must be used within a LocationServiceProvider"
    );
  }
  return context;
};
