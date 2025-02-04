import { StyleSheet } from "react-native";

// MARK: - Styles
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#F5F5F5",
  },
  contentContainer: {
    padding: 20,
  },
  section: {
    marginBottom: 20,
    backgroundColor: "white",
    borderRadius: 10,
    padding: 15,
    marginHorizontal: 2,
    shadowColor: "#000",
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.23,
    shadowRadius: 2.62,
    elevation: 4,
  },
  sectionHeaderContainer: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 15,
  },
  darkContainer: {
    backgroundColor: "#121212",
  },
  darkSection: {
    backgroundColor: "#1E1E1E",
  },
  sectionHeader: {
    fontSize: 24,
    fontWeight: "bold",
    marginBottom: 15,
    color: "#333",
  },
  darkText: {
    color: "#F5F5F5",
  },
  settingItem: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 10,
  },
  settingText: {
    fontSize: 18,
    color: "#333",
  },
  modeSection: {
    alignItems: "center",
    marginVertical: 20,
  },
  modeTitle: {
    fontSize: 22,
    fontWeight: "bold",
    marginTop: 10,
    color: "#333",
  },
  modeDescription: {
    fontSize: 14,
    color: "gray",
    marginTop: 5,
    textAlign: "center",
  },
  darkModeDescription: {
    color: "#B0B0B0",
  },
  switchButton: {
    backgroundColor: "#2196F3",
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 20,
    marginTop: 15,
  },
  darkSwitchButton: {
    backgroundColor: "#3D5AFE",
  },
  switchButtonText: {
    color: "white",
    fontSize: 16,
    fontWeight: "bold",
  },
  buttonContainer: {
    flexDirection: "row",
    justifyContent: "space-between",
    marginTop: 20,
  },
  settingsButton: {
    flex: 1,
    alignItems: "center",
    backgroundColor: "#f0f0f0",
    padding: 10,
    borderRadius: 10,
    marginHorizontal: 5,
    borderWidth: 1,
    borderColor: "#E0E0E0",
  },
  darkSettingsButton: {
    backgroundColor: "#333",
    borderColor: "#404040",
  },
  settingsButtonText: {
    marginTop: 5,
    fontSize: 12,
    color: "#333",
  },
  creditText: {
    fontSize: 16,
    color: "#333",
    marginBottom: 5,
  },
  caption: {
    fontSize: 12,
    color: "gray",
    marginTop: 10,
  },
  darkCaption: {
    color: "#B0B0B0",
  },
  modeSelectionContainer: {
    backgroundColor: "#f0f0f0",
    borderRadius: 10,
    padding: 15,
    marginTop: 5,
    marginBottom: 0,
    marginHorizontal: 5,
    borderWidth: 1,
    borderColor: "#E0E0E0",
  },
  darkModeSelectionContainer: {
    backgroundColor: "#333",
    borderColor: "#404040",
  },
  sectionIcon: {
    opacity: 0.6,
    marginBottom: 10,
  },
});

export default styles;
