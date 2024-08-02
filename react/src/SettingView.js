// MARK: - SettingsView Component
/**
 * SettingsView Component
 * 
 * This component represents the settings screen of the application.
 * It allows users to toggle dark mode, adventure mode, reset visited structures,
 * and access various information links.
 * 
 * Features:
 * - Dark mode toggle (synced with app-wide context)
 * - Adventure mode toggle
 * - Reset visited structures
 * - Access to location settings
 * - Links to external information
 * - Credits section
 * 
 * The component uses the DarkModeContext for app-wide dark mode state management.
 * The background color and other elements adjust based on Dark Mode settings.
 */

import React, { useState, useEffect } from 'react';
import { 
    View, 
    Text, 
    Switch, 
    TouchableOpacity, 
    Alert, 
    Linking, 
    StyleSheet, 
    ScrollView 
} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useStructures } from './StructureData';
import { useMapPoints } from './MapPoint';
import { useDarkMode } from './DarkMode';

const SettingsView = () => {
    // MARK: - Hooks and Context
    const { isDarkMode, toggleDarkMode } = useDarkMode();
    const { resetVisitedStructures, setAllStructuresAsVisited } = useStructures();
    const { resetVisitedMapPoints } = useMapPoints();
    const [adventureMode, setAdventureMode] = useState(true);

    // MARK: - Effects
    useEffect(() => {
        loadSettings();
    }, []);

    useEffect(() => {
        saveSettings();
    }, [adventureMode]);

    // MARK: - Settings Management
    const loadSettings = async () => {
        try {
            const adventureModeValue = await AsyncStorage.getItem('adventureMode');
            setAdventureMode(adventureModeValue === null ? true : JSON.parse(adventureModeValue));
        } catch (error) {
            console.error('Failed to load settings', error);
        }
    };

    const saveSettings = async () => {
        try {
            await AsyncStorage.setItem('adventureMode', JSON.stringify(adventureMode));
        } catch (error) {
            console.error('Failed to save settings', error);
        }
    };

    // MARK: - Event Handlers
    const handleToggleAdventureMode = (value) => {
        if (!value) {
            Alert.alert(
                "Toggle Adventure Mode Off",
                "This will mark all structures as visited. Are you sure?",
                [
                    { text: "Cancel", style: "cancel" },
                    { 
                        text: "Yes", 
                        onPress: () => {
                            setAllStructuresAsVisited();
                            setAdventureMode(false);
                        } 
                    }
                ]
            );
        } else {
            setAdventureMode(true);
            resetVisitedStructures();
            resetVisitedMapPoints();
        }
    };

    const handleResetVisitedStructures = () => {
        Alert.alert(
            "Reset All Visited Structures",
            "Are you sure you want to reset all visited structures?",
            [
                { text: "Cancel", style: "cancel" },
                { 
                    text: "Yes", 
                    onPress: () => {
                        resetVisitedStructures();
                        resetVisitedMapPoints();
                    } 
                }
            ]
        );
    };

    const openLocationSettings = () => {
        Linking.openSettings();
    };

    // MARK: - Render
    return (
        <ScrollView style={[styles.container, isDarkMode && styles.darkContainer]}>
            <View style={[styles.section, isDarkMode && styles.darkSection]}>
                <Text style={[styles.sectionHeader, isDarkMode && styles.darkText]}>Settings</Text>
                <View style={styles.settingItem}>
                    <Text style={[styles.settingText, isDarkMode && styles.darkText]}>Dark Mode</Text>
                    <Switch
                        value={isDarkMode}
                        onValueChange={toggleDarkMode}
                        trackColor={{ false: "#767577", true: "#81b0ff" }}
                        thumbColor={isDarkMode ? "#f5dd4b" : "#f4f3f4"}
                    />
                </View>
                <View style={styles.settingItem}>
                    <Text style={[styles.settingText, isDarkMode && styles.darkText]}>Adventure Mode</Text>
                    <Switch
                        value={adventureMode}
                        onValueChange={handleToggleAdventureMode}
                        trackColor={{ false: "#767577", true: "#81b0ff" }}
                        thumbColor={adventureMode ? "#f5dd4b" : "#f4f3f4"}
                    />
                </View>
                <Text style={[styles.caption, isDarkMode && styles.darkCaption]}>
                    Adventure mode automatically tracks your visited structures using your location.
                </Text>
                <TouchableOpacity 
                    style={[styles.button, isDarkMode && styles.darkButton]} 
                    onPress={handleResetVisitedStructures}
                >
                    <Text style={[styles.buttonText, isDarkMode && styles.darkButtonText]}>
                        Reset All Visited Structures
                    </Text>
                </TouchableOpacity>
                <TouchableOpacity 
                    style={[styles.button, isDarkMode && styles.darkButton]} 
                    onPress={openLocationSettings}
                >
                    <Text style={[styles.buttonText, isDarkMode && styles.darkButtonText]}>
                        Open Location Settings
                    </Text>
                </TouchableOpacity>
            </View>

            <View style={[styles.section, isDarkMode && styles.darkSection]}>
                <Text style={[styles.sectionHeader, isDarkMode && styles.darkText]}>Information</Text>
                <TouchableOpacity onPress={() => Linking.openURL('https://caed.calpoly.edu/history-structures')}>
                    <Text style={[styles.link, isDarkMode && styles.darkLink]}>Structures in In-depth</Text>
                </TouchableOpacity>
                <TouchableOpacity onPress={() => Linking.openURL('https://maps.apple.com/?address=Poly%20Canyon%20Rd,%20San%20Luis%20Obispo,%20CA%20%2093405,%20United%20States&auid=7360445136973306817&ll=35.314999,-120.652923&lsp=9902&q=Poly%20Canyon')}>
                    <Text style={[styles.link, isDarkMode && styles.darkLink]}>How to Get to Poly Canyon</Text>
                </TouchableOpacity>
            </View>

            <View style={[styles.section, isDarkMode && styles.darkSection]}>
                <Text style={[styles.sectionHeader, isDarkMode && styles.darkText]}>Credits</Text>
                <Text style={[styles.creditText, isDarkMode && styles.darkText]}>Parker Jones</Text>
                <Text style={[styles.creditText, isDarkMode && styles.darkText]}>Cal Poly SLO</Text>
                <Text style={[styles.creditText, isDarkMode && styles.darkText]}>CAED College & Department</Text>
                <Text style={[styles.caption, isDarkMode && styles.darkCaption]}>
                    Please email bug reports or issues to pjones15@calpoly.edu, thanks in advance!
                </Text>
            </View>
        </ScrollView>
    );
};

// MARK: - Styles
const styles = StyleSheet.create({
    container: {
        flex: 1,
        padding: 20,
        backgroundColor: '#F5F5F5',
    },
    darkContainer: {
        backgroundColor: 'black',
    },
    section: {
        marginBottom: 20,
        backgroundColor: 'white',
        borderRadius: 10,
        padding: 15,
        shadowColor: "#000",
        shadowOffset: {
            width: 0,
            height: 2,
        },
        shadowOpacity: 0.63,
        shadowRadius: 4.62,
        elevation: 5.5,
    },
    darkSection: {
        backgroundColor: '#1E1E1E',
        shadowColor: "#FFF",
    },
    sectionHeader: {
        fontSize: 18,
        fontWeight: 'bold',
        marginBottom: 15,
        color: '#333',
    },
    darkText: {
        color: '#F5F5F5',
    },
    settingItem: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: 10,
    },
    settingText: {
        fontSize: 16,
        color: '#333',
    },
    caption: {
        fontSize: 12,
        color: '#666',
        marginBottom: 10,
    },
    darkCaption: {
        color: '#AAA',
    },
    button: {
        backgroundColor: '#007AFF',
        padding: 10,
        borderRadius: 5,
        alignItems: 'center',
        marginTop: 10,
    },
    darkButton: {
        backgroundColor: '#0A84FF',
    },
    buttonText: {
        color: 'white',
        fontSize: 16,
    },
    darkButtonText: {
        color: '#F5F5F5',
    },
    link: {
        color: '#007AFF',
        fontSize: 16,
        marginBottom: 10,
    },
    darkLink: {
        color: '#0A84FF',
    },
    creditText: {
        fontSize: 14,
        color: '#333',
        marginBottom: 5,
    },
});

export default SettingsView;
