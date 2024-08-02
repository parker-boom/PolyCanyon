// MARK: - ContentView Component
/**
 * ContentView Component
 * 
 * This component serves as the main entry point of the application.
 * It checks if the app is being launched for the first time and conditionally 
 * renders the onboarding view or the main navigation container.
 * 
 * Features:
 * - Checks for first launch using AsyncStorage
 * - Displays onboarding view on first launch
 * - Wraps the app with various providers for state management
 * - Uses the NavigationContainer for navigation between views
 */

import React, { useEffect, useState } from 'react';
import { View } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import OnboardingView from './OnboardingView';
import MainView from './MainView';
import { NavigationContainer } from '@react-navigation/native';
import { StructureProvider } from './StructureData'; 
import { MapPointsProvider } from './MapPoint';
import { DarkModeProvider } from './DarkMode';

const ContentView = () => {
  // MARK: - State Variables
  const [isFirstLaunch, setIsFirstLaunch] = useState(true);

  // MARK: - Effects
  useEffect(() => {
    // Check if the app is being launched for the first time
    const checkFirstLaunch = async () => {
      try {
        const value = await AsyncStorage.getItem('isFirstLaunch');
        if (value !== null) {
          setIsFirstLaunch(false);
        }
      } catch (error) {
        console.log('Error checking first launch:', error);
      }
    };

    checkFirstLaunch();
  }, []);

  // MARK: - Handlers
  const handleOnboardingComplete = () => {
    setIsFirstLaunch(false);
    AsyncStorage.setItem('isFirstLaunch', 'false');
  };

  // MARK: - Render
  return (
    <DarkModeProvider>
      <StructureProvider>
        <MapPointsProvider>
          <View style={{ flex: 1, backgroundColor: isFirstLaunch ? 'lightblue' : 'lightgreen' }}>
            {isFirstLaunch ? (
              <OnboardingView onComplete={handleOnboardingComplete} />
            ) : (
              <NavigationContainer>
                <MainView />
              </NavigationContainer>
            )}
          </View>
        </MapPointsProvider>
      </StructureProvider>
    </DarkModeProvider>
  );
};

export default ContentView;
