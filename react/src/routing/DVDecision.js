// src/DVDecisionPrompt.js
import React from "react";
import { View, Text, StyleSheet, TouchableOpacity, Image } from "react-native";

const DVDecisionPrompt = ({ onDecision }) => {
  return (
    <View style={styles.container}>
      <View style={styles.content}>
        <Image
          source={require("./DesignVillage/Images/DVLogo.png")}
          style={styles.logo}
          resizeMode="contain"
        />
        <Text style={styles.title}>Design Village Weekend</Text>
        <Text style={styles.message}>Are you here celebrating?</Text>
        <View style={styles.buttonContainer}>
          <TouchableOpacity
            style={[styles.button, styles.noButton]}
            onPress={() => onDecision(false)}
          >
            <Text style={[styles.buttonText, styles.noButtonText]}>No</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.button, styles.yesButton]}
            onPress={() => onDecision(true)}
          >
            <Text style={styles.buttonText}>Yes</Text>
          </TouchableOpacity>
        </View>
        <Text style={styles.footnote}>
          Selecting yes will transform your app, but you can switch back anytime
        </Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#ffffff",
  },
  content: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    padding: 24,
    maxWidth: 500,
    alignSelf: "center",
    width: "100%",
  },
  logo: {
    width: "70%",
    height: 120,
    marginBottom: 32,
  },
  title: {
    fontSize: 28,
    fontWeight: "800",
    marginBottom: 24,
    color: "#1a1a1a",
    textAlign: "center",
  },
  message: {
    fontSize: 24,
    textAlign: "center",
    marginBottom: 32,
    color: "#333333",
  },
  buttonContainer: {
    flexDirection: "row",
    gap: 16,
    marginBottom: 32,
  },
  button: {
    paddingVertical: 14,
    paddingHorizontal: 32,
    borderRadius: 12,
    minWidth: 120,
    alignItems: "center",
  },
  noButton: {
    backgroundColor: "#f5f5f5",
    borderWidth: 1,
    borderColor: "#e0e0e0",
  },
  yesButton: {
    backgroundColor: "#007AFF",
  },
  buttonText: {
    fontSize: 16,
    fontWeight: "600",
    color: "#ffffff",
  },
  noButtonText: {
    color: "#666666",
  },
  footnote: {
    fontSize: 14,
    textAlign: "center",
    color: "#666666",
    maxWidth: "80%",
  },
});

export default DVDecisionPrompt;
