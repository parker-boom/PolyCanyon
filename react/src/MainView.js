// MARK: - MainView Component
/**
 * MainView Component
 *
 * This component sets up the bottom tab navigation for the app, including Map, Detail, and Settings views.
 * It dynamically adjusts the tab bar appearance based on dark mode settings.
 * The component utilizes various contexts and hooks for state management (mapPoints, darkMode, adventureMode).
 * It employs the 'screenOptions' approach for configuring the tab bar, ensuring a consistent look across the app.
 */

import React from "react";
import { createBottomTabNavigator } from "@react-navigation/bottom-tabs";
import Ionicons from "react-native-vector-icons/Ionicons";
import DetailView from "./Views/Detail/DetailView";
import MapView from "./Views/Map/MapView";
import SettingsView from "./Views/Settings/SettingView";
import { useMapPoints } from "./OldData/MapPoint";
import { DarkModeProvider, useDarkMode } from "./Core/States/DarkMode";
import { useAdventureMode } from "./Core/States/AdventureModeContext";

const Tab = createBottomTabNavigator();

const MainView = () => {
  // MARK: - Hooks
  // Access shared state and context
  const { mapPoints } = useMapPoints();
  const { isDarkMode } = useDarkMode();
  const { adventureMode } = useAdventureMode();

  // MARK: - Tab Bar Configuration
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

  // MARK: - Tab Navigator
  return (
    <Tab.Navigator screenOptions={screenOptions}>
      {/* Map Tab */}
      <Tab.Screen
        name="Map"
        component={MapView}
        initialParams={{ mapPoints, adventureMode }}
      />
      {/* Detail Tab */}
      <Tab.Screen
        name="Detail"
        component={DetailView}
        initialParams={{ mapPoints, adventureMode }}
      />
      {/* Settings Tab */}
      <Tab.Screen name="Settings" component={SettingsView} />
    </Tab.Navigator>
  );
};

// MARK: - DarkMode Wrapper
// Ensure DarkMode context is available throughout the app
const WrappedMainView = () => (
  <DarkModeProvider>
    <MainView />
  </DarkModeProvider>
);

export default WrappedMainView;
