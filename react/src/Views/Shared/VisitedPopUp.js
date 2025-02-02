import React from "react";
import {
  View,
  Text,
  Image,
  TouchableOpacity,
  StyleSheet,
  Dimensions,
  Pressable,
} from "react-native";
import Icon from "react-native-vector-icons/Ionicons";
import { getMainPhoto } from "../../Core/Images/ImageRegistry";

const { width, height } = Dimensions.get("window");

// MARK: - VisitedStructurePopup Component
/**
 * Displays a popup when a structure is visited.
 * Adapts appearance based on Dark Mode settings.
 */
const VisitedStructurePopup = ({
  structure,
  isPresented,
  setIsPresented,
  isDarkMode,
  onStructurePress,
}) => {
  if (!structure) return null;

  return (
    <Pressable style={styles.overlay} onPress={() => setIsPresented(false)}>
      <View style={styles.container}>
        {/* Just Visited Banner */}
        <View style={styles.bannerContainer}>
          <Text style={styles.emoji}>🔥</Text>
          <Text style={styles.bannerText}>Just Visited!</Text>
        </View>

        {/* Image Container */}
        <View style={styles.imageContainer}>
          <Image
            source={getMainPhoto(structure.number)}
            style={styles.image}
            resizeMode="cover"
          />
          <View style={styles.numberBadge}>
            <Text style={styles.numberText}>#{structure.number}</Text>
          </View>
        </View>

        {/* Action Buttons */}
        <View style={styles.actionContainer}>
          <TouchableOpacity
            style={styles.dismissButton}
            onPress={() => setIsPresented(false)}
          >
            <Icon name="close" size={24} color="rgba(0,0,0,0.6)" />
          </TouchableOpacity>

          <View style={styles.divider} />

          <TouchableOpacity
            style={styles.learnMoreButton}
            onPress={() => onStructurePress(structure)}
          >
            <Text style={styles.learnMoreText}>Learn More</Text>
            <Icon
              name="chevron-forward"
              size={24}
              color="rgba(0,0,0,0.6)"
              style={styles.chevron}
            />
          </TouchableOpacity>
        </View>
      </View>
    </Pressable>
  );
};

const styles = StyleSheet.create({
  overlay: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: "rgba(0,0,0,0.8)",
    justifyContent: "center",
    alignItems: "center",
  },
  container: {
    width: width - 80,
    maxHeight: height * 0.7,
    backgroundColor: "white",
    borderRadius: 20,
    padding: 10,
    shadowColor: "#000",
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.25,
    shadowRadius: 10,
    elevation: 5,
  },
  bannerContainer: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#F5F5F5",
    borderRadius: 10,
    marginHorizontal: 16,
    marginTop: 10,
    padding: 8,
    shadowColor: "#000",
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  emoji: {
    fontSize: 30,
    marginRight: 8,
    marginTop: -2,
  },
  bannerText: {
    fontSize: 28,
    fontWeight: "600",
    color: "rgba(0,0,0,0.8)",
  },
  imageContainer: {
    margin: 20,
    borderRadius: 12,
    overflow: "hidden",
    shadowColor: "#000",
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 4,
    elevation: 3,
  },
  image: {
    width: "100%",
    height: 250,
    borderRadius: 12,
  },
  numberBadge: {
    position: "absolute",
    bottom: 8,
    right: 8,
    backgroundColor: "rgba(128,128,128,0.8)",
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 8,
  },
  numberText: {
    color: "white",
    fontSize: 22,
    fontWeight: "bold",
  },
  actionContainer: {
    flexDirection: "row",
    height: 50,
    backgroundColor: "#F5F5F5",
    borderRadius: 10,
    marginHorizontal: 20,
    marginBottom: 10,
    overflow: "hidden",
  },
  dismissButton: {
    width: 60,
    height: "100%",
    justifyContent: "center",
    alignItems: "center",
  },
  divider: {
    width: 1,
    height: "100%",
    backgroundColor: "rgba(0,0,0,0.1)",
  },
  learnMoreButton: {
    flex: 1,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
  },
  learnMoreText: {
    fontSize: 20,
    fontWeight: "600",
    color: "rgba(0,0,0,0.6)",
  },
  chevron: {
    marginLeft: 15,
  },
});

export default VisitedStructurePopup;
