// src/RootRouter.js
import React, { useEffect, useState } from "react";
import { View, ActivityIndicator } from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";
import ContentView from "./AppView"; // This is your existing poly canyon flow with all providers.
import DVAppView from "./DesignVillage/DVAppView";   // The static Design Village branch.
import DVDecisionPrompt from "./DVDecision";

// Define the event window: April 25 (00:00) to April 28 (00:00)
const eventStartDate = new Date("2025-04-25T00:00:00");
const eventEndDate = new Date("2025-04-28T00:00:00");

const RootRouter = () => {
  // designVillageMode: 
  //    true  => DV mode,
  //    false => Poly Canyon,
  //    null  => decision pending (existing user during event window).
  const [designVillageMode, setDesignVillageMode] = useState(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const checkMode = async () => {
      const now = new Date();
      if (now < eventStartDate || now >= eventEndDate) {
        // Outside event window: force Poly Canyon mode.
        setDesignVillageMode(false);
        await AsyncStorage.setItem("designVillageModeOverride", "false");
      } else {
        // Within the event window.
        const override = await AsyncStorage.getItem("designVillageModeOverride");
        if (override !== null) {
          setDesignVillageMode(override === "true");
        } else {
          // Check onboarding status via isFirstLaunchV2.
          const isFirstLaunch = await AsyncStorage.getItem("isFirstLaunchV2");
          if (isFirstLaunch === null) {
            // New user: auto-route to DV.
            setDesignVillageMode(true);
            await AsyncStorage.setItem("designVillageModeOverride", "true");
          } else {
            // Existing user without a decision: prompt for a decision.
            setDesignVillageMode(null);
          }
        }
      }
      setIsLoading(false);
    };

    checkMode();
  }, []);

  if (isLoading) {
    // Optionally, show a loading spinner.
    return (
      <View style={{ flex: 1, justifyContent: "center", alignItems: "center" }}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  if (designVillageMode === null) {
    // Show the prompt for existing users to decide.
    return (
      <DVDecisionPrompt
        onDecision={(choice) => {
          setDesignVillageMode(choice);
          AsyncStorage.setItem("designVillageModeOverride", choice ? "true" : "false");
        }}
      />
    );
  }

  // Render the appropriate branch.
  return designVillageMode ? <DVAppView /> : <ContentView />;
};

export default RootRouter;
