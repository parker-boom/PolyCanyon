import { PermissionsAndroid } from 'react-native';
import Geolocation from '@react-native-community/geolocation';

const SAN_LUIS_OBISPO_COORDS = { latitude: 35.2828, longitude: -120.6596 };
const MAX_DISTANCE_MILES = 50;

export const requestLocationPermission = async () => {
  try {
    const granted = await PermissionsAndroid.request(
      PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
      {
        title: "Location Access Required",
        message: "This app needs to access your location",
        buttonNeutral: "Ask Me Later",
        buttonNegative: "Cancel",
        buttonPositive: "OK"
      }
    );
    return granted === PermissionsAndroid.RESULTS.GRANTED;
  } catch (err) {
    console.warn(err);
    return false;
  }
};

export const getCurrentLocation = () => {
  return new Promise((resolve, reject) => {
    Geolocation.getCurrentPosition(
      (position) => resolve(position),
      (error) => reject(error),
      { enableHighAccuracy: true, timeout: 15000, maximumAge: 10000 }
    );
  });
};

const calculateDistance = (lat1, lon1, lat2, lon2) => {
  const R = 3958.8; // Earth's radius in miles
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
    Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return R * c;
};

export const isNearSanLuisObispo = (position) => {
  const distance = calculateDistance(
    position.coords.latitude,
    position.coords.longitude,
    SAN_LUIS_OBISPO_COORDS.latitude,
    SAN_LUIS_OBISPO_COORDS.longitude
  );
  return distance <= MAX_DISTANCE_MILES;
};