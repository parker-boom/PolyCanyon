import React, { useState, useEffect, useRef } from 'react';
import { View, Image, StyleSheet, TouchableOpacity, Text, Dimensions } from 'react-native';
import Icon from 'react-native-vector-icons/Ionicons';
import { requestLocationPermission, getCurrentLocation, isWithinSafeZone } from './LocationManager';
import Geolocation from '@react-native-community/geolocation';

const MapView = ({ route }) => {
    const { mapPoints } = route.params;
    const [isDarkMode, setIsDarkMode] = useState(false);
    const [isSatelliteView, setIsSatelliteView] = useState(false);
    const [location, setLocation] = useState(null);
    const [nearestPoint, setNearestPoint] = useState(null);
    const mapRef = useRef(null);
    const [mapLayout, setMapLayout] = useState({ width: 0, height: 0 });

    const lightMap = require('../assets/map/LightMap.jpg');
    const satelliteMap = require('../assets/map/SatelliteMap.jpg');
    const blurredSatellite = require('../assets/map/BlurredSatellite.jpg');

    const MAP_ORIGINAL_WIDTH = 1843;
    const MAP_ORIGINAL_HEIGHT = 4164;

    useEffect(() => {
        requestLocationPermission();
        const watchId = Geolocation.watchPosition(
            (position) => handleLocationUpdate(position),
            (error) => console.log('Error watching position:', error),
            { enableHighAccuracy: true, distanceFilter: 10, interval: 5000, fastestInterval: 2000 }
        );

        return () => {
            Geolocation.clearWatch(watchId);
        };
    }, []);

    const handleLocationUpdate = (position) => {
        setLocation(position);
        if (isWithinSafeZone(position.coords)) {
            const nearest = findNearestMapPoint(position.coords, mapPoints);
            setNearestPoint(nearest);
        } else {
            setNearestPoint(null);
        }
    };

    const findNearestMapPoint = (coordinate, points) => {
        let nearest = null;
        let minDistance = Infinity;

        points.forEach(point => {
            const distance = Math.sqrt(
                Math.pow(coordinate.latitude - point.Latitude, 2) +
                Math.pow(coordinate.longitude - point.Longitude, 2)
            );
            if (distance < minDistance) {
                minDistance = distance;
                nearest = point;
            }
        });

        return nearest;
    };

    const calculatePixelPosition = (point) => {
        if (!point || !mapLayout.width || !mapLayout.height) return { left: 0, top: 0 };

        // Remove 'px' from the string and parse as float
        const originalX = parseFloat(point["Pixel X"].replace(' px', ''));
        const originalY = parseFloat(point["Pixel Y"].replace(' px', ''));

        // Calculate the scale factor
        const scaleX = mapLayout.width / MAP_ORIGINAL_WIDTH;
        const scaleY = mapLayout.height / MAP_ORIGINAL_HEIGHT;

        // Apply the scale factor to get the position on the scaled map
        const scaledX = originalX * scaleX;
        const scaledY = originalY * scaleY;

        return {
            left: scaledX -10, // Subtract half of the marker width
            top: scaledY - 10 // Subtract half of the marker height
        };
    };

    const onMapLayout = (event) => {
        const { width, height } = event.nativeEvent.layout;
        setMapLayout({ width, height });
    };

    return (
        <View style={styles.container}>
            <View style={styles.mapContainer} onLayout={onMapLayout}>
                {isSatelliteView && (
                    <Image
                        source={blurredSatellite}
                        style={styles.background}
                        resizeMode="cover"
                    />
                )}
                <Image
                    ref={mapRef}
                    source={isSatelliteView ? satelliteMap : lightMap}
                    style={styles.map}
                    resizeMode="contain"
                />
                {nearestPoint && (
                    <View style={[styles.userMarker, calculatePixelPosition(nearestPoint)]} />
                )}
            </View>
            <TouchableOpacity
                style={[styles.button, { backgroundColor: isDarkMode ? 'black' : 'white' }]}
                onPress={() => setIsSatelliteView(!isSatelliteView)}
            >
                <Icon
                    name={isSatelliteView ? 'map' : 'globe'}
                    size={24}
                    color={isDarkMode ? 'white' : 'black'}
                />
            </TouchableOpacity>
            {location && (
                <Text style={styles.locationText}>
                    Lat: {location.coords.latitude.toFixed(4)}, Lon: {location.coords.longitude.toFixed(4)}
                </Text>
            )}
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: 'white',
    },
    mapContainer: {
        flex: 1,
        position: 'relative',
    },
    background: {
        ...StyleSheet.absoluteFillObject,
    },
    map: {
        width: '100%',
        height: '100%',
        position: 'absolute',
    },
    button: {
        position: 'absolute',
        top: 40,
        right: 20, 
        width: 50,
        height: 50,
        borderRadius: 15,
        justifyContent: 'center',
        alignItems: 'center',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 1,
        shadowRadius: 5,
        elevation: 25,
    },
    locationText: {
        position: 'absolute',
        bottom: 20,
        left: 20,
        backgroundColor: 'rgba(255,255,255,0.7)',
        padding: 10,
        borderRadius: 5,
    },
    userMarker: {
        position: 'absolute',
        width: 20,
        height: 20,
        borderRadius: 10,
        backgroundColor: 'red',
        borderWidth: 2,
        borderColor: 'white',
    },
});

export default MapView;