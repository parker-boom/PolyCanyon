import React, { useState, useEffect, useRef } from "react";
import {
  View,
  Image,
  TouchableOpacity,
  StyleSheet,
  Animated,
  Easing,
  Text,
  StyleSheet as RNStyleSheet,
} from "react-native";
import Icon from "react-native-vector-icons/Ionicons";
import { useDarkMode } from "../../Core/States/DarkMode";
import { useAdventureMode } from "../../Core/States/AdventureMode";
import { useLocationService } from "../../Core/Location/LocationService";
import { useAppState } from "../../Core/States/AppState";
import { useNavigation } from "@react-navigation/native"; // NEW import
import styles from "./MapStyles";

// Map assets for regular (numbers) mode
const MAP_ASSETS = {
  light: require("../../assets/map/Normal/LightMap.jpg"),
  dark: require("../../assets/map/Normal/DarkMap.jpg"),
  satellite: require("../../assets/map/Normal/SatelliteMap.jpg"),
  blurredSatellite: require("../../assets/map/Normal/BlurredSatellite.jpg"),
};

// Map assets for no numbers mode
const MAP_ASSETS_NO_NUMBERS = {
  light: require("../../assets/map/NoNumbers/LightMapNN.jpg"),
  dark: require("../../assets/map/NoNumbers/DarkMapNN.jpg"),
  satellite: require("../../assets/map/NoNumbers/SatelliteMapNN.jpg"),
};

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
  const { mapStyle, toggleMapStyle, mapShowNumbers, toggleMapNumbers } =
    useAppState();
  const navigation = useNavigation();

  // Local state for map layout calculations
  const [mapLayout, setMapLayout] = useState({ width: 0, height: 0 });

  // Local state for settings panel open/closed
  const [settingsOpen, setSettingsOpen] = useState(false);
  // Animated value for settings button scaling
  const settingsScale = useRef(new Animated.Value(1)).current;

  // Animate settings button when toggling open/closed
  const toggleSettings = () => {
    setSettingsOpen((prev) => {
      const newState = !prev;
      Animated.timing(settingsScale, {
        toValue: newState ? 0.8 : 1,
        duration: 200,
        useNativeDriver: true,
      }).start();
      return newState;
    });
  };

  // Updated: When Virtual Tour button is pressed, navigate to VirtualTour screen
  const openVirtualTour = () => {
    navigation.navigate("VirtualTour");
  };

  // Calculate pixel position for the pulsing circle
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
    return {
      left: offsetX + originalX * scale - 10,
      top: offsetY + originalY * scale - 10,
    };
  };

  // Handler for layout changes
  const onMapLayout = (event) => {
    const { width, height } = event.nativeEvent.layout;
    setMapLayout({ width, height });
  };

  // Determine which map image to show based on dark mode, map style, and numbers toggle
  const getMapSource = () => {
    const useNoNumbers = !mapShowNumbers; // if mapShowNumbers is false, use no numbers image
    if (mapStyle === "satellite") {
      return useNoNumbers
        ? MAP_ASSETS_NO_NUMBERS.satellite
        : MAP_ASSETS.satellite;
    } else {
      if (isDarkMode) {
        return useNoNumbers ? MAP_ASSETS_NO_NUMBERS.dark : MAP_ASSETS.dark;
      } else {
        return useNoNumbers ? MAP_ASSETS_NO_NUMBERS.light : MAP_ASSETS.light;
      }
    }
  };

  return (
    <View style={styles.container}>
      {/* If satellite, render blurred background */}
      {mapStyle === "satellite" && (
        <Image
          source={MAP_ASSETS.blurredSatellite}
          style={RNStyleSheet.absoluteFill}
          blurRadius={10}
        />
      )}
      <View
        style={[
          RNStyleSheet.absoluteFill,
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

      {/* Bottom Left: Settings Button & Toggle Options */}
      <View
        style={{
          position: "absolute",
          bottom: 20,
          left: 20,
          alignItems: "center",
        }}
      >
        {settingsOpen && (
          <View style={{ marginBottom: 10, alignItems: "center" }}>
            {/* Satellite Toggle Button */}
            <TouchableOpacity
              onPress={toggleMapStyle}
              style={{
                width: 50,
                height: 50,
                borderRadius: 25,
                backgroundColor: isDarkMode ? "#333" : "#fff",
                justifyContent: "center",
                alignItems: "center",
                marginBottom: 10,
                shadowColor: isDarkMode ? "#fff" : "#000",
                shadowOffset: { width: 0, height: 2 },
                shadowOpacity: 0.25,
                shadowRadius: 3.84,
                elevation: 5,
              }}
            >
              <Icon
                name={mapStyle === "satellite" ? "map" : "globe"}
                size={24}
                color={isDarkMode ? "white" : "black"}
              />
            </TouchableOpacity>
            {/* Numbers Toggle Button */}
            <TouchableOpacity
              onPress={toggleMapNumbers}
              style={{
                width: 50,
                height: 50,
                borderRadius: 25,
                backgroundColor: isDarkMode ? "#333" : "#fff",
                justifyContent: "center",
                alignItems: "center",
                shadowColor: isDarkMode ? "#fff" : "#000",
                shadowOffset: { width: 0, height: 2 },
                shadowOpacity: 0.25,
                shadowRadius: 3.84,
                elevation: 5,
              }}
            >
              {mapShowNumbers ? (
                <Text
                  style={{
                    fontSize: 18,
                    color: isDarkMode ? "white" : "black",
                  }}
                >
                  123
                </Text>
              ) : (
                <Text
                  style={{
                    fontSize: 18,
                    color: isDarkMode ? "white" : "black",
                  }}
                >
                  NN
                </Text>
              )}
            </TouchableOpacity>
          </View>
        )}
        <Animated.View style={{ transform: [{ scale: settingsScale }] }}>
          <TouchableOpacity
            onPress={toggleSettings}
            style={{
              width: 50,
              height: 50,
              borderRadius: 15,
              backgroundColor: isDarkMode ? "black" : "white",
              justifyContent: "center",
              alignItems: "center",
              shadowColor: isDarkMode ? "#fff" : "#000",
              shadowOffset: { width: 0, height: 2 },
              shadowOpacity: 1,
              shadowRadius: 5,
              elevation: 25,
            }}
          >
            <Icon
              name={settingsOpen ? "close" : "settings-outline"}
              size={24}
              color={isDarkMode ? "white" : "black"}
            />
          </TouchableOpacity>
        </Animated.View>
      </View>

      {/* Bottom Right: Virtual Walkthrough Button */}
      <View style={{ position: "absolute", bottom: 20, right: 20 }}>
        <TouchableOpacity
          onPress={openVirtualTour}
          style={{
            width: 50,
            height: 50,
            borderRadius: 15,
            backgroundColor: isDarkMode ? "black" : "white",
            justifyContent: "center",
            alignItems: "center",
            shadowColor: isDarkMode ? "#fff" : "#000",
            shadowOffset: { width: 0, height: 2 },
            shadowOpacity: 1,
            shadowRadius: 5,
            elevation: 25,
          }}
        >
          <Icon
            name="walk-outline"
            size={24}
            color={isDarkMode ? "white" : "black"}
          />
        </TouchableOpacity>
      </View>
    </View>
  );
};

export default MapView;
