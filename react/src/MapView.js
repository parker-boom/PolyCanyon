import React, { useState, useEffect, useRef } from 'react';
import { View, Image, StyleSheet, TouchableOpacity, Text, Animated, Easing } from 'react-native';
import Icon from 'react-native-vector-icons/Ionicons';
import { requestLocationPermission, getCurrentLocation, isWithinSafeZone } from './LocationManager';
import Geolocation from '@react-native-community/geolocation';

const PulsingCircle = ({ isSatelliteView }) => {
    const scaleAnim = useRef(new Animated.Value(1)).current;

    useEffect(() => {
        Animated.loop(
            Animated.sequence([
                Animated.timing(scaleAnim, {
                    toValue: 1.5,
                    duration: 1250,
                    easing: Easing.inOut(Easing.ease),
                    useNativeDriver: true,
                }),
                Animated.timing(scaleAnim, {
                    toValue: 1,
                    duration: 1250,
                    easing: Easing.inOut(Easing.ease),
                    useNativeDriver: true,
                }),
            ])
        ).start();
    }, []);

    return (
        <View style={styles.pulsingCircleContainer}>
            <Animated.View
                style={[
                    styles.pulsingCircleOverlay,
                    {
                        transform: [{ scale: scaleAnim }],
                        opacity: scaleAnim.interpolate({
                            inputRange: [1, 1.5],
                            outputRange: [1, 0],
                        }),
                    },
                    isSatelliteView ? styles.shadowLight : styles.shadowDark,
                ]}
            />
            <View style={[styles.pulsingCircleInner, isSatelliteView ? styles.shadowLight : styles.shadowDark]} />
        </View>
    );
};


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

        const originalX = parseFloat(point["Pixel X"].replace(' px', ''));
        const originalY = parseFloat(point["Pixel Y"].replace(' px', ''));

        const scaleX = mapLayout.width / MAP_ORIGINAL_WIDTH;
        const scaleY = mapLayout.height / MAP_ORIGINAL_HEIGHT;
        const scale = Math.min(scaleX, scaleY);

        const offsetX = (mapLayout.width - (MAP_ORIGINAL_WIDTH * scale)) / 2;
        const offsetY = (mapLayout.height - (MAP_ORIGINAL_HEIGHT * scale)) / 2;

        const scaledX = originalX * scale;
        const scaledY = originalY * scale;

        return {
            left: offsetX + scaledX - 10,
            top: offsetY + scaledY - 10
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
                    <View style={[styles.markerContainer, calculatePixelPosition(nearestPoint)]}>
                        <PulsingCircle isSatelliteView={isSatelliteView} />
                    </View>
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
        resizeMode: 'contain',
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
    markerContainer: {
        position: 'absolute',
        width: 20,
        height: 20,
        justifyContent: 'center',
        alignItems: 'center',
    },
    pulsingCircleContainer: {
        width: 14,
        height: 14,
        justifyContent: 'center',
        alignItems: 'center',
    },
    pulsingCircleInner: {
        width: 14,
        height: 14,
        borderRadius: 7,
        backgroundColor: 'rgba(112, 235, 64, 1)',
        borderWidth: 2,
        borderColor: 'white',
    },
    pulsingCircleOverlay: {
        position: 'absolute',
        width: 14,
        height: 14,
        borderRadius: 7,
        borderWidth: 2,
        borderColor: 'white',
    },
    shadowDark: {
        shadowColor: "#000",
        shadowOffset: {
            width: 0,
            height: 2,
        },
        shadowOpacity: 0.25,
        shadowRadius: 3.84,
        elevation: 5,
    },
    shadowLight: {
        shadowColor: "#fff",
        shadowOffset: {
            width: 0,
            height: 2,
        },
        shadowOpacity: 0.25,
        shadowRadius: 3.84,
        elevation: 5,
    },
});

export default MapView;