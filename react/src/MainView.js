// MARK: - MainView Component
/**
 * MainView Component
 *
 * This component sets up the bottom tab navigation for the app, including Map, Detail, and Settings views.
 * It dynamically adjusts the tab bar appearance based on dark mode settings.
 * The component utilizes various contexts and hooks for state management (mapPoints, darkMode, adventureMode).
 * It employs the 'screenOptions' approach for configuring the tab bar, ensuring a consistent look across the app.
 */

import React, { useEffect, useState } from "react";
import { createBottomTabNavigator } from "@react-navigation/bottom-tabs";
import { createStackNavigator } from "@react-navigation/stack";
import Ionicons from "react-native-vector-icons/Ionicons";
import DetailView from "./Views/Detail/DetailView";
import MapView from "./Views/Map/MapView";
import SettingsView from "./Views/Settings/SettingView";
import StructPopUp from "./Views/PopUps/StructPopUp";
import VisitedStructurePopup from "./Views/PopUps/VisitedPopUp";
import { useDarkMode } from "./Core/States/DarkMode";
import { useDataStore } from "./Core/Data/DataStore";
import { useAppState } from "./Core/States/AppState";
import { useAdventureMode } from "./Core/States/AdventureMode";
import ModeSelectionPopup from "./Views/PopUps/ModeSelectionPopup";
import { useNavigation } from "@react-navigation/native";

const Tab = createBottomTabNavigator();
const Stack = createStackNavigator();

// TabNavigator component for main app tabs
const TabNavigator = () => {
  const { isDarkMode } = useDarkMode();

  const screenOptions = ({ route }) => ({
    headerShown: false,
    tabBarShowLabel: false,
    tabBarActiveTintColor: isDarkMode ? "#ffffff" : "#000000",
    tabBarInactiveTintColor: isDarkMode ? "#888888" : "#555555",
    tabBarStyle: {
      height: 75,
      paddingBottom: 5,
      backgroundColor: isDarkMode ? "#121212" : "#ffffff",
      borderTopColor: isDarkMode ? "#2c2c2e" : "#e0e0e0",
    },
    tabBarIcon: ({ focused, color, size }) => {
      let iconName;
      if (route.name === "Map") {
        iconName = focused ? "map" : "map-outline";
      } else if (route.name === "Detail") {
        iconName = focused
          ? "information-circle"
          : "information-circle-outline";
      } else if (route.name === "Settings") {
        iconName = focused ? "settings" : "settings-outline";
      }
      return <Ionicons name={iconName} size={40} color={color} />;
    },
  });

  return (
    <Tab.Navigator screenOptions={screenOptions}>
      <Tab.Screen name="Map" component={MapView} />
      <Tab.Screen name="Detail" component={DetailView} />
      <Tab.Screen name="Settings" component={SettingsView} />
    </Tab.Navigator>
  );
};

const MainView = () => {
  const { isDarkMode } = useDarkMode();
  const { adventureMode, updateAdventureMode } = useAdventureMode();
  const { isModeSelectionVisible, hideModeSelectionPopup } = useAppState();
  const { structures, getStructure } = useDataStore();
  const { visitedPopupVisible, hideVisitedPopup, selectedStructure } =
    useAppState();
  const navigation = useNavigation();
  const [selectedMode, setSelectedMode] = useState(adventureMode);

  // Handle structure selection (this is the SAME logic as DetailView)
  const handleStructurePress = (structure) => {
    console.log("Opening structure detail for number:", structure.number);
    hideVisitedPopup();
    navigation.navigate("StructureDetail"); // That's it! StructPopUp gets the number from selectedStructure
  };

  return (
    <>
      <Stack.Navigator
        screenOptions={{
          headerShown: false,
          presentation: "modal",
        }}
      >
        <Stack.Screen name="TabNavigator" component={TabNavigator} />
        <Stack.Screen
          name="StructureDetail"
          component={StructPopUp}
          options={{
            presentation: "fullScreenModal",
            animation: "slide_from_bottom",
          }}
        />
      </Stack.Navigator>

      {/* Visited Popup overlay */}
      {visitedPopupVisible && selectedStructure && (
        <VisitedStructurePopup
          structure={getStructure(selectedStructure)}
          isPresented={visitedPopupVisible}
          setIsPresented={hideVisitedPopup}
          isDarkMode={isDarkMode}
          onStructurePress={handleStructurePress}
        />
      )}

      {/* Mode selection popup */}
      <ModeSelectionPopup
        isVisible={isModeSelectionVisible}
        onSelect={(mode) => setSelectedMode(mode)}
        onConfirm={() => {
          updateAdventureMode(selectedMode);
          hideModeSelectionPopup();
        }}
        currentMode={adventureMode}
        selectedMode={selectedMode}
        isDarkMode={isDarkMode}
      />
    </>
  );
};

export default MainView;
