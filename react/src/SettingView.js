import React, { useState, useEffect } from 'react';
import { View, Text, Switch, TouchableOpacity, Alert, Linking, Platform, StyleSheet, ScrollView } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useStructures } from './StructureData';
import { useMapPoints } from './MapPoint';

const SettingsView = () => {
    const { structures, resetVisitedStructures, setAllStructuresAsVisited } = useStructures();
    const { resetVisitedMapPoints } = useMapPoints();
    const [isAdventureModeEnabled, setIsAdventureModeEnabled] = useState(true);
    const [isDarkMode, setIsDarkMode] = useState(false);
    const [visitedCount, setVisitedCount] = useState(0);
    const [visitedAllCount, setVisitedAllCount] = useState(0);
    const [dayCount, setDayCount] = useState(0);

    useEffect(() => {
        loadSettings();
    }, []);

    useEffect(() => {
        saveSettings();
    }, [isAdventureModeEnabled, isDarkMode, visitedCount, visitedAllCount, dayCount]);

    const loadSettings = async () => {
        try {
            const adventureModeValue = await AsyncStorage.getItem('isAdventureModeEnabled');
            setIsAdventureModeEnabled(adventureModeValue === null ? true : JSON.parse(adventureModeValue));
            
            const darkModeValue = await AsyncStorage.getItem('isDarkMode');
            setIsDarkMode(darkModeValue === null ? false : JSON.parse(darkModeValue));
            
            setVisitedCount(JSON.parse(await AsyncStorage.getItem('visitedCount')) || 0);
            setVisitedAllCount(JSON.parse(await AsyncStorage.getItem('visitedAllCount')) || 0);
            setDayCount(JSON.parse(await AsyncStorage.getItem('dayCount')) || 0);
        } catch (error) {
            console.error('Failed to load settings', error);
        }
    };

    const saveSettings = async () => {
        try {
            await AsyncStorage.setItem('isAdventureModeEnabled', JSON.stringify(isAdventureModeEnabled));
            await AsyncStorage.setItem('isDarkMode', JSON.stringify(isDarkMode));
            await AsyncStorage.setItem('visitedCount', JSON.stringify(visitedCount));
            await AsyncStorage.setItem('visitedAllCount', JSON.stringify(visitedAllCount));
            await AsyncStorage.setItem('dayCount', JSON.stringify(dayCount));
        } catch (error) {
            console.error('Failed to save settings', error);
        }
    };

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
                            setIsAdventureModeEnabled(false);
                        } 
                    }
                ]
            );
        } else {
            setIsAdventureModeEnabled(true);
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
        if (Platform.OS === 'ios') {
            Linking.openURL('app-settings:');
        } else {
            Linking.openSettings();
        }
    };

    return (
        <ScrollView style={[styles.container, isDarkMode && styles.darkContainer]}>
            <View style={styles.section}>
                <Text style={[styles.sectionHeader, isDarkMode && styles.darkText]}>Settings</Text>
                <View style={styles.settingItem}>
                    <Text style={[styles.settingText, isDarkMode && styles.darkText]}>Dark Mode</Text>
                    <Switch
                        value={isDarkMode}
                        onValueChange={setIsDarkMode}
                        trackColor={{ false: "#767577", true: "#81b0ff" }}
                        thumbColor={isDarkMode ? "#f5dd4b" : "#f4f3f4"}
                    />
                </View>
                <View style={styles.settingItem}>
                    <Text style={[styles.settingText, isDarkMode && styles.darkText]}>Adventure Mode</Text>
                    <Switch
                        value={isAdventureModeEnabled}
                        onValueChange={handleToggleAdventureMode}
                        trackColor={{ false: "#767577", true: "#81b0ff" }}
                        thumbColor={isAdventureModeEnabled ? "#f5dd4b" : "#f4f3f4"}
                    />
                </View>
                <Text style={[styles.caption, isDarkMode && styles.darkCaption]}>
                    Adventure mode automatically tracks your visited structures using your location.
                </Text>
                <TouchableOpacity style={styles.button} onPress={handleResetVisitedStructures}>
                    <Text style={styles.buttonText}>Reset All Visited Structures</Text>
                </TouchableOpacity>
                <TouchableOpacity style={styles.button} onPress={openLocationSettings}>
                    <Text style={styles.buttonText}>Open Location Settings</Text>
                </TouchableOpacity>
            </View>

            <View style={styles.section}>
                <Text style={[styles.sectionHeader, isDarkMode && styles.darkText]}>Statistics</Text>
                <View style={styles.statItem}>
                    <Text style={[styles.statText, isDarkMode && styles.darkText]}>Structures Visited</Text>
                    <Text style={[styles.statValue, isDarkMode && styles.darkText]}>{visitedCount}</Text>
                </View>
                <View style={styles.statItem}>
                    <Text style={[styles.statText, isDarkMode && styles.darkText]}>Milestone Visits</Text>
                    <Text style={[styles.statValue, isDarkMode && styles.darkText]}>{visitedAllCount}</Text>
                </View>
                <View style={styles.statItem}>
                    <Text style={[styles.statText, isDarkMode && styles.darkText]}>Days Visited</Text>
                    <Text style={[styles.statValue, isDarkMode && styles.darkText]}>{dayCount}</Text>
                </View>
            </View>

            <View style={styles.section}>
                <Text style={[styles.sectionHeader, isDarkMode && styles.darkText]}>Information</Text>
                <TouchableOpacity onPress={() => Linking.openURL('https://caed.calpoly.edu/history-structures')}>
                    <Text style={styles.link}>Structures in In-depth</Text>
                </TouchableOpacity>
                <TouchableOpacity onPress={() => Linking.openURL('https://maps.apple.com/?address=Poly%20Canyon%20Rd,%20San%20Luis%20Obispo,%20CA%20%2093405,%20United%20States&auid=7360445136973306817&ll=35.314999,-120.652923&lsp=9902&q=Poly%20Canyon')}>
                    <Text style={styles.link}>How to Get to Poly Canyon</Text>
                </TouchableOpacity>
            </View>

            <View style={styles.section}>
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

const styles = StyleSheet.create({
    container: {
        flex: 1,
        padding: 20,
        backgroundColor: '#F5F5F5',
    },
    darkContainer: {
        backgroundColor: '#121212',
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
        shadowOpacity: 0.23,
        shadowRadius: 2.62,
        elevation: 4,
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
    buttonText: {
        color: 'white',
        fontSize: 16,
    },
    statItem: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        marginBottom: 10,
    },
    statText: {
        fontSize: 16,
        color: '#333',
    },
    statValue: {
        fontSize: 16,
        fontWeight: 'bold',
        color: '#333',
    },
    link: {
        color: '#007AFF',
        fontSize: 16,
        marginBottom: 10,
    },
    creditText: {
        fontSize: 14,
        color: '#333',
        marginBottom: 5,
    },
});

export default SettingsView;