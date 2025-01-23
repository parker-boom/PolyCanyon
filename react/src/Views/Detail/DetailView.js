// MARK: - DetailView Component
/**
 * DetailView Component
 *
 * This component displays a list or grid of structures with the following features:
 * - Search functionality
 * - Filtering options (All, Visited, Unvisited, Favorites)
 * - Toggle between list and grid views
 * - Dark mode support
 * - Structure detail pop-up
 * - Adventure mode integration
 *
 * The component uses various hooks and contexts for state management and
 * consistent theming across the app.
 */

import React, { useState, useEffect } from "react";
import {
  View,
  Text,
  FlatList,
  StyleSheet,
  TextInput,
  TouchableOpacity,
  Animated,
  Modal,
} from "react-native";
import Ionicons from "react-native-vector-icons/Ionicons";
import { useStructures } from "../OldData/StructureData";
import FastImage from "react-native-fast-image";
import { BlurView } from "@react-native-community/blur";
import StructPopUp from "../PopUps/StructPopUp";
import { useDarkMode } from "../../Core/States/DarkMode";
import { useAdventureMode } from "../../Core/States/AdventureModeContext";
import { useLocation } from "../OldData/LocationManager";

// MARK: - Main Component
const DetailView = () => {
  // MARK: - Hooks and State
  const {
    structures,
    toggleStructureLiked,
    hasVisitedStructures,
    hasUnvisitedStructures,
    hasFavoritedStructures,
  } = useStructures();
  const { isDarkMode } = useDarkMode();
  const { adventureMode } = useAdventureMode();
  const [searchText, setSearchText] = useState("");
  const [isListView, setIsListView] = useState(false);
  const [filterState, setFilterState] = useState("all");
  const popUpOpacity = useState(new Animated.Value(0))[0];
  const [selectedStructure, setSelectedStructure] = useState(null);
  const [popUpText, setPopUpText] = useState("");
  const [localLikedStatus, setLocalLikedStatus] = useState({});

  // MARK: - Effects
  useEffect(() => {
    // Initialize local liked status
    const initialLikedStatus = {};
    structures.forEach((structure) => {
      initialLikedStatus[structure.number] = structure.isLiked;
    });
    setLocalLikedStatus(initialLikedStatus);
  }, [structures]);

  // MARK: - Helper Functions
  const handleFavoriteToggle = (structureNumber) => {
    // Toggle favorite status locally and in global state
    setLocalLikedStatus((prevStatus) => {
      const newStatus = {
        ...prevStatus,
        [structureNumber]: !prevStatus[structureNumber],
      };
      toggleStructureLiked(structureNumber);
      return newStatus;
    });
  };

  // MARK: - Filtering Logic
  const filteredStructures = structures.filter((structure) => {
    // Filter structures based on search text and current filter state
    const searchLower = searchText.toLowerCase();
    const matchesSearch =
      structure.title.toLowerCase().includes(searchLower) ||
      structure.number.toString().includes(searchLower);

    switch (filterState) {
      case "all":
        return matchesSearch;
      case "visited":
        return matchesSearch && structure.isVisited;
      case "unvisited":
        return matchesSearch && !structure.isVisited;
      case "favorites":
        return matchesSearch && structure.isLiked;
      default:
        return matchesSearch;
    }
  });

  // MARK: - Event Handlers
  const handleFilterChange = () => {
    let newFilterState;
    let newPopUpText;

    const filterOptions = ["all"];
    if (hasFavoritedStructures()) filterOptions.push("favorites");
    if (adventureMode) {
      if (hasVisitedStructures()) filterOptions.push("visited");
      if (hasUnvisitedStructures()) filterOptions.push("unvisited");
    }

    const currentIndex = filterOptions.indexOf(filterState);
    const nextIndex = (currentIndex + 1) % filterOptions.length;
    newFilterState = filterOptions[nextIndex];

    switch (newFilterState) {
      case "all":
        newPopUpText = "All";
        break;
      case "visited":
        newPopUpText = "Visited";
        break;
      case "unvisited":
        newPopUpText = "Unvisited";
        break;
      case "favorites":
        newPopUpText = "Favorites";
        break;
    }

    setFilterState(newFilterState);
    setPopUpText(newPopUpText);

    // Always show the pop-up, regardless of adventureMode
    Animated.sequence([
      Animated.timing(popUpOpacity, {
        toValue: 1,
        duration: 300,
        useNativeDriver: true,
      }),
      Animated.timing(popUpOpacity, {
        toValue: 0,
        duration: 700,
        useNativeDriver: true,
        delay: 1000,
      }),
    ]).start();
  };

  const handleStructurePress = (structure) => {
    // Set selected structure for detail view
    setSelectedStructure(structure);
  };

  // MARK: - Render Functions
  const renderListItem = ({ item }) => (
    // Render individual list item
    <TouchableOpacity onPress={() => handleStructurePress(item)}>
      <View style={[styles.row, isDarkMode && styles.darkRow]}>
        <Text style={[styles.number, isDarkMode && styles.darkText]}>
          {item.number}
        </Text>
        <Text style={[styles.title, isDarkMode && styles.darkText]}>
          {item.title}
        </Text>
        {adventureMode ? (
          <View
            style={[
              styles.statusIndicator,
              item.isVisited ? styles.visited : styles.notVisited,
            ]}
          />
        ) : (
          <TouchableOpacity
            style={styles.heartContainer}
            onPress={() => handleFavoriteToggle(item.number)}
          >
            <Ionicons
              name={localLikedStatus[item.number] ? "heart" : "heart-outline"}
              size={24}
              color={
                localLikedStatus[item.number]
                  ? "red"
                  : isDarkMode
                  ? "white"
                  : "black"
              }
            />
          </TouchableOpacity>
        )}
      </View>
    </TouchableOpacity>
  );

  const renderGridItem = ({ item }) => (
    // Render individual grid item
    <TouchableOpacity
      onPress={() => handleStructurePress(item)}
      style={[
        styles.gridItem,
        styles.shadow,
        isDarkMode && styles.darkGridItem,
      ]}
    >
      <View style={styles.imageContainer}>
        <FastImage
          source={item.mainImage.image}
          style={styles.gridImage}
          resizeMode={FastImage.resizeMode.cover}
        />
        {adventureMode && !item.isVisited && (
          <BlurView
            style={styles.blurView}
            blurType={isDarkMode ? "dark" : "light"}
            blurAmount={2}
          />
        )}
        <Text style={styles.gridNumberOverlay}>{item.number}</Text>
      </View>
      <View
        style={[
          styles.gridInfoContainer,
          isDarkMode && styles.darkGridInfoContainer,
        ]}
      >
        <Text style={[styles.gridNumber, isDarkMode && styles.darkText]}>
          {item.number}
        </Text>
        <Text style={[styles.gridTitle, isDarkMode && styles.darkText]}>
          {item.title}
        </Text>
      </View>
    </TouchableOpacity>
  );

  // MARK: - Main Render
  useLocation((error, position) => {
    if (adventureMode && !error && position) {
      // Update any location-dependent state or perform actions
    }
  });

  return (
    <View style={[styles.container, isDarkMode && styles.darkContainer]}>
      {/* Search and filter controls */}
      <View style={styles.searchContainerWrapper}>
        <View
          style={[
            styles.searchContainer,
            isDarkMode && styles.darkSearchContainer,
          ]}
        >
          <TouchableOpacity
            style={styles.filterButton}
            onPress={handleFilterChange}
          >
            <Ionicons
              name={filterState === "favorites" ? "heart" : "eye"}
              size={32}
              color={getFilterColor(filterState, isDarkMode)}
            />
          </TouchableOpacity>
          <View style={styles.searchBarContainer}>
            <TextInput
              style={[styles.searchBar, isDarkMode && styles.darkSearchBar]}
              placeholder="Search by number or title..."
              placeholderTextColor={isDarkMode ? "#888" : "#666"}
              value={searchText}
              onChangeText={setSearchText}
              autoCapitalize="none"
              autoCorrect={false}
            />
            {searchText !== "" && (
              <TouchableOpacity
                onPress={() => setSearchText("")}
                style={styles.clearButton}
              >
                <Ionicons
                  name="close-circle"
                  size={20}
                  color={isDarkMode ? "white" : "gray"}
                />
              </TouchableOpacity>
            )}
          </View>
          <TouchableOpacity
            onPress={() => setIsListView(!isListView)}
            style={styles.toggleButton}
          >
            <Ionicons
              name={isListView ? "list-outline" : "grid-outline"}
              size={32}
              color={isDarkMode ? "white" : "black"}
            />
          </TouchableOpacity>
        </View>
      </View>

      {/* Structure list/grid */}
      <FlatList
        style={[styles.list, isDarkMode && styles.darkList]}
        data={filteredStructures}
        renderItem={isListView ? renderListItem : renderGridItem}
        keyExtractor={(item) => item.number.toString()}
        key={isListView ? "list" : "grid"}
        numColumns={isListView ? 1 : 2}
      />

      {/* Filter change popup */}
      <Animated.View style={[styles.popUp, { opacity: popUpOpacity }]}>
        <Text style={[styles.popUpText, isDarkMode && styles.darkPopUpText]}>
          {popUpText}
        </Text>
      </Animated.View>

      {/* Structure detail modal */}
      <Modal
        visible={selectedStructure !== null}
        transparent={true}
        animationType="fade"
        onRequestClose={() => setSelectedStructure(null)}
      >
        {selectedStructure && (
          <StructPopUp
            structure={selectedStructure}
            onClose={() => setSelectedStructure(null)}
            isDarkMode={isDarkMode}
          />
        )}
      </Modal>
    </View>
  );
};

// MARK: - Helper Functions
const getFilterColor = (currentFilterState, isDarkMode) => {
  // Return appropriate color for filter icon
  switch (currentFilterState) {
    case "all":
      return isDarkMode ? "white" : "black";
    case "visited":
      return "green";
    case "unvisited":
      return "red";
    case "favorites":
      return "pink";
    default:
      return isDarkMode ? "white" : "black";
  }
};

export default DetailView;
