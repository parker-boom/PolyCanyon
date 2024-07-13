import React, { useState, useRef } from 'react';
import { View, Text, Image, TouchableOpacity, StyleSheet, Dimensions, SafeAreaView, PanResponder, Animated } from 'react-native';
import { BlurView } from '@react-native-community/blur';
import Ionicons from 'react-native-vector-icons/Ionicons';

const { width, height } = Dimensions.get('window');
const POPUP_HEIGHT = height * 0.85;

const StructPopUp = ({ structure, onClose, isDarkMode }) => {
  const [selectedImageIndex, setSelectedImageIndex] = useState(0);
  const pan = useRef(new Animated.ValueXY()).current;

  const panResponder = PanResponder.create({
    onStartShouldSetPanResponder: () => true,
    onMoveShouldSetPanResponder: () => true,
    onPanResponderGrant: () => {
      pan.setValue({ x: 0, y: 0 });
    },
    onPanResponderMove: (_, gestureState) => {
      pan.x.setValue(gestureState.dx);
    },
    onPanResponderRelease: (_, gestureState) => {
      if (gestureState.dx < -50 && selectedImageIndex === 0) {
        setSelectedImageIndex(1);
      } else if (gestureState.dx > 50 && selectedImageIndex === 1) {
        setSelectedImageIndex(0);
      }
      Animated.spring(pan, {
        toValue: { x: 0, y: 0 },
        useNativeDriver: true
      }).start();
    },
  });

  const imageStyle = {
    transform: [{ translateX: pan.x }]
  };

  return (
    <SafeAreaView style={[styles.container, isDarkMode && styles.darkContainer]}>
      <BlurView
        style={StyleSheet.absoluteFill}
        blurType={isDarkMode ? "dark" : "light"}
        blurAmount={10}
      />
      <View style={styles.content}>
        <Animated.View style={[styles.imageContainer, imageStyle]} {...panResponder.panHandlers}>
          {structure.mainImage && structure.closeUpImage && (
            <Image
              source={selectedImageIndex === 0 ? structure.mainImage : structure.closeUpImage}
              style={styles.image}
              resizeMode="cover"
            />
          )}
          <View style={styles.overlay}>
            <Text style={[styles.number, isDarkMode && styles.darkText]}>{structure.number}</Text>
            {/* Edit number style here */}
            <View style={styles.titleContainer}>
              <Text style={[styles.title, isDarkMode && styles.darkText]}>{structure.title}</Text>
              {/* Edit title style here */}
              {structure.year !== "xxxx" && (
                <Text style={[styles.year, isDarkMode && styles.darkText]}>{structure.year}</Text>
              )}
              {/* Edit year style here */}
            </View>
            <TouchableOpacity onPress={onClose} style={styles.closeButton}>
              <View style={styles.closeButtonCircle}>
                <Ionicons name="close" size={20} color={isDarkMode ? "black" : "white"} />
              </View>
            </TouchableOpacity>
          </View>
          <View style={styles.imageDots}>
            <View style={[styles.dot, selectedImageIndex === 0 && styles.activeDot]} />
            <View style={[styles.dot, selectedImageIndex === 1 && styles.activeDot]} />
          </View>
        </Animated.View>
        <View style={styles.descriptionContainer}>
          <Text style={[styles.description, isDarkMode && styles.darkText]}>
            {structure.description === "iii" ? "More information coming soon!" : structure.description}
          </Text>
          {/* Edit description style here */}
        </View>
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.9)',
  },
  darkContainer: {
    backgroundColor: 'rgba(0, 0, 0, 0.9)',
  },
  content: {
    width: width * 0.9,
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
  imageContainer: {
    width: '100%',
    height: POPUP_HEIGHT * 0.6,
    justifyContent: 'center',
    alignItems: 'center',
  },
  image: {
    width: '100%',
    height: '100%',
  },
  overlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    padding: 10,
  },
  number: {
    fontSize: 35,
    fontWeight: 'bold',
    color: 'white',
    textShadowColor: 'rgba(0, 0, 0, 0.75)',
    textShadowOffset: { width: -1, height: 1 },
    textShadowRadius: 10,
    paddingLeft: 10,
  },
  titleContainer: {
    flex: 1,
    alignItems: 'center',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    textAlign: 'center',
    color: 'white',
    textShadowColor: 'rgba(0, 0, 0, 0.75)',
    textShadowOffset: { width: -1, height: 1 },
    textShadowRadius: 10,
  },
  year: {
    fontSize: 24,
    textAlign: 'center',
    color: 'white',
    textShadowColor: 'rgba(0, 0, 0, 0.75)',
    textShadowOffset: { width: -1, height: 1 },
    textShadowRadius: 10,
  },
  closeButton: {
    width: 50,
    height: 50,
    justifyContent: 'center',
    alignItems: 'center',
  },
  closeButtonCircle: {
    width: 30,
    height: 30,
    borderRadius: 15,
    backgroundColor: 'rgba(255, 255, 255, 0.3)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  imageDots: {
    flexDirection: 'row',
    position: 'absolute',
    bottom: 10,
    alignSelf: 'center',
  },
  dot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: 'rgba(255, 255, 255, 0.5)',
    marginHorizontal: 5,
  },
  activeDot: {
    width: 12,
    height: 12,
    borderRadius: 6,
    backgroundColor: 'white',
  },
  descriptionContainer: {
    padding: 20,
    flex: 1,
  },
  description: {
    fontSize: 18,
    textAlign: 'center',
  },
  darkText: {
    color: 'white',
  },
});

export default StructPopUp;
