import React, { useEffect, useState } from "react";
import { createBottomTabNavigator } from "@react-navigation/bottom-tabs";
import { createStackNavigator } from "@react-navigation/stack";
import DetailView from "./Detail/DetailView";
import MapView from "./Map/MapView";
import SettingsView from "./Settings/SettingView";
import StructPopUp from "./Shared/StructPopUp";
import VisitedStructurePopup from "./Shared/VisitedPopUp";
import { useDarkMode } from "../Core/States/DarkMode";
import { useDataStore } from "../Core/Data/DataStore";
import { useAppState } from "../Core/States/AppState";
import { useAdventureMode } from "../Core/States/AdventureMode";
import ModeSelectionPopup from "./Shared/ModeSelectionPopup";
import { useNavigation } from "@react-navigation/native";
import TabBar from "./Shared/TabBar";
import VirtualTour from "./Map/VirtualTour";

const Tab = createBottomTabNavigator();
const Stack = createStackNavigator();

// TabNavigator component for main app tabs
const TabNavigator = () => {
  const { isDarkMode } = useDarkMode();

  return (
    <Tab.Navigator
      tabBar={(props) => <TabBar {...props} isDarkMode={isDarkMode} />}
      screenOptions={{
        headerShown: false,
      }}
    >
      <Tab.Screen name="Map" component={MapView} />
      <Tab.Screen name="Detail" component={DetailView} />
      <Tab.Screen name="Settings" component={SettingsView} />
    </Tab.Navigator>
  );
};

const MainView = () => {
  const { isDarkMode } = useDarkMode();
  const { adventureMode, updateAdventureMode } = useAdventureMode();
  const {
    isModeSelectionVisible,
    hideModeSelectionPopup,
    setSelectedStructure,
    visitedPopupVisible,
    hideVisitedPopup,
    selectedStructure,
  } = useAppState();
  const { getStructure } = useDataStore();
  const navigation = useNavigation();
  const [selectedMode, setSelectedMode] = useState(adventureMode);

  // Open struct pop up when Learn More is clicked
  const handleStructurePress = (structure) => {
    console.log(
      "MainView - Opening structure detail for number:",
      structure.number
    );
    hideVisitedPopup();
    setSelectedStructure(structure.number);
    navigation.navigate("StructureDetail");
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
        {/* NEW: VirtualTour screen as a full-screen view */}
        <Stack.Screen
          name="VirtualTour"
          component={VirtualTour}
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
