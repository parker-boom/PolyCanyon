import React, { useEffect, useState } from 'react';
import { View } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import OnboardingView from './OnboardingView';
import MainView from './MainView';
import { NavigationContainer } from '@react-navigation/native';
import { StructureProvider } from './StructureData'; 
import mapPointsData from './mapPoints.json';

const ContentView = () => {
  const [isFirstLaunch, setIsFirstLaunch] = useState(true);
  const [mapPoints, setMapPoints] = useState([]);

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

    // Process map points
    const processedData = mapPointsData.map(point => ({
      ...point,
      landmark: point.landmark === null ? -1 : point.landmark
    }));
    setMapPoints(processedData);
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
            <MainView mapPoints={mapPoints} />
          </NavigationContainer>
        )}
      </View>
    </StructureProvider>
  );
};

export default ContentView;