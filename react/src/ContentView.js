// ContentView.js
import React, { useEffect, useState } from 'react';
import { View } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import OnboardingView from './OnboardingView';
import MainView from './MainView';
import { NavigationContainer } from '@react-navigation/native';
import { StructureProvider } from './StructureData'; // Correct import of the provider

const ContentView = () => {
  const [isFirstLaunch, setIsFirstLaunch] = useState(true);

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
    <StructureProvider>
      <View style={{ flex: 1, backgroundColor: isFirstLaunch ? 'lightblue' : 'lightgreen' }}>
        {isFirstLaunch ? (
          <OnboardingView onComplete={handleOnboardingComplete} />
        ) : (
          <NavigationContainer>
            <MainView />
          </NavigationContainer>
        )}
      </View>
    </StructureProvider>
  );
};

export default ContentView;
