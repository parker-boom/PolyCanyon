import React, { useState } from "react";
import {
  View,
  Text,
  FlatList,
  TextInput,
  TouchableOpacity,
  Animated,
} from "react-native";
import Ionicons from "react-native-vector-icons/Ionicons";
import FastImage from "react-native-fast-image";
import { BlurView } from "@react-native-community/blur";
import { useDarkMode } from "../../Core/States/DarkMode";
import { useAdventureMode } from "../../Core/States/AdventureModeContext";
import { useDataStore } from "../../Core/Data/DataStore";
import { useAppState } from "../../Core/States/AppState";
import styles from "./DetailStyles";

const DetailView = () => {
  // Context hooks
  const { isDarkMode } = useDarkMode();
  const { adventureMode } = useAdventureMode();
  const { structures, hasVisitedStructures, hasLikedStructures } =
    useDataStore();
  const { setSelectedStructure } = useAppState();

  // Local state
  const [searchText, setSearchText] = useState("");
  const [isListView, setIsListView] = useState(false);
  const [filterState, setFilterState] = useState("all");
  const popUpOpacity = useState(new Animated.Value(0))[0];
  const [popUpText, setPopUpText] = useState("");

  // Filter structures based on search text and filter state
  const filteredStructures = structures.filter((structure) => {
    const searchLower = searchText.toLowerCase();
    const matchesSearch =
      structure.title.toLowerCase().includes(searchLower) ||
      structure.number.toString().includes(searchLower);

    switch (filterState) {
      case "visited":
        return matchesSearch && structure.isVisited;
      case "favorites":
        return matchesSearch && structure.isLiked;
      default: // "all"
        return matchesSearch;
    }
  });

  const handleFilterChange = () => {
    const filterOptions = ["all"];
    if (hasLikedStructures()) filterOptions.push("favorites");
    if (adventureMode && hasVisitedStructures()) filterOptions.push("visited");

    const currentIndex = filterOptions.indexOf(filterState);
    const nextIndex = (currentIndex + 1) % filterOptions.length;
    const newFilterState = filterOptions[nextIndex];

    const newPopUpText = {
      all: "All",
      visited: "Visited",
      favorites: "Favorites",
    }[newFilterState];

    setFilterState(newFilterState);
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
    setSelectedStructure(structure);
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

  const renderGridItem = ({ item }) => (
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

  const getFilterColor = (currentFilterState) =>
    ({
      all: isDarkMode ? "white" : "black",
      visited: "green",
      favorites: "pink",
    }[currentFilterState]);

  return (
    <View style={[styles.container, isDarkMode && styles.darkContainer]}>
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
              color={getFilterColor(filterState)}
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

      <FlatList
        style={[styles.list, isDarkMode && styles.darkList]}
        data={filteredStructures}
        renderItem={isListView ? renderListItem : renderGridItem}
        keyExtractor={(item) => item.number.toString()}
        key={isListView ? "list" : "grid"}
        numColumns={isListView ? 1 : 2}
      />

      <Animated.View style={[styles.popUp, { opacity: popUpOpacity }]}>
        <Text style={[styles.popUpText, isDarkMode && styles.darkPopUpText]}>
          {popUpText}
        </Text>
      </Animated.View>
    </View>
  );
};

export default DetailView;
