import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { View, Text, StyleSheet } from 'react-native';

const Tab = createBottomTabNavigator();

const MapView = () => (
  <View style={styles.mapView}>
    <Text style={styles.debugText}>Map View</Text>
  </View>
);

const DetailView = () => (
  <View style={styles.detailView}>
    <Text style={styles.debugText}>Detail View</Text>
  </View>
);

const SettingView = () => (
  <View style={styles.settingView}>
    <Text style={styles.debugText}>Settings View</Text>
  </View>
);

const MainView = () => {
  return (
    <Tab.Navigator>
      <Tab.Screen name="Map" component={MapView} />
      <Tab.Screen name="Detail" component={DetailView} />
      <Tab.Screen name="Settings" component={SettingView} />
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
  detailView: {
    flex: 1,
    backgroundColor: 'lightseagreen',
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
