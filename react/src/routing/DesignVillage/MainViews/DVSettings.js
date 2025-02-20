// DVSettings.js
import React, { useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  Image,
  Alert,
  Modal,
  Linking,
} from "react-native";
import Ionicons from "react-native-vector-icons/Ionicons";
import AsyncStorage from "@react-native-async-storage/async-storage";

// Import your images (ensure the paths are correct)
import OGDefault from "../Images/OGDefault.png";
import InstaIcon from "../Images/InstaIcon.png";
import CAEDLogo from "../Images/CAEDLogo.png";
import DVLogo from "../Images/DVLogo.png";

const DVSettings = ({ setDesignVillageMode }) => {
  const [showRulesPopup, setShowRulesPopup] = useState(false);

  const handleExplorePress = () => {
    Alert.alert(
      "Switch to Poly Canyon?",
      "Are you sure you want to switch? This will make your app the Poly Canyon experience. You can switch back in settings any time.",
      [
        { text: "Cancel", style: "cancel" },
        {
          text: "Switch",
          onPress: async () => {
            try {
              await AsyncStorage.setItem("designVillageModeOverride", "false");
              setDesignVillageMode(false);
            } catch (error) {
              console.error("Error switching app mode:", error);
            }
          },
        },
      ]
    );
  };

  return (
    <View style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        {/* Explore Button */}
        <TouchableOpacity
          style={styles.exploreButton}
          onPress={handleExplorePress}
        >
          <Image
            source={OGDefault}
            style={styles.exploreImage}
            resizeMode="cover"
          />
          <View style={styles.exploreTextContainer}>
            <Text style={styles.exploreText}>Explore the Canyon</Text>
            <Ionicons
              name="chevron-forward"
              size={20}
              style={styles.exploreChevron}
            />
          </View>
        </TouchableOpacity>

        {/* Divider */}
        <View style={styles.divider} />

        {/* Updated Social Section */}
        <View style={styles.socialSection}>
          <TouchableOpacity
            style={[styles.socialButton, styles.socialButtonLeft]}
            onPress={() =>
              Linking.openURL("https://www.instagram.com/designvillage.dwg/")
            }
          >
            <View style={styles.socialContent}>
              <Image
                source={InstaIcon}
                style={styles.socialIcon}
                resizeMode="contain"
              />
              <Text style={styles.socialText}>Instagram</Text>
            </View>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.socialButton, styles.socialButtonRight]}
            onPress={() =>
              Linking.openURL(
                "https://cpdesignvillage.wixstudio.com/designvillage/about"
              )
            }
          >
            <View style={styles.socialContent}>
              <Ionicons name="link" size={24} style={styles.socialIconLink} />
              <Text style={styles.socialText}>Website</Text>
            </View>
          </TouchableOpacity>
        </View>

        {/* Updated Credits Section */}
        <View style={styles.creditsSection}>
          <View style={styles.creditsLogos}>
            <Image
              source={CAEDLogo}
              style={styles.creditsLogo}
              resizeMode="contain"
            />
            <Image
              source={DVLogo}
              style={styles.creditsLogo}
              resizeMode="contain"
            />
          </View>
          <View style={styles.creditsTextContainer}>
            <Text style={styles.creditsText}>Developed by Parker Jones</Text>
            <Text style={styles.creditsSubText}>For CAED & Design Village</Text>
          </View>
        </View>
      </ScrollView>

      {/* Rules Popup Modal */}
      <Modal visible={showRulesPopup} animationType="slide" transparent={true}>
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>Rules</Text>
            <View style={styles.modalSpacer} />
            <TouchableOpacity
              style={styles.modalButton}
              onPress={() => setShowRulesPopup(false)}
            >
              <Text style={styles.modalButtonText}>Close</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#fafafa", // Similar to Color(white: 0.98)
  },
  header: {
    backgroundColor: "white",
    paddingHorizontal: 16,
    paddingTop: 10,
    paddingBottom: 5,
    // Mimic subtle shadow
    shadowColor: "#000",
    shadowOpacity: 0.05,
    shadowRadius: 8,
    shadowOffset: { width: 0, height: 4 },
    elevation: 2,
    marginBottom: 5,
  },
  headerContent: {
    flexDirection: "row",
    alignItems: "center",
  },
  headerTitle: {
    fontSize: 32,
    fontWeight: "bold",
    flex: 1,
  },
  headerIcon: {
    color: "black",
  },
  scrollContent: {
    paddingTop: 15,
    paddingBottom: 40,
  },
  exploreButton: {
    backgroundColor: "white",
    borderRadius: 16,
    marginHorizontal: 16,
    shadowColor: "#000",
    shadowOpacity: 0.08,
    shadowRadius: 10,
    shadowOffset: { width: 0, height: 4 },
    elevation: 3,
    marginBottom: 16,
  },
  exploreImage: {
    width: "100%",
    height: 160,
    borderTopLeftRadius: 16,
    borderTopRightRadius: 16,
  },
  exploreTextContainer: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    padding: 16,
  },
  exploreText: {
    fontSize: 24,
    fontWeight: "bold",
    color: "black",
  },
  exploreChevron: {
    color: "black",
  },
  rulesButton: {
    backgroundColor: "white",
    borderRadius: 12,
    marginHorizontal: 16,
    height: 72,
    justifyContent: "center",
    shadowColor: "#000",
    shadowOpacity: 0.08,
    shadowRadius: 8,
    shadowOffset: { width: 0, height: 4 },
    elevation: 3,
    marginBottom: 24,
  },
  rulesButtonContent: {
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 16,
  },
  rulesIcon: {
    color: "black",
    marginRight: 8,
  },
  rulesText: {
    fontSize: 20,
    fontWeight: "600",
    color: "black",
    flex: 1,
  },
  rulesChevron: {
    color: "black",
  },
  divider: {
    height: 1,
    backgroundColor: "#E0E0E0",
    marginHorizontal: 16,
    marginBottom: 24,
  },
  socialSection: {
    marginHorizontal: 16,
    flexDirection: "row",
    justifyContent: "space-between",
    marginBottom: 16,
  },
  socialButton: {
    flex: 1,
    backgroundColor: "white",
    borderRadius: 12,
    height: 60,
    justifyContent: "center",
    alignItems: "center",
    shadowColor: "#000",
    shadowOpacity: 0.08,
    shadowRadius: 8,
    shadowOffset: { width: 0, height: 4 },
    elevation: 3,
  },
  socialButtonLeft: {
    marginRight: 8,
  },
  socialButtonRight: {
    marginLeft: 8,
  },
  socialContent: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
  },
  socialIcon: {
    width: 24,
    height: 24,
    marginRight: 8,
  },
  socialIconLink: {
    marginRight: 8,
    color: "black",
  },
  socialText: {
    fontSize: 18,
    fontWeight: "600",
    color: "black",
  },
  creditsSection: {
    backgroundColor: "white",
    borderRadius: 16,
    marginHorizontal: 16,
    padding: 24,
    alignItems: "center",
    shadowColor: "#000",
    shadowOpacity: 0.08,
    shadowRadius: 10,
    shadowOffset: { width: 0, height: 4 },
    elevation: 3,
    marginTop: 0,
  },
  creditsLogos: {
    flexDirection: "row",
    justifyContent: "center",
    alignItems: "center",
    marginBottom: 16,
  },
  creditsLogo: {
    height: 45,
    width: 45,
    marginHorizontal: 12,
    borderRadius: 8,
    resizeMode: "contain",
  },
  creditsTextContainer: {
    alignItems: "center",
    marginTop: 8,
  },
  creditsText: {
    fontSize: 16,
    fontWeight: "500",
    color: "black",
  },
  creditsSubText: {
    fontSize: 14,
    color: "gray",
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: "rgba(0,0,0,0.3)",
    justifyContent: "center",
    alignItems: "center",
  },
  modalContent: {
    width: "80%",
    backgroundColor: "white",
    borderRadius: 16,
    padding: 20,
    alignItems: "center",
  },
  modalTitle: {
    fontSize: 28,
    fontWeight: "bold",
    marginTop: 40,
    marginBottom: 20,
  },
  modalSpacer: {
    flex: 1,
  },
  modalButton: {
    backgroundColor: "rgba(128,128,128,0.1)",
    borderRadius: 12,
    paddingVertical: 12,
    paddingHorizontal: 20,
    alignSelf: "stretch",
    margin: 20,
  },
  modalButtonText: {
    fontSize: 16,
    fontWeight: "600",
    color: "black",
    textAlign: "center",
  },
});

export default DVSettings;
