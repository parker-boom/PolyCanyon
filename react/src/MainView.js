import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
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
        tabBarStyle: {
          height: 60,  // Increase height for easier tapping
          paddingBottom: 5,
        },
      }}
    >
      <Tab.Screen 
        name="Map" 
        component={MapView} 
        options={{
          tabBarButton: (props) => (
            <TouchableOpacity
              {...props}
              onPress={() => {
                console.log('Map Tab Pressed');
                props.onPress();
              }}
            />
          ),
        }}
      />
      <Tab.Screen 
        name="Detail" 
        component={DetailView}
        options={{
          tabBarButton: (props) => (
            <TouchableOpacity
              {...props}
              onPress={() => {
                console.log('Detail Tab Pressed');
                props.onPress();
              }}
            />
          ),
        }}
      />
      <Tab.Screen 
        name="Settings" 
        component={SettingView}
        options={{
          tabBarButton: (props) => (
            <TouchableOpacity
              {...props}
              onPress={() => {
                console.log('Settings Tab Pressed');
                props.onPress();
              }}
            />
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