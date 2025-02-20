import React, { useState, useRef } from "react";
import {
  View,
  Text,
  Image,
  TouchableOpacity,
  StyleSheet,
  Animated,
} from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";

// Import images (using the images for slide 1 and 4)
// Make sure these paths are correct in your project.
import DVLogo from "./Images/DVLogo.png";
import OGDefault from "./Images/OGDefault.png";
// import DVNexus from './Images/DVNexus.png'; // Final slide image is commented out per instructions

// A simple role "enum"
const DVRole = {
  VISITOR: "visitor",
  COMPETITOR: "competitor",
};

const DVOnboarding = ({ onComplete }) => {
  const [currentSlide, setCurrentSlide] = useState(0);
  const [selectedRole, setSelectedRole] = useState(DVRole.VISITOR);
  const [onboardingComplete, setOnboardingComplete] = useState(false);

  const totalSlides = 5;

  const goToNextSlide = () => {
    if (currentSlide < totalSlides - 1) {
      setCurrentSlide(currentSlide + 1);
    }
  };

  const goToPreviousSlide = () => {
    if (currentSlide > 0) {
      setCurrentSlide(currentSlide - 1);
    }
  };

  const completeOnboarding = async () => {
    try {
      await AsyncStorage.setItem("DVUserRole", selectedRole);
      setOnboardingComplete(true);
      onComplete(selectedRole);
    } catch (error) {
      console.error("Error saving user role:", error);
    }
  };

  if (onboardingComplete) {
    return null;
  }

  // Render one slide at a time based on currentSlide
  let slideComponent;
  switch (currentSlide) {
    case 0:
      slideComponent = <DVWelcomeSlide onNext={goToNextSlide} />;
      break;
    case 1:
      slideComponent = (
        <DVOverviewSlide onNext={goToNextSlide} onBack={goToPreviousSlide} />
      );
      break;
    case 2:
      slideComponent = (
        <DVRulesSlide
          selectedRole={selectedRole}
          setSelectedRole={setSelectedRole}
          onNext={goToNextSlide}
          onBack={goToPreviousSlide}
        />
      );
      break;
    case 3:
      slideComponent = (
        <DVPolyCanyonSlide onNext={goToNextSlide} onBack={goToPreviousSlide} />
      );
      break;
    case 4:
      slideComponent = <DVFinalSlide onComplete={completeOnboarding} />;
      break;
    default:
      slideComponent = null;
  }

  return (
    <View style={styles.container}>
      {slideComponent}
      {currentSlide < 4 && (
        <DVOnboardingIndicator
          totalStages={totalSlides}
          currentStage={currentSlide}
        />
      )}
    </View>
  );
};

// A base slide component that provides layout and navigation buttons.
const DVBaseSlide = ({
  children,
  buttonText = "Next",
  buttonAction,
  buttonDisabled = false,
  showBackButton = true,
  onBack,
}) => {
  return (
    <View style={styles.baseSlide}>
      <View style={styles.contentContainer}>{children}</View>
      <View style={styles.navigationContainer}>
        <TouchableOpacity
          style={[styles.navButton, buttonDisabled && styles.navButtonDisabled]}
          onPress={buttonAction}
          disabled={buttonDisabled}
        >
          <Text style={styles.navButtonText}>{buttonText}</Text>
        </TouchableOpacity>
        {showBackButton && onBack && (
          <TouchableOpacity onPress={onBack}>
            <Text style={styles.backButton}>Back</Text>
          </TouchableOpacity>
        )}
      </View>
    </View>
  );
};

// Slide 1: Welcome
const DVWelcomeSlide = ({ onNext }) => {
  return (
    <DVBaseSlide buttonText="Next" buttonAction={onNext} showBackButton={false}>
      <View style={styles.centerContent}>
        <Text style={styles.welcomeTitle}>Welcome to</Text>
        <Text style={styles.welcomeSubtitle}>Design Village!</Text>
        <Image source={DVLogo} style={styles.logoImage} resizeMode="contain" />
        <Text style={styles.orientationText}>Let's get you oriented.</Text>
      </View>
    </DVBaseSlide>
  );
};

// Slide 2: Overview
const DVOverviewSlide = ({ onNext, onBack }) => {
  return (
    <DVBaseSlide buttonText="Next" buttonAction={onNext} onBack={onBack}>
      <View style={styles.centerContent}>
        <Text style={styles.overviewTitle}>The DV app has:</Text>
        <View style={styles.featureList}>
          <DVFeatureRow icon="map" text="A Map of the area" />
          <DVFeatureRow icon="calendar" text="Schedule for events" />
          <DVFeatureRow icon="info-circle" text="Info on the history" />
        </View>
      </View>
    </DVBaseSlide>
  );
};

// A callout component for important messages
const DVCallout = ({ text }) => {
  return (
    <View style={styles.calloutContainer}>
      <Text style={styles.calloutIcon}>📋</Text>
      <Text style={styles.calloutText}>{text}</Text>
    </View>
  );
};

// A compact rule row specifically for competitor rules
const DVCompactRuleRow = ({ icon, text }) => {
  return (
    <View style={styles.compactRuleRow}>
      <Text style={styles.compactRuleIcon}>{icon}</Text>
      <Text style={styles.compactRuleText}>{text}</Text>
    </View>
  );
};

// Slide 3: Rules (with a two-stage experience)
const DVRulesSlide = ({ selectedRole, setSelectedRole, onNext, onBack }) => {
  const [hasSelectedRole, setHasSelectedRole] = useState(false);

  const handleSelectRole = (role) => {
    setSelectedRole(role);
    setHasSelectedRole(true);
  };

  // Helper function to get the correct rules based on role
  const getRoleRules = (role) => {
    if (role === DVRole.COMPETITOR) {
      return [
        { icon: "🏠", text: "Build a stable shelter" },
        { icon: "🌿", text: "Preserve the site" },
        { icon: "📝", text: "Submit documentation" },
        { icon: "🌙", text: "Stay overnight" },
        { icon: "⚠️", text: "Follow safety rules" },
      ];
    } else {
      return [
        { icon: "👥", text: "Follow event staff guidance" },
        { icon: "🚶‍♂️", text: "Stay in visitor areas" },
        { icon: "🏗️", text: "Respect competitor spaces" },
        { icon: "✨", text: "Keep a safe distance" },
      ];
    }
  };

  return (
    <DVBaseSlide
      buttonText="Next"
      buttonAction={onNext}
      onBack={onBack}
      buttonDisabled={!hasSelectedRole}
    >
      <View style={styles.centerContent}>
        {!hasSelectedRole ? (
          <>
            <Text style={styles.rulesQuestion}>
              How are you experiencing Design Village?
            </Text>
            <View style={styles.rolesContainer}>
              <DVRoleButton
                title="Competitor"
                icon="🏃‍♂️"
                isSelected={selectedRole === DVRole.COMPETITOR}
                onPress={() => handleSelectRole(DVRole.COMPETITOR)}
              />
              <DVRoleButton
                title="Visitor"
                icon="👥"
                isSelected={selectedRole === DVRole.VISITOR}
                onPress={() => handleSelectRole(DVRole.VISITOR)}
              />
            </View>
          </>
        ) : (
          <>
            <Text style={styles.rulesSelected}>
              {selectedRole === DVRole.COMPETITOR
                ? "Competitor Rules"
                : "Visitor Guidelines"}
            </Text>
            <View style={styles.rulesContainer}>
              {selectedRole === DVRole.COMPETITOR ? (
                <>
                  <View style={styles.compactRulesList}>
                    {getRoleRules(selectedRole).map((rule, index) => (
                      <DVCompactRuleRow
                        key={index}
                        icon={rule.icon}
                        text={rule.text}
                      />
                    ))}
                  </View>
                  <DVCallout text="Visit the Rules tab for complete competition guidelines. All rules must be followed to participate." />
                </>
              ) : (
                <View style={styles.featureList}>
                  {getRoleRules(selectedRole).map((rule, index) => (
                    <DVFeatureRow
                      key={index}
                      icon={rule.icon}
                      text={rule.text}
                    />
                  ))}
                </View>
              )}
            </View>
          </>
        )}
      </View>
    </DVBaseSlide>
  );
};

// Slide 4: Poly Canyon Info
const DVPolyCanyonSlide = ({ onNext, onBack }) => {
  return (
    <DVBaseSlide buttonText="Next" buttonAction={onNext} onBack={onBack}>
      <View style={styles.centerContent}>
        <Text style={styles.polyTitle}>Curious about{"\n"}the canyon?</Text>
        <Image source={OGDefault} style={styles.polyImage} resizeMode="cover" />
        <DVSettingsPrompt text="Switch to 'Poly Canyon' to explore the structures!" />
      </View>
    </DVBaseSlide>
  );
};

// Slide 5: Final slide (image commented out)
const DVFinalSlide = ({ onComplete }) => {
  const [shouldComplete, setShouldComplete] = useState(false);
  const scaleAnim = useRef(new Animated.Value(1)).current;

  const handleEnter = () => {
    // Animate a scaling effect similar to the SwiftUI animation
    Animated.timing(scaleAnim, {
      toValue: 12,
      duration: 800,
      useNativeDriver: true,
    }).start(() => {
      setShouldComplete(true);
      setTimeout(() => {
        onComplete();
      }, 700);
    });
  };

  return (
    <View style={styles.finalContainer}>
      <View style={styles.finalContent}>
        {/*
        <Animated.Image
          source={DVNexus}
          style={[
            styles.finalImage,
            { transform: [{ scale: scaleAnim }], opacity: shouldComplete ? 0 : 1 },
          ]}
          resizeMode="contain"
        />
        */}
        <Text style={styles.finalTitle}>It takes a village.</Text>
        <Text style={styles.finalSubtitle}>
          Welcome to the nexus of creative connections!
        </Text>
      </View>
      <TouchableOpacity
        style={styles.enterButton}
        onPress={handleEnter}
        disabled={shouldComplete}
      >
        <Text style={styles.enterButtonText}>Enter Design Village</Text>
      </TouchableOpacity>
    </View>
  );
};

// An indicator at the top showing the current slide (hidden on the final slide)
const DVOnboardingIndicator = ({ totalStages, currentStage }) => {
  return (
    <View style={styles.indicatorContainer}>
      {Array.from({ length: totalStages }).map((_, index) => (
        <View
          key={index}
          style={[
            styles.indicatorDot,
            index === currentStage
              ? styles.indicatorDotActive
              : styles.indicatorDotInactive,
          ]}
        />
      ))}
    </View>
  );
};

// A row to display a feature with an icon and text.
const DVFeatureRow = ({ icon, text }) => {
  // Map text descriptions to actual icons
  const getIcon = (iconName) => {
    switch (iconName) {
      case "map":
        return "🗺️";
      case "calendar":
        return "📅";
      case "info-circle":
        return "ℹ️";
      default:
        return iconName; // For cases where we already pass an emoji
    }
  };

  return (
    <View style={styles.featureRow}>
      <Text style={styles.featureIcon}>{getIcon(icon)}</Text>
      <Text style={styles.featureText}>{text}</Text>
    </View>
  );
};

// A button used in the Rules slide for selecting a role.
const DVRoleButton = ({ title, icon, isSelected, onPress }) => {
  return (
    <TouchableOpacity
      style={[
        styles.roleButton,
        isSelected ? styles.roleButtonSelected : styles.roleButtonUnselected,
      ]}
      onPress={onPress}
    >
      <Text style={[styles.roleIcon, isSelected && styles.roleIconSelected]}>
        {icon}
      </Text>
      <Text style={[styles.roleTitle, isSelected && styles.roleTitleSelected]}>
        {title}
      </Text>
    </TouchableOpacity>
  );
};

// A prompt with a gear icon and text.
const DVSettingsPrompt = ({ text }) => {
  return (
    <View style={styles.settingsPrompt}>
      <Text style={styles.settingsIcon}>⚙️</Text>
      <Text style={styles.settingsText}>{text}</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#fff",
  },
  completeContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  },
  completeText: {
    fontSize: 24,
    fontWeight: "bold",
  },
  baseSlide: {
    flex: 1,
    justifyContent: "space-between",
    paddingHorizontal: 20,
    paddingTop: 100,
    paddingBottom: 60,
  },
  contentContainer: {
    flex: 1,
    alignItems: "center",
  },
  navigationContainer: {
    alignItems: "center",
  },
  navButton: {
    backgroundColor: "black",
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderRadius: 25,
    marginBottom: 10,
  },
  navButtonDisabled: {
    backgroundColor: "gray",
  },
  navButtonText: {
    color: "white",
    fontSize: 18,
    fontWeight: "bold",
  },
  backButton: {
    fontSize: 16,
    fontWeight: "500",
    color: "black",
    textDecorationLine: "underline",
  },
  centerContent: {
    alignItems: "center",
  },
  welcomeTitle: {
    fontSize: 32,
    fontWeight: "bold",
    color: "black",
    marginBottom: 0,
  },
  welcomeSubtitle: {
    fontSize: 50,
    fontWeight: "bold",
    color: "black",
    marginBottom: 15,
  },
  logoImage: {
    width: 200,
    height: 200,
    borderRadius: 40,
    marginBottom: 30,
  },
  orientationText: {
    fontSize: 28,
    fontWeight: "600",
    color: "rgba(0,0,0,0.8)",
    textAlign: "center",
    paddingHorizontal: 30,
  },
  overviewTitle: {
    fontSize: 38,
    fontWeight: "bold",
    color: "black",
    marginBottom: 50,
  },
  featureList: {
    width: "100%",
    alignItems: "center",
    paddingHorizontal: 20,
  },
  featureRow: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "flex-start",
    marginVertical: 12,
    width: "100%",
    paddingHorizontal: 30,
  },
  featureIcon: {
    fontSize: 34,
    width: 45,
    textAlign: "center",
    marginRight: 15,
  },
  featureText: {
    flex: 1,
    fontSize: 24,
    fontWeight: "600",
    color: "black",
  },
  rulesQuestion: {
    fontSize: 32,
    fontWeight: "bold",
    color: "black",
    textAlign: "center",
    marginBottom: 40,
  },
  rolesContainer: {
    flexDirection: "row",
    justifyContent: "space-between",
    width: "100%",
    paddingHorizontal: 20,
  },
  roleButton: {
    flex: 1,
    height: 160,
    marginHorizontal: 10,
    borderRadius: 20,
    justifyContent: "center",
    alignItems: "center",
  },
  roleButtonSelected: {
    backgroundColor: "black",
  },
  roleButtonUnselected: {
    backgroundColor: "rgba(128,128,128,0.2)",
  },
  roleIcon: {
    fontSize: 40,
    fontWeight: "bold",
    marginBottom: 10,
    color: "black",
  },
  roleIconSelected: {
    color: "white",
  },
  roleTitle: {
    fontSize: 22,
    fontWeight: "bold",
    color: "black",
  },
  roleTitleSelected: {
    color: "white",
  },
  rulesSelected: {
    fontSize: 32,
    fontWeight: "bold",
    color: "black",
    marginBottom: 25,
    textAlign: "center",
  },
  rulesContainer: {
    width: "100%",
    alignItems: "center",
    paddingHorizontal: 20,
  },
  compactRulesList: {
    width: "100%",
    marginBottom: 20,
  },
  compactRuleRow: {
    flexDirection: "row",
    alignItems: "center",
    marginVertical: 8,
    width: "100%",
  },
  compactRuleIcon: {
    fontSize: 24,
    width: 40,
    textAlign: "center",
  },
  compactRuleText: {
    flex: 1,
    fontSize: 18,
    fontWeight: "600",
    color: "black",
    marginLeft: 12,
  },
  polyTitle: {
    fontSize: 38,
    fontWeight: "bold",
    color: "black",
    textAlign: "center",
    marginBottom: 10,
  },
  polyImage: {
    width: 330,
    height: 220,
    borderRadius: 25,
    marginBottom: 20,
  },
  settingsPrompt: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "rgba(128,128,128,0.15)",
    paddingHorizontal: 20,
    paddingVertical: 16,
    borderRadius: 16,
    marginHorizontal: 40,
  },
  settingsIcon: {
    fontSize: 24,
    fontWeight: "bold",
    marginRight: 12,
  },
  settingsText: {
    fontSize: 20,
    fontWeight: "500",
  },
  finalContainer: {
    flex: 1,
    justifyContent: "space-between",
    paddingHorizontal: 20,
    paddingVertical: 60,
    alignItems: "center",
  },
  finalContent: {
    alignItems: "center",
  },
  finalImage: {
    width: 200,
    height: 200,
    marginBottom: 30,
  },
  finalTitle: {
    fontSize: 36,
    fontWeight: "bold",
    color: "black",
    textAlign: "center",
    marginBottom: 15,
  },
  finalSubtitle: {
    fontSize: 24,
    fontWeight: "500",
    color: "black",
    textAlign: "center",
  },
  enterButton: {
    backgroundColor: "black",
    paddingHorizontal: 20,
    paddingVertical: 16,
    borderRadius: 30,
    width: 250,
    alignItems: "center",
    marginBottom: 50,
  },
  enterButtonText: {
    fontSize: 22,
    fontWeight: "bold",
    color: "white",
  },
  indicatorContainer: {
    position: "absolute",
    top: 20,
    alignSelf: "center",
    flexDirection: "row",
    backgroundColor: "rgba(128,128,128,0.1)",
    paddingHorizontal: 20,
    paddingVertical: 8,
    borderRadius: 20,
    shadowColor: "#000",
    shadowOpacity: 0.1,
    shadowRadius: 4,
    shadowOffset: { width: 0, height: 2 },
  },
  indicatorDot: {
    marginHorizontal: 6,
  },
  indicatorDotActive: {
    width: 12,
    height: 12,
    borderRadius: 6,
    backgroundColor: "black",
  },
  indicatorDotInactive: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: "rgba(128,128,128,0.5)",
  },
  calloutContainer: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "rgba(0,0,0,0.05)",
    padding: 16,
    borderRadius: 16,
    width: "100%",
    borderWidth: 1,
    borderColor: "rgba(0,0,0,0.1)",
  },
  calloutIcon: {
    fontSize: 24,
    marginRight: 12,
  },
  calloutText: {
    flex: 1,
    fontSize: 18,
    fontWeight: "600",
    color: "black",
    lineHeight: 24,
  },
});

export default DVOnboarding;
