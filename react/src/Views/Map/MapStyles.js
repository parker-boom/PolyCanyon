import { StyleSheet } from "react-native";

// MARK: - Styles
const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  mapContainer: {
    flex: 1,
    position: "relative",
    zIndex: 2,
  },
  map: {
    width: "100%",
    height: "100%",
    resizeMode: "contain",
  },
  button: {
    position: "absolute",
    top: 20,
    right: 20,
    width: 50,
    height: 50,
    borderRadius: 15,
    justifyContent: "center",
    alignItems: "center",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 1,
    shadowRadius: 5,
    elevation: 25,
  },
  markerContainer: {
    position: "absolute",
    width: 20,
    height: 20,
    justifyContent: "center",
    alignItems: "center",
  },
  pulsingCircleContainer: {
    width: 14,
    height: 14,
    justifyContent: "center",
    alignItems: "center",
  },
  pulsingCircleInner: {
    width: 14,
    height: 14,
    borderRadius: 7,
    backgroundColor: "rgba(112, 235, 64, 1)",
    borderWidth: 2,
    borderColor: "white",
  },
  pulsingCircleOverlay: {
    position: "absolute",
    width: 14,
    height: 14,
    borderRadius: 7,
    borderWidth: 2,
    borderColor: "white",
  },
  shadowDark: {
    shadowColor: "#000",
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
  },
  shadowLight: {
    shadowColor: "#fff",
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
  },
  popupContainer: {
    position: "absolute",
    bottom: 20,
    left: 15,
    right: 15,
    backgroundColor: "transparent",
  },
  contentContainer: {
    flexDirection: "row",
    alignItems: "center",
    borderRadius: 15,
    padding: 10,
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
  },
  lightContentContainer: {
    backgroundColor: "white",
    shadowColor: "#000",
  },
  darkContentContainer: {
    backgroundColor: "#333",
    shadowColor: "#fff",
  },
  closeButton: {
    padding: 5,
  },
  popupImage: {
    width: 80,
    height: 80,
    borderRadius: 10,
    marginLeft: 10,
  },
  textContainer: {
    flex: 1,
    marginLeft: 10,
  },
  justVisitedText: {
    fontSize: 14,
  },
  titleText: {
    fontSize: 24,
    fontWeight: "bold",
  },
  numberText: {
    fontSize: 28,
    fontWeight: "bold",
    marginRight: 10,
  },
  chevron: {
    marginLeft: 10,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: "rgba(0, 0, 0, 0.5)",
    justifyContent: "center",
    alignItems: "center",
  },
  modalContent: {
    width: "100%",
    height: "100%",
    maxWidth: 600,
    maxHeight: "90%",
    justifyContent: "center",
    alignItems: "center",
  },
  ratingReminderWrapper: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "rgba(0, 0, 0, 0.5)",
  },
  ratingReminderContainer: {
    backgroundColor: "white",
    padding: 20,
    borderRadius: 10,
    alignItems: "center",
    shadowColor: "#000",
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.3,
    shadowRadius: 4.65,
    elevation: 8,
    maxWidth: "80%",
  },
  darkRatingReminderContainer: {
    backgroundColor: "#333",
    shadowColor: "#fff",
  },
  ratingReminderText: {
    fontSize: 18,
    marginVertical: 15,
    textAlign: "center",
  },
  rateNowButton: {
    backgroundColor: "#2196F3",
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 5,
    marginBottom: 10,
  },
  rateNowButtonText: {
    color: "white",
    fontSize: 16,
    fontWeight: "bold",
  },
  maybeLaterText: {
    fontSize: 16,
    color: "#666",
  },
  darkText: {
    color: "white",
  },
  // Control button base styles
  controlButton: {
    width: 50,
    height: 50,
    borderRadius: 15,
    backgroundColor: "#F5F5F5",
    justifyContent: "center",
    alignItems: "center",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
    borderWidth: 1,
    borderColor: "rgba(0, 0, 0, 0.1)",
  },
  controlButtonDark: {
    backgroundColor: "#121212",
    shadowColor: "#fff",
    borderColor: "rgba(255, 255, 255, 0.1)",
  },

  // Settings panel container
  settingsPanel: {
    marginBottom: 10,
    alignItems: "center",
  },

  // Toggle buttons (satellite and numbers)
  toggleButton: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: "#F5F5F5",
    justifyContent: "center",
    alignItems: "center",
    marginBottom: 10,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
    borderWidth: 1,
    borderColor: "rgba(0, 0, 0, 0.1)",
  },
  toggleButtonDark: {
    backgroundColor: "#121212",
    shadowColor: "#fff",
    borderColor: "rgba(255, 255, 255, 0.1)",
  },

  // Bottom left container for settings
  bottomLeftControls: {
    position: "absolute",
    bottom: 20,
    left: 20,
    alignItems: "center",
    zIndex: 3,
  },

  // Bottom right container for virtual tour
  bottomRightControls: {
    position: "absolute",
    bottom: 20,
    right: 20,
    zIndex: 3,
  },

  // Text styles for the numbers toggle
  toggleButtonText: {
    fontSize: 18,
    color: "#000000",
    fontWeight: "bold",
  },
  toggleButtonTextDark: {
    color: "#FFFFFF",
  },

  // Virtual Tour Info Popup styles
  virtualTourPopup: {
    position: "absolute",
    bottom: 90,
    right: 20,
    backgroundColor: "white",
    padding: 15,
    borderRadius: 12,
    maxWidth: 200,
    shadowColor: "#000",
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
    zIndex: 3,
  },
  virtualTourPopupDark: {
    backgroundColor: "#121212",
    shadowColor: "#fff",
  },
  virtualTourPopupText: {
    fontSize: 14,
    color: "#000",
    textAlign: "center",
  },
  virtualTourPopupTextDark: {
    color: "#fff",
  },
  virtualTourPopupArrow: {
    position: "absolute",
    bottom: -10,
    right: 20,
    width: 0,
    height: 0,
    backgroundColor: "transparent",
    borderStyle: "solid",
    borderLeftWidth: 10,
    borderRightWidth: 10,
    borderTopWidth: 10,
    borderLeftColor: "transparent",
    borderRightColor: "transparent",
    borderTopColor: "white",
  },
  virtualTourPopupArrowDark: {
    borderTopColor: "#121212",
  },
  blurredBackgroundContainer: {
    position: "absolute",
    top: -20,
    left: -20,
    right: -20,
    bottom: -20,
    overflow: "hidden",
    zIndex: 1,
  },

  blurredBackground: {
    flex: 1,
    width: "120%",
    height: "120%",
    transform: [{ scale: 1.2 }],
  },
});

export default styles;
