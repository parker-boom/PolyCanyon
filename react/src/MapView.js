import React, { useState, useEffect } from 'react';
import { View, Image, StyleSheet, TouchableOpacity, Button, Text } from 'react-native';
import Icon from 'react-native-vector-icons/Ionicons';
import { requestLocationPermission, getCurrentLocation } from './LocationManager';

const MapView = ({ isDarkMode }) => {
    const [isSatelliteView, setIsSatelliteView] = useState(false);
    const [location, setLocation] = useState(null);

    const lightMap = require('../assets/map/LightMap.jpg');
    const satelliteMap = require('../assets/map/SatelliteMap.jpg');
    const blurredSatellite = require('../assets/map/BlurredSatellite.jpg');

    useEffect(() => {
        requestLocationPermission();
    }, []);

    const handleGetLocation = () => {
        getCurrentLocation((error, position) => {
            if (error) {
                console.error(error);
            } else {
                setLocation(position);
            }
        });
    };

    return (
        <View style={[styles.container, { backgroundColor: isSatelliteView ? 'transparent' : 'white' }]}>
            {isSatelliteView && (
                <Image
                    source={blurredSatellite}
                    style={styles.background}
                    resizeMode="cover"
                />
            )}
            <Image
                source={isSatelliteView ? satelliteMap : lightMap}
                style={styles.map}
                resizeMode="contain"
            />
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
            <Button title="Get Location" onPress={handleGetLocation} />
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
        justifyContent: 'center',
        alignItems: 'center',
        position: 'relative',
    },
    background: {
        ...StyleSheet.absoluteFillObject,
    },
    map: {
        width: '100%',
        height: '97%', 
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
        backgroundColor: 'rgba(255,255,255,0.7)',
        padding: 10,
        borderRadius: 5,
    },
});

export default MapView;