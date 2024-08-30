// MARK: - StructPopUp Component
/**
 * StructPopUp Component
 * 
 * This component displays a detailed popup view for a structure. 
 * It allows users to swipe between images, view structure details, and close the popup.
 * 
 * Features:
 * - Swipeable main and close-up images with indicator dots
 * - Animated information panel
 * - Custom tab selector for stats and description
 * - Dark mode support
 * - Dismiss button and structure title/number overlay
 */

import React, { useState, useRef, useEffect } from 'react';
import { 
    View, 
    Text, 
    TouchableOpacity, 
    StyleSheet, 
    Dimensions, 
    ScrollView, 
    Animated, 
    PanResponder,
    LayoutAnimation,
    Platform,
    UIManager,
    Image
} from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';
import FastImage from 'react-native-fast-image';
import { BlurView } from '@react-native-community/blur'; // Add this import

if (Platform.OS === 'android' && UIManager.setLayoutAnimationEnabledExperimental) {
    UIManager.setLayoutAnimationEnabledExperimental(true);
}

const { width, height } = Dimensions.get('window');
const POPUP_PADDING = 40;
const POPUP_WIDTH = width - (POPUP_PADDING * 2);
const POPUP_HEIGHT = height - (POPUP_PADDING * 2);

const StructPopUp = ({ structure, onClose, isDarkMode }) => {
    const [isShowingInfo, setIsShowingInfo] = useState(false);
    const [selectedTab, setSelectedTab] = useState('stats');
    const [currentImageIndex, setCurrentImageIndex] = useState(0);
    const [imageAspectRatios, setImageAspectRatios] = useState([1, 1]);

    const pan = useRef(new Animated.ValueXY()).current;
    const flipAnimation = useRef(new Animated.Value(0)).current;

    useEffect(() => {
        const images = [structure.mainImage, structure.closeUpImage];
        const aspectRatios = [];

        images.forEach((image, index) => {
            if (typeof image === 'number') {
                // Local image (require)
                const { width, height } = Image.resolveAssetSource(image);
                aspectRatios[index] = width / height;
            } else if (typeof image === 'string') {
                // Remote image URL
                Image.getSize(image, (width, height) => {
                    aspectRatios[index] = width / height;
                    if (aspectRatios.length === images.length) {
                        setImageAspectRatios(aspectRatios);
                    }
                }, (error) => {
                    console.error(`Error getting image size for image ${index}:`, error);
                    aspectRatios[index] = 1;
                    if (aspectRatios.length === images.length) {
                        setImageAspectRatios(aspectRatios);
                    }
                });
            } else if (image && image.image) {
                // Object with image property
                if (typeof image.image === 'number') {
                    // Local image (require)
                    const { width, height } = Image.resolveAssetSource(image.image);
                    aspectRatios[index] = width / height;
                } else if (typeof image.image === 'string') {
                    // Remote image URL
                    Image.getSize(image.image, (width, height) => {
                        aspectRatios[index] = width / height;
                        if (aspectRatios.length === images.length) {
                            setImageAspectRatios(aspectRatios);
                        }
                    }, (error) => {
                        console.error(`Error getting image size for image ${index}:`, error);
                        aspectRatios[index] = 1;
                        if (aspectRatios.length === images.length) {
                            setImageAspectRatios(aspectRatios);
                        }
                    });
                }
            } else {
                console.error(`Unsupported image format for image ${index}`);
                aspectRatios[index] = 1;
            }

            if (aspectRatios.length === images.length) {
                setImageAspectRatios(aspectRatios);
            }
        });
    }, [structure.mainImage, structure.closeUpImage]);

    const panResponder = PanResponder.create({
        onMoveShouldSetPanResponder: () => true,
        onPanResponderMove: Animated.event([null, { dy: pan.y }], { useNativeDriver: false }),
        onPanResponderRelease: (e, gestureState) => {
            if (gestureState.dy > 100) {
                onClose();
            } else {
                Animated.spring(pan, { toValue: { x: 0, y: 0 }, useNativeDriver: false }).start();
            }
        },
    });

    const flipCard = () => {
        LayoutAnimation.configureNext(LayoutAnimation.Presets.easeInEaseOut);
        setIsShowingInfo(!isShowingInfo);
        Animated.timing(flipAnimation, {
            toValue: isShowingInfo ? 0 : 180,
            duration: 300,
            useNativeDriver: true,
        }).start();
    };

    const frontInterpolate = flipAnimation.interpolate({
        inputRange: [0, 180],
        outputRange: ['0deg', '180deg'],
    });

    const backInterpolate = flipAnimation.interpolate({
        inputRange: [0, 180],
        outputRange: ['180deg', '360deg'],
    });

    const frontAnimatedStyle = {
        transform: [{ rotateY: frontInterpolate }]
    };

    const backAnimatedStyle = {
        transform: [{ rotateY: backInterpolate }]
    };

    const renderImageSection = () => (
        <View style={styles.imageSection}>
            <ScrollView
                horizontal
                pagingEnabled
                showsHorizontalScrollIndicator={false}
                onMomentumScrollEnd={(event) => {
                    const newIndex = Math.round(event.nativeEvent.contentOffset.x / POPUP_WIDTH);
                    setCurrentImageIndex(newIndex);
                }}
            >
                {[structure.mainImage, structure.closeUpImage].map((image, index) => {
                    const aspectRatio = imageAspectRatios[index];
                    const isLandscape = aspectRatio > 1;
                    const imageStyle = isLandscape
                        ? { width: POPUP_WIDTH - 20, height: (POPUP_WIDTH - 20) / aspectRatio }
                        : { width: (POPUP_HEIGHT - 80) * aspectRatio, height: POPUP_HEIGHT - 80 }; // Subtract space for info button and padding

                    const imageSource = image.image || image;

                    return (
                        <View key={index} style={styles.imageContainer}>
                            {isLandscape && (
                                <BlurView
                                    style={StyleSheet.absoluteFill}
                                    blurType="light"
                                    blurAmount={10}
                                >
                                    <FastImage
                                        source={imageSource}
                                        style={[StyleSheet.absoluteFill, { opacity: 0.5 }]}
                                    />
                                </BlurView>
                            )}
                            <FastImage 
                                source={imageSource} 
                                style={[styles.image, imageStyle]} 
                                resizeMode="contain" 
                            />
                        </View>
                    );
                })}
            </ScrollView>
            <View style={styles.overlayContent}>
                <TouchableOpacity style={styles.dismissButton} onPress={onClose}>
                    <Ionicons name="close-circle-outline" size={30} color="white" />
                </TouchableOpacity>
                <View style={styles.structureInfo}>
                    <Text style={[styles.structureNumber, styles.textShadow]}>{structure.number}</Text>
                    <Text style={[styles.structureTitle, styles.textShadow]}>{structure.title}</Text>
                </View>
            </View>
            <View style={[styles.imageDots, styles.textShadow]}>
                {[0, 1].map(index => (
                    <View key={index} style={[styles.dot, currentImageIndex === index && styles.activeDot]} />
                ))}
            </View>
        </View>
    );

    const renderInformationPanel = () => (
        <View style={styles.informationPanel}>
            <TouchableOpacity style={styles.closeInfoButton} onPress={onClose}>
                <Ionicons name="close" size={24} color={isDarkMode ? "white" : "black"} />
            </TouchableOpacity>
            <View style={styles.infoHeader}>
                <Text style={[styles.infoHeaderNumber, isDarkMode && styles.darkText]}>{structure.number}</Text>
                <Text style={[styles.infoHeaderTitle, isDarkMode && styles.darkText]}>{structure.title}</Text>
            </View>
            <View style={styles.tabSelector}>
                <TouchableOpacity
                    style={[styles.tabButton, selectedTab === 'stats' && styles.selectedTab]}
                    onPress={() => setSelectedTab('stats')}
                >
                    <Ionicons name="stats-chart" size={20} color={isDarkMode ? "white" : "black"} style={styles.tabIcon} />
                    <Text style={[styles.tabButtonText, isDarkMode && styles.darkText]}>Stats</Text>
                </TouchableOpacity>
                <TouchableOpacity
                    style={[styles.tabButton, selectedTab === 'info' && styles.selectedTab]}
                    onPress={() => setSelectedTab('info')}
                >
                    <Ionicons name="information-circle" size={20} color={isDarkMode ? "white" : "black"} style={styles.tabIcon} />
                    <Text style={[styles.tabButtonText, isDarkMode && styles.darkText]}>Info</Text>
                </TouchableOpacity>
            </View>
            {selectedTab === 'stats' ? renderStatisticsView() : renderDescriptionView()}
        </View>
    );

    const renderStatisticsView = () => (
        <View style={styles.statsSection}>
            <View style={styles.statRow}>
                <InfoPill icon="📅" title="Year" value={structure.year} isDarkMode={isDarkMode} />
                <InfoPill icon="🏛️" title="Style" value={structure.architecturalStyle} isDarkMode={isDarkMode} />
            </View>
            <FunFactPill fact={structure.additionalInfo} isDarkMode={isDarkMode} />
        </View>
    );

    const renderDescriptionView = () => (
        <Text style={[styles.description, isDarkMode && styles.darkText]}>{structure.description}</Text>
    );

    return (
        <View style={styles.outerContainer}>
            <View style={[styles.container, isDarkMode && styles.darkContainer]}>
                <View style={styles.contentContainer}>
                    {isShowingInfo ? renderInformationPanel() : renderImageSection()}
                </View>
                <TouchableOpacity 
                    style={[styles.infoButton, isDarkMode && styles.darkInfoButton]} 
                    onPress={() => setIsShowingInfo(!isShowingInfo)}
                >
                    <Text style={[styles.infoButtonText, isDarkMode && styles.darkText]}>
                        {isShowingInfo ? "Images" : "Information"}
                    </Text>
                    <Ionicons 
                        name={isShowingInfo ? "image" : "information-circle"} 
                        size={24} 
                        color={isDarkMode ? "white" : "black"} 
                    />
                </TouchableOpacity>
            </View>
        </View>
    );
};

const InfoPill = ({ icon, title, value, isDarkMode }) => (
    <View style={[styles.infoPill, isDarkMode && styles.darkInfoPill]}>
        <Text style={styles.infoPillIcon}>{icon}</Text>
        <Text style={[styles.infoPillTitle, isDarkMode && styles.darkText]}>{title}</Text>
        <Text style={[styles.infoPillValue, isDarkMode && styles.darkText]}>{value}</Text>
    </View>
);

const FunFactPill = ({ fact, isDarkMode }) => (
    <View style={[styles.funFactPill, isDarkMode && styles.darkFunFactPill]}>
        <Text style={styles.funFactIcon}>✨</Text>
        <Text style={[styles.funFactTitle, isDarkMode && styles.darkText]}>Fun Fact</Text>
        <Text style={[styles.funFactValue, isDarkMode && styles.darkText]}>{fact}</Text>
    </View>
);

const styles = StyleSheet.create({
    outerContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: 'rgba(0, 0, 0, 0.5)',
    },
    container: {
        width: POPUP_WIDTH,
        height: POPUP_HEIGHT,
        backgroundColor: 'white',
        borderRadius: 20,
        overflow: 'hidden',
        shadowColor: "#000",
        shadowOffset: {
            width: 0,
            height: 2,
        },
        shadowOpacity: 0.25,
        shadowRadius: 3.84,
        elevation: 5,
    },
    darkContainer: {
        backgroundColor: 'black',
    },
    contentContainer: {
        flex: 1,
        padding: 10,
    },
    imageSection: {
        flex: 1,
        borderRadius: 10,
        overflow: 'hidden',
    },
    imageContainer: {
        width: POPUP_WIDTH - 20,
        height: POPUP_HEIGHT - 80, // Subtract space for info button and padding
        justifyContent: 'center',
        alignItems: 'center',
        borderRadius: 10,
        overflow: 'hidden',
    },
    image: {
        // The width and height will be set dynamically
    },
    overlayContent: {
        ...StyleSheet.absoluteFillObject,
        padding: 20,
        justifyContent: 'space-between',
    },
    dismissButton: {
        alignSelf: 'flex-end',
    },
    structureInfo: {
        alignItems: 'flex-start',
    },
    textShadow: {
        textShadowColor: 'rgba(0, 0, 0, 0.75)',
        textShadowOffset: { width: -1, height: 1 },
        textShadowRadius: 10
    },
    structureNumber: {
        fontSize: 40,
        fontWeight: 'bold',
        color: 'white',
        marginBottom: 5,
    },
    structureTitle: {
        fontSize: 30,
        fontWeight: '600',
        color: 'white',
    },
    imageDots: {
        flexDirection: 'row',
        position: 'absolute',
        bottom: 20,
        right: 20,
    },
    dot: {
        width: 8,
        height: 8,
        borderRadius: 4,
        backgroundColor: 'rgba(255, 255, 255, 0.5)',
        marginHorizontal: 4,
    },
    activeDot: {
        backgroundColor: 'white',
        width: 10,
        height: 10,
        borderRadius: 5,
    },
    infoButton: {
        flexDirection: 'row',
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: 'rgba(200, 200, 200, 0.3)',
        borderRadius: 15,
        padding: 15,
        marginHorizontal: 15,
        marginVertical: 10,
        marginBottom: 20, // Added bottom padding
    },
    darkInfoButton: {
        backgroundColor: 'rgba(100, 100, 100, 0.3)',
    },
    infoButtonText: {
        fontSize: 18,
        fontWeight: '600',
        marginRight: 10,
    },
    darkText: {
        color: 'white',
    },
    informationPanel: {
        flex: 1,
        padding: 10,
    },
    closeInfoButton: {
        position: 'absolute',
        top: 10,
        right: 10,
        zIndex: 1,
    },
    infoHeader: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        marginBottom: 20,
    },
    infoHeaderNumber: {
        fontSize: 24,
        fontWeight: 'bold',
    },
    infoHeaderTitle: {
        fontSize: 20,
        fontWeight: '600',
        flex: 1,
        textAlign: 'center',
    },
    tabSelector: {
        flexDirection: 'row',
        justifyContent: 'center',
        marginBottom: 20,
    },
    tabButton: {
        flexDirection: 'row',
        alignItems: 'center',
        paddingHorizontal: 20,
        paddingVertical: 10,
        borderRadius: 20,
    },
    tabIcon: {
        marginRight: 5,
    },
    selectedTab: {
        backgroundColor: 'rgba(200, 200, 200, 0.3)',
    },
    tabButtonText: {
        fontSize: 16,
        fontWeight: '600',
    },
    statsSection: {
        marginTop: 20,
    },
    statRow: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        marginBottom: 10,
    },
    infoPill: {
        backgroundColor: 'rgba(200, 200, 200, 0.3)',
        borderRadius: 15,
        padding: 10,
        flex: 1,
        marginRight: 10,
    },
    darkInfoPill: {
        backgroundColor: 'rgba(100, 100, 100, 0.3)',
    },
    infoPillIcon: {
        fontSize: 20,
    },
    infoPillTitle: {
        fontSize: 14,
        fontWeight: '600',
        color: 'gray',
    },
    infoPillValue: {
        fontSize: 16,
        fontWeight: '500',
    },
    funFactPill: {
        backgroundColor: 'rgba(100, 150, 255, 0.3)',
        borderRadius: 15,
        padding: 10,
        marginTop: 10,
    },
    darkFunFactPill: {
        backgroundColor: 'rgba(50, 100, 200, 0.3)',
    },
    funFactIcon: {
        fontSize: 20,
    },
    funFactTitle: {
        fontSize: 14,
        fontWeight: '600',
        color: 'gray',
    },
    funFactValue: {
        fontSize: 16,
        fontWeight: '500',
    },
    description: {
        fontSize: 18,
        padding: 15,
        textAlign: 'center',
    },
});

export default StructPopUp;