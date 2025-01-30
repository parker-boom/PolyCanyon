import { StyleSheet } from "react-native";

// Styles
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "white",
  },
  slide: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    padding: 20,
  },
  icon: {
    width: 180,
    height: 180,
    marginTop: 40,
    marginBottom: 20,
    borderRadius: 36,
  },
  titleContainer: {
    marginBottom: 10,
  },
  title: {
    fontSize: 32,
    fontWeight: "bold",
    textAlign: "center",
  },
  blackTitle: {
    color: "black",
  },
  largerTitle: {
    fontSize: 36,
  },
  boldTitle: {
    fontWeight: "900",
  },
  greenTitle: {
    color: "#4CAF50",
  },
  blueTitle: {
    color: "#2196F3",
  },
  subtitle: {
    fontSize: 18,
    textAlign: "center",
    marginBottom: 30,
    color: "#666",
  },
  largerSubtitle: {
    fontSize: 20,
  },
  modeIcon: {
    width: 80,
    height: 80,
    borderRadius: 40,
    justifyContent: "center",
    alignItems: "center",
    marginBottom: 20,
  },
  modePicker: {
    flexDirection: "row",
    backgroundColor: "#f0f0f0",
    borderRadius: 25,
    marginBottom: 20,
  },
  modeButton: {
    paddingVertical: 10,
    paddingHorizontal: 20,
    borderRadius: 25,
  },
  selectedMode: {
    backgroundColor: "white",
  },
  modeButtonText: {
    fontSize: 16,
    fontWeight: "bold",
  },
  recommendationLabel: {
    flexDirection: "row",
    alignItems: "center",
    paddingVertical: 5,
    paddingHorizontal: 10,
    borderRadius: 15,
    marginBottom: 20,
  },
  recommendationText: {
    color: "white",
    marginLeft: 5,
    fontWeight: "bold",
  },
  featureList: {
    alignSelf: "stretch",
    marginBottom: 30,
  },
  featureItem: {
    fontSize: 16,
    marginBottom: 10,
  },
  completeButton: {
    paddingVertical: 12,
    paddingHorizontal: 30,
    borderRadius: 25,
  },
  completeButtonText: {
    color: "white",
    fontSize: 18,
    fontWeight: "bold",
  },
  pulsingDotContainer: {
    width: 100,
    height: 100,
    justifyContent: "center",
    alignItems: "center",
    marginBottom: 30,
  },
  pulsingDot: {
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: "rgba(33, 150, 243, 0.3)",
    position: "absolute",
  },
  largerInnerDot: {
    width: 70,
    height: 70,
    borderRadius: 35,
    backgroundColor: "#2196F3",
  },
  navigationButton: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "#2196F3",
    paddingVertical: 10,
    paddingHorizontal: 20,
    borderRadius: 25,
    marginBottom: 30,
  },
  navigationButtonText: {
    color: "white",
    fontSize: 18,
    fontWeight: "bold",
    marginRight: 10,
  },
  pagination: {
    bottom: 20,
  },
  dot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: "#bbb",
    margin: 3,
  },
  activeDot: {
    backgroundColor: "#2196F3",
  },
  bottomButtonContainer: {
    position: "absolute",
    bottom: 60,
    left: 0,
    right: 0,
    alignItems: "center",
  },
  iconSpacing: {
    marginVertical: 20,
  },
  recommendationSpacing: {
    marginBottom: 10,
  },
  centeredFeatureList: {
    alignItems: "center",
    marginBottom: 30,
  },
  largerFeatureItem: {
    fontSize: 18,
    marginBottom: 10,
  },
  grayTitle: {
    color: "#666",
  },
});

export default styles;
