// File: ./Views/VirtualTour/VirtualTour.js

import React, { useState, useEffect, useRef } from "react";
import {
  View,
  Text,
  Image,
  TouchableOpacity,
  StyleSheet,
  Animated,
  Easing,
  Dimensions,
} from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { useNavigation } from "@react-navigation/native";
import Icon from "react-native-vector-icons/Ionicons";
import { useDataStore } from "../../Core/Data/DataStore";
import { useLocationService } from "../../Core/Location/LocationService";

// Constants for the original map image dimensions
const ORIGINAL_WIDTH = 1843;
const ORIGINAL_HEIGHT = 4164;

// Always use this asset for Virtual Tour
const MAP_IMAGE = require("../../assets/map/NoNumbers/SatelliteMapNN.jpg");

// AsyncStorage key for persisting the current structure index
const CURRENT_STRUCTURE_INDEX_KEY = "virtualTourCurrentStructureIndex";

// Helper function: clamp a value between min and max
const clamp = (value, min, max) => Math.min(Math.max(value, min), max);

const VirtualTour = () => {
  const navigation = useNavigation();
  const { structures } = useDataStore(); // Array of structure objects
  const { getMapPointForStructure } = useLocationService();
  const screenWidth = Dimensions.get("window").width;
  const screenHeight = Dimensions.get("window").height;
  const containerHeight = screenHeight * 0.6; // Top 60% as the “map window”

  // Compute scale factor so that the map image's width always equals container's width.
  const scaleFactor = screenWidth / ORIGINAL_WIDTH;
  const scaledMapHeight = ORIGINAL_HEIGHT * scaleFactor;

  // State for current structure index (persisted via AsyncStorage)
  const [currentIndex, setCurrentIndex] = useState(0);

  // Animated value for vertical offset (applied to the entire map+dot component)
  const animatedOffset = useRef(new Animated.Value(0)).current;

  // Load persisted index on mount
  useEffect(() => {
    const loadIndex = async () => {
      const storedIndex = await AsyncStorage.getItem(
        CURRENT_STRUCTURE_INDEX_KEY
      );
      if (storedIndex !== null) {
        setCurrentIndex(Number(storedIndex));
      }
    };
    loadIndex();
  }, []);

  // Persist the index whenever it changes
  useEffect(() => {
    AsyncStorage.setItem(CURRENT_STRUCTURE_INDEX_KEY, currentIndex.toString());
  }, [currentIndex]);

  // Get current structure from the data store
  const currentStructure =
    structures && structures.length > 0 ? structures[currentIndex] : null;

  // Calculate the “raw” dot position relative to the full (scaled) map.
  // We assume the mapping table returns an object { x, y } in the original image's coordinates.
  const getRawDotPosition = () => {
    if (!currentStructure) return { x: 0, y: 0 };
    const mapPoint = getMapPointForStructure(currentStructure.number);
    if (!mapPoint) return { x: 0, y: 0 };
    return {
      // Multiply by scaleFactor to get position in the scaled map image
      x: mapPoint.x * scaleFactor,
      y: mapPoint.y * scaleFactor,
    };
  };

  // Calculate the vertical offset for the entire map container.
  // The idea is to slide the full map (with the dot in its proper position) so that the dot appears at the vertical center.
  const computeSlidingOffset = () => {
    const rawDot = getRawDotPosition();
    // Desired position: center of container
    const desiredCenterY = containerHeight / 2;
    // Calculate how much we need to shift: negative means move map upward.
    const offset = desiredCenterY - rawDot.y;
    // Clamp the offset so that the map image does not slide too far:
    // Maximum offset = 0 (i.e. top edge of the map is at top of container)
    // Minimum offset = containerHeight - scaledMapHeight (i.e. bottom edge of the map touches bottom of container)
    return clamp(offset, containerHeight - scaledMapHeight, 0);
  };

  // Animate the sliding offset whenever the current structure changes.
  useEffect(() => {
    const newOffset = computeSlidingOffset();
    Animated.timing(animatedOffset, {
      toValue: newOffset,
      duration: 300,
      easing: Easing.inOut(Easing.ease),
      useNativeDriver: true,
    }).start();
  }, [currentStructure]);

  // Handlers for next/previous buttons.
  const goNext = () => {
    if (structures && structures.length > 0) {
      const nextIndex = (currentIndex + 1) % structures.length;
      setCurrentIndex(nextIndex);
    }
  };

  const goPrevious = () => {
    if (structures && structures.length > 0) {
      const prevIndex =
        (currentIndex - 1 + structures.length) % structures.length;
      setCurrentIndex(prevIndex);
    }
  };

  // "Learn More" button navigates to full structure detail.
  const openStructureDetail = () => {
    if (currentStructure) {
      navigation.navigate("StructureDetail", {
        structureNumber: currentStructure.number,
      });
    }
  };

  // Close Virtual Tour: simply go back.
  const closeVirtualTour = () => {
    navigation.goBack();
  };

  // Get raw dot coordinates
  const rawDot = getRawDotPosition();

  return (
    <View style={styles.container}>
      {/* Top Map Section: A fixed-height (60% of screen) container with overflow hidden */}
      <View
        style={[
          styles.mapWindow,
          { height: containerHeight, width: screenWidth },
        ]}
      >
        <Animated.View
          style={[
            styles.animatedMapContainer,
            {
              width: screenWidth,
              height: scaledMapHeight,
              transform: [{ translateY: animatedOffset }],
            },
          ]}
        >
          <Image
            source={MAP_IMAGE}
            style={{ width: screenWidth, height: scaledMapHeight }}
            resizeMode="cover"
          />
          {/* Render the dot at its raw coordinates relative to the full map */}
          <View
            style={[
              styles.dotContainer,
              {
                top: rawDot.y - 10, // assuming dot is 20x20, center it by subtracting half
                left: rawDot.x - 10,
              },
            ]}
          >
            <View style={styles.dot} />
          </View>
        </Animated.View>
        {/* Overlay: Title and structure number on top of the map */}
        {currentStructure && (
          <View style={styles.titleOverlay}>
            <Text style={styles.titleText}>
              #{currentStructure.number} {currentStructure.title}
            </Text>
          </View>
        )}
      </View>

      {/* Bottom Information Bar (40% of screen) */}
      <View style={styles.bottomBar}>
        <View style={styles.infoContainer}>
          {currentStructure &&
            currentStructure.images &&
            currentStructure.images[0] && (
              <Image
                source={{ uri: currentStructure.images[0] }}
                style={styles.structureImage}
              />
            )}
          <View style={styles.textContainer}>
            {currentStructure && (
              <>
                <Text style={styles.structureTitle}>
                  #{currentStructure.number} {currentStructure.title}
                </Text>
                <Text style={styles.funFact}>{currentStructure.funFact}</Text>
              </>
            )}
          </View>
        </View>
        <View style={styles.navContainer}>
          <TouchableOpacity onPress={goPrevious} style={styles.navButton}>
            <Icon name="chevron-back" size={24} color="#fff" />
          </TouchableOpacity>
          <TouchableOpacity
            onPress={openStructureDetail}
            style={[styles.navButton, styles.learnMoreButton]}
          >
            <Text style={styles.learnMoreText}>Learn More</Text>
          </TouchableOpacity>
          <TouchableOpacity onPress={goNext} style={styles.navButton}>
            <Icon name="chevron-forward" size={24} color="#fff" />
          </TouchableOpacity>
        </View>
      </View>

      {/* Close Button */}
      <TouchableOpacity onPress={closeVirtualTour} style={styles.closeButton}>
        <Icon name="close" size={28} color="#fff" />
      </TouchableOpacity>
    </View>
  );
};

export default VirtualTour;

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#000",
  },
  // The visible window for the map (top 60% of screen)
  mapWindow: {
    overflow: "hidden",
  },
  // The animated container that holds the full scaled map and the dot.
  animatedMapContainer: {
    position: "absolute",
    left: 0,
    top: 0,
  },
  // Dot container used to position the dot absolutely within the map.
  dotContainer: {
    position: "absolute",
    width: 20,
    height: 20,
    justifyContent: "center",
    alignItems: "center",
  },
  // The dot itself – you can later enhance this with pulsing animation if desired.
  dot: {
    width: 20,
    height: 20,
    borderRadius: 10,
    backgroundColor: "rgba(112,235,64,1)",
    borderWidth: 2,
    borderColor: "#fff",
  },
  // Overlay on top of the map: structure title/number
  titleOverlay: {
    position: "absolute",
    bottom: 10,
    left: 10,
    backgroundColor: "rgba(0,0,0,0.5)",
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 5,
  },
  titleText: {
    color: "#fff",
    fontSize: 18,
    fontWeight: "bold",
  },
  // Bottom bar container (40% of screen)
  bottomBar: {
    flex: 1,
    backgroundColor: "#111",
    padding: 15,
    justifyContent: "space-between",
  },
  infoContainer: {
    flexDirection: "row",
    alignItems: "center",
  },
  structureImage: {
    width: 80,
    height: 80,
    borderRadius: 10,
    marginRight: 10,
  },
  textContainer: {
    flex: 1,
  },
  structureTitle: {
    color: "#fff",
    fontSize: 20,
    fontWeight: "bold",
    marginBottom: 5,
  },
  funFact: {
    color: "#ccc",
    fontSize: 16,
  },
  navContainer: {
    flexDirection: "row",
    justifyContent: "space-around",
    alignItems: "center",
    marginTop: 15,
  },
  navButton: {
    backgroundColor: "#333",
    padding: 10,
    borderRadius: 10,
  },
  learnMoreButton: {
    flex: 1,
    marginHorizontal: 20,
    justifyContent: "center",
    alignItems: "center",
  },
  learnMoreText: {
    color: "#fff",
    fontSize: 18,
  },
  closeButton: {
    position: "absolute",
    top: 40,
    right: 20,
    backgroundColor: "rgba(0,0,0,0.5)",
    padding: 10,
    borderRadius: 20,
  },
});
