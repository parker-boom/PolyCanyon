// MARK: - Custom Tab Bar Component
/**
 * TabBar Component
 *
 * A custom bottom tab bar with enhanced visual styling including shadows,
 * scaling effects, and consistent icon designs.
 */

import React from "react";
import { View, TouchableOpacity, StyleSheet } from "react-native";
import Ionicons from "react-native-vector-icons/Ionicons";

const TabBar = ({ state, descriptors, navigation, isDarkMode }) => {
  return (
    <View style={[styles.container, isDarkMode && styles.containerDark]}>
      {state.routes.map((route, index) => {
        const { options } = descriptors[route.key];
        const isFocused = state.index === index;

        const onPress = () => {
          const event = navigation.emit({
            type: "tabPress",
            target: route.key,
          });

          if (!isFocused && !event.defaultPrevented) {
            navigation.navigate(route.name);
          }
        };

        let iconName;
        if (route.name === "Detail") {
          iconName = "archive";
        } else if (route.name === "Map") {
          iconName = "map";
        } else if (route.name === "Settings") {
          iconName = "settings";
        }

        return (
          <TouchableOpacity
            key={index}
            onPress={onPress}
            style={[styles.tab, isFocused && styles.focusedTab]}
          >
            <Ionicons
              name={iconName}
              size={33}
              color={
                isFocused
                  ? isDarkMode
                    ? "#FFFFFF"
                    : "#000000"
                  : isDarkMode
                  ? "#888888"
                  : "#999999"
              }
              style={[styles.icon, isFocused && styles.focusedIcon]}
            />
          </TouchableOpacity>
        );
      })}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: "row",
    height: 60,
    backgroundColor: "#F5F5F5",
    borderTopWidth: 1,
    borderTopColor: "#E0E0E0",
    shadowColor: "#000",
    shadowOffset: {
      width: 0,
      height: 3,
    },
    shadowOpacity: 0.5,
    shadowRadius: 5,
    elevation: 10,
  },
  containerDark: {
    backgroundColor: "#121212",
    borderTopColor: "#2C2C2E",
  },
  tab: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    paddingBottom: 5,
  },
  focusedTab: {
    transform: [{ scale: 1.1 }],
  },
  icon: {
    shadowColor: "#000",
    shadowOffset: {
      width: 0,
      height: 1,
    },
    shadowOpacity: 0,
    shadowRadius: 1,
  },
  focusedIcon: {
    shadowOpacity: 0.4,
  },
});

export default TabBar;
