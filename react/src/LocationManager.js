import { PermissionsAndroid, Platform } from 'react-native';
import Geolocation from '@react-native-community/geolocation';

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

const getCurrentLocation = (callback) => {
    Geolocation.getCurrentPosition(
        (position) => {
            console.log('Current position:', position);
            callback(null, position);
        },
        (error) => {
            console.log('Error getting current position:', error);
            callback(error, null);
        },
        {
            enableHighAccuracy: true,
            timeout: 15000,
            maximumAge: 10000
        }
    );
};

export { requestLocationPermission, getCurrentLocation };