import React, { useEffect, useState } from "react";
import { View } from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";
import OnboardingView from "./Views/Onboarding/OnboardingView";
import MainView from "./Views/MainView";
import { NavigationContainer } from "@react-navigation/native";
import { DarkModeProvider } from "./Core/States/DarkMode";
import { DataStoreProvider } from "./Core/Data/DataStore";
import { AdventureModeProvider } from "./Core/States/AdventureMode";
import { LocationServiceProvider } from "./Core/Location/LocationService";
import { AppStateProvider, useAppState } from "./Core/States/AppState";

// Separate component for app content that uses AppState
const AppContent = () => {
  const [isLoading, setIsLoading] = useState(true);
  const [isFirstLaunch, setIsFirstLaunch] = useState(false);
  const { setIsOnboardingCompleted } = useAppState();

  useEffect(() => {
    checkOnboardingStatus();
  }, []);

  const checkOnboardingStatus = async () => {
    try {
      // Look for a key that indicates the user finished onboarding.
      const value = await AsyncStorage.getItem("onboardingCompleted");
      const onboardingCompleted = value === "true";
      // If not completed, it’s the first launch (or incomplete onboarding).
      setIsFirstLaunch(!onboardingCompleted);
      setIsOnboardingCompleted(onboardingCompleted);
      setIsLoading(false);
    } catch (error) {
      console.log("Error checking onboarding status:", error);
      setIsLoading(false);
    }
  };

  const handleOnboardingComplete = () => {
    // When onboarding is complete, mark it in state and persist that fact.
    setIsFirstLaunch(false);
    setIsOnboardingCompleted(true);
    AsyncStorage.setItem("onboardingCompleted", "true");
  };

  if (isLoading) {
    return null;
  }

  return (
    <View style={{ flex: 1 }}>
      {isFirstLaunch ? (
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
