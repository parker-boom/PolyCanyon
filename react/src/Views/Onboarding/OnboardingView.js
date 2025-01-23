import React, { useState, useEffect } from "react";
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Image,
  Animated,
  Dimensions,
} from "react-native";
import Swiper from "react-native-swiper";
import Ionicons from "react-native-vector-icons/Ionicons";
import AsyncStorage from "@react-native-async-storage/async-storage";
import {
  requestLocationPermission,
  getCurrentLocation,
  isNearSanLuisObispo,
} from "../OldData/OnboardingLocationManager";
import { useAdventureMode } from "../../Core/States/AdventureModeContext";

const { width, height } = Dimensions.get("window");

// Main component
const OnboardingView = ({ onComplete }) => {
  // State management
  const [currentPage, setCurrentPage] = useState(0);
  const [hasAskedForLocation, setHasAskedForLocation] = useState(false);
  const [isAdventureModeRecommended, setIsAdventureModeRecommended] =
    useState(false);
  const [isAdventureModeEnabled, setIsAdventureModeEnabled] = useState(false);
  const { updateAdventureMode } = useAdventureMode();

  // Color constants
  const adventureModeColor = "#4CAF50";
  const virtualTourColor = "#FF6803";

  // Handle location permission and determine if Adventure Mode is recommended
  const handleLocationPermission = async () => {
    const permissionGranted = await requestLocationPermission();
    setHasAskedForLocation(true);

    if (permissionGranted) {
      try {
        const position = await getCurrentLocation();
        const nearSLO = isNearSanLuisObispo(position);
        setIsAdventureModeRecommended(nearSLO);
        setIsAdventureModeEnabled(nearSLO);
      } catch (error) {
        console.error("Error getting location:", error);
        setIsAdventureModeRecommended(false);
        setIsAdventureModeEnabled(false);
      }
    } else {
      setIsAdventureModeRecommended(false);
      setIsAdventureModeEnabled(false);
    }
  };

  // Complete onboarding and save Adventure Mode preference
  const handleComplete = async () => {
    await AsyncStorage.setItem(
      "adventureMode",
      JSON.stringify(isAdventureModeEnabled)
    );
    updateAdventureMode(isAdventureModeEnabled);
    onComplete();
  };

  // Render individual slides
  const renderWelcomeSlide = () => (
    <View style={styles.slide}>
      <Image source={require("../../assets/icon.jpg")} style={styles.icon} />
      <View style={styles.titleContainer}>
        <Text style={styles.title}>Welcome to</Text>
        <Text style={[styles.title, styles.greenTitle, styles.boldTitle]}>
          Poly Canyon
        </Text>
      </View>
      <Text style={[styles.subtitle, styles.largerSubtitle]}>
        Explore and learn about Cal Poly's famous architectural structures
      </Text>
      <View style={styles.bottomButtonContainer}>
        {renderNavigationButton("Next", () => setCurrentPage(1))}
      </View>
    </View>
  );

  const renderLocationRequestSlide = () => (
    <View style={styles.slide}>
      <PulsingLocationDot />
      <View style={styles.titleContainer}>
        <Text style={styles.title}>Enable</Text>
        <Text style={[styles.title, styles.blueTitle, styles.boldTitle]}>
          Location Services
        </Text>
      </View>
      <Text style={[styles.subtitle, styles.largerSubtitle]}>
        We need your location to enhance your experience
      </Text>
      {!hasAskedForLocation ? (
        renderNavigationButton(
          "Allow Location Access",
          handleLocationPermission
        )
      ) : (
        <View style={styles.bottomButtonContainer}>
          {renderNavigationButton("Next", () => setCurrentPage(2))}
        </View>
      )}
    </View>
  );

  const renderModeSelectionSlide = () => (
    <View style={styles.slide}>
      <Text style={[styles.title, styles.grayTitle, styles.largerTitle]}>
        Choose Your Experience
      </Text>
      <View style={styles.iconSpacing}>
        <ModeIcon
          name={isAdventureModeEnabled ? "walk" : "search"}
          color={isAdventureModeEnabled ? adventureModeColor : virtualTourColor}
        />
      </View>
      <CustomModePicker
        isAdventureModeEnabled={isAdventureModeEnabled}
        setIsAdventureModeEnabled={setIsAdventureModeEnabled}
        adventureModeColor={adventureModeColor}
        virtualTourColor={virtualTourColor}
      />
      <View style={styles.recommendationSpacing}>
        <RecommendationLabel
          isRecommended={isAdventureModeEnabled === isAdventureModeRecommended}
        />
      </View>
      <View style={styles.centeredFeatureList}>
        {isAdventureModeEnabled ? (
          <>
            <Text style={styles.largerFeatureItem}>
              • Explore structures in person
            </Text>
            <Text style={styles.largerFeatureItem}>• Track your progress</Text>
            <Text style={styles.largerFeatureItem}>• Use live location</Text>
          </>
        ) : (
          <>
            <Text style={styles.largerFeatureItem}>• Browse remotely</Text>
            <Text style={styles.largerFeatureItem}>
              • Learn about all structures
            </Text>
            <Text style={styles.largerFeatureItem}>• No location needed</Text>
          </>
        )}
      </View>
      <View style={styles.bottomButtonContainer}>
        <TouchableOpacity
          style={[
            styles.completeButton,
            {
              backgroundColor: isAdventureModeEnabled
                ? adventureModeColor
                : virtualTourColor,
            },
          ]}
          onPress={handleComplete}
        >
          <Text style={styles.completeButtonText}>Let's Go!</Text>
        </TouchableOpacity>
      </View>
    </View>
  );

  // Custom components for Mode Selection slide
  const ModeIcon = ({ name, color }) => (
    <View style={[styles.modeIcon, { backgroundColor: color }]}>
      <Ionicons name={name} size={40} color="white" />
    </View>
  );

  const CustomModePicker = ({
    isAdventureModeEnabled,
    setIsAdventureModeEnabled,
    adventureModeColor,
    virtualTourColor,
  }) => (
    <View style={styles.modePicker}>
      <TouchableOpacity
        style={[
          styles.modeButton,
          !isAdventureModeEnabled && styles.selectedMode,
        ]}
        onPress={() => setIsAdventureModeEnabled(false)}
      >
        <Text
          style={[
            styles.modeButtonText,
            !isAdventureModeEnabled && { color: virtualTourColor },
          ]}
        >
          Virtual Tour
        </Text>
      </TouchableOpacity>
      <TouchableOpacity
        style={[
          styles.modeButton,
          isAdventureModeEnabled && styles.selectedMode,
        ]}
        onPress={() => setIsAdventureModeEnabled(true)}
      >
        <Text
          style={[
            styles.modeButtonText,
            isAdventureModeEnabled && { color: adventureModeColor },
          ]}
        >
          Adventure
        </Text>
      </TouchableOpacity>
    </View>
  );

  const RecommendationLabel = ({ isRecommended }) => (
    <View
      style={[
        styles.recommendationLabel,
        { backgroundColor: isRecommended ? "#4CAF50" : "#FF5722" },
      ]}
    >
      <Ionicons
        name={isRecommended ? "checkmark-circle" : "close-circle"}
        size={20}
        color="white"
      />
      <Text style={styles.recommendationText}>
        {isRecommended ? "Recommended" : "Not Recommended"}
      </Text>
    </View>
  );

  // Animated location dot component
  const PulsingLocationDot = () => {
    const pulseAnim = new Animated.Value(1);

    useEffect(() => {
      Animated.loop(
        Animated.sequence([
          Animated.timing(pulseAnim, {
            toValue: 1.2,
            duration: 1000,
            useNativeDriver: true,
          }),
          Animated.timing(pulseAnim, {
            toValue: 1,
            duration: 1000,
            useNativeDriver: true,
          }),
        ])
      ).start();
    }, []);

    return (
      <View style={styles.pulsingDotContainer}>
        <Animated.View
          style={[styles.pulsingDot, { transform: [{ scale: pulseAnim }] }]}
        />
        <View style={styles.largerInnerDot} />
      </View>
    );
  };

  // Navigation button component
  const renderNavigationButton = (text, onPress) => (
    <TouchableOpacity style={styles.navigationButton} onPress={onPress}>
      <Text style={styles.navigationButtonText}>{text}</Text>
      <Ionicons name="chevron-forward" size={24} color="white" />
    </TouchableOpacity>
  );

  // Main render method
  return (
    <View style={styles.container}>
      <Swiper
        loop={false}
        showsPagination={true}
        index={currentPage}
        onIndexChanged={setCurrentPage}
        paginationStyle={styles.pagination}
        dotStyle={styles.dot}
        activeDotStyle={styles.activeDot}
      >
        {renderWelcomeSlide()}
        {renderLocationRequestSlide()}
        {renderModeSelectionSlide()}
      </Swiper>
    </View>
  );
};

export default OnboardingView;
