// MARK: - MainView Component
/**
 * MainView Component
 * 
 * This component sets up the bottom tab navigation for the app.
 * It includes tabs for Map, Detail, and Settings views.
 * The component now responds to dark mode changes, updating the tab bar appearance accordingly.
 * It uses the recommended 'screenOptions' approach for configuring the tab bar.
 */

import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import Ionicons from 'react-native-vector-icons/Ionicons';
import DetailView from './DetailView';
import MapView from './MapView';
import SettingsView from './SettingView';
import { useMapPoints } from './MapPoint';
import { DarkModeProvider, useDarkMode } from './DarkMode';
import { useAdventureMode } from './AdventureModeContext';

const Tab = createBottomTabNavigator();

const MainView = () => {
    const { mapPoints } = useMapPoints();
    const { isDarkMode } = useDarkMode();
    const { adventureMode } = useAdventureMode();

    // MARK: - Screen Options
    const screenOptions = ({ route }) => ({
        headerShown: false,
        tabBarShowLabel: false,
        tabBarActiveTintColor: isDarkMode ? '#ffffff' : '#000000',
        tabBarInactiveTintColor: isDarkMode ? '#888888' : '#555555',
        tabBarStyle: {
            height: 75,
            paddingBottom: 5,
            backgroundColor: isDarkMode ? '#121212' : '#ffffff',
            borderTopColor: isDarkMode ? '#2c2c2e' : '#e0e0e0',
        },
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
    });

    return (
        <Tab.Navigator screenOptions={screenOptions}>
            <Tab.Screen
                name="Map"
                component={MapView}
                initialParams={{ mapPoints, adventureMode }}
            />
            <Tab.Screen
                name="Detail"
                component={DetailView}
                initialParams={{ mapPoints, adventureMode }}
            />
            <Tab.Screen
                name="Settings"
                component={SettingsView}
            />
        </Tab.Navigator>
    );
};

// MARK: - Wrapped MainView with DarkModeProvider
const WrappedMainView = () => (
    <DarkModeProvider>
        <MainView />
    </DarkModeProvider>
);

export default WrappedMainView;