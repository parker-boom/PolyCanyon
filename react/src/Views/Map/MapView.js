import React, { useState, useEffect, useRef } from "react";
import {
  View,
  Image,
  TouchableOpacity,
  StyleSheet,
  Animated,
  Easing,
} from "react-native";
import Icon from "react-native-vector-icons/Ionicons";
import { useDarkMode } from "../../Core/States/DarkMode";
import { useAdventureMode } from "../../Core/States/AdventureMode";
import { useLocationService } from "../../Core/Location/LocationService";
import { useAppState } from "../../Core/States/AppState";
import styles from "./MapStyles";

// Map assets
const MAP_ASSETS = {
  light: require("../../assets/map/LightMap.jpg"),
  dark: require("../../assets/map/DarkMap.jpg"),
  satellite: require("../../assets/map/SatelliteMap.jpg"),
  blurredSatellite: require("../../assets/map/BlurredSatellite.jpg"),
};

// Original map dimensions for pixel calculations
const MAP_ORIGINAL_WIDTH = 1843;
const MAP_ORIGINAL_HEIGHT = 4164;

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
      <View
        style={[
          styles.pulsingCircleInner,
          isSatelliteView ? styles.shadowLight : styles.shadowDark,
        ]}
      />
    </View>
  );
};

const MapView = () => {
  // Context hooks
  const { isDarkMode } = useDarkMode();
  const { adventureMode } = useAdventureMode();
  const { currentLocation, nearestMapPoint } = useLocationService();
  const { mapStyle, toggleMapStyle } = useAppState();

  // Local state for map layout calculations
  const [mapLayout, setMapLayout] = useState({ width: 0, height: 0 });

  // Add debug logging
  useEffect(() => {}, [adventureMode, nearestMapPoint]);

  // Add logging to pixel position calculation
  const calculatePixelPosition = (point) => {
    if (!point || !mapLayout.width || !mapLayout.height) {
      return { left: 0, top: 0 };
    }

    const originalX = parseFloat(point.pixelPosition.x);
    const originalY = parseFloat(point.pixelPosition.y);

    const scaleX = mapLayout.width / MAP_ORIGINAL_WIDTH;
    const scaleY = mapLayout.height / MAP_ORIGINAL_HEIGHT;
    const scale = Math.min(scaleX, scaleY);

    const offsetX = (mapLayout.width - MAP_ORIGINAL_WIDTH * scale) / 2;
    const offsetY = (mapLayout.height - MAP_ORIGINAL_HEIGHT * scale) / 2;

    const position = {
      left: offsetX + originalX * scale - 10,
      top: offsetY + originalY * scale - 10,
    };

    return position;
  };

  // Add logging for map layout changes
  const onMapLayout = (event) => {
    const { width, height } = event.nativeEvent.layout;
    setMapLayout({ width, height });
  };

  // Determine which map to show
  const getMapSource = () => {
    if (mapStyle === "satellite") return MAP_ASSETS.satellite;
    return isDarkMode ? MAP_ASSETS.dark : MAP_ASSETS.light;
  };

  return (
    <View style={styles.container}>
      {mapStyle === "satellite" && (
        <Image
          source={MAP_ASSETS.blurredSatellite}
          style={StyleSheet.absoluteFill}
          blurRadius={10}
        />
      )}
      <View
        style={[
          StyleSheet.absoluteFill,
          { backgroundColor: isDarkMode ? "black" : "white" },
        ]}
      />
      <View style={styles.mapContainer} onLayout={onMapLayout}>
        <Image
          source={getMapSource()}
          style={styles.map}
          resizeMode="contain"
        />
        {adventureMode && nearestMapPoint && (
          <View
            style={[
              styles.markerContainer,
              calculatePixelPosition(nearestMapPoint),
            ]}
          >
            <PulsingCircle isSatelliteView={mapStyle === "satellite"} />
          </View>
        )}
      </View>
      <TouchableOpacity
        style={[
          styles.button,
          {
            backgroundColor: isDarkMode ? "black" : "white",
            shadowColor: isDarkMode ? "#fff" : "#000",
          },
        ]}
        onPress={toggleMapStyle}
      >
        <Icon
          name={mapStyle === "satellite" ? "map" : "globe"}
          size={24}
          color={isDarkMode ? "white" : "black"}
        />
      </TouchableOpacity>
    </View>
  );
};

export default MapView;
