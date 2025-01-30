import { StyleSheet } from "react-native";

// MARK: - Styles
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "white",
  },
  darkContainer: {
    backgroundColor: "black",
  },
  headerWrapper: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    zIndex: 1,
    paddingHorizontal: 10,
    paddingTop: 10,
  },
  header: {
    borderRadius: 20,
    padding: 15,
    shadowColor: "#000",
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.15,
    shadowRadius: 15,
    elevation: 8,
  },
  lightHeader: {
    backgroundColor: "rgba(255, 255, 255, 0.95)",
  },
  darkHeader: {
    backgroundColor: "rgba(28, 28, 30, 0.95)",
  },
  searchContainer: {
    flexDirection: "row",
    alignItems: "center",
    borderRadius: 12,
    padding: 12,
    marginBottom: 12,
  },
  lightSearchContainer: {
    backgroundColor: "rgba(142, 142, 147, 0.1)",
  },
  darkSearchContainer: {
    backgroundColor: "rgba(44, 44, 46, 0.8)",
  },
  searchIcon: {
    marginRight: 10,
  },
  searchInput: {
    flex: 1,
    fontSize: 17,
    color: "black",
    padding: 0,
  },
  darkSearchInput: {
    color: "white",
  },
  controlsRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
  },
  filterButton: {
    flexDirection: "row",
    alignItems: "center",
    borderRadius: 8,
    padding: 8,
    paddingHorizontal: 12,
  },
  lightFilterButton: {
    backgroundColor: "rgba(142, 142, 147, 0.1)",
  },
  darkFilterButton: {
    backgroundColor: "rgba(44, 44, 46, 0.8)",
  },
  filterIcon: {
    marginRight: 8,
  },
  filterText: {
    fontSize: 16,
    fontWeight: "600",
    marginRight: 4,
  },
  viewModeContainer: {
    flexDirection: "row",
    borderRadius: 8,
    padding: 4,
  },
  lightViewModeContainer: {
    backgroundColor: "rgba(142, 142, 147, 0.1)",
  },
  darkViewModeContainer: {
    backgroundColor: "rgba(44, 44, 46, 0.8)",
  },
  viewModeButton: {
    flexDirection: "row",
    alignItems: "center",
    padding: 8,
    borderRadius: 6,
  },
  activeViewModeButton: {
    backgroundColor: "rgba(255, 255, 255, 0.9)",
  },
  darkActiveViewModeButton: {
    backgroundColor: "rgba(28, 28, 30, 0.9)",
  },
  viewModeText: {
    marginLeft: 6,
    fontSize: 16,
    fontWeight: "600",
  },
  contentContainer: {
    flex: 1,
    marginTop: 135,
    paddingTop: 15,
  },
  gridContentPadding: {
    paddingHorizontal: 16,
  },
  listContentPadding: {
    paddingHorizontal: 0,
  },
  searchContainerWrapper: {
    padding: 10,
    paddingBottom: 5,
  },
  searchBarContainer: {
    flex: 1,
    flexDirection: "row",
    alignItems: "center",
    marginHorizontal: 10,
  },
  searchBar: {
    flex: 1,
    fontSize: 18,
    color: "black",
  },
  darkSearchBar: {
    color: "white",
  },
  clearButton: {
    padding: 8,
    marginLeft: 8,
  },
  list: {
    flex: 1,
    width: "100%",
  },
  darkList: {
    backgroundColor: "black",
  },
  listContent: {
    flexGrow: 1,
  },
  row: {
    flexDirection: "row",
    padding: 15,
    backgroundColor: "white",
    borderBottomWidth: 1,
    borderBottomColor: "#E0E0E0",
    alignItems: "center",
    width: "100%",
  },
  darkRow: {
    backgroundColor: "#1C1C1E",
    borderBottomColor: "#2C2C2E",
  },
  number: {
    fontSize: 18,
    width: 30,
    textAlign: "center",
    fontWeight: "300",
    color: "black",
    opacity: 0.75,
  },
  title: {
    fontSize: 18,
    fontWeight: "500",
    marginLeft: 10,
    flex: 1,
    color: "black",
  },
  darkText: {
    color: "white",
  },
  statusIndicator: {
    width: 12,
    height: 12,
    borderRadius: 6,
    marginLeft: 10,
  },
  visited: {
    backgroundColor: "#4CAF50",
  },
  notVisited: {
    backgroundColor: "#F44336",
  },
  heartContainer: {
    padding: 5,
  },
  gridItem: {
    flex: 1,
    height: 180,
    margin: 6,
    borderRadius: 15,
    overflow: "hidden",
    backgroundColor: "white",
    shadowColor: "#000000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.75,
    shadowRadius: 0.84,
    elevation: 4,
  },
  darkGridItem: {
    backgroundColor: "#1C1C1E",
    shadowColor: "#FFF",
  },
  imageContainer: {
    flex: 1,
    position: "relative",
  },
  gridImage: {
    width: "100%",
    height: "100%",
  },
  gridNumberOverlay: {
    position: "absolute",
    top: 8,
    left: 8,
    fontSize: 18,
    fontWeight: "700",
    color: "white",
    zIndex: 2,
    textShadowColor: "rgba(0, 0, 0, 0.95)",
    textShadowOffset: { width: 0, height: 1 },
    textShadowRadius: 5,
  },
  gridTitle: {
    position: "absolute",
    bottom: 8,
    left: 8,
    right: 8,
    fontSize: 18,
    fontWeight: "700",
    color: "white",
    zIndex: 10,
    textShadowColor: "rgba(0, 0, 0, 0.95)",
    textShadowOffset: { width: 0, height: 1 },
    textShadowRadius: 7,
    padding: 2,
  },
  fullBlur: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  statusIndicatorContainer: {
    position: "absolute",
    top: 8,
    right: 8,
    zIndex: 2,
  },
  blueDot: {
    width: 12,
    height: 12,
    borderRadius: 6,
    backgroundColor: "#007AFF",
    opacity: 0.8,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.3,
    shadowRadius: 2,
  },
  checkmark: {
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.3,
    shadowRadius: 2,
  },
  gridInfoContainer: {
    position: "absolute",
    bottom: 0,
    left: 0,
    right: 0,
    padding: 8,
    zIndex: 1,
  },
  gridNumber: {
    fontSize: 16,
    fontWeight: "600",
    color: "white",
    marginTop: 2,
  },
});

export default styles;
