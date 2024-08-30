// MARK: - MapView Component
/**
 * MapView Component
 * 
 * This component displays a map showing the user's location and nearby structures.
 * It supports switching between light and satellite views and adapts to Dark Mode.
 * When Dark Mode is enabled, a different map image is displayed, and the background is set to black.
 */

import React, { useState, useEffect, useRef } from 'react';
import { View, Image, StyleSheet, TouchableOpacity, Text, Animated, Easing, Dimensions, Modal } from 'react-native';
import Icon from 'react-native-vector-icons/Ionicons';
import { requestLocationPermission, getCurrentLocation, isWithinSafeZone } from './LocationManager';
import Geolocation from '@react-native-community/geolocation';
import StructPopUp from './StructPopUp';
import { useStructures } from './StructureData';
import { useMapPoints } from './MapPoint';
import { BlurView } from '@react-native-community/blur';
import { useDarkMode } from './DarkMode';

// MARK: - PulsingCircle Component
/**
 * PulsingCircle Component
 * 
 * This component displays a pulsing circle to indicate the user's current location on the map.
 * The appearance adapts based on whether the satellite view is enabled.
 */
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

// MARK: - VisitedStructurePopup Component
/**
 * VisitedStructurePopup Component
 * 
 * This component displays a popup when a structure is visited.
 * The appearance adapts based on Dark Mode settings.
 */
const VisitedStructurePopup = ({ structure, isPresented, setIsPresented, isDarkMode, onStructurePress }) => {
    return (
        <View style={styles.popupContainer}>
            <View style={styles.contentContainer}>
                <TouchableOpacity style={styles.closeButton} onPress={() => setIsPresented(false)}>
                    <Icon 
                        name="close"
                        size={28}
                        color={isDarkMode ? 'white' : 'black'}
                    />
                </TouchableOpacity>
                <Image
                    source={structure.closeUpImage}
                    style={styles.popupImage}
                />
                <TouchableOpacity style={styles.textContainer} onPress={() => onStructurePress(structure)}>
                    <Text style={[styles.justVisitedText, { color: isDarkMode ? 'rgba(255,255,255,0.6)' : 'rgba(0,0,0,0.8)' }]}>
                        Just Visited!
                    </Text>
                    <Text style={[styles.titleText, { color: isDarkMode ? 'white' : 'black' }]}>
                        {structure.title}
                    </Text>
                </TouchableOpacity>
                <Text style={[styles.numberText, { color: isDarkMode ? 'rgba(255,255,255,0.7)' : 'rgba(0,0,0,0.7)' }]}>
                    {structure.number}
                </Text>
                <Icon
                    name="chevron-forward"
                    size={20}
                    color={isDarkMode ? 'white' : 'black'}
                    style={styles.chevron}
                />
            </View>
        </View>
    );
};

// MARK: - MapView Component
/**
 * MapView Component
 * 
 * This component displays the map and handles user interactions such as switching views and marking structures as visited.
 * The map image changes based on whether Dark Mode is enabled, and the background is set to black.
 */
const MapView = ({ route }) => {
    const { mapPoints } = useMapPoints();
    const { structures, setStructures } = useStructures();
    const { isDarkMode } = useDarkMode();
    const [isSatelliteView, setIsSatelliteView] = useState(false);
    const [location, setLocation] = useState(null);
    const [nearestPoint, setNearestPoint] = useState(null);
    const mapRef = useRef(null);
    const [mapLayout, setMapLayout] = useState({ width: 0, height: 0 });
    const [visitedStructure, setVisitedStructure] = useState(null);
    const [showPopup, setShowPopup] = useState(false);
    const [showStructPopUp, setShowStructPopUp] = useState(false);
    const [visitedLandmarks, setVisitedLandmarks] = useState(new Set());

    const lightMap = require('../assets/map/LightMap.jpg');
    const satelliteMap = require('../assets/map/SatelliteMap.jpg');
    const darkMap = require('../assets/map/DarkMap.jpg');
    const blurredSatellite = require('../assets/map/BlurredSatellite.jpg');

    const MAP_ORIGINAL_WIDTH = 1843;
    const MAP_ORIGINAL_HEIGHT = 4164;

    // Load location and setup location updates
    useEffect(() => {
        requestLocationPermission();
        const watchId = Geolocation.watchPosition(
            (position) => handleLocationUpdate(position),
            (error) => {},
            { enableHighAccuracy: true, distanceFilter: 10, interval: 5000, fastestInterval: 2000 }
        );

        return () => {
            Geolocation.clearWatch(watchId);
        };
    }, [mapPoints, structures]);

    // Handle location updates and find the nearest map point
    const handleLocationUpdate = (position) => {
        setLocation(position);
        if (isWithinSafeZone(position.coords)) {
            const nearest = findNearestMapPoint(position.coords, mapPoints);
            setNearestPoint(nearest);
            if (nearest && nearest.landmark !== -1) {
                markStructureAsVisited(nearest.landmark);
            }
        } else {
            setNearestPoint(null);
        }
    };

    // Find the nearest map point to the given coordinates
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

    // Mark a structure as visited and update the state
    const markStructureAsVisited = (landmarkId) => {
        const toVisit = [landmarkId];
        const visitedSet = new Set();

        while (toVisit.length > 0) {
            const currentId = toVisit.pop();

            if (visitedSet.has(currentId)) continue;
            visitedSet.add(currentId);

            setStructures(prevStructures => {
                return prevStructures.map(structure => {
                    if (structure.number === currentId && !structure.isVisited) {
                        if (currentId === landmarkId) {
                            setVisitedStructure(structure);
                            setShowPopup(true);
                        }
                        return { ...structure, isVisited: true };
                    }
                    return structure;
                });
            });

            // Special cases for landmarks that are interconnected
            const specialCases = {
                8: [54, 196],
                13: [19, 108],
                14: [59, 80],
                15: [21, 130],
                17: [24, 132],
                20: [26, 91],
                22: [36, 113],
                30: [49, 60],
                31: [68, 161],
                32: [23, 50]
            };

            if (specialCases[currentId]) {
                specialCases[currentId].forEach(index => {
                    const point = mapPoints.find(point => point.landmark === index);
                    if (point && !visitedSet.has(index)) {
                        toVisit.push(index);
                    }
                });
            }
        }
    };

    // Calculate pixel position on the map based on original map points
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

    // Handle layout changes of the map container
    const onMapLayout = (event) => {
        const { width, height } = event.nativeEvent.layout;
        setMapLayout({ width, height });
    };

    // Handle structure press events and display the popup
    const handleStructurePress = (structure) => {
        setVisitedStructure(structure);
        setShowPopup(false); // Close VisitedStructurePopUp
        setShowStructPopUp(true); // Open StructPopUp
    };

    return (
        <View style={styles.container}>
            {isSatelliteView ? (
                <Image source={blurredSatellite} style={StyleSheet.absoluteFill} blurRadius={10} />
            ) : (
                <View style={[StyleSheet.absoluteFill, { backgroundColor: isDarkMode ? 'black' : 'white' }]} />
            )}
            <View style={styles.mapContainer} onLayout={onMapLayout}>
                <Image
                    ref={mapRef}
                    source={isSatelliteView ? satelliteMap : (isDarkMode ? darkMap : lightMap)}
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
                style={[styles.button, { backgroundColor: isDarkMode ? 'black' : 'white', shadowColor: isDarkMode ? '#fff' : '#000' }]}
                onPress={() => setIsSatelliteView(!isSatelliteView)}
            >
                <Icon
                    name={isSatelliteView ? 'map' : 'globe'}
                    size={24}
                    color={isDarkMode ? 'white' : 'black'}
                />
            </TouchableOpacity>
            {showPopup && visitedStructure && (
                <VisitedStructurePopup
                    structure={visitedStructure}
                    isPresented={showPopup}
                    setIsPresented={setShowPopup}
                    isDarkMode={isDarkMode}
                    onStructurePress={handleStructurePress}
                />
            )}
            <Modal
                visible={showStructPopUp}
                transparent={true}
                animationType="fade"
                onRequestClose={() => setShowStructPopUp(false)}
            >
                <BlurView
                    style={StyleSheet.absoluteFill}
                    blurType={isDarkMode ? "dark" : "light"}
                    blurAmount={10}
                >
                    <View style={styles.modalContainer}>
                        {visitedStructure && (
                            <StructPopUp
                                structure={visitedStructure}
                                onClose={() => setShowStructPopUp(false)}
                                isDarkMode={isDarkMode}
                            />
                        )}
                    </View>
                </BlurView>
            </Modal>
        </View>
    );
};

// MARK: - Styles
const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
    mapContainer: {
        flex: 1,
        position: 'relative',
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
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 1,
        shadowRadius: 5,
        elevation: 25,
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
    popupContainer: {
        position: 'absolute',
        bottom: 20,
        left: 15,
        right: 15,
        backgroundColor: 'transparent',
    },
    contentContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: 'white',
        borderRadius: 15,
        padding: 10,
        shadowColor: "#000",
        shadowOffset: {
            width: 0,
            height: 2,
        },
        shadowOpacity: 0.25,
        shadowRadius: 3.84,
        elevation: 5,
    },
    closeButton: {
        padding: 5,
    },
    popupImage: {
        width: 80,
        height: 80,
        borderRadius: 10,
        marginLeft: 10,
    },
    textContainer: {
        flex: 1,
        marginLeft: 10,
    },
    justVisitedText: {
        fontSize: 14,
    },
    titleText: {
        fontSize: 24,
        fontWeight: 'bold',
    },
    numberText: {
        fontSize: 28,
        fontWeight: 'bold',
        marginRight: 10,
    },
    chevron: {
        marginLeft: 10,
    },
    modalContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        padding: 20,
        backgroundColor: 'rgba(0, 0, 0, 0.0)',
    },
});


export default MapView;
