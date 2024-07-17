import { PermissionsAndroid, Platform } from 'react-native';
import Geolocation from '@react-native-community/geolocation';

const safeZoneCorners = {
  bottomLeft: { latitude: 35.31214, longitude: -120.65529 },
  topRight: { latitude: 35.31813, longitude: -120.65110 }
};

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
      console.log("Fine location permission granted");

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

      if (backgroundLocationGranted === PermissionsAndroid.RESULTS.GRANTED) {
        console.log("Background location permission granted");
      } else {
        console.log("Background location permission denied");
      }
    } else {
      console.log("Fine location permission denied");
    }
  } catch (err) {
    console.warn(err);
  }
};

const isWithinSafeZone = (coordinate) => {
  const { latitude, longitude } = coordinate;
  return latitude >= safeZoneCorners.bottomLeft.latitude &&
         latitude <= safeZoneCorners.topRight.latitude &&
         longitude >= safeZoneCorners.bottomLeft.longitude &&
         longitude <= safeZoneCorners.topRight.longitude;
};

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

const markStructureAsVisited = (landmarkId, mapPoints) => {
  const updatedMapPoints = mapPoints.map(point => {
    if (point.landmark === landmarkId) {
      return { ...point, isVisited: true };
    }
    return point;
  });

  // Here you would typically update your state or storage with the updated mapPoints
  console.log(`Structure with landmark ID ${landmarkId} marked as visited`);
  return updatedMapPoints;
};

const getCurrentLocation = (callback, mapPoints) => {
  Geolocation.getCurrentPosition(
    (position) => {
      const { latitude, longitude } = position.coords;
      console.log('Current position:', position);

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
      console.log('Error getting current position:', error);
      callback(error, null, mapPoints);
    },
    {
      enableHighAccuracy: true,
      timeout: 15000,
      maximumAge: 10000
    }
  );
};

export { requestLocationPermission, getCurrentLocation, isWithinSafeZone };