// src/DVDecisionPrompt.js
import React from "react";
import { View, Text, StyleSheet, TouchableOpacity } from "react-native";

const DVDecisionPrompt = ({ onDecision }) => {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Limited Time Event!</Text>
      <Text style={styles.message}>
        Design Village is live this weekend. Would you like to check it out?
      </Text>
      <View style={styles.buttonContainer}>
        <TouchableOpacity
          style={[styles.button, styles.noButton]}
          onPress={() => onDecision(false)}
        >
          <Text style={styles.buttonText}>No</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.button, styles.yesButton]}
          onPress={() => onDecision(true)}
        >
          <Text style={styles.buttonText}>Yes</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: "bold",
    marginBottom: 20,
  },
  message: {
    fontSize: 16,
    textAlign: "center",
    marginBottom: 40,
  },
  buttonContainer: {
    flexDirection: "row",
  },
  button: {
    padding: 10,
    borderRadius: 8,
    marginHorizontal: 10,
  },
  noButton: {
    backgroundColor: "gray",
  },
  yesButton: {
    backgroundColor: "blue",
  },
  buttonText: {
    color: "white",
    fontWeight: "bold",
  },
});

export default DVDecisionPrompt;
