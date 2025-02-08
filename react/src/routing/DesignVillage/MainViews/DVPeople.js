import React from "react";
import { View, Text, StyleSheet } from "react-native";

const DVPeople = () => {
  return (
    <View style={styles.screen}>
      <Text style={styles.screenText}>Design Village People</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  },
  screenText: {
    fontSize: 24,
  },
});

export default DVPeople;
