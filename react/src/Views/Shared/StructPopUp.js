// MARK: - StructNew Component
import React, { useState, useEffect } from "react";
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StyleSheet,
  Dimensions,
  Platform,
} from "react-native";
import FastImage from "react-native-fast-image";
import { BlurView } from "@react-native-community/blur";
import Ionicons from "react-native-vector-icons/Ionicons";
import { useNavigation } from "@react-navigation/native";
import { useDataStore } from "../../Core/Data/DataStore";
import { useAppState } from "../../Core/States/AppState";
import { useDarkMode } from "../../Core/States/DarkMode";
import { getImageSource } from "../../Core/Images/ImageRegistry";

const { width, height } = Dimensions.get("window");

const HeaderView = ({ structure, onClose, isDarkMode }) => (
  <View style={[styles.header, isDarkMode && styles.darkHeader]}>
    <View style={styles.headerContent}>
      <View
        style={[styles.numberCircle, isDarkMode && styles.darkNumberCircle]}
      >
        <Text style={[styles.numberText, isDarkMode && styles.darkNumberText]}>
          {structure.number}
        </Text>
      </View>

      <View
        style={[styles.titleContainer, isDarkMode && styles.darkTitleContainer]}
      >
        <Text style={[styles.titleText, isDarkMode && styles.darkTitleText]}>
          {structure.title}
        </Text>
      </View>

      <TouchableOpacity
        style={[styles.closeButton, isDarkMode && styles.darkCloseButton]}
        onPress={onClose}
      >
        <Ionicons
          name="close"
          size={24}
          color={isDarkMode ? "white" : "black"}
        />
      </TouchableOpacity>
    </View>
  </View>
);

const InfoSection = ({ structure, isDarkMode, onImagePress }) => (
  <ScrollView style={styles.infoSection} showsVerticalScrollIndicator={false}>
    <View style={styles.infoContent}>
      <View style={styles.topRow}>
        <TouchableOpacity
          style={styles.mainImageContainer}
          onPress={onImagePress}
        >
          <FastImage
            source={getImageSource(structure.images[0])}
            style={styles.mainImage}
          />
          {structure.year !== "xxxx" && (
            <View style={styles.yearBadge}>
              <Text style={styles.yearText}>{structure.year}</Text>
            </View>
          )}
        </TouchableOpacity>

        <View style={styles.funFactContainer}>
          <Text
            style={[styles.sectionTitle, isDarkMode && styles.darkSectionTitle]}
          >
            💯 FUN FACT
          </Text>
          <Text
            style={[styles.funFactText, isDarkMode && styles.darkFunFactText]}
          >
            {structure.funFact}
          </Text>
        </View>
      </View>

      <View style={styles.infoBox}>
        <Text
          style={[styles.sectionTitle, isDarkMode && styles.darkSectionTitle]}
        >
          📝 DESCRIPTION
        </Text>
        <Text
          style={[
            styles.descriptionText,
            isDarkMode && styles.darkDescriptionText,
          ]}
        >
          {structure.description}
        </Text>
      </View>

      {structure.builders !== "iii" && (
        <View style={[styles.infoBox, isDarkMode && styles.darkInfoBox]}>
          <Text
            style={[styles.sectionTitle, isDarkMode && styles.darkSectionTitle]}
          >
            👷 BUILDERS
          </Text>
          <Text style={[styles.infoText, isDarkMode && styles.darkInfoText]}>
            {structure.builders}
          </Text>
        </View>
      )}

      {structure.advisors && structure.advisors.length > 0 && (
        <View style={[styles.infoBox, isDarkMode && styles.darkInfoBox]}>
          <Text
            style={[styles.sectionTitle, isDarkMode && styles.darkSectionTitle]}
          >
            🎓 ADVISORS
          </Text>
          <Text style={[styles.infoText, isDarkMode && styles.darkInfoText]}>
            {Array.isArray(structure.advisors)
              ? structure.advisors.join(", ")
              : structure.advisors}
          </Text>
        </View>
      )}
    </View>
  </ScrollView>
);

const ImagesSection = ({ structure, onLikeToggle, isLiked, isDarkMode }) => {
  const [currentIndex, setCurrentIndex] = useState(0);

  return (
    <View style={styles.imagesSection}>
      <ScrollView
        horizontal
        pagingEnabled
        showsHorizontalScrollIndicator={false}
        onMomentumScrollEnd={(e) => {
          const newIndex = Math.round(e.nativeEvent.contentOffset.x / width);
          setCurrentIndex(newIndex);
        }}
      >
        {structure.images.map((imageKey, index) => (
          <View
            key={imageKey}
            style={[
              styles.imagePageContainer,
              { position: "relative", overflow: "hidden" },
            ]}
          >
            {/* Background blurred image */}
            <FastImage
              source={getImageSource(imageKey)}
              style={[
                StyleSheet.absoluteFill,
                styles.backgroundImage,
                { zIndex: 0 },
              ]}
              resizeMode="cover"
            />
            <BlurView
              style={[StyleSheet.absoluteFill, { zIndex: 1 }]}
              blurType={isDarkMode ? "dark" : "light"}
              blurAmount={10}
            />

            {/* Foreground clear image */}
            <FastImage
              source={getImageSource(imageKey)}
              style={[styles.foregroundImage, { zIndex: 2 }]}
              resizeMode="contain"
            />
          </View>
        ))}
      </ScrollView>

      <View style={styles.dotsContainer}>
        {structure.images.map((_, index) => (
          <View
            key={index}
            style={[styles.dot, currentIndex === index && styles.activeDot]}
          />
        ))}
      </View>

      <TouchableOpacity style={styles.likeButton} onPress={onLikeToggle}>
        <Ionicons
          name={isLiked ? "heart" : "heart-outline"}
          size={48}
          color={isLiked ? "red" : "white"}
        />
      </TouchableOpacity>
    </View>
  );
};

const BottomTabPicker = ({ selectedTab, onTabChange, isDarkMode }) => (
  <View style={[styles.bottomTab, isDarkMode && styles.darkBottomTab]}>
    <View style={[styles.tabPicker, isDarkMode && styles.darkTabPicker]}>
      <TouchableOpacity
        style={[
          styles.tabButton,
          selectedTab === "info" && styles.activeTab,
          isDarkMode && styles.darkActiveTab,
        ]}
        onPress={() => onTabChange("info")}
      >
        <Ionicons
          name="information-circle"
          size={24}
          color={selectedTab === "info" ? "black" : "gray"}
        />
        <Text
          style={[
            styles.tabText,
            selectedTab === "info" && styles.activeTabText,
            isDarkMode && styles.darkTabText,
          ]}
        >
          Info
        </Text>
      </TouchableOpacity>

      <View style={[styles.tabDivider, isDarkMode && styles.darkTabDivider]} />

      <TouchableOpacity
        style={[
          styles.tabButton,
          selectedTab === "images" && styles.activeTab,
          isDarkMode && styles.darkActiveTab,
        ]}
        onPress={() => onTabChange("images")}
      >
        <Ionicons
          name="images"
          size={24}
          color={selectedTab === "images" ? "black" : "gray"}
        />
        <Text
          style={[
            styles.tabText,
            selectedTab === "images" && styles.activeTabText,
            isDarkMode && styles.darkTabText,
          ]}
        >
          Images
        </Text>
      </TouchableOpacity>
    </View>
  </View>
);

const StructPopUp = () => {
  const navigation = useNavigation();
  const { isDarkMode } = useDarkMode();
  const { selectedStructure, setSelectedStructure } = useAppState();
  const { getStructure, toggleStructureLiked, markStructureAsOpened } =
    useDataStore();
  const [selectedTab, setSelectedTab] = useState("info");

  const structure = getStructure(selectedStructure);

  useEffect(() => {
    if (structure.isVisited) {
      markStructureAsOpened(structure.number);
    }
  }, []);

  if (!structure) return null;

  const handleClose = () => {
    setSelectedStructure(null);
    navigation.goBack();
  };

  return (
    <View style={[styles.container, isDarkMode && styles.darkContainer]}>
      <HeaderView
        structure={structure}
        onClose={handleClose}
        isDarkMode={isDarkMode}
      />
      <View style={styles.content}>
        {selectedTab === "info" ? (
          <InfoSection
            structure={structure}
            isDarkMode={isDarkMode}
            onImagePress={() => setSelectedTab("images")}
          />
        ) : (
          <ImagesSection
            structure={structure}
            onLikeToggle={() => toggleStructureLiked(structure.number)}
            isLiked={structure.isLiked}
            isDarkMode={isDarkMode}
          />
        )}
      </View>
      <BottomTabPicker
        selectedTab={selectedTab}
        onTabChange={setSelectedTab}
        isDarkMode={isDarkMode}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "white",
  },
  darkContainer: {
    backgroundColor: "#121212",
  },
  header: {
    height: height * 0.1,
    backgroundColor: "#f5f5f5",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  darkHeader: {
    backgroundColor: "#1c1c1e",
  },
  headerContent: {
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 16,
    paddingBottom: 30,
    height: "100%",
    marginTop: 15,
  },
  numberCircle: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: "white",
    justifyContent: "center",
    alignItems: "center",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 4,
    elevation: 5,
  },
  darkNumberCircle: {
    backgroundColor: "#2c2c2e",
  },
  numberText: {
    fontSize: 22,
    fontWeight: "900",
    color: "#000",
  },
  darkNumberText: {
    color: "#fff",
  },
  titleContainer: {
    flex: 1,
    backgroundColor: "white",
    marginHorizontal: 12,
    borderRadius: 14,
    padding: 8,
    minHeight: 44,
    justifyContent: "center",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3,
    elevation: 5,
  },
  darkTitleContainer: {
    backgroundColor: "#2c2c2e",
  },
  titleText: {
    fontSize: 24,
    fontWeight: "bold",
    textAlign: "center",
    color: "#000",
  },
  darkTitleText: {
    color: "#fff",
  },
  closeButton: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: "white",
    justifyContent: "center",
    alignItems: "center",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 4,
    elevation: 5,
  },
  darkCloseButton: {
    backgroundColor: "#2c2c2e",
  },
  content: {
    height: height * 0.82,
  },
  infoSection: {
    flex: 1,
  },
  infoContent: {
    padding: 15,
  },
  topRow: {
    flexDirection: "row",
    height: 160,
    marginBottom: 15,
  },
  mainImageContainer: {
    width: 160,
    height: 160,
    borderRadius: 16,
    overflow: "hidden",
    backgroundColor: "#f5f5f5",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 5,
    elevation: 5,
  },
  mainImage: {
    width: "100%",
    height: "100%",
  },
  yearBadge: {
    position: "absolute",
    bottom: 8,
    right: 8,
    paddingHorizontal: 8,
    paddingVertical: 4,
    backgroundColor: "rgba(0,0,0,0.7)",
    borderRadius: 8,
  },
  yearText: {
    color: "white",
    fontSize: 14,
    fontWeight: "600",
  },
  funFactContainer: {
    flex: 1,
    marginLeft: 15,
    backgroundColor: "white",
    borderRadius: 16,
    padding: 12,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.15,
    shadowRadius: 5,
    elevation: 5,
  },
  darkFunFactContainer: {
    backgroundColor: "#2c2c2e",
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: "bold",
    marginBottom: 8,
    color: "#000",
  },
  darkSectionTitle: {
    color: "#fff",
  },
  funFactText: {
    fontSize: 18,
    lineHeight: 24,
    color: "#333",
  },
  darkFunFactText: {
    color: "#e5e5e7",
  },
  infoBox: {
    backgroundColor: "white",
    borderRadius: 16,
    padding: 16,
    marginBottom: 15,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.15,
    shadowRadius: 5,
    elevation: 5,
  },
  darkInfoBox: {
    backgroundColor: "#2c2c2e",
  },
  descriptionText: {
    fontSize: 18,
    lineHeight: 26,
    color: "#333",
  },
  darkDescriptionText: {
    color: "#e5e5e7",
  },
  infoText: {
    fontSize: 18,
    lineHeight: 26,
    color: "#333",
  },
  darkInfoText: {
    color: "#e5e5e7",
  },
  imagesSection: {
    flex: 1,
    backgroundColor: "black",
  },
  imagePageContainer: {
    width: width,
    height: "100%",
    justifyContent: "center",
    alignItems: "center",
  },
  backgroundImage: {
    width: "100%",
    height: "100%",
    opacity: 0.5,
  },
  foregroundImage: {
    width: width,
    height: "100%",
    position: "absolute",
  },
  dotsContainer: {
    flexDirection: "row",
    position: "absolute",
    bottom: 15,
    alignSelf: "center",
  },
  dot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    backgroundColor: "rgba(255,255,255,0.4)",
    marginHorizontal: 4,
  },

  activeDot: {
    width: 12,
    height: 12,
    borderRadius: 6,
    backgroundColor: "white",
  },
  likeButton: {
    position: "absolute",
    bottom: 21,
    right: 15,
    width: 44,
    height: 44,
    borderRadius: 22,
    justifyContent: "center",
    alignItems: "center",
  },
  bottomTab: {
    height: height * 0.08,
    backgroundColor: "#f5f5f5",
    justifyContent: "center",
    alignItems: "center",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: -2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  darkBottomTab: {
    backgroundColor: "#1c1c1e",
  },
  tabPicker: {
    flexDirection: "row",
    backgroundColor: "white",
    borderRadius: 20,
    padding: 4,
    width: 300,
    height: 38,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.15,
    shadowRadius: 3,
    elevation: 5,
  },
  darkTabPicker: {
    backgroundColor: "#2c2c2e",
  },
  tabButton: {
    flex: 1,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    borderRadius: 16,
  },
  activeTab: {
    backgroundColor: "#f0f0f0",
  },
  darkActiveTab: {
    backgroundColor: "#3c3c3e",
  },
  tabText: {
    marginLeft: 4,
    fontSize: 16,
    fontWeight: "600",
    color: "#666",
  },
  activeTabText: {
    color: "#000",
  },
  darkTabText: {
    color: "#999",
  },
  darkActiveTabText: {
    color: "#fff",
  },
  tabDivider: {
    width: 1,
    backgroundColor: "#ddd",
    marginVertical: 8,
  },
  darkTabDivider: {
    backgroundColor: "#3c3c3e",
  },
});

export default StructPopUp;
