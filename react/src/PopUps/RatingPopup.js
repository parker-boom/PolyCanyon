import React, { useState, useEffect } from 'react';
import { 
    View, 
    Text, 
    Modal, 
    TouchableOpacity, 
    StyleSheet, 
    Dimensions,
    Animated
} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useStructures } from '../Data/StructureData';
import FastImage from 'react-native-fast-image';
import Ionicons from 'react-native-vector-icons/Ionicons';

// Constants
const { width, height } = Dimensions.get('window');
const RATING_INDEX_KEY = 'RATING_INDEX_KEY';

// Main component
const RatingPopup = ({ isVisible, onClose, isDarkMode }) => {
    // Custom hook for structure data
    const { structures, toggleStructureLiked, countLikedStructures } = useStructures();
    
    // State management
    const [currentIndex, setCurrentIndex] = useState(0);
    const [isComplete, setIsComplete] = useState(false);

    // Load current index when modal becomes visible
    useEffect(() => {
        if (isVisible) {
            loadCurrentIndex();
        }
    }, [isVisible]);

    // AsyncStorage functions
    const loadCurrentIndex = async () => {
        try {
            const savedIndex = await AsyncStorage.getItem(RATING_INDEX_KEY);
            if (savedIndex !== null) {
                const index = parseInt(savedIndex, 10);
                setCurrentIndex(index);
                setIsComplete(index >= structures.length);
            }
        } catch (error) {
            console.error('Error loading current index:', error);
        }
    };

    const saveCurrentIndex = async (index) => {
        try {
            await AsyncStorage.setItem(RATING_INDEX_KEY, index.toString());
        } catch (error) {
            console.error('Error saving current index:', error);
        }
    };

    // Rating handlers
    const handleRate = async (liked) => {
        if (!isComplete && currentIndex < structures.length) {
            const currentStructure = structures[currentIndex];
            toggleStructureLiked(currentStructure.number, liked);
            
            const newIndex = currentIndex + 1;
            setCurrentIndex(newIndex);
            await saveCurrentIndex(newIndex);
            
            setIsComplete(newIndex >= structures.length);
        }
    };

    const handleExit = async () => {
        await saveCurrentIndex(currentIndex);
        onClose();
    };

    const handleRestart = async () => {
        const newIndex = 0;
        setCurrentIndex(newIndex);
        setIsComplete(false);
        await saveCurrentIndex(newIndex);
    };

    // Render functions
    const renderRatingContent = () => {
        if (isComplete || currentIndex >= structures.length) {
            return renderCompletionScreen();
        }

        const currentStructure = structures[currentIndex];
        if (!currentStructure) {
            console.error('Current structure is undefined:', currentIndex, structures.length);
            return null;
        }

        return renderRatingScreen(currentStructure);
    };

    const renderCompletionScreen = () => {
        const likedCount = countLikedStructures();
        return (
            <View style={styles.completeContainer}>
                <View style={styles.pulsingHeart}>
                    <Ionicons name="heart" size={100} color="red" />
                </View>
                <Text style={[styles.completeText, isDarkMode && styles.darkText]}>
                    You've rated all structures!
                </Text>
                <Text style={[styles.likedCountText, isDarkMode && styles.darkText]}>
                    Liked: {likedCount} / {structures.length}
                </Text>
                <TouchableOpacity style={styles.restartButton} onPress={handleRestart}>
                    <Text style={styles.restartButtonText}>Restart</Text>
                </TouchableOpacity>
                <TouchableOpacity style={styles.exitButtonComplete} onPress={handleExit}>
                    <Text style={styles.exitButtonTextComplete}>Exit</Text>
                </TouchableOpacity>
            </View>
        );
    };

    const renderRatingScreen = (currentStructure) => {
        return (
            <View style={styles.contentContainer}>
                <Text style={[styles.rateStructuresTitle, isDarkMode && styles.darkText]}>
                    Rate Structures
                </Text>
                <View style={[styles.imageContainer, styles.imageShadow, isDarkMode && styles.darkImageShadow]}>
                    <FastImage
                        source={currentStructure.mainImage.image}
                        style={styles.structureImage}
                        resizeMode={FastImage.resizeMode.cover}
                    />
                    <View style={styles.titleOverlay}>
                        <Text style={styles.structureTitle}>{currentStructure.title}</Text>
                    </View>
                </View>
                <Text style={[styles.progressText, isDarkMode && styles.darkText]}>
                    {currentIndex + 1} / {structures.length}
                </Text>
                <View style={styles.ratingButtonsContainer}>
                    <TouchableOpacity 
                        style={[styles.ratingButton, styles.dislikeButton]} 
                        onPress={() => handleRate(false)}
                    >
                        <Ionicons name="close" size={40} color="white" />
                    </TouchableOpacity>
                    <TouchableOpacity 
                        style={[styles.ratingButton, styles.likeButton]} 
                        onPress={() => handleRate(true)}
                    >
                        <Ionicons name="heart" size={40} color="white" />
                    </TouchableOpacity>
                </View>
            </View>
        );
    };

    // Main render
    return (
        <Modal
            visible={isVisible}
            transparent={true}
            animationType="slide"
        >
            <View style={[styles.modalContainer, isDarkMode && styles.darkModalContainer]}>
                {renderRatingContent()}
                {!isComplete && (
                    <TouchableOpacity style={styles.exitButton} onPress={handleExit}>
                        <Text style={[styles.exitButtonText, isDarkMode && styles.darkText]}>Exit</Text>
                    </TouchableOpacity>
                )}
            </View>
        </Modal>
    );
};

// Styles
const styles = StyleSheet.create({
    modalContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: 'white',
    },
    darkModalContainer: {
        backgroundColor: '#121212',
    },
    contentContainer: {
        width: width * 0.9,
        alignItems: 'center',
    },
    imageContainer: {
        width: width * 0.9,
        height: height * 0.56,
        borderRadius: 20,
        overflow: 'hidden',
        borderWidth: 0,
        borderColor: '#ccc',
    },
    imageShadow: {
        shadowColor: "#000",
        shadowOffset: {
            width: 0,
            height: 6,
        },
        shadowOpacity: 0.5,
        shadowRadius: 8,
        elevation: 15,
    },
    darkImageShadow: {
        shadowColor: "#fff",
        elevation: 15,
    },
    structureImage: {
        width: '100%',
        height: '100%',
    },
    titleOverlay: {
        position: 'absolute',
        bottom: 0,
        left: 0,
        right: 0,
        backgroundColor: 'rgba(0, 0, 0, 0.6)',
        padding: 10,
        borderBottomLeftRadius: 20,
        borderBottomRightRadius: 20,
    },
    structureTitle: {
        color: 'white',
        fontSize: 27,
        fontWeight: 'bold',
        textAlign: 'center',
    },
    progressText: {
        fontSize: 22,
        fontWeight: 'bold',
        marginTop: 25,
        marginBottom: 15,
        color: 'black',
    },
    ratingButtonsContainer: {
        flexDirection: 'row',
        justifyContent: 'center',
        width: '100%',
        marginTop: 20,
        marginBottom: 20,
    },
    ratingButton: {
        padding: 15,
        marginHorizontal: 25,
        backgroundColor: '#f0f0f0',
        borderRadius: 50,
        alignItems: 'center',
        justifyContent: 'center',
    },
    likeButton: {
        backgroundColor: 'green',
    },
    dislikeButton: {
        backgroundColor: 'red',
    },
    exitButton: {
        position: 'absolute',
        bottom: 20,
        paddingVertical: 8,
        paddingHorizontal: 25,
        backgroundColor: '#2196F3',
        borderRadius: 20,
    },
    exitButtonText: {
        color: 'white',
        fontSize: 16,
        fontWeight: 'bold',
    },
    completeContainer: {
        alignItems: 'center',
    },
    completeText: {
        fontSize: 24,
        fontWeight: 'bold',
        marginBottom: 10,
        textAlign: 'center',
    },
    likedCountText: {
        fontSize: 20,
        marginBottom: 20,
    },
    restartButton: {
        backgroundColor: '#2196F3',
        paddingHorizontal: 30,
        paddingVertical: 15,
        borderRadius: 20,
        marginBottom: 15,
    },
    restartButtonText: {
        color: 'white',
        fontSize: 18,
        fontWeight: 'bold',
    },
    exitButtonComplete: {
        backgroundColor: '#f0f0f0',
        paddingHorizontal: 30,
        paddingVertical: 10,
        borderRadius: 20,
    },
    exitButtonTextComplete: {
        color: '#333',
        fontSize: 16,
        fontWeight: 'bold',
    },
    pulsingHeart: {
        marginBottom: 20,
    },
    darkText: {
        color: 'white',
    },
    rateStructuresTitle: {
        fontSize: 42,
        fontWeight: '600',
        marginBottom: 20,
        textAlign: 'center',
        color: 'black',
    },
});

export default RatingPopup;