import React, { useEffect, useState } from "react";
import { View, ActivityIndicator, StyleSheet } from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";
import DVOnboarding from "./DVOnboarding";
import DVMain from "./DVMain";

const DVAppView = ({ setDesignVillageMode }) => {
  const [isLoading, setIsLoading] = useState(true);
  const [onboardingComplete, setOnboardingComplete] = useState(false);

  useEffect(() => {
    const checkOnboardingStatus = async () => {
      try {
        const status = await AsyncStorage.getItem("DVOnboardingComplete");
        setOnboardingComplete(status === "true");
      } catch (error) {
        console.error("Error fetching onboarding status:", error);
      } finally {
        setIsLoading(false);
      }
    };
    checkOnboardingStatus();
  }, []);

  const handleOnboardingComplete = async () => {
    try {
      await AsyncStorage.setItem("DVOnboardingComplete", "true");
      setOnboardingComplete(true);
    } catch (error) {
      console.error("Error setting onboarding complete:", error);
    }
  };

  if (isLoading) {
    return (
      <View style={styles.loaderContainer}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  return onboardingComplete ? (
    <DVMain setDesignVillageMode={setDesignVillageMode} />
  ) : (
    <DVOnboarding onComplete={handleOnboardingComplete} />
  );
};

const styles = StyleSheet.create({
  loaderContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  },
});

export default DVAppView;
