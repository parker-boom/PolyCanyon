import React, { useEffect, useState } from 'react';
import { View } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import OnboardingView from './OnboardingView';
import MainView from './MainView';
import { NavigationContainer } from '@react-navigation/native';

const ContentView = () => {
  const [isFirstLaunch, setIsFirstLaunch] = useState(true);
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [isAdventureModeEnabled, setIsAdventureModeEnabled] = useState(true);

  useEffect(() => {
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

  const handleOnboardingComplete = () => {
    setIsFirstLaunch(false);
    AsyncStorage.setItem('isFirstLaunch', 'false');
  };

  return (
    <View style={{ flex: 1 }}>
      {isFirstLaunch ? (
        <OnboardingView onOnboardingComplete={handleOnboardingComplete} />
      ) : (
        <NavigationContainer>
        <MainView
          isDarkMode={isDarkMode}
          isAdventureModeEnabled={isAdventureModeEnabled}
        />
        </NavigationContainer>
      )}
    </View>
  );
};

export default ContentView;