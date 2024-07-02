import React, { useRef } from 'react';
import { View, Image, Dimensions, StyleSheet, TouchableOpacity } from 'react-native';
import Swiper from 'react-native-swiper';

const { width, height } = Dimensions.get('window');

const images = [
  require('C:/Users/parke/Desktop/PolyCanyon/assets/onboarding/jpg/1.jpg'),
  require('C:/Users/parke/Desktop/PolyCanyon/assets/onboarding/jpg/2.jpg'),
  require('C:/Users/parke/Desktop/PolyCanyon/assets/onboarding/jpg/3.jpg'),
  require('C:/Users/parke/Desktop/PolyCanyon/assets/onboarding/jpg/4.jpg'),
];

const OnboardingView = ({ onComplete }) => {
  const swiperRef = useRef(null);
  const totalPages = images.length;

  return (
    <View style={styles.container}>
      <Swiper
        ref={swiperRef}
        loop={false}
        showsPagination={true}
        paginationStyle={styles.pagination}
        dotStyle={styles.dot}
        activeDotStyle={styles.activeDot}
      >
        {images.map((image, index) => (
          <TouchableOpacity
            key={index}
            activeOpacity={1}
            onPress={() => {
              if (index !== totalPages - 1) {
                swiperRef.current.scrollBy(1);
              } else {
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
    backgroundColor: 'white',
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
