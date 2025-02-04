import { StyleSheet, Dimensions } from "react-native";

const { width, height } = Dimensions.get("window");

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
    paddingTop: 40,
    paddingBottom: 40,
    marginTop: -height * 0.1,
  },
  icon: {
    width: 180,
    height: 180,
    marginBottom: 30,
    borderRadius: 40,
    marginTop: -20,
  },
  title: {
    fontSize: 32,
    fontWeight: "bold",
    textAlign: "center",
    color: "black",
    marginBottom: 5,
  },
  greenTitle: {
    color: "#4CAF50",
    fontSize: 42,
  },
  blueTitle: {
    color: "#2196F3",
    fontSize: 42,
  },
  coloredTitle: {
    fontSize: 38,
    marginTop: -5,
  },
  subtitle: {
    fontSize: 22,
    textAlign: "center",
    color: "#666",
    marginVertical: 20,
    paddingHorizontal: 20,
    lineHeight: 30,
  },
  titleContainer: {
    marginBottom: 10,
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
  modeIcon: {
    width: 100,
    height: 100,
    borderRadius: 50,
    justifyContent: "center",
    alignItems: "center",
    marginVertical: 30,
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
    marginTop: 20,
    marginBottom: 30,
    paddingHorizontal: 20,
    alignItems: "center",
  },
  featureItem: {
    fontSize: 18,
    color: "#444",
    marginBottom: 15,
    lineHeight: 24,
    textAlign: "center",
  },
  completeButton: {
    paddingVertical: 16,
    paddingHorizontal: 50,
    borderRadius: 30,
    marginTop: 20,
  },
  completeButtonText: {
    color: "white",
    fontSize: 22,
    fontWeight: "bold",
  },
  pulsingDotContainer: {
    width: 120,
    height: 120,
    justifyContent: "center",
    alignItems: "center",
    marginVertical: 30,
  },
  pulsingDot: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: "rgba(33, 150, 243, 0.3)",
    position: "absolute",
  },
  largerInnerDot: {
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: "#2196F3",
  },
  navigationButton: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "rgba(0,0,0,0.8)",
    paddingVertical: 12,
    paddingHorizontal: 25,
    borderRadius: 25,
    position: "absolute",
    bottom: height * 0.15,
    alignSelf: "center",
  },
  navigationButtonText: {
    color: "white",
    fontSize: 18,
    fontWeight: "bold",
    marginRight: 8,
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
    bottom: 0,
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
  backButton: {
    position: "absolute",
    bottom: height * 0.08,
    alignSelf: "center",
    paddingVertical: 8,
    paddingHorizontal: 16,
  },
  backButtonText: {
    color: "#666",
    fontSize: 16,
  },
  finalSlide: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    padding: 20,
    paddingTop: 40,
    paddingBottom: 40,
    marginTop: -height * 0.1,
  },
  finalSlideBackground: {
    ...StyleSheet.absoluteFillObject,
    opacity: 0.15,
    zIndex: -1,
  },
  backgroundLocationButton: {
    flexDirection: "row",
    alignItems: "center",
    paddingVertical: 12,
    paddingHorizontal: 20,
    borderRadius: 25,
    marginTop: 10,
    marginBottom: 30,
  },
  backgroundLocationButtonText: {
    color: "white",
    fontSize: 16,
    fontWeight: "bold",
  },
});

export default styles;
