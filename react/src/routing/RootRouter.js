// src/RootRouter.js
import React, { useEffect, useState } from "react";
import { View, ActivityIndicator, AppState } from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";
import ContentView from "../AppView";
import DVAppView from "./DesignVillage/DVAppView"; // The static Design Village branch.
import DVDecisionPrompt from "./DVDecision";

// Development flags
const FORCE_DV_MODE_FOR_TESTING = __DEV__ && false;
const CLEAR_PREFERENCES_FOR_TESTING = __DEV__ && false;

// Helper function to create dates in local timezone
const createLocalDate = (dateString) => {
  const [year, month, day] = dateString.split("-").map(Number);
  return new Date(year, month - 1, day, 0, 0, 0);
};

// Define the event window: April 25 (00:00) to April 28 (00:00) in local time
const eventStartDate = createLocalDate("2025-04-25");
const eventEndDate = createLocalDate("2025-04-28");

// Helper to check if we're in the event window
const isInEventWindow = () => {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  return today >= eventStartDate && today < eventEndDate;
};

const RootRouter = () => {
  // designVillageMode:
  //    true  => DV mode,
  //    false => Poly Canyon,
  //    null  => decision pending (existing user during event window).
  const [designVillageMode, setDesignVillageMode] = useState(null);
  const [isLoading, setIsLoading] = useState(true);

  const checkMode = async () => {
    // Clear preferences if testing flag is set
    if (CLEAR_PREFERENCES_FOR_TESTING) {
      console.log("[RootRouter] Development mode - clearing saved preferences");
      await AsyncStorage.multiRemove([
        "designVillageModeOverride",
        "isFirstLaunchV2",
      ]);
    }

    // If forcing DV mode for testing
    if (FORCE_DV_MODE_FOR_TESTING) {
      console.log(
        "[RootRouter] Development mode - forcing Design Village mode"
      );
      setDesignVillageMode(true);
      setIsLoading(false);
      return;
    }

    const inEventWindow = isInEventWindow();
    console.log("[RootRouter] Current date:", new Date().toLocaleString());
    console.log(
      "[RootRouter] Event window:",
      eventStartDate.toLocaleString(),
      "to",
      eventEndDate.toLocaleString(),
      `(${inEventWindow ? "ACTIVE" : "INACTIVE"})`
    );

    // Debug: Log all relevant AsyncStorage values
    const [override, firstLaunch, forceReload] = await Promise.all([
      AsyncStorage.getItem("designVillageModeOverride"),
      AsyncStorage.getItem("isFirstLaunchV2"),
      AsyncStorage.getItem("forceReload"),
    ]);

    // Clear the force reload flag if it exists
    if (forceReload) {
      await AsyncStorage.removeItem("forceReload");
    }

    console.log("[RootRouter] Stored preferences:", {
      designVillageModeOverride: override,
      isFirstLaunchV2: firstLaunch,
      forceReload: forceReload,
    });

    if (!inEventWindow) {
      console.log(
        "[RootRouter] Outside event window - forcing Poly Canyon mode"
      );
      setDesignVillageMode(false);
      // Clear the override when outside event window
      await AsyncStorage.removeItem("designVillageModeOverride");
    } else {
      console.log(
        "[RootRouter] Within event window - checking user preferences"
      );
      // During event window, default to Design Village unless explicitly overridden
      if (override === "false") {
        // User explicitly chose Poly Canyon
        console.log("[RootRouter] User explicitly chose Poly Canyon");
        setDesignVillageMode(false);
      } else if (firstLaunch === null) {
        // New user - auto-route to Design Village
        console.log(
          "[RootRouter] New user detected - auto-routing to Design Village"
        );
        setDesignVillageMode(true);
        await AsyncStorage.setItem("designVillageModeOverride", "true");
      } else if (override === null) {
        // Existing user who hasn't made a choice - show prompt
        console.log(
          "[RootRouter] Existing user without preference - showing decision prompt"
        );
        setDesignVillageMode(null);
      } else {
        // Default or explicitly chose Design Village
        console.log("[RootRouter] Using Design Village mode");
        setDesignVillageMode(true);
      }
    }
    setIsLoading(false);
  };

  // Initial check on mount
  useEffect(() => {
    checkMode();
  }, []);

  // Add a listener for AsyncStorage changes
  useEffect(() => {
    // Subscribe to AsyncStorage changes
    const subscription = AppState.addEventListener(
      "change",
      async (nextAppState) => {
        if (nextAppState === "active") {
          checkMode();
        }
      }
    );

    // Check for changes to designVillageModeOverride every second
    const storageCheck = setInterval(async () => {
      try {
        const override = await AsyncStorage.getItem(
          "designVillageModeOverride"
        );
        const inEventWindow = isInEventWindow();

        if (!inEventWindow) {
          if (designVillageMode === true) {
            setDesignVillageMode(false);
          }
        } else {
          // During event window
          if (override === "false" && designVillageMode === true) {
            setDesignVillageMode(false);
          } else if (!override && designVillageMode === false) {
            setDesignVillageMode(true);
          }
        }
      } catch (error) {
        console.error("Error checking mode override:", error);
      }
    }, 1000);

    // Cleanup
    return () => {
      subscription.remove();
      clearInterval(storageCheck);
    };
  }, [designVillageMode]);

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
          // Only save override if choosing Poly Canyon
          if (!choice) {
            AsyncStorage.setItem("designVillageModeOverride", "false");
          } else {
            // If choosing Design Village, remove any override
            AsyncStorage.removeItem("designVillageModeOverride");
          }
        }}
      />
    );
  }

  // Render the appropriate branch.
  return designVillageMode ? (
    <DVAppView setDesignVillageMode={setDesignVillageMode} />
  ) : (
    <ContentView setDesignVillageMode={setDesignVillageMode} />
  );
};

export default RootRouter;
