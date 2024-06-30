import React, { useState } from 'react';
import { View, Image, Dimensions, StyleSheet, TouchableOpacity, Text } from 'react-native';
import Swiper from 'react-native-swiper';

const { width, height } = Dimensions.get('window');

const images = [
  require('C:/Users/parke/Desktop/PolyCanyon/assets/onboarding/jpg/1.jpg'),
  require('C:/Users/parke/Desktop/PolyCanyon/assets/onboarding/jpg/2.jpg'),
  require('C:/Users/parke/Desktop/PolyCanyon/assets/onboarding/jpg/3.jpg'),
  require('C:/Users/parke/Desktop/PolyCanyon/assets/onboarding/jpg/4.jpg'),
];

const OnboardingView = ({ onComplete }) => {
  const [currentPage, setCurrentPage] = useState(0);
  const totalPages = images.length;

  return (
    <View style={styles.container}>
      <Text style={styles.debugText}>Onboarding Screen</Text>
      <Swiper
        loop={false}
        showsPagination={true}
        paginationStyle={styles.pagination}
        dotStyle={styles.dot}
        activeDotStyle={styles.activeDot}
        onIndexChanged={(index) => setCurrentPage(index)}
      >
        {images.map((image, index) => (
          <TouchableOpacity
            key={index}
            activeOpacity={1}
            onPress={() => {
              if (index === totalPages - 1) {
                onComplete();
              }
            }}
            style={styles.slide}
          >
            <Image
              source={image}
              style={styles.image}
              onLoad={() => console.log(`Image ${index + 1} loaded successfully.`)}
              onError={(error) => console.log(`Error loading image ${index + 1}:`, error)}
            />
          </TouchableOpacity>
        ))}
      </Swiper>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'lightblue',
  },
  debugText: {
    fontSize: 24,
    color: 'red',
    textAlign: 'center',
    margin: 20,
  },
  slide: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  image: {
    width: width,
    height: height,
    resizeMode: 'contain',
  },
  pagination: {
    bottom: 30,
  },
  dot: {
    backgroundColor: 'rgba(0,0,0,.2)',
    width: 8,
    height: 8,
    borderRadius: 4,
    margin: 3,
  },
  activeDot: {
    backgroundColor: '#000',
    width: 8,
    height: 8,
    borderRadius: 4,
    margin: 3,
  },
});

export default OnboardingView;
