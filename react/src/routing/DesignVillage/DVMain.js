// DVMain.js
import React, { useState } from "react";
import { View, Text, StyleSheet, TouchableOpacity } from "react-native";
import Ionicons from "react-native-vector-icons/Ionicons";
import DVInfo from "./MainViews/DVInfo";
import DVMap from "./MainViews/DVMap";
import DVSchedule from "./MainViews/DVSchedule";
import DVSettings from "./MainViews/DVSettings";

const DVMain = ({ setDesignVillageMode }) => {
  const [activeTab, setActiveTab] = useState("DVInfo");

  // Removed DVPeople from the tabs.
  const tabs = [
    { name: "DVInfo", icon: "information-circle" },
    { name: "DVMap", icon: "map" },
    { name: "DVSchedule", icon: "calendar" },
    { name: "DVSettings", icon: "settings" },
  ];

  // Header configuration for each tab (using the Info header design as inspiration)
  const headerConfig = {
    DVInfo: { title: "Info", icon: "information-circle" },
    DVMap: { title: "Map", icon: "map" },
    DVSchedule: { title: "Schedule", icon: "calendar" },
    DVSettings: { title: "Settings", icon: "settings" },
  };

  const renderActiveTab = () => {
    switch (activeTab) {
      case "DVInfo":
        return <DVInfo />;
      case "DVMap":
        return <DVMap />;
      case "DVSchedule":
        return <DVSchedule />;
      case "DVSettings":
        return <DVSettings setDesignVillageMode={setDesignVillageMode} />;
      default:
        return null;
    }
  };

  return (
    <View style={styles.container}>
      <Header
        title={headerConfig[activeTab].title}
        icon={headerConfig[activeTab].icon}
      />
      <View style={styles.content}>{renderActiveTab()}</View>
      <TabBar tabs={tabs} activeTab={activeTab} onTabPress={setActiveTab} />
    </View>
  );
};

const Header = ({ title, icon }) => {
  return (
    <View style={headerStyles.container}>
      <View style={headerStyles.headerContent}>
        <Text style={headerStyles.title}>{title}</Text>
        <Ionicons name={icon} size={33} style={headerStyles.icon} />
      </View>
    </View>
  );
};

const TabBar = ({ tabs, activeTab, onTabPress }) => {
  return (
    <View style={tabStyles.container}>
      {tabs.map((tab, index) => {
        const isFocused = activeTab === tab.name;
        return (
          <TouchableOpacity
            key={index}
            onPress={() => onTabPress(tab.name)}
            style={[tabStyles.tab, isFocused && tabStyles.focusedTab]}
          >
            <Ionicons
              name={tab.icon}
              size={33}
              color={isFocused ? "#000000" : "#888888"}
              style={[tabStyles.icon, isFocused && tabStyles.focusedIcon]}
            />
          </TouchableOpacity>
        );
      })}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  content: {
    flex: 1,
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
});

const headerStyles = StyleSheet.create({
  container: {
    backgroundColor: "white",
    paddingHorizontal: 16,
    paddingTop: 10,
    paddingBottom: 5,
    shadowColor: "#000",
    shadowOpacity: 0.05,
    shadowRadius: 8,
    shadowOffset: { width: 0, height: 4 },
    elevation: 2,
  },
  headerContent: {
    flexDirection: "row",
    alignItems: "center",
  },
  title: {
    fontSize: 32,
    fontWeight: "bold",
    flex: 1,
    color: "#000000",
  },
  icon: {
    color: "rgba(0,0,0,0.8)",
  },
});

const tabStyles = StyleSheet.create({
  container: {
    flexDirection: "row",
    height: 60,
    backgroundColor: "#F5F5F5",
    borderTopWidth: 1,
    borderTopColor: "#E0E0E0",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.5,
    shadowRadius: 5,
    elevation: 10,
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
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0,
    shadowRadius: 1,
  },
  focusedIcon: {
    shadowOpacity: 0.4,
  },
});

export default DVMain;
