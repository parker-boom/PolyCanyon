import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Image, Animated, Dimensions } from 'react-native';
import Swiper from 'react-native-swiper';
import Ionicons from 'react-native-vector-icons/Ionicons';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { requestLocationPermission, getCurrentLocation, isNearSanLuisObispo } from './OnboardingLocationManager';
import { useAdventureMode } from './AdventureModeContext';

const { width, height } = Dimensions.get('window');

const OnboardingView = ({ onComplete }) => {
  const [currentPage, setCurrentPage] = useState(0);
  const [hasAskedForLocation, setHasAskedForLocation] = useState(false);
  const [isAdventureModeRecommended, setIsAdventureModeRecommended] = useState(false);
  const [isAdventureModeEnabled, setIsAdventureModeEnabled] = useState(false);
  const { updateAdventureMode } = useAdventureMode();

  const adventureModeColor = '#4CAF50';
  const virtualTourColor = '#FF6803';

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
        console.error('Error getting location:', error);
        setIsAdventureModeRecommended(false);
        setIsAdventureModeEnabled(false);
      }
    } else {
      setIsAdventureModeRecommended(false);
      setIsAdventureModeEnabled(false);
    }
  };

  const handleComplete = async () => {
    await AsyncStorage.setItem('adventureMode', JSON.stringify(isAdventureModeEnabled));
    updateAdventureMode(isAdventureModeEnabled);
    onComplete(); // This will mark onboarding as complete and move to MainView
  };

  const renderWelcomeSlide = () => (
    <View style={styles.slide}>
      <Image source={require('../assets/icon.jpg')} style={styles.icon} />
      <View style={styles.titleContainer}>
        <Text style={styles.title}>Welcome to</Text>
        <Text style={[styles.title, styles.greenTitle, styles.boldTitle]}>Poly Canyon</Text>
      </View>
      <Text style={[styles.subtitle, styles.largerSubtitle]}>Explore and learn about Cal Poly's famous architectural structures</Text>
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
        <Text style={[styles.title, styles.blueTitle, styles.boldTitle]}>Location Services</Text>
      </View>
      <Text style={[styles.subtitle, styles.largerSubtitle]}>We need your location to enhance your experience</Text>
      {!hasAskedForLocation ? (
        renderNavigationButton("Allow Location Access", handleLocationPermission)
      ) : (
        <View style={styles.bottomButtonContainer}>
          {renderNavigationButton("Next", () => setCurrentPage(2))}
        </View>
      )}
    </View>
  );

  const renderModeSelectionSlide = () => (
    <View style={styles.slide}>
      <Text style={[styles.title, styles.grayTitle, styles.largerTitle]}>Choose Your Experience</Text>
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
        <RecommendationLabel isRecommended={isAdventureModeEnabled === isAdventureModeRecommended} />
      </View>
      <View style={styles.centeredFeatureList}>
        {isAdventureModeEnabled ? (
          <>
            <Text style={styles.largerFeatureItem}>• Explore structures in person</Text>
            <Text style={styles.largerFeatureItem}>• Track your progress</Text>
            <Text style={styles.largerFeatureItem}>• Use live location</Text>
          </>
        ) : (
          <>
            <Text style={styles.largerFeatureItem}>• Browse remotely</Text>
            <Text style={styles.largerFeatureItem}>• Learn about all structures</Text>
            <Text style={styles.largerFeatureItem}>• No location needed</Text>
          </>
        )}
      </View>
      <View style={styles.bottomButtonContainer}>
        <TouchableOpacity
          style={[styles.completeButton, { backgroundColor: isAdventureModeEnabled ? adventureModeColor : virtualTourColor }]}
          onPress={handleComplete}
        >
          <Text style={styles.completeButtonText}>Let's Go!</Text>
        </TouchableOpacity>
      </View>
    </View>
  );

  const ModeIcon = ({ name, color }) => (
    <View style={[styles.modeIcon, { backgroundColor: color }]}>
      <Ionicons name={name} size={40} color="white" />
    </View>
  );

  const CustomModePicker = ({ isAdventureModeEnabled, setIsAdventureModeEnabled, adventureModeColor, virtualTourColor }) => (
    <View style={styles.modePicker}>
      <TouchableOpacity
        style={[styles.modeButton, !isAdventureModeEnabled && styles.selectedMode]}
        onPress={() => setIsAdventureModeEnabled(false)}
      >
        <Text style={[styles.modeButtonText, !isAdventureModeEnabled && { color: virtualTourColor }]}>Virtual Tour</Text>
      </TouchableOpacity>
      <TouchableOpacity
        style={[styles.modeButton, isAdventureModeEnabled && styles.selectedMode]}
        onPress={() => setIsAdventureModeEnabled(true)}
      >
        <Text style={[styles.modeButtonText, isAdventureModeEnabled && { color: adventureModeColor }]}>Adventure</Text>
      </TouchableOpacity>
    </View>
  );

  const RecommendationLabel = ({ isRecommended }) => (
    <View style={[styles.recommendationLabel, { backgroundColor: isRecommended ? '#4CAF50' : '#FF5722' }]}>
      <Ionicons name={isRecommended ? "checkmark-circle" : "close-circle"} size={20} color="white" />
      <Text style={styles.recommendationText}>{isRecommended ? "Recommended" : "Not Recommended"}</Text>
    </View>
  );

  const PulsingLocationDot = () => {
    const pulseAnim = new Animated.Value(1);

    useEffect(() => {
      Animated.loop(
        Animated.sequence([
          Animated.timing(pulseAnim, { toValue: 1.2, duration: 1000, useNativeDriver: true }),
          Animated.timing(pulseAnim, { toValue: 1, duration: 1000, useNativeDriver: true })
        ])
      ).start();
    }, []);

    return (
      <View style={styles.pulsingDotContainer}>
        <Animated.View style={[styles.pulsingDot, { transform: [{ scale: pulseAnim }] }]} />
        <View style={styles.largerInnerDot} />
      </View>
    );
  };

  const renderNavigationButton = (text, onPress) => (
    <TouchableOpacity style={styles.navigationButton} onPress={onPress}>
      <Text style={styles.navigationButtonText}>{text}</Text>
      <Ionicons name="chevron-forward" size={24} color="white" />
    </TouchableOpacity>
  );

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

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'white',
  },
  slide: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  icon: {
    width: 180,  // Increased size
    height: 180, // Increased size
    marginTop: 40,    // Less padding on top
    marginBottom: 20, // Less padding on bottom
    borderRadius: 36, // Adjusted for larger size
  },
  titleContainer: {
    marginBottom: 10,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    textAlign: 'center',
  },
  blackTitle: {
    color: 'black',
  },
  largerTitle: {
    fontSize: 36,
  },
  boldTitle: {
    fontWeight: '900',
  },
  greenTitle: {
    color: '#4CAF50',
  },
  blueTitle: {
    color: '#2196F3',
  },
  subtitle: {
    fontSize: 18,
    textAlign: 'center',
    marginBottom: 30,
    color: '#666',
  },
  largerSubtitle: {
    fontSize: 20,
  },
  modeIcon: {
    width: 80,
    height: 80,
    borderRadius: 40,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 20,
  },
  modePicker: {
    flexDirection: 'row',
    backgroundColor: '#f0f0f0',
    borderRadius: 25,
    marginBottom: 20,
  },
  modeButton: {
    paddingVertical: 10,
    paddingHorizontal: 20,
    borderRadius: 25,
  },
  selectedMode: {
    backgroundColor: 'white',
  },
  modeButtonText: {
    fontSize: 16,
    fontWeight: 'bold',
  },
  recommendationLabel: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 5,
    paddingHorizontal: 10,
    borderRadius: 15,
    marginBottom: 20,
  },
  recommendationText: {
    color: 'white',
    marginLeft: 5,
    fontWeight: 'bold',
  },
  featureList: {
    alignSelf: 'stretch',
    marginBottom: 30,
  },
  featureItem: {
    fontSize: 16,
    marginBottom: 10,
  },
  completeButton: {
    paddingVertical: 12,
    paddingHorizontal: 30,
    borderRadius: 25,
  },
  completeButtonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
  },
  pulsingDotContainer: {
    width: 100,
    height: 100,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 30, // Added spacing below the circle
  },
  pulsingDot: {
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: 'rgba(33, 150, 243, 0.3)',
    position: 'absolute',
  },
  largerInnerDot: {
    width: 70,
    height: 70,
    borderRadius: 35,
    backgroundColor: '#2196F3',
  },
  navigationButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#2196F3',
    paddingVertical: 10,
    paddingHorizontal: 20,
    borderRadius: 25,
    marginBottom: 30
  },
  navigationButtonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
    marginRight: 10,
  },
  pagination: {
    bottom: 20,
  },
  dot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: '#bbb',
    margin: 3,
  },
  activeDot: {
    backgroundColor: '#2196F3',
  },
  bottomButtonContainer: {
    position: 'absolute',
    bottom: 60,
    left: 0,
    right: 0,
    alignItems: 'center', // Center horizontally
  },
  iconSpacing: {
    marginVertical: 20,
  },
  recommendationSpacing: {
    marginBottom: 10,
  },
  centeredFeatureList: {
    alignItems: 'center',
    marginBottom: 30,
  },
  largerFeatureItem: {
    fontSize: 18,
    marginBottom: 10,
  },
  grayTitle: {
    color: '#666', // Gray color
  },
});

export default OnboardingView;
