import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { View, Text, StyleSheet } from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';  // Import Ionicons
import DetailView from './DetailView';

const Tab = createBottomTabNavigator();

const MapView = () => (
  <View style={styles.mapView}>
    <Text style={styles.debugText}>Map View</Text>
  </View>
);

const SettingView = () => (
  <View style={styles.settingView}>
    <Text style={styles.debugText}>Settings View</Text>
  </View>
);

const MainView = () => {
  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false, 
        tabBarStyle: {
          height: 60,
          paddingBottom: 5,
        },
        tabBarShowLabel: false,  
      }}
    >
      <Tab.Screen 
        name="Map" 
        component={MapView} 
        options={{
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="map-outline" color={color} size={size} />
          ),
        }}
      />
      <Tab.Screen 
        name="Detail" 
        component={DetailView}
        options={{
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="information-circle-outline" color={color} size={size} />
          ),
        }}
      />
      <Tab.Screen 
        name="Settings" 
        component={SettingView}
        options={{
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="settings-outline" color={color} size={size} />
          ),
        }}
      />
    </Tab.Navigator>
  );
};

const styles = StyleSheet.create({
  mapView: {
    flex: 1,
    backgroundColor: 'lightcoral',
    justifyContent: 'center',
    alignItems: 'center',
  },
  settingView: {
    flex: 1,
    backgroundColor: 'lightgoldenrodyellow',
    justifyContent: 'center',
    alignItems: 'center',
  },
  debugText: {
    fontSize: 24,
    color: 'red',
  },
});

export default MainView;