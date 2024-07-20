import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { View, Text, StyleSheet } from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';
import DetailView from './DetailView';
import MapView from './MapView';
import SettingsView from './SettingView';
import { useMapPoints } from './MapPoint';

const Tab = createBottomTabNavigator();

const MainView = () => {
    const { mapPoints } = useMapPoints();

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
                initialParams={{ mapPoints }}
            />
            <Tab.Screen
                name="Detail"
                component={DetailView}
                initialParams={{ mapPoints }}
            />
            <Tab.Screen
                name="Settings"
                component={SettingsView}
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
