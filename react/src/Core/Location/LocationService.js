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

export const LocationServiceProvider = ({ children }) => {
  const { markStructureAsVisited, getStructure } = useDataStore();
  const [mapPoints, setMapPoints] = useState([]);
  const mapPointsRef = useRef([]);
  const { adventureMode } = useAdventureMode();
  const { showVisitedPopup, setSelectedStructure, isOnboardingCompleted } =
    useAppState();

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

  // Maps structure numbers to their corresponding map points, adjusting for 0-based array indexing
  const getMapPointForStructure = (structureNumber) => {
    const structureToMapPointMapping = {
      1: 0, // MapPoint 1
      2: 2, // MapPoint 3
      3: 51, // MapPoint 52
      4: 52, // MapPoint 53
      5: 9, // MapPoint 10
      6: 10, // MapPoint 11
      7: 195, // MapPoint 196
      8: 12, // MapPoint 13
      9: 75, // MapPoint 76
      10: 15, // MapPoint 16
      11: 57, // MapPoint 58
      12: 18, // MapPoint 19
      13: 58, // MapPoint 59
      14: 20, // MapPoint 21
      15: 202, // MapPoint 203
      16: 23, // MapPoint 24
      17: 87, // MapPoint 88
      18: 90, // MapPoint 91
      19: 34, // MapPoint 35
      20: 112, // MapPoint 113
      21: 36, // MapPoint 37
      22: 31, // MapPoint 32
      23: 19, // MapPoint 20
      24: 56, // MapPoint 57
      25: 55, // MapPoint 56
      26: 43, // MapPoint 44
      27: 54, // MapPoint 55
      28: 59, // MapPoint 60
      29: 67, // MapPoint 68
      30: 198, // MapPoint 199
      31: 196, // MapPoint 197
    };

    const mapPointIndex = structureToMapPointMapping[structureNumber];
    if (mapPointIndex === undefined || !mapPoints[mapPointIndex]) {
      return null;
    }

    const mapPoint = mapPoints[mapPointIndex];
    return {
      x: mapPoint.pixelPosition.x,
      y: mapPoint.pixelPosition.y,
    };
  };

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
    // Early return if no coordinate provided
    if (
      !coordinate ||
      typeof coordinate.latitude === "undefined" ||
      typeof coordinate.longitude === "undefined"
    ) {
      return false;
    }

    const inBounds =
      coordinate.latitude >= CANYON_BOUNDS.bottomLeft.latitude &&
      coordinate.latitude <= CANYON_BOUNDS.topRight.latitude &&
      coordinate.longitude >= CANYON_BOUNDS.topLeft.longitude &&
      coordinate.longitude <= CANYON_BOUNDS.bottomRight.longitude;

    return inBounds;
  };

  const getDistanceToCanyon = (coordinate) => {
    return calculateDistance(coordinate, CANYON_CENTER);
  };

  const handleLocationUpdate = (position) => {
    const now = Date.now();
    if (now - lastUpdateTime < UPDATE_INTERVALS.MINIMUM_TIME) {
      return;
    }

    setLastUpdateTime(now);
    setCurrentLocation(position);

    // Skip structure checks during onboarding
    if (!isOnboardingCompleted) {
      console.log("Skipping location updates during onboarding");
      return;
    }

    // Continue with normal location handling...
    if (isWithinCanyon(position.coords)) {
      const nearest = findNearestMapPoint(position.coords);
      setNearestPoint(nearest);
      setAdventureModeStatus(AdventureModeStatus.EXPLORING);
      checkForStructureVisits(nearest);
      return;
    }

    // If not in canyon, then check distance to determine if approaching
    const distance = getDistanceToCanyon(position.coords);

    if (distance <= DISTANCE_THRESHOLDS.ALMOST_THERE) {
      setAdventureModeStatus(AdventureModeStatus.ALMOST_THERE);
      startBackgroundTracking();
    } else {
      setAdventureModeStatus(AdventureModeStatus.NOT_VISITING);
      stopBackgroundTracking();
    }
  };

  const startAppropriateTracking = async () => {
    if (!adventureMode) return;
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

  const checkForStructureVisits = (nearestPoint) => {
    // Early return if in onboarding
    if (!isOnboardingCompleted) {
      console.log("Skipping structure visit check during onboarding");
      return;
    }

    // Early return if no map point was found
    if (!nearestPoint) return;

    // Extract the structure number from the map point
    const structureNumber = nearestPoint.structure;

    // Ensure this is a valid structure number (between 1 and 31)
    if (structureNumber < 1 || structureNumber > 31) return;

    markStructureAsVisited(structureNumber);
  };

  const loadMapPoints = () => {
    try {
      const points = mapPointsData.map((data) =>
        MapPoint.fromMapPointData(data)
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
      return null;
    }

    let nearestPoint = null;
    let minDistance = Infinity;

    points.forEach((point) => {
      const distance = calculateDistance(coordinate, point.coordinate);
      if (distance < minDistance) {
        minDistance = distance;
        nearestPoint = point;
      }
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

  const value = {
    mapPoints,
    currentLocation,
    adventureModeStatus,
    trackingState,
    getMapPointForStructure,
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
