// MARK: - SettingsView Component
/**
 * SettingsView Component
 *
 * This component represents the settings screen of the application.
 * It provides a user interface for managing various app settings and preferences.
 *
 * Key Features:
 * - Dark mode toggle
 * - Adventure/Virtual Tour mode switch with explanatory UI
 * - Mode-specific actions (Reset visited/favorited structures, Location settings, Rate structures)
 * - Credits section
 * - Integration with custom hooks for state management
 * - Popup components for mode selection and structure rating
 */

import React, { useState, useCallback, useEffect } from "react";
import {
  View,
  Text,
  Switch,
  TouchableOpacity,
  Alert,
  Linking,
  StyleSheet,
  ScrollView,
} from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { useStructures } from "../../OldData/StructureData";
import { useMapPoints } from "../../OldData/MapPoint";
import { useDarkMode } from "../../Core/States/DarkMode";
import Ionicons from "react-native-vector-icons/Ionicons";
import ModeSelectionPopup from "../../PopUps/ModeSelectionPopup";
import { useAdventureMode } from "../../Core/States/AdventureModeContext";
import {
  useLocation,
  requestLocationPermission,
} from "../../OldData/LocationManager";
import RatingPopup from "../../PopUps/RatingPopup";

const SettingsView = () => {
  // MARK: - State and Hooks
  const { adventureMode, updateAdventureMode } = useAdventureMode();
  const { isDarkMode, toggleDarkMode } = useDarkMode();
  const { resetVisitedStructures, resetFavoritedStructures } = useStructures();
  const { resetVisitedMapPoints } = useMapPoints();
  const [showModePopup, setShowModePopup] = useState(false);
  const [localAdventureMode, setLocalAdventureMode] = useState(adventureMode);
  const [showRatingPopup, setShowRatingPopup] = useState(false);
  const [ratingIndex, setRatingIndex] = useState(0);

  // Sync local state with global adventure mode
  useEffect(() => {
    setLocalAdventureMode(adventureMode);
  }, [adventureMode]);

  // Use location hook for Adventure mode
  useLocation((error, position) => {
    if (adventureMode && !error && position) {
      // Update any location-dependent state or perform actions
    }
  });

  // MARK: - Event Handlers
  const handleToggleMode = () => {
    setShowModePopup(true);
  };

  const handleModeSelection = useCallback((newMode) => {
    setLocalAdventureMode(newMode);
  }, []);

  const handleConfirmModeChange = useCallback(() => {
    if (localAdventureMode !== adventureMode) {
      updateAdventureMode(localAdventureMode);
    }
    setShowModePopup(false);
  }, [localAdventureMode, adventureMode, updateAdventureMode]);

  // Handler for resetting visited structures
  const handleResetVisitedStructures = () => {
    Alert.alert(
      "Reset All Visited Structures",
      "Are you sure you want to reset all visited structures?",
      [
        { text: "Cancel", style: "cancel" },
        {
          text: "Yes",
          onPress: () => {
            resetVisitedStructures();
            resetVisitedMapPoints();
          },
        },
      ]
    );
  };

  const handleResetFavoritedStructures = () => {
    Alert.alert(
      "Reset Favorite Structures",
      "Are you sure you want to reset all favorite structures?",
      [
        { text: "Cancel", style: "cancel" },
        {
          text: "Yes",
          onPress: () => {
            resetFavoritedStructures();
          },
        },
      ]
    );
  };

  const handleRateStructures = () => {
    setShowRatingPopup(true);
  };

  const handleCloseRatingPopup = () => {
    setShowRatingPopup(false);
  };

  // Handler for opening location settings
  const openLocationSettings = () => {
    if (adventureMode) {
      requestLocationPermission();
    } else {
      Alert.alert(
        "Location Not Required",
        "Location tracking is not needed in Virtual Tour Mode. Switch to Adventure Mode to use location features."
      );
    }
  };

  // MARK: - Render
  return (
    <>
      <ScrollView
        style={[styles.container, isDarkMode && styles.darkContainer]}
      >
        {/* General Settings Section */}
        <View style={[styles.section, isDarkMode && styles.darkSection]}>
          <Text style={[styles.sectionHeader, isDarkMode && styles.darkText]}>
            General Settings
          </Text>

          {/* Dark Mode Toggle */}
          <View style={styles.settingItem}>
            <Text style={[styles.settingText, isDarkMode && styles.darkText]}>
              Dark Mode
            </Text>
            <Switch
              value={isDarkMode}
              onValueChange={toggleDarkMode}
              trackColor={{ false: "#767577", true: "#81b0ff" }}
              thumbColor={isDarkMode ? "#f5dd4b" : "#f4f3f4"}
            />
          </View>

          {/* Mode Selection UI */}
          <View style={styles.modeSection}>
            <Ionicons
              name={localAdventureMode ? "walk" : "search"}
              size={40}
              color={
                localAdventureMode
                  ? isDarkMode
                    ? "#6ECF76"
                    : "#4CAF50"
                  : isDarkMode
                  ? "#FFA347"
                  : "#FF6803"
              }
            />
            <Text style={[styles.modeTitle, isDarkMode && styles.darkText]}>
              {localAdventureMode ? "Adventure Mode" : "Virtual Tour Mode"}
            </Text>
            <Text
              style={[
                styles.modeDescription,
                isDarkMode && styles.darkModeDescription,
              ]}
            >
              {localAdventureMode
                ? "Explore structures in person"
                : "Browse structures remotely"}
            </Text>
            <TouchableOpacity
              style={[
                styles.switchButton,
                isDarkMode && styles.darkSwitchButton,
              ]}
              onPress={handleToggleMode}
            >
              <Text style={styles.switchButtonText}>Switch</Text>
            </TouchableOpacity>
          </View>

          {/* Mode-specific Action Buttons */}
          <View style={styles.buttonContainer}>
            {adventureMode ? (
              <>
                <SettingsButton
                  onPress={handleResetVisitedStructures}
                  icon="refresh"
                  text="Reset Structures"
                  color={isDarkMode ? "#FF6B6B" : "red"}
                  isDarkMode={isDarkMode}
                />
                <SettingsButton
                  onPress={openLocationSettings}
                  icon="location"
                  text="Location Settings"
                  color={isDarkMode ? "#6ECF76" : "green"}
                  isDarkMode={isDarkMode}
                />
              </>
            ) : (
              <>
                <SettingsButton
                  onPress={handleResetFavoritedStructures}
                  icon="heart-dislike"
                  text="Reset Favorites"
                  color={isDarkMode ? "#FF6B6B" : "red"}
                  isDarkMode={isDarkMode}
                />
                <SettingsButton
                  onPress={handleRateStructures}
                  icon="heart"
                  text="Rate Structures"
                  color={isDarkMode ? "#FF6B6B" : "red"}
                  isDarkMode={isDarkMode}
                />
              </>
            )}
          </View>
        </View>

        {/* Credits Section */}
        <View style={[styles.section, isDarkMode && styles.darkSection]}>
          <Text style={[styles.sectionHeader, isDarkMode && styles.darkText]}>
            Credits
          </Text>
          <Text style={[styles.creditText, isDarkMode && styles.darkText]}>
            Parker Jones
          </Text>
          <Text style={[styles.creditText, isDarkMode && styles.darkText]}>
            Cal Poly SLO
          </Text>
          <Text style={[styles.creditText, isDarkMode && styles.darkText]}>
            CAED College & Department
          </Text>
          <Text style={[styles.caption, isDarkMode && styles.darkCaption]}>
            Please email bug reports or issues to pjones15@calpoly.edu, thanks
            in advance!
          </Text>
        </View>
      </ScrollView>
      <ModeSelectionPopup
        isVisible={showModePopup}
        onSelect={handleModeSelection}
        onConfirm={handleConfirmModeChange}
        currentMode={localAdventureMode}
        selectedMode={localAdventureMode}
        isDarkMode={isDarkMode}
      />
      <RatingPopup
        isVisible={showRatingPopup}
        onClose={handleCloseRatingPopup}
        isDarkMode={isDarkMode}
      />
    </>
  );
};

// MARK: - Helper Components
const SettingsButton = ({ onPress, icon, text, color, isDarkMode }) => (
  <TouchableOpacity
    style={[styles.settingsButton, isDarkMode && styles.darkSettingsButton]}
    onPress={onPress}
  >
    <Ionicons name={icon} size={24} color={color} />
    <Text style={[styles.settingsButtonText, isDarkMode && styles.darkText]}>
      {text}
    </Text>
  </TouchableOpacity>
);

export default SettingsView;
