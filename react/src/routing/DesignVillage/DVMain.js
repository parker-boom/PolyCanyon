import React, { useState } from "react";
import { View, TouchableOpacity, StyleSheet } from "react-native";
import Ionicons from "react-native-vector-icons/Ionicons";
import DVInfo from "./MainViews/DVInfo";
import DVMap from "./MainViews/DVMap";
import DVPeople from "./MainViews/DVPeople";
import DVSchedule from "./MainViews/DVSchedule";
import DVSettings from "./MainViews/DVSettings";

const DVMain = () => {
  const [activeTab, setActiveTab] = useState("DVInfo");

  const tabs = [
    { name: "DVInfo", icon: "information-circle-outline" },
    { name: "DVMap", icon: "map-outline" },
    { name: "DVPeople", icon: "people-outline" },
    { name: "DVSchedule", icon: "calendar-outline" },
    { name: "DVSettings", icon: "settings-outline" },
  ];

  const renderActiveTab = () => {
    switch (activeTab) {
      case "DVInfo":
        return <DVInfo />;
      case "DVMap":
        return <DVMap />;
      case "DVPeople":
        return <DVPeople />;
      case "DVSchedule":
        return <DVSchedule />;
      case "DVSettings":
        return <DVSettings />;
      default:
        return null;
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.content}>{renderActiveTab()}</View>
      <TabBar tabs={tabs} activeTab={activeTab} onTabPress={setActiveTab} />
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
              color={isFocused ? "#000000" : "#999999"}
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
  screen: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  },
  screenText: {
    fontSize: 24,
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
    shadowOffset: {
      width: 0,
      height: 3,
    },
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

export default DVMain;
