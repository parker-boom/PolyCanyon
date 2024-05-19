import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import MapView from './MapView';
import DetailView from './DetailView';
import SettingView from './SettingView';

const Tab = createBottomTabNavigator();

const MainView = () => {
  return (
    <Tab.Navigator>
      <Tab.Screen name="Map" component={MapView} />
      <Tab.Screen name="Detail" component={DetailView} />
      <Tab.Screen name="Settings" component={SettingView} />
    </Tab.Navigator>
  );
};

export default MainView;