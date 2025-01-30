import React, { useState, useRef } from "react";
import {
  View,
  Text,
  FlatList,
  TextInput,
  TouchableOpacity,
  Animated,
  Modal,
} from "react-native";
import Ionicons from "react-native-vector-icons/Ionicons";
import FastImage from "react-native-fast-image";
import { BlurView } from "@react-native-community/blur";
import { useDarkMode } from "../../Core/States/DarkMode";
import { useAdventureMode } from "../../Core/States/AdventureMode";
import { useDataStore } from "../../Core/Data/DataStore";
import { useAppState } from "../../Core/States/AppState";
import styles from "./DetailStyles";
import LinearGradient from "react-native-linear-gradient";
import { useLocationService } from "../../Core/Location/LocationService";
import { getMainPhoto } from "../../Core/Images/ImageRegistry";
import { useNavigation } from "@react-navigation/native";

const DetailView = () => {
  // Context hooks
  const { isDarkMode } = useDarkMode();
  const { adventureMode } = useAdventureMode();
  const { structures, hasVisitedStructures, hasLikedStructures } =
    useDataStore();
  const { setSelectedStructure } = useAppState();
  const locationService = useLocationService();
  const navigation = useNavigation();

  // Local state
  const [searchText, setSearchText] = useState("");
  const [sortState, setSortState] = useState("all");
  const [isGridView, setIsGridView] = useState(true);
  const [showFilterMenu, setShowFilterMenu] = useState(false);
  const popUpOpacity = useState(new Animated.Value(0))[0];
  const [popUpText, setPopUpText] = useState("");
  const searchInputRef = useRef(null);

  // Filter structures based on search text and filter state
  const filteredStructures = structures.filter((structure) => {
    const searchLower = searchText.toLowerCase();
    const matchesSearch =
      structure.title.toLowerCase().includes(searchLower) ||
      structure.number.toString().includes(searchLower);

    switch (sortState) {
      case "visited":
        return matchesSearch && structure.isVisited;
      case "favorites":
        return matchesSearch && structure.isLiked;
      default:
        return matchesSearch;
    }
  });

  const handleFilterChange = () => {
    const filterOptions = ["all"];
    if (hasLikedStructures()) filterOptions.push("favorites");
    if (adventureMode && hasVisitedStructures()) filterOptions.push("visited");

    const currentIndex = filterOptions.indexOf(sortState);
    const nextIndex = (currentIndex + 1) % filterOptions.length;
    const newSortState = filterOptions[nextIndex];

    const newPopUpText = {
      all: "All",
      visited: "Visited",
      favorites: "Favorites",
    }[newSortState];

    setSortState(newSortState);
    setPopUpText(newPopUpText);

    Animated.sequence([
      Animated.timing(popUpOpacity, {
        toValue: 1,
        duration: 300,
        useNativeDriver: true,
      }),
      Animated.timing(popUpOpacity, {
        toValue: 0,
        duration: 700,
        delay: 1000,
        useNativeDriver: true,
      }),
    ]).start();
  };

  const handleStructurePress = (structure) => {
    console.log("Structure pressed, number:", structure.number);
    setSelectedStructure(structure.number);
    navigation.navigate("StructureDetail");
  };

  const renderListItem = ({ item }) => (
    <TouchableOpacity onPress={() => handleStructurePress(item)}>
      <View style={[styles.row, isDarkMode && styles.darkRow]}>
        <Text style={[styles.number, isDarkMode && styles.darkText]}>
          {item.number}
        </Text>
        <Text style={[styles.title, isDarkMode && styles.darkText]}>
          {item.title}
        </Text>
        <View
          style={[
            styles.statusIndicator,
            item.isVisited ? styles.visited : styles.notVisited,
          ]}
        />
      </View>
    </TouchableOpacity>
  );

  const renderGridItem = ({ item }) => {
    const showAdventureBlur =
      adventureMode &&
      locationService.isWithinCanyon(locationService.currentLocation?.coords) &&
      !item.isVisited;

    return (
      <TouchableOpacity
        onPress={() => handleStructurePress(item)}
        style={[styles.gridItem, isDarkMode && styles.darkGridItem]}
      >
        <View style={styles.imageContainer}>
          {/* Base image */}
          <FastImage
            source={getMainPhoto(item.number)}
            style={styles.gridImage}
            resizeMode={FastImage.resizeMode.cover}
          />

          {/* Bottom blur overlay (only affects image) */}
          <View style={styles.bottomBlurContainer}>
            <BlurView
              style={styles.bottomBlur}
              blurType={isDarkMode ? "dark" : "light"}
              blurAmount={4}
            />
          </View>

          {/* Adventure mode full blur */}
          {showAdventureBlur && (
            <BlurView
              style={styles.fullBlur}
              blurType={isDarkMode ? "dark" : "light"}
              blurAmount={2}
            />
          )}

          {/* Overlays (not affected by blur) */}
          <Text style={styles.gridNumberOverlay}>#{item.number}</Text>
          <Text style={styles.gridTitle} numberOfLines={1}>
            {item.title}
          </Text>

          {/* Status indicators */}
          {item.isVisited && (
            <View style={styles.statusIndicatorContainer}>
              {item.isOpened ? (
                <Ionicons
                  name="checkmark-circle"
                  size={24}
                  color="white"
                  style={styles.checkmark}
                />
              ) : (
                <View style={styles.blueDot} />
              )}
            </View>
          )}
        </View>
      </TouchableOpacity>
    );
  };

  const getFilterColor = (currentSortState) =>
    ({
      all: isDarkMode ? "white" : "black",
      visited: "green",
      favorites: "pink",
    }[currentSortState]);

  const getFilterIcon = () => {
    switch (sortState) {
      case "all":
        return "apps";
      case "visited":
        return "checkmark-circle";
      case "favorites":
        return "heart";
      default:
        return "apps";
    }
  };

  const getFilterText = () => {
    switch (sortState) {
      case "all":
        return "All";
      case "visited":
        return "Visited";
      case "favorites":
        return "Liked";
      default:
        return "All";
    }
  };

  const getFilterOptions = () => {
    const options = [{ id: "all", text: "All", icon: "apps" }];

    if (hasLikedStructures()) {
      options.push({ id: "favorites", text: "Liked", icon: "heart" });
    }

    if (adventureMode && hasVisitedStructures()) {
      options.push({
        id: "visited",
        text: "Visited",
        icon: "checkmark-circle",
      });
    }

    return options;
  };

  const hasFilterOptions =
    hasLikedStructures() || (adventureMode && hasVisitedStructures());

  const handleClearSearch = () => {
    setSearchText("");
    searchInputRef.current?.blur();
  };

  const renderHeader = () => (
    <View
      style={[styles.headerWrapper, isDarkMode && styles.darkHeaderWrapper]}
    >
      <View
        style={[
          styles.header,
          isDarkMode ? styles.darkHeader : styles.lightHeader,
        ]}
      >
        <View
          style={[
            styles.searchContainer,
            isDarkMode
              ? styles.darkSearchContainer
              : styles.lightSearchContainer,
          ]}
        >
          <Ionicons
            name="search"
            size={20}
            color={isDarkMode ? "white" : "black"}
            style={styles.searchIcon}
          />
          <TextInput
            ref={searchInputRef}
            style={[styles.searchInput, isDarkMode && styles.darkSearchInput]}
            placeholder="Search structures..."
            placeholderTextColor={isDarkMode ? "#888" : "#666"}
            value={searchText}
            onChangeText={setSearchText}
          />
          {searchText !== "" && (
            <TouchableOpacity
              onPress={handleClearSearch}
              style={styles.clearButton}
            >
              <Ionicons
                name="close-circle"
                size={20}
                color={isDarkMode ? "white" : "black"}
              />
            </TouchableOpacity>
          )}
        </View>

        <View style={styles.controlsRow}>
          {hasFilterOptions ? (
            <TouchableOpacity
              style={[
                styles.filterButton,
                isDarkMode ? styles.darkFilterButton : styles.lightFilterButton,
              ]}
              onPress={() => setShowFilterMenu(true)}
            >
              <Ionicons
                name={getFilterIcon()}
                size={20}
                color={isDarkMode ? "white" : "black"}
                style={styles.filterIcon}
              />
              <Text
                style={[
                  styles.filterText,
                  { color: isDarkMode ? "white" : "black" },
                ]}
              >
                {getFilterText()}
              </Text>
              <Ionicons
                name="chevron-down"
                size={16}
                color={isDarkMode ? "white" : "black"}
              />
            </TouchableOpacity>
          ) : (
            <View
              style={[
                styles.filterButton,
                isDarkMode ? styles.darkFilterButton : styles.lightFilterButton,
                { opacity: 0.5 },
              ]}
            >
              <Ionicons
                name={getFilterIcon()}
                size={20}
                color={isDarkMode ? "white" : "black"}
                style={styles.filterIcon}
              />
              <Text
                style={[
                  styles.filterText,
                  { color: isDarkMode ? "white" : "black" },
                ]}
              >
                All
              </Text>
            </View>
          )}

          <View
            style={[
              styles.viewModeContainer,
              isDarkMode
                ? styles.darkViewModeContainer
                : styles.lightViewModeContainer,
            ]}
          >
            <TouchableOpacity
              style={[
                styles.viewModeButton,
                isGridView && styles.activeViewModeButton,
                isGridView && isDarkMode && styles.darkActiveViewModeButton,
              ]}
              onPress={() => setIsGridView(true)}
            >
              <Ionicons
                name="grid"
                size={20}
                color={isDarkMode ? "white" : "black"}
              />
              {isGridView && (
                <Text
                  style={[
                    styles.viewModeText,
                    { color: isDarkMode ? "white" : "black" },
                  ]}
                >
                  Grid
                </Text>
              )}
            </TouchableOpacity>

            <TouchableOpacity
              style={[
                styles.viewModeButton,
                !isGridView && styles.activeViewModeButton,
                !isGridView && isDarkMode && styles.darkActiveViewModeButton,
              ]}
              onPress={() => setIsGridView(false)}
            >
              <Ionicons
                name="list"
                size={20}
                color={isDarkMode ? "white" : "black"}
              />
              {!isGridView && (
                <Text
                  style={[
                    styles.viewModeText,
                    { color: isDarkMode ? "white" : "black" },
                  ]}
                >
                  List
                </Text>
              )}
            </TouchableOpacity>
          </View>
        </View>
      </View>
    </View>
  );

  return (
    <View style={[styles.container, isDarkMode && styles.darkContainer]}>
      {renderHeader()}

      <View
        style={[
          styles.contentContainer,
          isGridView ? styles.gridContentPadding : styles.listContentPadding,
        ]}
      >
        <FlatList
          style={[styles.list, isDarkMode && styles.darkList]}
          contentContainerStyle={styles.listContent}
          data={filteredStructures}
          renderItem={isGridView ? renderGridItem : renderListItem}
          keyExtractor={(item) => item.number.toString()}
          key={isGridView ? "grid" : "list"}
          numColumns={isGridView ? 2 : 1}
          keyboardDismissMode="on-drag"
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}
        />
      </View>

      <Animated.View style={[styles.popUp, { opacity: popUpOpacity }]}>
        <Text style={[styles.popUpText, isDarkMode && styles.darkPopUpText]}>
          {popUpText}
        </Text>
      </Animated.View>

      <Modal
        visible={showFilterMenu}
        transparent={true}
        animationType="fade"
        onRequestClose={() => setShowFilterMenu(false)}
      >
        <TouchableOpacity
          style={{
            flex: 1,
            backgroundColor: "rgba(0,0,0,0.5)",
            justifyContent: "flex-start",
            paddingTop: 180,
          }}
          activeOpacity={1}
          onPress={() => setShowFilterMenu(false)}
        >
          <View
            style={{
              backgroundColor: isDarkMode ? "#1C1C1E" : "white",
              borderRadius: 12,
              marginHorizontal: 20,
              padding: 8,
              shadowColor: "#000",
              shadowOffset: {
                width: 0,
                height: 4,
              },
              shadowOpacity: 0.25,
              shadowRadius: 4,
              elevation: 5,
            }}
          >
            {getFilterOptions().map((option) => (
              <TouchableOpacity
                key={option.id}
                style={{
                  flexDirection: "row",
                  alignItems: "center",
                  padding: 12,
                  borderRadius: 8,
                  backgroundColor:
                    sortState === option.id
                      ? isDarkMode
                        ? "#2C2C2E"
                        : "#F2F2F7"
                      : "transparent",
                }}
                onPress={() => {
                  setSortState(option.id);
                  setShowFilterMenu(false);
                }}
              >
                <Ionicons
                  name={option.icon}
                  size={20}
                  color={isDarkMode ? "white" : "black"}
                  style={{ marginRight: 12 }}
                />
                <Text
                  style={{
                    fontSize: 16,
                    color: isDarkMode ? "white" : "black",
                    fontWeight: sortState === option.id ? "600" : "normal",
                  }}
                >
                  {option.text}
                </Text>
              </TouchableOpacity>
            ))}
          </View>
        </TouchableOpacity>
      </Modal>
    </View>
  );
};

export default DetailView;
