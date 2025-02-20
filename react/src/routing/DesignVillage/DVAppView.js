import React, { useEffect, useState } from "react";
import { View, ActivityIndicator, StyleSheet } from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";
import DVOnboarding from "./DVOnboarding";
import DVMain from "./DVMain";

const DVAppView = ({ setDesignVillageMode }) => {
  const [isLoading, setIsLoading] = useState(true);
  const [onboardingComplete, setOnboardingComplete] = useState(false);
  const [userRole, setUserRole] = useState(null);

  useEffect(() => {
    const initializeApp = async () => {
      try {
        const [status, role] = await Promise.all([
          AsyncStorage.getItem("DVOnboardingComplete"),
          AsyncStorage.getItem("DVUserRole"),
        ]);
        setOnboardingComplete(status === "true");
        setUserRole(role || "visitor");
      } catch (error) {
        console.error("Error fetching app state:", error);
      } finally {
        setIsLoading(false);
      }
    };
    initializeApp();
  }, []);

  const handleOnboardingComplete = async (selectedRole) => {
    try {
      await AsyncStorage.setItem("DVOnboardingComplete", "true");
      setUserRole(selectedRole);
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
    <DVMain
      setDesignVillageMode={setDesignVillageMode}
      userRole={userRole}
      setUserRole={setUserRole}
    />
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
