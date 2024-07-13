import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { View, Text, StyleSheet } from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons'; 
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
      screenOptions={({ route }) => ({
        headerShown: false,
        tabBarStyle: {
          height: 75,
          paddingBottom: 5,
        },
        tabBarShowLabel: false,
        tabBarActiveTintColor: 'black',  
        tabBarInactiveTintColor: 'black',  
        tabBarIcon: ({ focused, color, size }) => {
          let iconName;
          if (route.name === 'Map') {
            iconName = focused ? 'map' : 'map-outline';  
          } else if (route.name === 'Detail') {
            iconName = focused ? 'information-circle' : 'information-circle-outline';  
          } else if (route.name === 'Settings') {
            iconName = focused ? 'settings' : 'settings-outline';  
          }
          return <Ionicons name={iconName} size={40} color={color} />;
        },
      })}
    >
      <Tab.Screen 
        name="Map" 
        component={MapView} 
      />
      <Tab.Screen 
        name="Detail" 
        component={DetailView}
      />
      <Tab.Screen 
        name="Settings" 
        component={SettingView}
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
