import React from "react";
import { View, TouchableOpacity, Image, Text } from "react-native";

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
  return (
    <View style={styles.popupContainer}>
      <View
        style={[
          styles.contentContainer,
          isDarkMode
            ? styles.darkContentContainer
            : styles.lightContentContainer,
        ]}
      >
        <TouchableOpacity
          style={styles.closeButton}
          onPress={() => setIsPresented(false)}
        >
          <Icon name="close" size={28} color={isDarkMode ? "white" : "black"} />
        </TouchableOpacity>
        <Image source={structure.mainImage.image} style={styles.popupImage} />
        <TouchableOpacity
          style={styles.textContainer}
          onPress={() => onStructurePress(structure)}
        >
          <Text
            style={[
              styles.justVisitedText,
              {
                color: isDarkMode ? "rgba(255,255,255,0.6)" : "rgba(0,0,0,0.8)",
              },
            ]}
          >
            Just Visited!
          </Text>
          <Text
            style={[
              styles.titleText,
              { color: isDarkMode ? "white" : "black" },
            ]}
          >
            {structure.title}
          </Text>
        </TouchableOpacity>
        <Text
          style={[
            styles.numberText,
            { color: isDarkMode ? "rgba(255,255,255,0.7)" : "rgba(0,0,0,0.7)" },
          ]}
        >
          {structure.number}
        </Text>
        <Icon
          name="chevron-forward"
          size={20}
          color={isDarkMode ? "white" : "black"}
          style={styles.chevron}
        />
      </View>
    </View>
  );
};
