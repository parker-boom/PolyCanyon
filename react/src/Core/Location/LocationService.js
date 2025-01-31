import React, {
  createContext,
  useContext,
  useState,
  useEffect,
  useRef,
} from "react";
import { Platform } from "react-native";
import Geolocation from "@react-native-community/geolocation";
import { PermissionsAndroid } from "react-native";
import { useDataStore } from "../Data/DataStore";
import { useAdventureMode } from "../States/AdventureMode";
import mapPointsData from "./mapPoints.json";
import { MapPoint } from "../Data/Models";
import { useAppState } from "../States/AppState";

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
  const [mapPoints, setMapPoints] = useState([]);
  const mapPointsRef = useRef([]);
  const { markStructureAsVisited, getStructure } = useDataStore();
  const { adventureMode } = useAdventureMode();
  const { showVisitedPopup, setSelectedStructure } = useAppState();

  // New state for location tracking
  const [trackingState, setTrackingState] = useState(TrackingState.INACTIVE);
  const [adventureModeStatus, setAdventureModeStatus] = useState(
    AdventureModeStatus.NOT_VISITING
  );
  const [currentLocation, setCurrentLocation] = useState(null);
  const [lastUpdateTime, setLastUpdateTime] = useState(0);
  const [watchId, setWatchId] = useState(null);
  const [nearestPoint, setNearestPoint] = useState(null);

  useEffect(() => {
    console.log("LocationService initializing - Loading map points");
    loadMapPoints();
  }, []);

  useEffect(() => {
    if (!adventureMode) {
      stopLocationTracking();
      setTrackingState(TrackingState.INACTIVE);
    } else {
      startAppropriateTracking();
    }
  }, [adventureMode]);

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
    console.log("Checking canyon bounds for coordinate:", coordinate);
    console.log(
      "Latitude bounds:",
      CANYON_BOUNDS.bottomLeft.latitude,
      "to",
      CANYON_BOUNDS.topRight.latitude
    );
    console.log(
      "Longitude bounds:",
      CANYON_BOUNDS.topLeft.longitude,
      "to",
      CANYON_BOUNDS.bottomRight.longitude
    );

    const inBounds =
      coordinate.latitude >= CANYON_BOUNDS.bottomLeft.latitude &&
      coordinate.latitude <= CANYON_BOUNDS.topRight.latitude &&
      coordinate.longitude >= CANYON_BOUNDS.topLeft.longitude &&
      coordinate.longitude <= CANYON_BOUNDS.bottomRight.longitude;

    console.log("Is within canyon:", inBounds);
    return inBounds;
  };

  const getDistanceToCanyon = (coordinate) => {
    return calculateDistance(coordinate, CANYON_CENTER);
  };

  const handleLocationUpdate = (position) => {
    console.log("Location Update Received:", position);
    const now = Date.now();
    if (now - lastUpdateTime < UPDATE_INTERVALS.MINIMUM_TIME) {
      console.log("Update too soon, skipping");
      return;
    }

    setLastUpdateTime(now);
    setCurrentLocation(position);

    // Check if in canyon boundaries FIRST
    if (isWithinCanyon(position.coords)) {
      console.log("User is in canyon, finding nearest point");
      const nearest = findNearestMapPoint(position.coords);
      console.log("Setting nearest point:", nearest);
      setNearestPoint(nearest);
      setAdventureModeStatus(AdventureModeStatus.EXPLORING);
      checkForStructureVisits(position.coords);
      return;
    }

    // If not in canyon, then check distance to determine if approaching
    const distance = getDistanceToCanyon(position.coords);
    console.log("Distance to canyon:", distance);

    if (distance <= DISTANCE_THRESHOLDS.ALMOST_THERE) {
      console.log("User is almost at canyon");
      setAdventureModeStatus(AdventureModeStatus.ALMOST_THERE);
      startBackgroundTracking();
    } else {
      console.log("User is far from canyon");
      setAdventureModeStatus(AdventureModeStatus.NOT_VISITING);
      stopBackgroundTracking();
    }
  };

  const startAppropriateTracking = async () => {
    console.log(
      "Starting appropriate tracking, Adventure Mode:",
      adventureMode
    );
    if (!adventureMode) return;

    const hasPermission = await requestLocationPermission(false);
    console.log("Location permission granted:", hasPermission);
    if (!hasPermission) return;

    startInAppTracking();
  };

  const startInAppTracking = () => {
    console.log("Starting in-app tracking, current watchId:", watchId);
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

    console.log("New watch ID created:", newWatchId);
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

  const checkForStructureVisits = (coordinate) => {
    const nearestPoint = findNearestMapPoint(coordinate);
    if (!nearestPoint) return;

    const distance = calculateDistance(coordinate, nearestPoint.coordinate);

    // Get the structure to check if it's already visited
    const structure = getStructure(nearestPoint.structure);

    if (
      distance <= DISTANCE_THRESHOLDS.STRUCTURE_VISIT &&
      nearestPoint.structure !== -1 &&
      structure && // Make sure structure exists
      !structure.isVisited // Only mark if not already visited
    ) {
      console.log(
        "Structure in range and not visited:",
        nearestPoint.structure
      );
      markStructureAsVisited(nearestPoint.structure);
    }
  };

  const loadMapPoints = () => {
    try {
      const points = mapPointsData.map((data) =>
        MapPoint.fromMapPointData(data)
      );
      console.log(
        `Successfully loaded ${points.length} map points:`,
        points[0]
      );
      setMapPoints(points);
      mapPointsRef.current = points;
    } catch (error) {
      console.error("Error loading map points:", error);
    }
  };

  const findNearestMapPoint = (coordinate) => {
    const points = mapPointsRef.current;
    if (!points.length) {
      console.log("No map points available to find nearest point");
      return null;
    }

    console.log(
      `Finding nearest point to coordinate from ${points.length} points:`,
      coordinate
    );

    let nearestPoint = null;
    let minDistance = Infinity;

    points.forEach((point) => {
      const distance = calculateDistance(coordinate, point.coordinate);
      if (distance < minDistance) {
        minDistance = distance;
        nearestPoint = point;
      }
    });

    console.log("Nearest point found:", {
      point: nearestPoint,
      distance: minDistance,
      pixelPosition: nearestPoint?.pixelPosition,
    });

    return nearestPoint;
  };

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

  const getMapPointForStructure = (structureNumber) => {
    const mapPointIndex = structureToMapPointMapping[structureNumber];
    return mapPointIndex ? mapPoints[mapPointIndex - 1] : null;
  };

  const value = {
    mapPoints,
    currentLocation,
    adventureModeStatus,
    trackingState,
    nearestMapPoint: nearestPoint,
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
