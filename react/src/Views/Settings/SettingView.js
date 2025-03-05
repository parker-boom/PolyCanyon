import React from "react";
import {
  View,
  Text,
  Switch,
  TouchableOpacity,
  Alert,
  ScrollView,
} from "react-native";
import { useDarkMode } from "../../Core/States/DarkMode";
import { useAdventureMode } from "../../Core/States/AdventureMode";
import { useDataStore } from "../../Core/Data/DataStore";
import { useAppState } from "../../Core/States/AppState";
import { useLocationService } from "../../Core/Location/LocationService";
import { useRoute } from "@react-navigation/native";
import Ionicons from "react-native-vector-icons/Ionicons";
import AsyncStorage from "@react-native-async-storage/async-storage";
import styles from "./SettingsStyles";

// Helper to check if we're in Design Village event window
const isInEventWindow = () => {
  const createLocalDate = (dateString) => {
    const [year, month, day] = dateString.split("-").map(Number);
    return new Date(year, month - 1, day, 0, 0, 0);
  };

  const eventStartDate = createLocalDate("2025-04-25");
  const eventEndDate = createLocalDate("2025-04-28");
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  return today >= eventStartDate && today < eventEndDate;
};

const SettingsView = () => {
  const route = useRoute();
  const { setDesignVillageMode } = route.params || {};

  // Context hooks
  const { isDarkMode, toggleDarkMode } = useDarkMode();
  const { adventureMode, updateAdventureMode } = useAdventureMode();
  const { resetStructures } = useDataStore();
  const { showModeSelectionPopup, resetVisitedStructures } = useAppState();
  const { requestLocationPermission } = useLocationService();

  // Event Handlers
  const handleToggleMode = () => {
    showModeSelectionPopup();
  };

  const handleResetData = () => {
    Alert.alert(
      adventureMode
        ? "Reset All Visited Structures"
        : "Reset Favorite Structures",
      `Are you sure you want to reset all ${
        adventureMode ? "visited" : "favorite"
      } structures?`,
      [
        { text: "Cancel", style: "cancel" },
        {
          text: "Yes",
          onPress: () => {
            resetVisitedStructures();
            resetStructures();
          },
        },
      ]
    );
  };

  const openLocationSettings = async () => {
    if (adventureMode) {
      await requestLocationPermission(true);
    } else {
      Alert.alert(
        "Location Not Required",
        "Location tracking is not needed in Virtual Tour Mode. Switch to Adventure Mode to use location features."
      );
    }
  };

  const handleDesignVillageSwitch = () => {
    Alert.alert(
      "Switch to Design Village?",
      "Would you like to switch to the Design Village experience?",
      [
        { text: "Cancel", style: "cancel" },
        {
          text: "Switch",
          onPress: async () => {
            try {
              // Just remove the override - RootRouter will handle the switch
              await AsyncStorage.removeItem("designVillageModeOverride");
            } catch (error) {
              console.error("Error switching app mode:", error);
            }
          },
        },
      ]
    );
  };

  return (
    <ScrollView
      style={[styles.container, isDarkMode && styles.darkContainer]}
      contentContainerStyle={styles.contentContainer}
    >
      {/* Design Village Switch - Only shown during event window */}
      {isInEventWindow() && (
        <View style={[styles.section, isDarkMode && styles.darkSection]}>
          <View style={styles.sectionHeaderContainer}>
            <Text style={[styles.sectionHeader, isDarkMode && styles.darkText]}>
              Design Village 2025
            </Text>
            <Ionicons
              name="home"
              size={24}
              color={isDarkMode ? "#F5F5F5" : "#333"}
              style={styles.sectionIcon}
            />
          </View>
          <TouchableOpacity
            style={[styles.dvButton, isDarkMode && styles.darkDvButton]}
            onPress={handleDesignVillageSwitch}
          >
            <Text style={[styles.dvButtonText, isDarkMode && styles.darkText]}>
              Switch to Design Village Mode
            </Text>
          </TouchableOpacity>
        </View>
      )}

      {/* General Settings Section */}
      <View style={[styles.section, isDarkMode && styles.darkSection]}>
        <View style={styles.sectionHeaderContainer}>
          <Text style={[styles.sectionHeader, isDarkMode && styles.darkText]}>
            General Settings
          </Text>
          <Ionicons
            name="settings-outline"
            size={24}
            color={isDarkMode ? "#F5F5F5" : "#333"}
            style={styles.sectionIcon}
          />
        </View>

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
        <View
          style={[
            styles.modeSelectionContainer,
            isDarkMode && styles.darkModeSelectionContainer,
          ]}
        >
          <View style={styles.modeSection}>
            <Ionicons
              name={adventureMode ? "walk" : "search"}
              size={40}
              color={
                adventureMode
                  ? isDarkMode
                    ? "#6ECF76"
                    : "#4CAF50"
                  : isDarkMode
                  ? "#FFA347"
                  : "#FF6803"
              }
            />
            <Text style={[styles.modeTitle, isDarkMode && styles.darkText]}>
              {adventureMode ? "Adventure Mode" : "Virtual Tour Mode"}
            </Text>
            <Text
              style={[
                styles.modeDescription,
                isDarkMode && styles.darkModeDescription,
              ]}
            >
              {adventureMode
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
        </View>

        {/* Mode-specific Action Buttons */}
        <View style={styles.buttonContainer}>
          <SettingsButton
            onPress={handleResetData}
            icon={adventureMode ? "refresh" : "heart-dislike"}
            text={adventureMode ? "Reset Structures" : "Reset Favorites"}
            color={isDarkMode ? "#FF6B6B" : "red"}
            isDarkMode={isDarkMode}
          />
          {adventureMode && (
            <SettingsButton
              onPress={openLocationSettings}
              icon="location"
              text="Location Settings"
              color={isDarkMode ? "#6ECF76" : "green"}
              isDarkMode={isDarkMode}
            />
          )}
        </View>
      </View>

      {/* Credits Section */}
      <View style={[styles.section, isDarkMode && styles.darkSection]}>
        <View style={styles.sectionHeaderContainer}>
          <Text style={[styles.sectionHeader, isDarkMode && styles.darkText]}>
            Credits
          </Text>
          <Ionicons
            name="information-circle-outline"
            size={24}
            color={isDarkMode ? "#F5F5F5" : "#333"}
            style={styles.sectionIcon}
          />
        </View>
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
          Please email bug reports or issues to pjones15@calpoly.edu, thanks in
          advance!
        </Text>
      </View>
    </ScrollView>
  );
};

// Helper Component
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
