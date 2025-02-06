/**
 * VirtualTour Component
 *
 * A guided tour interface that allows users to explore structures on a map.
 * Features include:
 * - Interactive map with structure locations
 * - Auto-centering on selected structures
 * - Structure information display
 * - Navigation between structures
 * - Persistent tour progress
 */

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
  Image as RNImage,
} from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { useNavigation } from "@react-navigation/native";
import Icon from "react-native-vector-icons/Ionicons";
import { useDataStore } from "../../Core/Data/DataStore";
import { useLocationService } from "../../Core/Location/LocationService";
import { getMainPhoto } from "../../Core/Images/ImageRegistry";
import { useDarkMode } from "../../Core/States/DarkMode";
import { useAppState } from "../../Core/States/AppState";

// Map dimensions used for scaling calculations
const ORIGINAL_WIDTH = 1843;
const ORIGINAL_HEIGHT = 4164;

// Base map image without structure numbers
const MAP_IMAGE = require("../../assets/map/NoNumbers/SatelliteMapNN.jpg");

// Storage key for saving tour progress
const CURRENT_STRUCTURE_INDEX_KEY = "virtualTourCurrentStructureIndex";

/**
 * Constrains a value between minimum and maximum bounds
 */
const clamp = (value, min, max) => Math.min(Math.max(value, min), max);

const { width: SCREEN_WIDTH } = Dimensions.get("window");

const VirtualTour = () => {
  const navigation = useNavigation();
  const { structures } = useDataStore(); // Array of structure objects
  const { getMapPointForStructure } = useLocationService();
  const screenWidth = Dimensions.get("window").width;
  const screenHeight = Dimensions.get("window").height;
  const containerHeight = screenHeight * 0.6; // Top 60% as the "map window"
  const { isDarkMode } = useDarkMode();
  const { setSelectedStructure } = useAppState();

  // Compute scale factor so that the map image's width always equals container's width.
  const scaleFactor = screenWidth / ORIGINAL_WIDTH;
  const scaledMapHeight = ORIGINAL_HEIGHT * scaleFactor;

  // State for current structure index (persisted via AsyncStorage)
  const [currentIndex, setCurrentIndex] = useState(0);

  // Animated value for vertical offset (applied to the entire map+dot component)
  const animatedOffset = useRef(new Animated.Value(0)).current;

  // Add state for fade animation
  const fadeAnim = useRef(new Animated.Value(1)).current;

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

  // Calculate the "raw" dot position relative to the full (scaled) map.
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

  /**
   * Calculates the map offset needed to center the current structure
   * Returns a vertical offset value that positions the structure dot
   * in the center of the visible map area
   */
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

  // Update the preloadImages function
  const preloadImages = (indexes) => {
    indexes.forEach((index) => {
      if (structures[index]) {
        const imageSource = getMainPhoto(structures[index].number);
        // Only prefetch if it's a URL string, not a require'd asset
        if (typeof imageSource === "string") {
          RNImage.prefetch(imageSource);
        }
      }
    });
  };

  // Preload adjacent images when current index changes
  useEffect(() => {
    if (structures && structures.length > 0) {
      const nextIndex = (currentIndex + 1) % structures.length;
      const prevIndex =
        (currentIndex - 1 + structures.length) % structures.length;
      preloadImages([nextIndex, prevIndex]);
    }
  }, [currentIndex, structures]);

  // Update navigation functions to include fade transition
  const navigateWithFade = (newIndex) => {
    Animated.sequence([
      Animated.timing(fadeAnim, {
        toValue: 0,
        duration: 150,
        useNativeDriver: true,
      }),
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 150,
        useNativeDriver: true,
      }),
    ]).start();

    setCurrentIndex(newIndex);
  };

  const goNext = () => {
    if (structures && structures.length > 0) {
      const nextIndex = (currentIndex + 1) % structures.length;
      navigateWithFade(nextIndex);
    }
  };

  const goPrevious = () => {
    if (structures && structures.length > 0) {
      const prevIndex =
        (currentIndex - 1 + structures.length) % structures.length;
      navigateWithFade(prevIndex);
    }
  };

  // "Learn More" button navigates to full structure detail.
  const openStructureDetail = () => {
    if (currentStructure) {
      setSelectedStructure(currentStructure.number);
      navigation.navigate("StructureDetail");
    }
  };

  // Close Virtual Tour: simply go back.
  const closeVirtualTour = () => {
    navigation.goBack();
  };

  // Get raw dot coordinates
  const rawDot = getRawDotPosition();

  return (
    <View
      style={[
        styles.container,
        { backgroundColor: isDarkMode ? "#000" : "#fff" },
      ]}
    >
      {/* Map Section */}
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
        {/* Updated title overlay with auto-scaling text */}
        {currentStructure && (
          <View style={styles.titleOverlay}>
            <Text
              style={[
                styles.titleText,
                { color: isDarkMode ? "#fff" : "#000" },
              ]}
              adjustsFontSizeToFit
              numberOfLines={1}
            >
              #{currentStructure.number} {currentStructure.title}
            </Text>
          </View>
        )}
      </View>

      {/* Content Section */}
      <View
        style={[
          styles.bottomBar,
          { backgroundColor: isDarkMode ? "#111" : "#f5f5f5" },
        ]}
      >
        <View style={styles.infoContainer}>
          {/* Structure Image */}
          <View style={styles.imageSection}>
            {currentStructure && (
              <Animated.View style={{ opacity: fadeAnim, flex: 1 }}>
                <Image
                  source={getMainPhoto(currentStructure.number)}
                  style={styles.structureImage}
                  resizeMode="cover"
                />
              </Animated.View>
            )}
          </View>

          {/* Fun Fact */}
          <View style={styles.funFactSection}>
            {currentStructure && (
              <Text
                style={[
                  styles.funFact,
                  { color: isDarkMode ? "#fff" : "#000" },
                ]}
              >
                {currentStructure.funFact}
              </Text>
            )}
          </View>
        </View>

        {/* Navigation */}
        <View style={styles.navContainer}>
          <TouchableOpacity
            onPress={goPrevious}
            style={[
              styles.navButton,
              { backgroundColor: isDarkMode ? "#333" : "#e0e0e0" },
            ]}
          >
            <Icon
              name="chevron-back"
              size={24}
              color={isDarkMode ? "#fff" : "#000"}
            />
          </TouchableOpacity>

          <TouchableOpacity
            onPress={openStructureDetail}
            style={[
              styles.learnMoreButton,
              { backgroundColor: isDarkMode ? "#333" : "#e0e0e0" },
            ]}
          >
            <Text
              style={[
                styles.learnMoreText,
                { color: isDarkMode ? "#fff" : "#000" },
              ]}
            >
              Learn More
            </Text>
          </TouchableOpacity>

          <TouchableOpacity
            onPress={goNext}
            style={[
              styles.navButton,
              { backgroundColor: isDarkMode ? "#333" : "#e0e0e0" },
            ]}
          >
            <Icon
              name="chevron-forward"
              size={24}
              color={isDarkMode ? "#fff" : "#000"}
            />
          </TouchableOpacity>
        </View>
      </View>

      {/* Perfectly centered close button */}
      <TouchableOpacity onPress={closeVirtualTour} style={styles.closeButton}>
        <View style={styles.closeButtonInner}>
          <Icon name="close" size={20} color="#000" />
        </View>
      </TouchableOpacity>
    </View>
  );
};

export default VirtualTour;

const styles = StyleSheet.create({
  // Core layout
  container: {
    flex: 1,
  },
  mapWindow: {
    overflow: "hidden",
  },

  // Map components
  animatedMapContainer: {
    position: "absolute",
    left: 0,
    top: 0,
  },
  dotContainer: {
    position: "absolute",
    width: 20,
    height: 20,
    justifyContent: "center",
    alignItems: "center",
  },
  dot: {
    width: 20,
    height: 20,
    borderRadius: 10,
    backgroundColor: "rgba(112,235,64,1)",
    borderWidth: 2,
    borderColor: "#fff",
  },

  // Structure information overlay
  titleOverlay: {
    position: "absolute",
    bottom: 10,
    left: "50%",
    transform: [{ translateX: -125 }],
    backgroundColor: "#fff",
    opacity: 0.95,
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderRadius: 12,
    width: 250,
    alignItems: "center",
    shadowColor: "#000",
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  titleText: {
    fontSize: 22,
    fontWeight: "800",
    textAlign: "center",
    includeFontPadding: false,
  },
  bottomBar: {
    flex: 1,
    padding: 15,
    justifyContent: "space-between",
  },
  infoContainer: {
    flex: 1,
    flexDirection: "row",
    marginBottom: 15,
  },
  imageSection: {
    flex: 1,
    marginRight: 15,
    borderRadius: 16,
    overflow: "hidden",
    borderWidth: 2,
    borderColor: "rgba(0,0,0,0.1)",
    backgroundColor: "#fff",
    shadowColor: "#000",
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.2,
    shadowRadius: 8,
    elevation: 8,
  },
  structureImage: {
    width: "100%",
    height: "100%",
    borderRadius: 16,
  },
  funFactSection: {
    flex: 1,
    justifyContent: "center",
    paddingLeft: 10,
  },
  funFact: {
    fontSize: 22,
    lineHeight: 30,
    fontWeight: "500",
  },

  navContainer: {
    flexDirection: "row",
    justifyContent: "space-around",
    alignItems: "center",
    marginTop: 15,
  },
  navButton: {
    width: 45,
    height: 45,
    justifyContent: "center",
    alignItems: "center",
    borderRadius: 12,
    shadowColor: "#000",
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.2,
    shadowRadius: 3,
    elevation: 4,
  },
  learnMoreButton: {
    flex: 1,
    marginHorizontal: 20,
    height: 45,
    justifyContent: "center",
    alignItems: "center",
    borderRadius: 12,
    shadowColor: "#000",
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.2,
    shadowRadius: 3,
    elevation: 4,
  },
  learnMoreText: {
    fontSize: 18,
    fontWeight: "600",
  },

  // Utility components
  closeButton: {
    position: "absolute",
    top: 15,
    right: 15,
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: "#fff",
    justifyContent: "center",
    alignItems: "center",
    shadowColor: "#000",
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
  },
  closeButtonInner: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: "#fff",
    justifyContent: "center",
    alignItems: "center",
  },
});
