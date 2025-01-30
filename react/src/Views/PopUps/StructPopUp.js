// MARK: - StructPopUp Component
/**
 * StructPopUp Component
 *
 * This component displays a detailed popup view for a structure in a React Native app.
 * It provides an interactive and visually appealing interface for users to explore
 * structure details.
 *
 * Key Features:
 * - Swipeable image gallery with main and close-up images
 * - Animated information panel with structure details
 * - Dark mode support
 * - Like/favorite functionality
 * - Dismissible popup with gesture support
 * - Adaptive layout for different image aspect ratios
 * - Fun fact animation
 */

import React, { useState, useEffect } from "react";
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Dimensions,
  ScrollView,
  Platform,
  UIManager,
  Image,
} from "react-native";
import Ionicons from "react-native-vector-icons/Ionicons";
import FastImage from "react-native-fast-image";
import { BlurView } from "@react-native-community/blur";
import { LinearGradient } from "react-native-linear-gradient";
import { useNavigation } from "@react-navigation/native";
import { useDataStore } from "../../Core/Data/DataStore";
import { useAppState } from "../../Core/States/AppState";
import { useDarkMode } from "../../Core/States/DarkMode";
import { getImageSource } from "../../Core/Images/ImageRegistry";

if (
  Platform.OS === "android" &&
  UIManager.setLayoutAnimationEnabledExperimental
) {
  UIManager.setLayoutAnimationEnabledExperimental(true);
}

const { width, height } = Dimensions.get("window");

const StructPopUp = () => {
  // Hooks
  const navigation = useNavigation();
  const { isDarkMode } = useDarkMode();
  const { selectedStructure, setSelectedStructure } = useAppState();
  const { getStructure, toggleStructureLiked } = useDataStore();

  // Local state
  const [isShowingInfo, setIsShowingInfo] = useState(false);
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const [imageAspectRatios, setImageAspectRatios] = useState({});

  // Get the full structure data using just the number
  const structure = getStructure(selectedStructure);

  console.log("StructPopUp: getting structure", selectedStructure, structure);

  useEffect(() => {
    if (!structure) {
      navigation.goBack();
      return;
    }

    // Load aspect ratios for all images
    structure.images.forEach((imageKey, index) => {
      const image = Image.resolveAssetSource(getImageSource(imageKey));
      setImageAspectRatios((prev) => ({
        ...prev,
        [imageKey]: image.width / image.height,
      }));
    });
  }, [structure]);

  const handleClose = () => {
    setSelectedStructure(null);
    navigation.goBack();
  };

  const handleFavoriteToggle = () => {
    toggleStructureLiked(structure.number);
  };

  // Component render methods...
  const renderImageSection = () => (
    <View style={styles.imageSection}>
      <ScrollView
        horizontal
        pagingEnabled
        showsHorizontalScrollIndicator={false}
        onMomentumScrollEnd={(event) => {
          const newIndex = Math.round(
            event.nativeEvent.contentOffset.x / width
          );
          setCurrentImageIndex(newIndex);
        }}
      >
        {structure.images.map((imageKey, index) => {
          const aspectRatio = imageAspectRatios[imageKey] || 1;
          const isLandscape = aspectRatio > 1;
          const imageStyle = isLandscape
            ? { width: width, height: width / aspectRatio }
            : { height: height, width: height * aspectRatio };

          return (
            <View key={imageKey} style={styles.imageContainer}>
              {isLandscape && (
                <BlurView
                  style={StyleSheet.absoluteFill}
                  blurType={isDarkMode ? "dark" : "light"}
                  blurAmount={10}
                >
                  <FastImage
                    source={getImageSource(imageKey)}
                    style={[StyleSheet.absoluteFill, { opacity: 0.5 }]}
                  />
                </BlurView>
              )}
              <FastImage
                source={getImageSource(imageKey)}
                style={[styles.image, imageStyle]}
                resizeMode="contain"
              />
            </View>
          );
        })}
      </ScrollView>

      {/* Image dots indicator */}
      <View style={styles.imageDots}>
        {structure.images.map((_, index) => (
          <View
            key={index}
            style={[
              styles.dot,
              currentImageIndex === index && styles.activeDot,
            ]}
          />
        ))}
      </View>

      <View style={styles.overlayContent}>
        <TouchableOpacity style={styles.dismissButton} onPress={handleClose}>
          <Ionicons name="close-circle-outline" size={30} color="white" />
        </TouchableOpacity>
        <View style={styles.structureInfo}>
          <Text style={[styles.structureNumber, styles.textShadow]}>
            {structure.number}
          </Text>
          <Text style={[styles.structureTitle, styles.textShadow]}>
            {structure.title}
          </Text>
        </View>
      </View>

      <TouchableOpacity style={styles.heartIcon} onPress={handleFavoriteToggle}>
        <Ionicons
          name={structure.isLiked ? "heart" : "heart-outline"}
          size={40}
          color={structure.isLiked ? "red" : "white"}
        />
      </TouchableOpacity>
    </View>
  );

  const renderInformationPanel = () => (
    <View style={styles.informationPanel}>
      <View style={styles.infoHeader}>
        <Text
          style={[
            styles.infoHeaderNumber,
            { color: isDarkMode ? "#FFFFFF" : "#000000" },
          ]}
        >
          {structure.number}
        </Text>
        <View style={styles.infoHeaderTitleContainer}>
          <Text style={[styles.infoHeaderTitle, isDarkMode && styles.darkText]}>
            {structure.title}
          </Text>
          {structure.year !== "xxxx" && (
            <Text
              style={[styles.infoHeaderYear, isDarkMode && styles.darkText]}
            >
              {structure.year}
            </Text>
          )}
        </View>
      </View>

      <ScrollView style={styles.infoScrollView}>
        {structure.builders !== "iii" && (
          <InfoSection
            icon="👷"
            title="Builders"
            value={structure.builders}
            isDarkMode={isDarkMode}
          />
        )}
        <InfoSection
          icon="✨"
          title="Fun Fact"
          value={structure["fun fact"]}
          isDarkMode={isDarkMode}
        />
        <InfoSection
          icon="📖"
          title="Description"
          value={structure.description}
          isDarkMode={isDarkMode}
        />
      </ScrollView>
    </View>
  );

  // Early return if no structure
  if (!structure) return null;

  return (
    <View style={[styles.container, isDarkMode && styles.darkContainer]}>
      {isShowingInfo ? renderInformationPanel() : renderImageSection()}
      <TouchableOpacity
        style={[styles.infoButton, isDarkMode && styles.darkInfoButton]}
        onPress={() => setIsShowingInfo(!isShowingInfo)}
      >
        <Text style={[styles.infoButtonText, isDarkMode && styles.darkText]}>
          {isShowingInfo ? "Images" : "Information"}
        </Text>
        <Ionicons
          name={isShowingInfo ? "image" : "information-circle"}
          size={24}
          color={isDarkMode ? "white" : "black"}
        />
      </TouchableOpacity>
    </View>
  );
};

// InfoSection component for information panel
const InfoSection = ({ icon, title, value, isDarkMode }) => (
  <View style={[styles.infoSection, isDarkMode && styles.darkInfoSection]}>
    <View style={styles.infoSectionHeader}>
      <Text style={styles.infoSectionIcon}>{icon}</Text>
      <Text style={[styles.infoSectionTitle, isDarkMode && styles.darkText]}>
        {title}
      </Text>
    </View>
    <Text style={[styles.infoSectionValue, isDarkMode && styles.darkText]}>
      {value}
    </Text>
  </View>
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "white",
  },
  darkContainer: {
    backgroundColor: "#121212",
  },
  imageSection: {
    flex: 1,
    borderRadius: 10,
    overflow: "hidden",
  },
  imageContainer: {
    width: width - 20,
    height: height - 80, // Subtract space for info button and padding
    justifyContent: "center",
    alignItems: "center",
    borderRadius: 10,
    overflow: "hidden",
  },
  image: {
    // The width and height will be set dynamically
  },
  overlayContent: {
    ...StyleSheet.absoluteFillObject,
    padding: 20,
    justifyContent: "space-between",
  },
  dismissButton: {
    alignSelf: "flex-end",
  },
  structureInfo: {
    alignItems: "flex-start",
  },
  textShadow: {
    textShadowColor: "rgba(0, 0, 0, 0.75)",
    textShadowOffset: { width: -1, height: 1 },
    textShadowRadius: 10,
  },
  structureNumber: {
    fontSize: 40,
    fontWeight: "bold",
    color: "white",
    marginBottom: 5,
  },
  structureTitle: {
    fontSize: 30,
    fontWeight: "600",
    color: "white",
  },
  imageDots: {
    flexDirection: "row",
    position: "absolute",
    bottom: 20,
    right: 20,
  },
  dot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: "rgba(255, 255, 255, 0.5)",
    marginHorizontal: 4,
  },
  activeDot: {
    backgroundColor: "white",
    width: 10,
    height: 10,
    borderRadius: 5,
  },
  infoButton: {
    flexDirection: "row",
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "rgba(200, 200, 200, 0.3)",
    borderRadius: 15,
    padding: 15,
    marginHorizontal: 15,
    marginVertical: 10,
    marginBottom: 20, // Added bottom padding
  },
  darkInfoButton: {
    backgroundColor: "rgba(100, 100, 100, 0.3)",
  },
  infoButtonText: {
    fontSize: 18,
    fontWeight: "600",
    marginRight: 10,
  },
  darkText: {
    color: "white",
  },
  informationPanel: {
    flex: 1,
    padding: 10,
  },
  infoHeader: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    marginBottom: 20,
  },
  infoHeaderNumber: {
    fontSize: 28,
    fontWeight: "bold",
  },
  infoHeaderTitleContainer: {
    flex: 1,
    alignItems: "center",
  },
  infoHeaderTitle: {
    fontSize: 22,
    fontWeight: "700",
    textAlign: "center",
  },
  infoHeaderYear: {
    fontSize: 18,
    fontWeight: "600",
    marginTop: 0,
  },
  infoScrollView: {
    flex: 1,
  },
  infoSection: {
    backgroundColor: "#F2F2F7",
    borderRadius: 15,
    padding: 15,
    marginBottom: 15,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  infoSectionHeader: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: 5,
  },
  infoSectionIcon: {
    fontSize: 20,
    marginRight: 10,
    textShadowColor: "rgba(0, 0, 0, 0.3)",
    textShadowOffset: { width: 1, height: 1 },
    textShadowRadius: 2,
  },
  infoSectionTitle: {
    fontSize: 16,
    fontWeight: "600",
    color: "#666666",
  },
  infoSectionValue: {
    fontSize: 18,
    fontWeight: "400",
    color: "#000000",
  },
  darkInfoSection: {
    backgroundColor: "#2C2C2E",
  },
  heartIcon: {
    position: "absolute",
    bottom: 50, // Positioned just above the image dots
    right: 20,
    zIndex: 10,
  },
});

export default StructPopUp;
