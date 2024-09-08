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

import React, { useEffect, useState } from 'react';
import { View } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import OnboardingView from './Onboarding/OnboardingView';
import MainView from './MainView';
import { NavigationContainer } from '@react-navigation/native';
import { StructureProvider } from './Data/StructureData'; 
import { MapPointsProvider } from './Data/MapPoint';
import { DarkModeProvider } from './States/DarkMode';
import { AdventureModeProvider } from './States/AdventureModeContext';

const ContentView = () => {
  // State to track if this is the app's first launch
  const [isFirstLaunchV2, setIsFirstLaunchV2] = useState(true);

  // Check first launch status when component mounts
  useEffect(() => {
    checkFirstLaunchV2();
  }, []);

  // Function to check if this is the app's first launch
  const checkFirstLaunchV2 = async () => {
    try {
      const value = await AsyncStorage.getItem('isFirstLaunchV2');
      if (value !== null) {
        setIsFirstLaunchV2(false);
      }
    } catch (error) {
      console.log('Error checking first launch V2:', error);
    }
  };

  // Function to handle completion of onboarding
  const handleOnboardingComplete = () => {
    setIsFirstLaunchV2(false);
    AsyncStorage.setItem('isFirstLaunchV2', 'false');
  };

  return (
    // Wrap the app in various context providers for global state management
    <DarkModeProvider>
      <StructureProvider>
        <MapPointsProvider>
          <AdventureModeProvider>
            <View style={{ flex: 1 }}>
              {isFirstLaunchV2 ? (
                // Show onboarding view if it's the first launch
                <OnboardingView
                  onComplete={handleOnboardingComplete}
                />
              ) : (
                // Show main app content if it's not the first launch
                <NavigationContainer>
                  <MainView />
                </NavigationContainer>
              )}
            </View>
          </AdventureModeProvider>
        </MapPointsProvider>
      </StructureProvider>
    </DarkModeProvider>
  );
};

export default ContentView;
