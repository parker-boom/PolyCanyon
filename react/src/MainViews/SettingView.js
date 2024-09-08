// MARK: - SettingsView Component
/**
 * SettingsView Component
 * 
 * This component represents the settings screen of the application.
 * It provides a user interface for managing various app settings and preferences.
 * 
 * Key Features:
 * - Dark mode toggle
 * - Adventure/Virtual Tour mode switch with explanatory UI
 * - Mode-specific actions (Reset visited/favorited structures, Location settings, Rate structures)
 * - Credits section
 * - Integration with custom hooks for state management
 * - Popup components for mode selection and structure rating
 */

import React, { useState, useCallback, useEffect } from 'react';
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
import { useStructures } from '../Data/StructureData';
import { useMapPoints } from '../Data/MapPoint';
import { useDarkMode } from '../States/DarkMode';
import Ionicons from 'react-native-vector-icons/Ionicons';
import ModeSelectionPopup from '../PopUps/ModeSelectionPopup';
import { useAdventureMode } from '../States/AdventureModeContext';
import { useLocation, requestLocationPermission } from '../Data/LocationManager';
import RatingPopup from '../PopUps/RatingPopup';

const SettingsView = () => {
    // MARK: - State and Hooks
    const { adventureMode, updateAdventureMode } = useAdventureMode();
    const { isDarkMode, toggleDarkMode } = useDarkMode();
    const { resetVisitedStructures, resetFavoritedStructures } = useStructures();
    const { resetVisitedMapPoints } = useMapPoints();
    const [showModePopup, setShowModePopup] = useState(false);
    const [localAdventureMode, setLocalAdventureMode] = useState(adventureMode);
    const [showRatingPopup, setShowRatingPopup] = useState(false);
    const [ratingIndex, setRatingIndex] = useState(0);

    // Sync local state with global adventure mode
    useEffect(() => {
        setLocalAdventureMode(adventureMode);
    }, [adventureMode]);

    // Use location hook for Adventure mode
    useLocation((error, position) => {
        if (adventureMode && !error && position) {
            // Update any location-dependent state or perform actions
        }
    });

    // MARK: - Event Handlers
    const handleToggleMode = () => {
        setShowModePopup(true);
    };

    const handleModeSelection = useCallback((newMode) => {
        setLocalAdventureMode(newMode);
    }, []);

    const handleConfirmModeChange = useCallback(() => {
        if (localAdventureMode !== adventureMode) {
            updateAdventureMode(localAdventureMode);
        }
        setShowModePopup(false);
    }, [localAdventureMode, adventureMode, updateAdventureMode]);

    // Handler for resetting visited structures
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

    const handleResetFavoritedStructures = () => {
        Alert.alert(
            "Reset Favorite Structures",
            "Are you sure you want to reset all favorite structures?",
            [
                { text: "Cancel", style: "cancel" },
                { 
                    text: "Yes", 
                    onPress: () => {
                        resetFavoritedStructures();
                    } 
                }
            ]
        );
    };

    const handleRateStructures = () => {
        setShowRatingPopup(true);
    };

    const handleCloseRatingPopup = () => {
        setShowRatingPopup(false);
    };

    // Handler for opening location settings
    const openLocationSettings = () => {
        if (adventureMode) {
            requestLocationPermission();
        } else {
            Alert.alert(
                "Location Not Required",
                "Location tracking is not needed in Virtual Tour Mode. Switch to Adventure Mode to use location features."
            );
        }
    };

    // MARK: - Render
    return (
        <>
            <ScrollView style={[styles.container, isDarkMode && styles.darkContainer]}>
                {/* General Settings Section */}
                <View style={[styles.section, isDarkMode && styles.darkSection]}>
                    <Text style={[styles.sectionHeader, isDarkMode && styles.darkText]}>General Settings</Text>
                    
                    {/* Dark Mode Toggle */}
                    <View style={styles.settingItem}>
                        <Text style={[styles.settingText, isDarkMode && styles.darkText]}>Dark Mode</Text>
                        <Switch
                            value={isDarkMode}
                            onValueChange={toggleDarkMode}
                            trackColor={{ false: "#767577", true: "#81b0ff" }}
                            thumbColor={isDarkMode ? "#f5dd4b" : "#f4f3f4"}
                        />
                    </View>

                    {/* Mode Selection UI */}
                    <View style={styles.modeSection}>
                        <Ionicons 
                            name={localAdventureMode ? "walk" : "search"} 
                            size={40} 
                            color={localAdventureMode ? (isDarkMode ? '#6ECF76' : '#4CAF50') : (isDarkMode ? '#FFA347' : '#FF6803')} 
                        />
                        <Text style={[styles.modeTitle, isDarkMode && styles.darkText]}>
                            {localAdventureMode ? "Adventure Mode" : "Virtual Tour Mode"}
                        </Text>
                        <Text style={[styles.modeDescription, isDarkMode && styles.darkModeDescription]}>
                            {localAdventureMode ? "Explore structures in person" : "Browse structures remotely"}
                        </Text>
                        <TouchableOpacity style={[styles.switchButton, isDarkMode && styles.darkSwitchButton]} onPress={handleToggleMode}>
                            <Text style={styles.switchButtonText}>Switch</Text>
                        </TouchableOpacity>
                    </View>

                    {/* Mode-specific Action Buttons */}
                    <View style={styles.buttonContainer}>
                        {adventureMode ? (
                            <>
                                <SettingsButton
                                    onPress={handleResetVisitedStructures}
                                    icon="refresh"
                                    text="Reset Structures"
                                    color={isDarkMode ? "#FF6B6B" : "red"}
                                    isDarkMode={isDarkMode}
                                />
                                <SettingsButton
                                    onPress={openLocationSettings}
                                    icon="location"
                                    text="Location Settings"
                                    color={isDarkMode ? "#6ECF76" : "green"}
                                    isDarkMode={isDarkMode}
                                />
                            </>
                        ) : (
                            <>
                                <SettingsButton
                                    onPress={handleResetFavoritedStructures}
                                    icon="heart-dislike"
                                    text="Reset Favorites"
                                    color={isDarkMode ? "#FF6B6B" : "red"}
                                    isDarkMode={isDarkMode}
                                />
                                <SettingsButton
                                    onPress={handleRateStructures}
                                    icon="heart"
                                    text="Rate Structures"
                                    color={isDarkMode ? "#FF6B6B" : "red"}
                                    isDarkMode={isDarkMode}
                                />
                            </>
                        )}
                    </View>
                </View>

                {/* Credits Section */}
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
            <ModeSelectionPopup 
                isVisible={showModePopup}
                onSelect={handleModeSelection}
                onConfirm={handleConfirmModeChange}
                currentMode={localAdventureMode}
                selectedMode={localAdventureMode}
                isDarkMode={isDarkMode}
            />
            <RatingPopup 
                isVisible={showRatingPopup}
                onClose={handleCloseRatingPopup}
                isDarkMode={isDarkMode}
            />
        </>
    );
};

// MARK: - Helper Components
const SettingsButton = ({ onPress, icon, text, color, isDarkMode }) => (
    <TouchableOpacity style={[styles.settingsButton, isDarkMode && styles.darkSettingsButton]} onPress={onPress}>
        <Ionicons name={icon} size={24} color={color} />
        <Text style={[styles.settingsButtonText, isDarkMode && styles.darkText]}>{text}</Text>
    </TouchableOpacity>
);

// MARK: - Styles
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
    darkSection: {
        backgroundColor: '#1E1E1E',
    },
    sectionHeader: {
        fontSize: 24,
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
        fontSize: 18,
        color: '#333',
    },
    modeSection: {
        alignItems: 'center',
        marginVertical: 20,
    },
    modeTitle: {
        fontSize: 22,
        fontWeight: 'bold',
        marginTop: 10,
        color: '#333',
    },
    modeDescription: {
        fontSize: 14,
        color: 'gray',
        marginTop: 5,
        textAlign: 'center',
    },
    darkModeDescription: {
        color: '#B0B0B0',
    },
    switchButton: {
        backgroundColor: '#2196F3',
        paddingHorizontal: 20,
        paddingVertical: 10,
        borderRadius: 20,
        marginTop: 15,
    },
    darkSwitchButton: {
        backgroundColor: '#3D5AFE',
    },
    switchButtonText: {
        color: 'white',
        fontSize: 16,
        fontWeight: 'bold',
    },
    buttonContainer: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        marginTop: 20,
    },
    settingsButton: {
        flex: 1,
        alignItems: 'center',
        backgroundColor: '#f0f0f0',
        padding: 10,
        borderRadius: 10,
        marginHorizontal: 5,
    },
    darkSettingsButton: {
        backgroundColor: '#333',
    },
    settingsButtonText: {
        marginTop: 5,
        fontSize: 12,
        color: '#333',
    },
    creditText: {
        fontSize: 16,
        color: '#333',
        marginBottom: 5,
    },
    caption: {
        fontSize: 12,
        color: 'gray',
        marginTop: 10,
    },
    darkCaption: {
        color: '#B0B0B0',
    },
});

export default SettingsView;
