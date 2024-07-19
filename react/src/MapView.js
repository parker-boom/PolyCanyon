import React, { useState, useEffect, useRef } from 'react';
import { View, Image, StyleSheet, TouchableOpacity, Text, Animated, Easing, Dimensions } from 'react-native';
import Icon from 'react-native-vector-icons/Ionicons';
import { requestLocationPermission, getCurrentLocation, isWithinSafeZone } from './LocationManager';
import Geolocation from '@react-native-community/geolocation';
import StructPopUp from './StructPopUp';
import { useStructures } from './StructureData';

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

const VisitedStructurePopup = ({ structure, isPresented, setIsPresented, isDarkMode }) => {
    const [showStructPopup, setShowStructPopup] = useState(false);

    const handleClose = () => {
        setIsPresented(false);
    };

    const handleStructurePress = () => {
        setShowStructPopup(true);
    };

    return (
        <View style={styles.popupContainer}>
            <TouchableOpacity style={styles.closeButton} onPress={handleClose}>
                <Icon 
                    name="close"
                    size={28}
                    color={isDarkMode ? 'white' : 'black'}
                />
            </TouchableOpacity>
            <TouchableOpacity style={styles.contentContainer} onPress={handleStructurePress}>
                <Image
                    source={structure.closeUpImage}
                    style={styles.popupImage}
                />
                <View style={styles.textContainer}>
                    <Text style={[styles.justVisitedText, { color: isDarkMode ? 'rgba(255,255,255,0.6)' : 'rgba(0,0,0,0.8)' }]}>
                        Just Visited!
                    </Text>
                    <Text style={[styles.titleText, { color: isDarkMode ? 'white' : 'black' }]}>
                        {structure.title}
                    </Text>
                </View>
                <Text style={[styles.numberText, { color: isDarkMode ? 'rgba(255,255,255,0.7)' : 'rgba(0,0,0,0.7)' }]}>
                    {structure.number}
                </Text>
                <Icon
                    name="chevron-forward"
                    size={20}
                    color={isDarkMode ? 'white' : 'black'}
                    style={styles.chevron}
                />
            </TouchableOpacity>
            {showStructPopup && (
                <StructPopUp
                    structure={structure}
                    isDarkMode={isDarkMode}
                    onClose={() => {
                        setShowStructPopup(false);
                        setIsPresented(false);
                    }}
                />
            )}
        </View>
    );
};

const MapView = ({ route }) => {
    const { mapPoints } = route.params;
    const { structures, setStructures } = useStructures();
    const [isDarkMode, setIsDarkMode] = useState(false);
    const [isSatelliteView, setIsSatelliteView] = useState(false);
    const [location, setLocation] = useState(null);
    const [nearestPoint, setNearestPoint] = useState(null);
    const mapRef = useRef(null);
    const [mapLayout, setMapLayout] = useState({ width: 0, height: 0 });
    const [visitedStructure, setVisitedStructure] = useState(null);
    const [showPopup, setShowPopup] = useState(false);

    const lightMap = require('../assets/map/LightMap.jpg');
    const satelliteMap = require('../assets/map/SatelliteMap.jpg');
    const blurredSatellite = require('../assets/map/BlurredSatellite.jpg');

    const MAP_ORIGINAL_WIDTH = 1843;
    const MAP_ORIGINAL_HEIGHT = 4164;

    useEffect(() => {
        console.log('MapView mounted. mapPoints:', mapPoints);
        console.log('Initial structures:', structures);
        
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
        console.log('Location updated:', position.coords);
        setLocation(position);
        if (isWithinSafeZone(position.coords)) {
            const nearest = findNearestMapPoint(position.coords, mapPoints);
            console.log('Nearest point:', nearest);
            setNearestPoint(nearest);
            if (nearest && nearest.landmark !== -1) {
                console.log('Attempting to mark structure as visited. Landmark:', nearest.landmark);
                markStructureAsVisited(nearest.landmark);
            }
        } else {
            console.log('Location is outside safe zone');
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

        console.log('Finding nearest map point for coordinate:', coordinate);
        return nearest;
    };

    const markStructureAsVisited = (landmarkId) => {
        console.log('Marking structure as visited. LandmarkId:', landmarkId);
        setStructures(prevStructures => {
            const updatedStructures = prevStructures.map(structure => {
                if (structure.number === landmarkId) {
                    console.log('Found matching structure:', structure);
                    if (!structure.isVisited) {
                        console.log('Structure was not previously visited. Marking as visited.');
                        setVisitedStructure(structure);
                        setShowPopup(true);
                    } else {
                        console.log('Structure was already visited.');
                    }
                    return { ...structure, isVisited: true };
                }
                return structure;
            });
            console.log('Updated structures:', updatedStructures);
            return updatedStructures;
        });

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

        if (specialCases[landmarkId]) {
            specialCases[landmarkId].forEach(index => {
                markPointAsVisitedByIndex(index);
            });
        }
    };

    const markPointAsVisitedByIndex = (index) => {
        console.log('Marking point as visited by index:', index);
        const updatedMapPoints = [...mapPoints];
        if (index >= 0 && index < updatedMapPoints.length) {
            const newIndex = index - 1;
            updatedMapPoints[newIndex].isVisited = true;
            console.log('Updated map point:', updatedMapPoints[newIndex]);
            markStructureAsVisited(updatedMapPoints[newIndex].landmark);
        } else {
            console.log('Invalid index:', index);
        }
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
            {showPopup && visitedStructure && (
                <VisitedStructurePopup
                    structure={visitedStructure}
                    isPresented={showPopup}
                    setIsPresented={setShowPopup}
                    isDarkMode={isDarkMode}
                />
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
    popupContainer: {
        position: 'absolute',
        bottom: 20,
        left: 15,
        right: 15,
        backgroundColor: 'transparent',
    },
    closeButton: {
        position: 'absolute',
        top: 10,
        left: 10,
        zIndex: 1,
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
    popupImage: {
        width: 80,
        height: 80,
        borderRadius: 10,
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
        marginLeft: 5,
    },
    chevron: {
        marginLeft: 10,
    },
});

export default MapView;