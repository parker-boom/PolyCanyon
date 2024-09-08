import React from 'react';
import { View, Text, TouchableOpacity, Modal, StyleSheet } from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';

// Main component definition
const ModeSelectionPopup = ({ isVisible, onSelect, onConfirm, currentMode, selectedMode, isDarkMode }) => {
    // Define colors for each mode
    const adventureColor = '#4CAF50';
    const virtualTourColor = '#FF6803';

    return (
        <Modal
            animationType="slide"
            transparent={true}
            visible={isVisible}
        >
            {/* Main container with dark mode support */}
            <View style={[styles.centeredView, isDarkMode && styles.darkCenteredView]}>
                <View style={[styles.modalView, isDarkMode && styles.darkModalView]}>
                    <Text style={[styles.modalTitle, isDarkMode && styles.darkText]}>Switch it Up</Text>
                    
                    {/* Adventure Mode button */}
                    <TouchableOpacity
                        style={[
                            styles.modeButton, 
                            selectedMode && { borderColor: adventureColor, borderWidth: 2 }
                        ]}
                        onPress={() => onSelect(true)}
                    >
                        <Ionicons name="walk" size={40} color={adventureColor} />
                        <View style={styles.modeTextContainer}>
                            <Text style={[styles.modeButtonText, isDarkMode && styles.darkText]}>Adventure Mode</Text>
                            <Text style={[styles.modeSubtitle, isDarkMode && styles.darkSubtitle]}>In-person exploration</Text>
                        </View>
                    </TouchableOpacity>
                    
                    {/* Virtual Tour Mode button */}
                    <TouchableOpacity
                        style={[
                            styles.modeButton, 
                            !selectedMode && { borderColor: virtualTourColor, borderWidth: 2 }
                        ]}
                        onPress={() => onSelect(false)}
                    >
                        <Ionicons name="search" size={40} color={virtualTourColor} />
                        <View style={styles.modeTextContainer}>
                            <Text style={[styles.modeButtonText, isDarkMode && styles.darkText]}>Virtual Tour Mode</Text>
                            <Text style={[styles.modeSubtitle, isDarkMode && styles.darkSubtitle]}>Virtual viewing</Text>
                        </View>
                    </TouchableOpacity>
                    
                    {/* Confirm button */}
                    <TouchableOpacity 
                        style={[styles.confirmButton, { backgroundColor: selectedMode ? adventureColor : virtualTourColor }]} 
                        onPress={onConfirm}
                    >
                        <Text style={styles.buttonText}>Confirm</Text>
                    </TouchableOpacity>
                </View>
            </View>
        </Modal>
    );
};

// Styles definition
const styles = StyleSheet.create({
    centeredView: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: 'rgba(0, 0, 0, 0.5)',
    },
    darkCenteredView: {
        backgroundColor: 'rgba(255, 255, 255, 0.1)',
    },
    modalView: {
        margin: 20,
        backgroundColor: 'white',
        borderRadius: 20,
        padding: 35,
        alignItems: 'center',
        shadowColor: '#000',
        shadowOffset: {
            width: 0,
            height: 2
        },
        shadowOpacity: 0.25,
        shadowRadius: 4,
        elevation: 5,
        width: '80%',
        maxWidth: 400,
    },
    darkModalView: {
        backgroundColor: '#333',
    },
    modalTitle: {
        marginBottom: 20,
        textAlign: 'center',
        fontSize: 24,
        fontWeight: 'bold',
    },
    darkText: {
        color: 'white',
    },
    modeButton: {
        flexDirection: 'row',
        alignItems: 'center',
        padding: 15,
        marginVertical: 10,
        borderRadius: 15,
        width: '100%',
        borderWidth: 2,
        borderColor: 'transparent',
    },
    modeTextContainer: {
        marginLeft: 15,
        flex: 1,
    },
    modeButtonText: {
        fontSize: 18,
        fontWeight: 'bold',
    },
    modeSubtitle: {
        fontSize: 14,
        color: 'gray',
        marginTop: 5,
    },
    darkSubtitle: {
        color: '#aaa',
    },
    confirmButton: {
        borderRadius: 20,
        padding: 15,
        elevation: 2,
        marginTop: 30,
        minWidth: 120,
        alignItems: 'center',
    },
    buttonText: {
        color: 'white',
        fontWeight: 'bold',
        fontSize: 18,
    },
});

export default ModeSelectionPopup;