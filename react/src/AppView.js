// MARK: - ContentView Component
/**
 * ContentView Component
 *
 * This component is the root of the application, managing the app's initial launch flow and global state.
 *
 * Key features:
 * - Checks for first launch using AsyncStorage
 * - Conditionally renders onboarding or main app content
 * - Provides global state management through various context providers
 * - Integrates React Navigation for app routing
 */

import React, { useEffect, useState } from "react";
import { View } from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";
import OnboardingView from "./Views/Onboarding/OnboardingView";
import MainView from "./MainView";
import { NavigationContainer } from "@react-navigation/native";
import { DarkModeProvider } from "./Core/States/DarkMode";
import { DataStoreProvider } from "./Core/Data/DataStore";
import { AdventureModeProvider } from "./Core/States/AdventureMode";
import { LocationServiceProvider } from "./Core/Location/LocationService";
import { AppStateProvider, useAppState } from "./Core/States/AppState";

// Separate component for app content that uses AppState
const AppContent = () => {
  const [isLoading, setIsLoading] = useState(true);
  const [isFirstLaunchV2, setIsFirstLaunchV2] = useState(false);
  const { setIsOnboardingCompleted } = useAppState();

  useEffect(() => {
    checkFirstLaunchV2();
  }, []);

  const checkFirstLaunchV2 = async () => {
    try {
      const value = await AsyncStorage.getItem("isFirstLaunchV2");
      const isFirstLaunch = value === null;
      setIsFirstLaunchV2(isFirstLaunch);
      setIsOnboardingCompleted(!isFirstLaunch);
      setIsLoading(false);
    } catch (error) {
      console.log("Error checking first launch V2:", error);
      setIsLoading(false);
    }
  };

  const handleOnboardingComplete = () => {
    setIsFirstLaunchV2(false);
    setIsOnboardingCompleted(true);
    AsyncStorage.setItem("isFirstLaunchV2", "false");
  };

  if (isLoading) {
    return null;
  }

  return (
    <View style={{ flex: 1 }}>
      {isFirstLaunchV2 ? (
        <OnboardingView onComplete={handleOnboardingComplete} />
      ) : (
        <NavigationContainer>
          <MainView />
        </NavigationContainer>
      )}
    </View>
  );
};

// Main ContentView that provides context
const ContentView = () => {
  return (
    <AppStateProvider>
      <DarkModeProvider>
        <DataStoreProvider>
          <AdventureModeProvider>
            <LocationServiceProvider>
              <AppContent />
            </LocationServiceProvider>
          </AdventureModeProvider>
        </DataStoreProvider>
      </DarkModeProvider>
    </AppStateProvider>
  );
};

export default ContentView;
