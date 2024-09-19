// MARK: DetailView.swift

import SwiftUI
import Combine
import CoreLocation
import Glur // Package for gradient blur

/**
 * DetailView
 *
 * Displays detailed information about structures in the Poly Canyon app. Users can view structures
 * in either grid or list formats, search for specific structures, and filter them based on various criteria
 * such as favorites, visited, unopened, and unvisited. The view also handles displaying popups with
 * detailed information about selected structures.
 */
struct DetailView: View {
    // MARK: - Observed Objects and Bindings
    @ObservedObject var structureData: StructureData
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var mapPointManager: MapPointManager
    @Binding var isDarkMode: Bool
    @Binding var isAdventureModeEnabled: Bool
    
    // MARK: - State Variables
    @State private var selectedStructure: Structure?
    @State private var showStructPopup = false
    @State private var searchText = ""
    @State private var isGridView = true
    @State private var showPopup = false
    @State private var showOnboardingImage = false
    @AppStorage("visitedCount") private var visitedCount: Int = 0
    @State private var showEyePopup = false
    @State private var sortState: SortState = .all
    
    // MARK: - Sorting States
    enum SortState {
        case all, favorites, visited, unopened, unvisited
    }
    
    // MARK: - Computed Properties for Sorting Options
    private var hasVisitedStructures: Bool {
        structureData.structures.contains { $0.isVisited }
    }
    
    private var hasUnopenedStructures: Bool {
        structureData.structures.contains { $0.isVisited && !$0.isOpened }
    }
    
    private var hasUnvisitedStructures: Bool {
        structureData.structures.contains { !$0.isVisited }
    }
    
    private var hasLikedStructures: Bool {
        structureData.structures.contains { $0.isLiked }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background Color
            (isDarkMode ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Header with Sort Button, Search Bar, and View Toggle
                headerView
                
                // Scrollable Content: Grid or List View
                ScrollView {
                    if isGridView {
                        if shouldShowRecentlyVisited {
                            recentlyVisitedView
                                .padding(.top, 10)
                        }
                        
                        if shouldShowRecentlyUnopened {
                            recentlyUnopenedView
                                .padding(.top, 10)
                        }
                        
                        if shouldShowNearbyUnvisited {
                            nearbyUnvisitedView
                                .padding(.top, 10)
                        }
                        
                        gridView
                    } else {
                        listView
                    }
                }
            }
            .background(isDarkMode ? Color.black : Color.white)
            .onAppear {
                let firstVisit = UserDefaults.standard.integer(forKey: "firstVisitedStructure")
                if firstVisit != 0 {
                    structureData.ensureStructureVisited(firstVisit)
                }
            }
            .onAppear {
                // Observe structureVisited notifications to update visited structures
                if isAdventureModeEnabled {
                    NotificationCenter.default.addObserver(forName: .structureVisited, object: nil, queue: .main) { [self] notification in
                        if let landmarkId = notification.object as? Int {
                            structureData.markStructureAsVisited(landmarkId, recentlyVisitedCount: visitedCount)
                            visitedCount += 1
                        }
                    }
                }
            }
            
            // Structure Popup Overlay
            if showStructPopup {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showStructPopup = false
                    }
                
                if let selectedStructure = selectedStructure {
                    StructPopUp(
                        structureData: structureData,
                        structure: selectedStructure,
                        isDarkMode: $isDarkMode,
                        isPresented: $showStructPopup
                    )
                    .padding(15)
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
        }
        .overlay(
            // Eye Icon Popup Overlay
            Group {
                if showEyePopup {
                    VStack {
                        Spacer()
                        PopupView(message: getPopupMessage(), isDarkMode: isDarkMode)
                            .padding(.bottom, 15)
                            .transition(.move(edge: .bottom))
                    }
                }
            }
        )
        .background(isDarkMode ? Color.black : Color.white)
    }
    
    // MARK: - Header View
    /**
     * Header View containing the Sort Button, Search Bar, and View Toggle.
     */
    var headerView: some View {
        HStack {
            sortButton
            
            SearchBar(text: $searchText, placeholder: "Search structures...", isDarkMode: isDarkMode)
                .frame(maxWidth: .infinity)
            
            if searchText != "" {
                Button(action: {
                    searchText = ""
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(isDarkMode ? .white : .black)
                        .font(.system(size: 20, weight: .semibold))
                        .padding(.trailing, 5)
                }
            }
            
            Toggle(isOn: $isGridView) {
                Text("View Mode")
            }
            .toggleStyle(CustomToggleStyle(isDarkMode: isDarkMode))
        }
        .background(isDarkMode ? Color.black : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: isDarkMode ? .white.opacity(0.2) : .black.opacity(0.4), radius: 5, x: 0, y: 3)
        .padding(.horizontal, 10)
        .padding(.bottom, -5)
    }
    
    // MARK: - Sort Button
    /**
     * Sort Button that presents a menu for filtering structures.
     */
    var sortButton: some View {
        Menu {
            Button(action: { sortState = .all }) {
                Label("All", systemImage: "circle.fill")
            }
            if hasLikedStructures {
                Button(action: { sortState = .favorites }) {
                    Label("Favorites", systemImage: "heart.fill")
                }
            }
            if isAdventureModeEnabled {
                if hasVisitedStructures {
                    Button(action: { sortState = .visited }) {
                        Label("Visited", systemImage: "checkmark.circle")
                    }
                }
                if hasUnopenedStructures {
                    Button(action: { sortState = .unopened }) {
                        Label("Unopened", systemImage: "envelope")
                    }
                }
                if hasUnvisitedStructures {
                    Button(action: { sortState = .unvisited }) {
                        Label("Unvisited", systemImage: "xmark.circle")
                    }
                }
            }
        } label: {
            Image(systemName: getSortButtonImageName())
                .foregroundColor(getSortButtonColor())
                .font(.system(size: 28, weight: .semibold))
                .padding(5)
                .cornerRadius(8)
        }
        .padding(.leading, 5)
    }
    
    /**
     * Determines the appropriate sort button image based on the current sort state.
     *
     * - Returns: A string representing the system image name.
     */
    func getSortButtonImageName() -> String {
        switch sortState {
        case .all:
            return "circle.fill"
        case .favorites:
            return "heart.fill"
        case .visited:
            return "checkmark.circle"
        case .unopened:
            return "envelope"
        case .unvisited:
            return "xmark.circle"
        }
    }
    
    /**
     * Determines the appropriate sort button color based on the current sort state.
     *
     * - Returns: A Color representing the sort button's color.
     */
    func getSortButtonColor() -> Color {
        switch sortState {
        case .all:
            return isDarkMode ? .white : .black
        case .favorites:
            return .red
        case .visited:
            return .green
        case .unopened:
            return .blue
        case .unvisited:
            return .red
        }
    }
    
    // MARK: - Filtered Structures
    /**
     * Filters the structures based on search text and sort state.
     *
     * - Returns: An array of Structure objects that match the search and filter criteria.
     */
    var filteredStructures: [Structure] {
        let searchFiltered = structureData.structures.filter { structure in
            searchText.isEmpty || structure.title.localizedCaseInsensitiveContains(searchText) || String(structure.number).contains(searchText)
        }
        
        switch sortState {
        case .all:
            return searchFiltered
        case .favorites:
            return searchFiltered.filter { $0.isLiked }
        case .visited:
            return searchFiltered.filter { $0.isVisited }
        case .unopened:
            return searchFiltered.filter { $0.isVisited && !$0.isOpened }
        case .unvisited:
            return searchFiltered.filter { !$0.isVisited }
        }
    }
    
    // MARK: - Grid View
    /**
     * Displays structures in a grid format.
     */
    var gridView: some View {
        VStack {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                ForEach(filteredStructures, id: \.id) { structure in
                    StructureGridItem(structure: structure, isDarkMode: isDarkMode, isAdventureModeEnabled: isAdventureModeEnabled)
                        .onTapGesture {
                            showStructurePopup(structure)
                        }
                }
                .shadow(color: isDarkMode ? .white.opacity(0.2) : .black.opacity(0.4), radius: 5, x: 0, y: 3)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - List View
    /**
     * Displays structures in a list format.
     */
    var listView: some View {
        VStack(spacing: 0) {
            ForEach(filteredStructures, id: \.id) { structure in
                Divider()
                    .background(isDarkMode ? Color.white.opacity(0.3) : Color.black.opacity(0.4))
                
                HStack {
                    Text("\(structure.number)")
                        .foregroundColor(isDarkMode ? .white : .black)
                        .font(.system(size: 18, weight: .thin))
                    
                    Text(structure.title)
                        .foregroundColor(isDarkMode ? .white : .black)
                        .font(.system(size: 23, weight: .semibold))
                        .padding(.leading, 10)
                    
                    Spacer()
                    
                    if isAdventureModeEnabled {
                        if structure.isVisited && !structure.isOpened {
                            Circle()
                                .fill(Color.blue.opacity(0.7))
                                .frame(width: 8, height: 8)
                                .padding(.trailing, 5)
                        }
                        
                        Image(systemName: "figure.walk")
                            .foregroundColor(structure.isVisited ? .green : .red)
                            .font(.title2)
                            .padding(.trailing, 10)
                    } else {
                        Button(action: {
                            structureData.toggleLike(for: structure.id)
                        }) {
                            Image(systemName: structure.isLiked ? "heart.fill" : "heart")
                                .foregroundColor(structure.isLiked ? .red : .white)
                                .font(.system(size: 22))
                        }
                        .padding(.trailing, 10)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(isDarkMode ? Color.black : Color.white)
                .onTapGesture {
                    showStructurePopup(structure)
                }
            }
            Divider()
        }
        .padding(.top, 5)
    }
    
    // MARK: - Popup Views
    /**
     * Displays recently visited structures in a horizontal layout.
     */
    var recentlyVisitedView: some View {
        let recentlyVisitedStructures = structureData.structures
            .filter { $0.recentlyVisited != -1 }
            .sorted { $0.recentlyVisited > $1.recentlyVisited }
            .prefix(3)
        
        return VStack {
            HStack {
                Spacer()
                
                ForEach(recentlyVisitedStructures, id: \.id) { structure in
                    ZStack(alignment: .bottomTrailing) {
                        Image(structure.mainPhoto)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(15)
                        
                        Text("\(structure.number)")
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2, x: 0, y: 0)
                            .padding(4)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(5)
                            .offset(x: -5, y: -5)
                    }
                    .frame(width: 80, height: 80)
                    .shadow(color: isDarkMode ? .white.opacity(0.1) : .black.opacity(0.2), radius: 4, x: 0, y: 0)
                    .onTapGesture {
                        showStructurePopup(structure)
                    }
                    
                    Spacer()
                }
            }
            
            Text("Recently Visited")
                .font(.headline)
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.top, 5)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(10)
        .background(isDarkMode ? Color.black : Color.white)
        .cornerRadius(15)
        .shadow(color: isDarkMode ? .white.opacity(0.2) : .black.opacity(0.4), radius: 5, x: 0, y: 3)
        .frame(maxWidth: UIScreen.main.bounds.width - 20)
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
    }
    
    /**
     * Displays recently unopened structures in a horizontal layout.
     */
    var recentlyUnopenedView: some View {
        let recentlyUnopenedStructures = structureData.structures
            .filter { !$0.isOpened && $0.isVisited }
            .sorted { $0.recentlyVisited > $1.recentlyVisited }
            .prefix(3)
        
        return VStack {
            HStack {
                Spacer()
                
                ForEach(recentlyUnopenedStructures, id: \.id) { structure in
                    ZStack(alignment: .bottomTrailing) {
                        Image(structure.mainPhoto)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(15)
                        
                        Text("\(structure.number)")
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2, x: 0, y: 0)
                            .padding(4)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(5)
                            .offset(x: -5, y: -5)
                    }
                    .frame(width: 80, height: 80)
                    .shadow(color: isDarkMode ? .white.opacity(0.1) : .black.opacity(0.2), radius: 4, x: 0, y: 0)
                    .onTapGesture {
                        showStructurePopup(structure)
                    }
                    
                    Spacer()
                }
            }
            
            Text("Recently Unopened")
                .font(.headline)
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.top, 5)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(10)
        .background(isDarkMode ? Color.black : Color.white)
        .cornerRadius(15)
        .shadow(color: isDarkMode ? .white.opacity(0.2) : .black.opacity(0.4), radius: 5, x: 0, y: 3)
        .frame(maxWidth: UIScreen.main.bounds.width - 20)
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
    }
    
    /**
     * Displays nearby unvisited structures in a horizontal layout.
     */
    var nearbyUnvisitedView: some View {
        let nearbyUnvisitedStructures = structureData.structures
            .filter { !$0.isVisited }
            .sorted { getDistance(to: $0) < getDistance(to: $1) }
            .prefix(3)
        
        return VStack {
            HStack {
                Spacer()
                
                ForEach(nearbyUnvisitedStructures, id: \.id) { structure in
                    ZStack(alignment: .bottomTrailing) {
                        Image(structure.mainPhoto)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(15)
                        
                        Text("\(structure.number)")
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2, x: 0, y: 0)
                            .padding(4)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(5)
                            .offset(x: -5, y: -5)
                    }
                    .frame(width: 80, height: 80)
                    .shadow(color: isDarkMode ? .white.opacity(0.1) : .black.opacity(0.2), radius: 4, x: 0, y: 0)
                    .onTapGesture {
                        showStructurePopup(structure)
                    }
                    
                    Spacer()
                }
            }
            
            Text("Nearby Unvisited")
                .font(.headline)
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.top, 5)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(10)
        .background(isDarkMode ? Color.black : Color.white)
        .cornerRadius(15)
        .shadow(color: isDarkMode ? .white.opacity(0.2) : .black.opacity(0.4), radius: 5, x: 0, y: 3)
        .frame(maxWidth: UIScreen.main.bounds.width - 20)
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
    }
    
    // MARK: - Helper Functions
    
    /**
     * Calculates the distance from the user's location to a given structure.
     *
     * - Parameter structure: The Structure object to calculate distance to.
     * - Returns: A CLLocationDistance representing the distance in meters.
     */
    func getDistance(to structure: Structure) -> CLLocationDistance {
        guard let userLocation = locationManager.lastLocation else { return .infinity }
        let structureLocation = mapPointManager.mapPoints.first { $0.landmark == structure.number }?.coordinate
        let structureCLLocation = CLLocation(latitude: structureLocation?.latitude ?? 0, longitude: structureLocation?.longitude ?? 0)
        return userLocation.distance(from: structureCLLocation)
    }
    
    /**
     * Determines if certain filtered views should be displayed based on sort state and adventure mode.
     *
     * - Returns: A Boolean indicating whether recently visited structures should be shown.
     */
    private var shouldShowRecentlyVisited: Bool {
        structureData.structures.contains(where: { $0.recentlyVisited != -1 }) && sortState == .visited && isAdventureModeEnabled
    }
    
    /**
     * Determines if certain filtered views should be displayed based on sort state and adventure mode.
     *
     * - Returns: A Boolean indicating whether recently unopened structures should be shown.
     */
    private var shouldShowRecentlyUnopened: Bool {
        structureData.structures.contains(where: { !$0.isOpened && $0.isVisited }) && sortState == .unopened && isAdventureModeEnabled
    }
    
    /**
     * Determines if certain filtered views should be displayed based on sort state and adventure mode.
     *
     * - Returns: A Boolean indicating whether nearby unvisited structures should be shown.
     */
    private var shouldShowNearbyUnvisited: Bool {
        structureData.structures.contains(where: { !$0.isVisited }) && sortState == .unvisited && isAdventureModeEnabled
    }
    
    /**
     * Generates the appropriate message for the popup based on the current sort state.
     *
     * - Returns: A String message representing the current filter.
     */
    func getPopupMessage() -> String {
        switch sortState {
        case .all:
            return "All"
        case .favorites:
            return "Favorites"
        case .visited:
            return "Visited"
        case .unopened:
            return "Unopened"
        case .unvisited:
            return "Unvisited"
        }
    }
    
    /**
     * Displays a temporary popup message for the current sort state.
     *
     * - Parameter state: The current SortState.
     */
    func showPopup(for state: SortState) {
        withAnimation {
            showEyePopup = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showEyePopup = false
            }
        }
    }
    
    /**
     * Handles displaying the structure popup when a structure is selected.
     *
     * - Parameter structure: The Structure object that was selected.
     */
    private func showStructurePopup(_ structure: Structure) {
        selectedStructure = structure
        if structure.isVisited {
            structureData.markStructureAsOpened(structure.number)
        }
        showStructPopup = true
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        let impactMed = UIImpactFeedbackGenerator(style: .rigid)
        impactMed.impactOccurred()
    }
}

// MARK: - View Extensions and Helper Structs

/**
 * RoundedCornerShape
 *
 * A custom Shape that allows for specifying which corners to round.
 */
struct RoundedCornerShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    /**
     * Creates the path for the rounded corner shape.
     *
     * - Parameter rect: The CGRect in which to draw the shape.
     * - Returns: A Path representing the rounded corners.
     */
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

/**
 * PopupView
 *
 * Displays a transient popup message, typically used for showing filter selections.
 */
struct PopupView: View {
    let message: String
    let isDarkMode: Bool
    
    var body: some View {
        Text(message)
            .padding()
            .font(.system(size: 23, weight: .semibold))
            .background(popupBackground)
            .foregroundColor(isDarkMode ? .white : .black)
            .cornerRadius(10)
            .shadow(color: isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7), radius: 6, x: 0, y: 0)
            .frame(width: UIScreen.main.bounds.width * 0.6)
            .transition(.move(edge: .bottom))
    }
    
    /// Determines the background color based on dark mode.
    var popupBackground: Color {
        isDarkMode ? Color.black : Color.white
    }
}

/**
 * SearchBar
 *
 * A custom search bar component that integrates with UIKit's UISearchBar for advanced customization.
 */
struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var isDarkMode: Bool

    /**
     * Creates the UISearchBar view.
     *
     * - Parameter context: The context in which the view is created.
     * - Returns: A customized UISearchBar instance.
     */
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = CustomUISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.autocapitalizationType = .none
        searchBar.searchBarStyle = .minimal

        // Remove background, icon, and set text color
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBar.setImage(UIImage(), for: .search, state: .normal) // Removes the search icon
        searchBar.tintColor = .clear // Removes the tint color for the search icon

        let textField = searchBar.searchTextField
        textField.backgroundColor = .clear // Removes background
        textField.borderStyle = .none
        textField.textColor = isDarkMode ? .white : .black // Set text color

        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray // Set placeholder color to gray
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: placeholderAttributes)

        // Add padding to the text field
        textField.leftView = nil
        textField.layoutMargins = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        
        return searchBar
    }

    /**
     * Updates the UISearchBar with new data.
     *
     * - Parameters:
     *   - uiView: The UISearchBar instance to update.
     *   - context: The current context.
     */
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }

    /**
     * Creates the coordinator for handling UISearchBarDelegate methods.
     *
     * - Returns: An instance of Coordinator.
     */
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    /**
     * Coordinator class to handle UISearchBarDelegate methods.
     */
    class Coordinator: NSObject, UISearchBarDelegate {
        var parent: SearchBar

        /**
         * Initializes the Coordinator with a reference to the parent SearchBar.
         *
         * - Parameter parent: The parent SearchBar instance.
         */
        init(_ parent: SearchBar) {
            self.parent = parent
        }

        /**
         * Updates the search text as the user types.
         *
         * - Parameters:
         *   - searchBar: The UISearchBar instance.
         *   - searchText: The current text in the search bar.
         */
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            parent.text = searchText
        }
    }
}

/**
 * CustomUISearchBar
 *
 * A subclass of UISearchBar that removes the clear ("X") button from the search text field.
 */
class CustomUISearchBar: UISearchBar {
    override func layoutSubviews() {
        super.layoutSubviews()
        // Remove the clear button (X)
        if let textField = self.value(forKey: "searchField") as? UITextField {
            if let clearButton = textField.value(forKey: "clearButton") as? UIButton {
                clearButton.isHidden = true
            }
        }
    }
}

/**
 * CustomToggleStyle
 *
 * A custom toggle style for switching between grid and list views.
 */
struct CustomToggleStyle: ToggleStyle {
    var isDarkMode: Bool

    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()  // Toggles the state of the Toggle
        }) {
            HStack {
                Image(systemName: configuration.isOn ? "square.grid.2x2" : "list.bullet")
                    .foregroundColor(isDarkMode ? .white : .black)
                    .font(.system(size: 28, weight: .bold))
                    .frame(width: 44, height: 44)
                    .background(isDarkMode ? Color.black : Color.white)  // Set background based on dark mode
                    .cornerRadius(8)
            }
        }
        .buttonStyle(PlainButtonStyle())  // Removes default button styling
        .frame(height: 44)
        .background(isDarkMode ? Color.black.opacity(0.1) : Color.white.opacity(0.9))
        .cornerRadius(10)
        .padding(.trailing, 5)
    }
}

/**
 * StructureGridItem
 *
 * Represents an individual structure item within the grid view. Displays the structure's image and number,
 * and handles tap gestures to show detailed information.
 */
struct StructureGridItem: View {
    let structure: Structure
    let isDarkMode: Bool
    let isAdventureModeEnabled: Bool
    
    @StateObject private var imageLoader = ImageLoader()
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ZStack(alignment: .topTrailing) {
                if (structure.isVisited && isAdventureModeEnabled) || (!isAdventureModeEnabled) {
                    imageLoader.image?
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: (UIScreen.main.bounds.width - 45) / 2, height: (UIScreen.main.bounds.width - 60) / 2)
                        .glur(radius: 6.0, offset: 0.6, interpolation: 0.4, direction: .down)
                        .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
                        .clipped()
                        .cornerRadius(15)
                        .overlay(
                            Group {
                                if imageLoader.isLoading {
                                    ProgressView()
                                }
                            }
                        )
                    
                    if structure.isOpened {
                        // Checkmark at the top right
                        Image("Check")
                            .resizable()
                            .foregroundColor(.white)
                            .frame(width: 13, height: 13)
                            .padding(12)
                    } else {
                        if isAdventureModeEnabled {
                            // Blue circle if visited but not opened & adventure mode
                            Circle()
                                .fill(Color.blue.opacity(0.7))
                                .frame(width: 10, height: 10)
                                .shadow(color: .white.opacity(1), radius: 1, x: 0, y: 0)
                                .shadow(color: .white.opacity(0.7), radius: 2, x: 0, y: 0)
                                .shadow(color: .white.opacity(0.8), radius: 4, x: 0, y: 0)
                                .padding(12)
                        }
                    }
                } else {
                    Image(structure.mainPhoto)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: (UIScreen.main.bounds.width - 45) / 2, height: (UIScreen.main.bounds.width - 60) / 2)
                        .clipped()
                        .cornerRadius(15)
                        .blur(radius: 2.5)
                }
            }
            
            // Text overlay for structure number and title
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text("\(structure.number)")
                        .font(.system(size: 22))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Spacer()
                }
                
                Text(structure.title)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .allowsTightening(true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
            .padding(.top, 5)
        }
        .onAppear {
            imageLoader.load(imageName: structure.mainPhoto)
        }
        .onDisappear {
            imageLoader.cancel()
        }
    }
}

/**
 * ImageLoader
 *
 * Handles asynchronous loading of images for structures, providing a published Image object and loading state.
 */
class ImageLoader: ObservableObject {
    @Published var image: Image?
    @Published var isLoading = false
    
    private var cancellable: AnyCancellable?
    
    /**
     * Initiates the loading of an image by name.
     *
     * - Parameter imageName: The name of the image to load.
     */
    func load(imageName: String) {
        guard image == nil else { return }
        
        isLoading = true
        cancellable = loadImage(named: imageName)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Error loading image: \(error)")
                }
            } receiveValue: { [weak self] uiImage in
                self?.image = Image(uiImage: uiImage)
            }
    }
    
    /**
     * Cancels any ongoing image loading tasks.
     */
    func cancel() {
        cancellable?.cancel()
    }
    
    /**
     * Loads an image asynchronously from the app bundle.
     *
     * - Parameter imageName: The name of the image to load.
     * - Returns: A publisher that emits a UIImage or an Error.
     */
    private func loadImage(named imageName: String) -> AnyPublisher<UIImage, Error> {
        return Future<UIImage, Error> { promise in
            if let image = UIImage(named: imageName) {
                promise(.success(image))
            } else {
                promise(.failure(NSError(domain: "ImageLoading", code: 0, userInfo: [NSLocalizedDescriptionKey: "Image not found"])))
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let structureVisited = Notification.Name("StructureVisited")
}

// MARK: - Preview
struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(
            structureData: StructureData(),
            locationManager: LocationManager(
                mapPointManager: MapPointManager(),
                structureData: StructureData(),
                isAdventureModeEnabled: true
            ),
            mapPointManager: MapPointManager(),
            isDarkMode: .constant(false),
            isAdventureModeEnabled: .constant(true)
        )
    }
}
