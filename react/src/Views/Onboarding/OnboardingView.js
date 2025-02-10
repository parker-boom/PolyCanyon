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
import { useLocationService } from "../../Core/Location/LocationService";
import { useAdventureMode } from "../../Core/States/AdventureMode";
import { useAppState } from "../../Core/States/AppState";
import Geolocation from "@react-native-community/geolocation";
import styles from "./OnboardingStyles";

const { width, height } = Dimensions.get("window");

// Location state enum to match SwiftUI version
const OnboardingLocationState = {
  NO_LOCATION: "noLocation",
  NOT_COMING: "notComing",
  NOT_VISITING: "notVisiting",
  VISITING: "visiting",
};

// Main component
const OnboardingView = ({ onComplete }) => {
  // State management
  const [currentPage, setCurrentPage] = useState(0);
  const [locationState, setLocationState] = useState(
    OnboardingLocationState.NO_LOCATION
  );
  const [hasLocationPermission, setHasLocationPermission] = useState(false);
  const {
    requestLocationPermission,
    getDistanceToCanyon,
    isWithinCanyon,
    fetchCurrentLocation,
  } = useLocationService();
  const { updateAdventureMode } = useAdventureMode();
  const { setSelectedStructure } = useAppState();

  // Color constants
  const adventureModeColor = "#4CAF50";
  const virtualTourColor = "#FF6803";

  // Add at the top with other constants
  const DISTANCE_THRESHOLDS = {
    ONBOARDING_RECOMMENDATION: 48280, // 30 miles in meters
  };

  // Handle location permission and determine if Adventure Mode is recommended
  const handleLocationPermission = async () => {
    const permissionGranted = await requestLocationPermission(false);
    setHasLocationPermission(permissionGranted);

    if (permissionGranted) {
      try {
        // Use the one‑off fetch function to get the location now:
        const location = await fetchCurrentLocation();
        console.log("Fetched location for onboarding:", location);
        if (location && isWithinCanyon(location.coords)) {
          console.log("User is in canyon");
          setLocationState(OnboardingLocationState.VISITING);
        } else if (location) {
          const distance = getDistanceToCanyon(location.coords);
          console.log("Distance to canyon:", distance);
          if (distance <= DISTANCE_THRESHOLDS.ONBOARDING_RECOMMENDATION) {
            console.log("User is within 30 miles");
            setLocationState(OnboardingLocationState.NOT_VISITING);
          } else {
            console.log("User is far away");
            setLocationState(OnboardingLocationState.NOT_COMING);
          }
        } else {
          console.log("No location returned");
          setLocationState(OnboardingLocationState.NO_LOCATION);
        }
      } catch (error) {
        console.error("Error fetching location during onboarding:", error);
        setLocationState(OnboardingLocationState.NO_LOCATION);
      }
    } else {
      console.log("Permission denied for location");
      setLocationState(OnboardingLocationState.NO_LOCATION);
    }
  };

  // Add a separate handler for background permission
  const handleBackgroundPermission = async () => {
    const backgroundPermissionGranted = await requestLocationPermission(true);
    // You can handle the result if needed
    return backgroundPermissionGranted;
  };

  // Complete onboarding and save Adventure Mode preference
  const handleComplete = async () => {
    const isAdventureModeRecommended = [
      OnboardingLocationState.VISITING,
      OnboardingLocationState.NOT_VISITING,
    ].includes(locationState);

    await AsyncStorage.setItem(
      "adventureMode",
      JSON.stringify(isAdventureModeRecommended)
    );
    updateAdventureMode(isAdventureModeRecommended);
    await AsyncStorage.setItem("isFirstLaunchV2", "false");
    onComplete();
  };

  // Render individual slides
  const renderWelcomeSlide = () => (
    <View style={styles.slide}>
      <Image source={require("../../assets/icon.jpg")} style={styles.icon} />
      <Text style={styles.title}>Time to discover</Text>
      <Text style={[styles.title, styles.greenTitle]}>Poly Canyon</Text>
      <Text style={styles.subtitle}>
        Before you start exploring, let's get things ready.
      </Text>
      {renderNavigationButton("Next", () => setCurrentPage(1))}
    </View>
  );

  const renderLocationRequestSlide = () => (
    <View style={styles.slide}>
      <Text style={styles.title}>First, we need</Text>
      <Text style={[styles.title, styles.blueTitle]}>your location</Text>
      <PulsingLocationDot />
      <Text style={styles.subtitle}>
        This helps us know if you're visiting the canyon
      </Text>
      {!hasLocationPermission
        ? renderNavigationButton("Enable Location", handleLocationPermission)
        : renderNavigationButton("Next", () => setCurrentPage(2))}
    </View>
  );

  const renderModeSelectionSlide = () => (
    <View style={styles.slide}>
      <Text style={styles.title}>
        {locationState === OnboardingLocationState.VISITING
          ? "You're here!"
          : locationState === OnboardingLocationState.NOT_VISITING
          ? "Planning to visit?"
          : "Let's explore virtually"}
      </Text>
      <ModeIcon
        name={
          locationState === OnboardingLocationState.VISITING ||
          locationState === OnboardingLocationState.NOT_VISITING
            ? "walk"
            : "search"
        }
        color={
          locationState === OnboardingLocationState.VISITING ||
          locationState === OnboardingLocationState.NOT_VISITING
            ? adventureModeColor
            : virtualTourColor
        }
      />
      <Text style={styles.subtitle}>
        {locationState === OnboardingLocationState.VISITING
          ? "Since you're already in the canyon, let's get you set up for an in-person adventure!"
          : locationState === OnboardingLocationState.NOT_VISITING
          ? "You're close enough to visit! Let's set you up for an in-person adventure."
          : "Since you're far from the canyon, we'll set you up for virtual exploration."}
      </Text>
      {renderNavigationButton("Next", () => setCurrentPage(3))}
    </View>
  );

  const renderModeFollowUpSlide = () => (
    <View style={styles.slide}>
      <Text style={styles.title}>
        {locationState === OnboardingLocationState.VISITING ||
        locationState === OnboardingLocationState.NOT_VISITING
          ? "Let's auto track"
          : "Best ways to"}
      </Text>
      <Text
        style={[
          styles.title,
          styles.coloredTitle,
          {
            color:
              locationState === OnboardingLocationState.VISITING ||
              locationState === OnboardingLocationState.NOT_VISITING
                ? adventureModeColor
                : virtualTourColor,
          },
        ]}
      >
        {locationState === OnboardingLocationState.VISITING ||
        locationState === OnboardingLocationState.NOT_VISITING
          ? "Your Adventure:"
          : "Virtually Explore:"}
      </Text>
      {locationState === OnboardingLocationState.VISITING ||
      locationState === OnboardingLocationState.NOT_VISITING ? (
        <>
          <AdventureFeaturesList />
          <TouchableOpacity
            style={[
              styles.backgroundLocationButton,
              { backgroundColor: adventureModeColor },
            ]}
            onPress={handleBackgroundPermission}
          >
            <Ionicons
              name="location"
              size={20}
              color="white"
              style={{ marginRight: 8 }}
            />
            <Text style={styles.backgroundLocationButtonText}>
              Enable Background Location
            </Text>
          </TouchableOpacity>
        </>
      ) : (
        <VirtualFeaturesList />
      )}
      {renderNavigationButton("Next", () => setCurrentPage(4))}
    </View>
  );

  const renderFinalSlide = () => (
    <View style={styles.finalSlide}>
      <View
        style={[
          styles.finalSlideBackground,
          {
            backgroundColor:
              locationState === OnboardingLocationState.VISITING ||
              locationState === OnboardingLocationState.NOT_VISITING
                ? adventureModeColor
                : virtualTourColor,
          },
        ]}
      />
      <View style={{ alignItems: "center" }}>
        <Text style={[styles.title, { marginBottom: 10 }]}>
          You're all set!
        </Text>
        <Text style={[styles.subtitle, { marginBottom: 40 }]}>
          {locationState === OnboardingLocationState.VISITING ||
          locationState === OnboardingLocationState.NOT_VISITING
            ? "Time to explore the canyon"
            : "Time to learn about the canyon"}
        </Text>
        <TouchableOpacity
          style={[
            styles.completeButton,
            {
              backgroundColor:
                locationState === OnboardingLocationState.VISITING ||
                locationState === OnboardingLocationState.NOT_VISITING
                  ? adventureModeColor
                  : virtualTourColor,
              width: 200,
              alignItems: "center",
            },
          ]}
          onPress={handleComplete}
        >
          <Text style={styles.completeButtonText}>Begin</Text>
        </TouchableOpacity>
      </View>
    </View>
  );

  // Custom components for Mode Selection slide
  const ModeIcon = ({ name, color }) => (
    <View style={[styles.modeIcon, { backgroundColor: color }]}>
      <Ionicons
        name={name === "search" ? "search" : "walk"}
        size={40}
        color="white"
      />
    </View>
  );

  const VirtualFeaturesList = () => (
    <View style={styles.featureList}>
      <Text style={styles.featureItem}>
        • Take a virtual tour of the canyon
      </Text>
      <Text style={styles.featureItem}>
        • Uncover key details about structures
      </Text>
      <Text style={styles.featureItem}>
        • Mark your favorites as you explore
      </Text>
    </View>
  );

  const AdventureFeaturesList = () => (
    <View style={styles.featureList}>
      <Text style={styles.featureItem}>
        • Auto-track your visited structures
      </Text>
      <Text style={styles.featureItem}>• Get real-time distance updates</Text>
      <Text style={styles.featureItem}>• Earn achievements as you explore</Text>
    </View>
  );

  // Animated location dot component
  const PulsingLocationDot = () => {
    const pulseAnim = new Animated.Value(1);

    useEffect(() => {
      const animation = Animated.loop(
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
      );

      animation.start();

      return () => {
        animation.stop();
      };
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
    <View style={styles.bottomButtonContainer}>
      <TouchableOpacity style={styles.navigationButton} onPress={onPress}>
        <Text style={styles.navigationButtonText}>{text}</Text>
        <Ionicons name="chevron-forward" size={24} color="white" />
      </TouchableOpacity>
      {currentPage > 0 && (
        <TouchableOpacity
          style={styles.backButton}
          onPress={() => setCurrentPage(currentPage - 1)}
        >
          <Text style={styles.backButtonText}>Back</Text>
        </TouchableOpacity>
      )}
    </View>
  );

  // Main render method
  return (
    <View style={styles.container}>
      <Swiper
        loop={false}
        showsPagination={true}
        index={currentPage}
        onIndexChanged={setCurrentPage}
        scrollEnabled={false}
        paginationStyle={styles.pagination}
        dotStyle={styles.dot}
        activeDotStyle={styles.activeDot}
        removeClippedSubviews={false}
      >
        {renderWelcomeSlide()}
        {renderLocationRequestSlide()}
        {renderModeSelectionSlide()}
        {renderModeFollowUpSlide()}
        {renderFinalSlide()}
      </Swiper>
    </View>
  );
};

export default OnboardingView;
