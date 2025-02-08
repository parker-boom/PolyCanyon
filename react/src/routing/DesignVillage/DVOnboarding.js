import React, { useState } from "react";
import { View, Text, TouchableOpacity, StyleSheet } from "react-native";

const DVOnboarding = ({ onComplete }) => {
  const [currentSlide, setCurrentSlide] = useState(0);

  const slides = [
    <WelcomeSlide key="welcome" />,
    <AppOverviewSlide key="overview" />,
    <RulesSlide key="rules" />,
    <PolyCanyonNoticeSlide key="notice" />,
    <ConfirmationSlide key="confirmation" />,
  ];

  const handleNext = () => {
    if (currentSlide === slides.length - 1) {
      onComplete();
    } else {
      setCurrentSlide(currentSlide + 1);
    }
  };

  const handlePrevious = () => {
    if (currentSlide > 0) {
      setCurrentSlide(currentSlide - 1);
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.content}>{slides[currentSlide]}</View>
      <View style={styles.buttonContainer}>
        <TouchableOpacity onPress={handleNext} style={styles.button}>
          <Text style={styles.buttonText}>
            {currentSlide === slides.length - 1 ? "Finish" : "Next"}
          </Text>
        </TouchableOpacity>
        {currentSlide > 0 && (
          <TouchableOpacity onPress={handlePrevious} style={styles.button}>
            <Text style={styles.buttonText}>Previous</Text>
          </TouchableOpacity>
        )}
      </View>
    </View>
  );
};

const WelcomeSlide = () => (
  <View style={styles.slide}>
    <Text style={styles.slideTitle}>Welcome</Text>
    <Text style={styles.slideContent}>This is the welcome slide.</Text>
  </View>
);

const AppOverviewSlide = () => (
  <View style={styles.slide}>
    <Text style={styles.slideTitle}>App Overview</Text>
    <Text style={styles.slideContent}>This slide provides an overview of the app.</Text>
  </View>
);

const RulesSlide = () => (
  <View style={styles.slide}>
    <Text style={styles.slideTitle}>Rules</Text>
    <Text style={styles.slideContent}>This slide explains the rules.</Text>
  </View>
);

const PolyCanyonNoticeSlide = () => (
  <View style={styles.slide}>
    <Text style={styles.slideTitle}>Poly Canyon Notice</Text>
    <Text style={styles.slideContent}>This slide provides important notices about Poly Canyon.</Text>
  </View>
);

const ConfirmationSlide = () => (
  <View style={styles.slide}>
    <Text style={styles.slideTitle}>Confirmation</Text>
    <Text style={styles.slideContent}>Confirm your onboarding details on this slide.</Text>
  </View>
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
    justifyContent: "space-between",
  },
  content: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  },
  slide: {
    alignItems: "center",
  },
  slideTitle: {
    fontSize: 24,
    fontWeight: "bold",
    marginBottom: 10,
  },
  slideContent: {
    fontSize: 16,
    textAlign: "center",
  },
  buttonContainer: {
    marginBottom: 20,
  },
  button: {
    backgroundColor: "#007AFF",
    paddingVertical: 12,
    paddingHorizontal: 20,
    borderRadius: 8,
    marginVertical: 5,
    alignItems: "center",
  },
  buttonText: {
    color: "#FFFFFF",
    fontSize: 16,
  },
});

export default DVOnboarding;
