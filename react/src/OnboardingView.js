import React from 'react';
import { View, Image, TouchableWithoutFeedback, Dimensions, StyleSheet } from 'react-native';

const OnboardingView = ({ onOnboardingComplete }) => {
  const windowWidth = Dimensions.get('window').width;
  const windowHeight = Dimensions.get('window').height;
  const imageWidth = 1080;
  const imageHeight = 1920;

  const scaleFactor = Math.min(windowWidth / imageWidth, windowHeight / imageHeight);
  const scaledWidth = imageWidth * scaleFactor;
  const scaledHeight = imageHeight * scaleFactor;

  return (
    <TouchableWithoutFeedback onPress={onOnboardingComplete}>
      <View style={styles.container}>
        <Image
          source={require('../assets/onboarding/Onboarding.jpg')}
          style={{
            width: scaledWidth,
            height: scaledHeight,
            borderRadius: 20,
          }}
          resizeMode="contain"
        />
      </View>
    </TouchableWithoutFeedback>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
  },
});

export default OnboardingView;