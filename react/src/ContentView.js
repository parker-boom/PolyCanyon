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
 * - Manages the global adventure mode state
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
  const [isFirstLaunchV2, setIsFirstLaunchV2] = useState(true);
  const [adventureMode, setAdventureMode] = useState(true);

  useEffect(() => {
    checkFirstLaunchV2();
    loadAdventureMode();
  }, []);

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

  const loadAdventureMode = async () => {
    try {
      const value = await AsyncStorage.getItem('adventureMode');
      if (value !== null) {
        setAdventureMode(JSON.parse(value));
      }
    } catch (error) {
      console.log('Error loading adventure mode:', error);
    }
  };

  const handleOnboardingComplete = () => {
    setIsFirstLaunchV2(false);
    AsyncStorage.setItem('isFirstLaunchV2', 'false');
  };

  const handleSetAdventureMode = async (newMode) => {
    setAdventureMode(newMode);
    try {
      await AsyncStorage.setItem('adventureMode', JSON.stringify(newMode));
    } catch (error) {
      console.log('Error saving adventure mode:', error);
    }
  };

  return (
    <DarkModeProvider>
      <StructureProvider>
        <MapPointsProvider>
          <View style={{ flex: 1 }}>
            {isFirstLaunchV2 ? (
              <OnboardingView
                onComplete={handleOnboardingComplete}
                setAdventureModeGlobal={handleSetAdventureMode}
              />
            ) : (
              <NavigationContainer>
                <MainView 
                  adventureMode={adventureMode} 
                  setAdventureMode={handleSetAdventureMode} 
                />
              </NavigationContainer>
            )}
          </View>
        </MapPointsProvider>
      </StructureProvider>
    </DarkModeProvider>
  );
};

export default ContentView;
