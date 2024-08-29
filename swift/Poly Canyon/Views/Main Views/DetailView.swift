
// MARK: Overview
/*
    DetailView.swift

    This file defines the DetailView structure, which displays detailed information about structures in a grid or list view.

    Key Components:
    - Binding properties for dark mode and adventure mode.
    - ObservedObject properties for data management (structureData, locationManager, mapPointManager).
    - State properties to manage UI interactions and filters.

    Functionality:
    - Toggles between grid and list views.
    - Displays recently visited, unopened, and nearby unvisited structures.
    - Handles search functionality and filters using the eye icon.
    - Shows structure details in a popup when selected.
*/



// MARK: Code
import SwiftUI
import Combine
import CoreLocation
import Glur  //package for gradient blur [need to add as package dependency to use]


struct DetailView: View {
    @ObservedObject var structureData: StructureData
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var mapPointManager: MapPointManager
    @Binding var isDarkMode: Bool
    @Binding var isAdventureModeEnabled: Bool
    @State private var selectedStructure: Structure?

    @State private var searchText = ""
    @State private var isGridView = true
    @State private var showPopup = false
    @State private var showOnboardingImage = false
    @AppStorage("visitedCount") private var visitedCount: Int = 0

    @State private var showEyePopup = false
    @State private var eyeIconState: EyeIconState = .all
    @State private var virtualTourSortState: VirtualTourSortState = .all

    enum EyeIconState {
        case all
        case visited
        case unopened
        case unvisited
    }
    
    enum VirtualTourSortState  {
        case all, favorites
    }
    
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
           (isDarkMode ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)
            
            VStack {

                // Header view for switching filters and views
                headerView
                
                            
                // Scroll view that displays either grid or list view
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
                        
                        // Show grid view
                        gridView
                    } else {
                        // Show list view
                        listView
                    }
                }
            
                
                // Present pop up
                .sheet(isPresented: $showPopup) {
                     if let selectedStructure = selectedStructure {
                         StructPopUp(
                             structureData: structureData,
                             structure: selectedStructure,
                             isDarkMode: $isDarkMode
                         ) {
                             showPopup = false
                         }
                     }
                 }
            }
            .background(isDarkMode ? Color.black : Color.white)
            
            // MARK: - On Appear
            .onAppear {
                // Load the structures from CSV on the first open
                if structureData.structures.count < 36 {
                    structureData.loadStructuresFromCSV()
                }
                // Less then 36 was just to make sure newest structure added

        
                
                // Accept notifications to mark as visited if adventure mode enabled
                if isAdventureModeEnabled {
                    NotificationCenter.default.addObserver(forName: .structureVisited, object: nil, queue: .main) { [self] notification in
                        if let landmarkId = notification.object as? Int {
                            if let index = structureData.structures.firstIndex(where: { $0.number == landmarkId }) {
                                structureData.structures[index].isVisited = true
                                
                                if structureData.structures[index].recentlyVisited == -1 {
                                    structureData.structures[index].recentlyVisited = visitedCount
                                    visitedCount += 1
                                }
                            }
                        }
                    }
                }
            }
        }
        .overlay(
            Group {

                // Show eyePopUp when you change filters
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
    
    
    // MARK: - Views and Helpers
    var headerView: some View {
        HStack {
            if isAdventureModeEnabled {
                adventureModeEyeButton
            } else {
                virtualTourSortButton
            }

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

    var adventureModeEyeButton: some View {
        Button(action: toggleEyeIconState) {
            Image(systemName: "eye")
                .foregroundColor(getEyeIconColor())
                .font(.system(size: 28, weight: .semibold))
                .padding(5)
                .cornerRadius(8)
        }
        .padding(.leading, 5)
    }

    var virtualTourSortButton: some View {
        Button(action: toggleVirtualTourSortState) {
            Image(systemName: virtualTourSortState == .all ? "circle.fill" : "heart.fill")
                .foregroundColor(virtualTourSortState == .all ? .black : .red)
                .font(.system(size: 28, weight: .semibold))
                .padding(5)
                .cornerRadius(8)
        }
        .padding(.leading, 5)
    }

    var filteredStructures: [Structure] {
        let searchFiltered = structureData.structures.filter { structure in
            searchText.isEmpty || structure.title.localizedCaseInsensitiveContains(searchText) || String(structure.number).contains(searchText)
        }

        if isAdventureModeEnabled {
            switch eyeIconState {
            case .all:
                return searchFiltered
            case .visited:
                return searchFiltered.filter { $0.isVisited }
            case .unopened:
                return searchFiltered.filter { $0.isVisited && !$0.isOpened }
            case .unvisited:
                return searchFiltered.filter { !$0.isVisited }
            }
        } else {
            switch virtualTourSortState {
            case .all:
                return searchFiltered
            case .favorites:
                return searchFiltered.filter { $0.isLiked }
            }
        }
    }

    // MARK: GridView
    // Grid view that shows all structures in a grid, with images
    var gridView: some View {
        VStack {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                ForEach(filteredStructures, id: \.id) { structure in
                    StructureGridItem(structure: structure, isDarkMode: isDarkMode, isAdventureModeEnabled: isAdventureModeEnabled)
                        .onTapGesture {
                            selectedStructure = structure
                            if let index = structureData.structures.firstIndex(where: { $0.id == structure.id }) {
                                structureData.objectWillChange.send()
                                if structureData.structures[index].isVisited {
                                    structureData.structures[index].isOpened = true
                                }
                            }
                            showPopup = true
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

                            let impactMed = UIImpactFeedbackGenerator(style: .rigid)
                            impactMed.impactOccurred()
                        }
                }
                .shadow(color: isDarkMode ? .white.opacity(0.2) : .black.opacity(0.4), radius: 5, x: 0, y: 3)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 30)
        }
    }




    // MARK: ListView
    // Show all structures in a smaller more concise list
    var listView: some View {
        VStack(spacing: 0) {
            ForEach(filteredStructures, id: \.id) { structure in
                
                Divider()
                    .background(isDarkMode ? Color.white.opacity(0.3) : Color.black.opacity(0.4))
                
                // Show number then title
                HStack {
                    Text("\(structure.number)")
                        .foregroundColor(isDarkMode ? .white : .black)
                        .font(.system(size: 18, weight: .thin))
                        .foregroundColor(isDarkMode ? .white : Color.black.opacity(0.7))
                    
                    Text(structure.title)
                        .foregroundColor(isDarkMode ? .white : .black)
                        .font(.system(size: 23, weight: .semibold))
                        .foregroundColor(isDarkMode ? .white : .black)
                        .padding(.leading, 10)
                    
                    Spacer()
                    
                    if structure.isVisited && !structure.isOpened && isAdventureModeEnabled{
                        Circle()
                            .fill(Color.blue.opacity(0.7))
                            .frame(width: 8, height: 8)
                            .padding(.trailing, 5)
                    }
                    
                    if isAdventureModeEnabled {
                        // Walking figure green if visited
                        Image(systemName: "figure.walk")
                            .foregroundColor(structure.isVisited ? .green : .red)
                            .font(.title2)
                            .padding(.trailing, 10)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(isDarkMode ? Color.black : Color.white)
                
                // Show pop up if clicked
                .onTapGesture {
                    selectedStructure = structure
                    if let index = structureData.structures.firstIndex(where: { $0.id == structure.id }) {
                        structureData.objectWillChange.send()
                        if structureData.structures[index].isVisited {
                            structureData.structures[index].isOpened = true
                        }
                    }
                    showPopup = true
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    
                    // Generate haptic feedback
                    let impactMed = UIImpactFeedbackGenerator(style: .rigid)
                    impactMed.impactOccurred()
                }
            }
            Divider()
        }
        .padding(.top, 5)
    }

    // MARK: PopUpViews
    // Show recently visited structures in order
    var recentlyVisitedView: some View {
        let recentlyVisitedStructures = structureData.structures
            .filter { $0.recentlyVisited != -1 }
            .sorted { $0.recentlyVisited > $1.recentlyVisited }
            .prefix(3)
        
        return VStack {
            HStack {
                Spacer()

                // Show image and number of each
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
                    // Open if clicked on
                    .onTapGesture {
                        selectedStructure = structure
                        if let index = structureData.structures.firstIndex(where: { $0.id == structure.id }) {
                            structureData.objectWillChange.send()
                            structureData.structures[index].isOpened = true
                        }
                        showPopup = true
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        
                        // Generate haptic feedback
                        let impactMed = UIImpactFeedbackGenerator(style: .rigid)
                        impactMed.impactOccurred()
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
    
    // Shows recently unopened views
    var recentlyUnopenedView: some View {
        let recentlyUnopenedStructures = structureData.structures
            .filter { !$0.isOpened && $0.isVisited }
            .sorted { $0.recentlyVisited > $1.recentlyVisited }
            .prefix(3)
        
        return VStack {
            HStack {
                Spacer()
                // Show images and number for each
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
                    // Open if tap
                    .onTapGesture {
                        selectedStructure = structure
                        if let index = structureData.structures.firstIndex(where: { $0.id == structure.id }) {
                            structureData.objectWillChange.send()
                            structureData.structures[index].isOpened = true
                        }
                        showPopup = true
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        
                        // Generate haptic feedback
                        let impactMed = UIImpactFeedbackGenerator(style: .rigid)
                        impactMed.impactOccurred()
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

    // Show nearby structures if they aren't visited
    var nearbyUnvisitedView: some View {
        let userLocation = locationManager.lastLocation
        let nearbyUnvisitedStructures = structureData.structures
            .filter { !$0.isVisited }
            .sorted { getDistance(to: $0) < getDistance(to: $1) }
            .prefix(3)
        
        return VStack {
            HStack {
                Spacer()

                // Show each image and number
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
                    // Open if selected
                    .onTapGesture {
                        selectedStructure = structure
                        if structureData.structures.firstIndex(where: { $0.id == structure.id }) != nil {
                            structureData.objectWillChange.send()
                        }
                        showPopup = true
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        
                        // Generate haptic feedback
                        let impactMed = UIImpactFeedbackGenerator(style: .rigid)
                        impactMed.impactOccurred()
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
    
    private var shouldShowRecentlyVisited: Bool {
        structureData.structures.contains(where: { $0.recentlyVisited != -1 }) && eyeIconState == .visited && isAdventureModeEnabled
    }

    private var shouldShowRecentlyUnopened: Bool {
        structureData.structures.contains(where: { !$0.isOpened && $0.isVisited }) && eyeIconState == .unopened && isAdventureModeEnabled
    }

    private var shouldShowNearbyUnvisited: Bool {
        structureData.structures.contains(where: { !$0.isVisited }) && eyeIconState == .unvisited && isAdventureModeEnabled
    }

    

    // Get distance to nearby structures for unvisited
    func getDistance(to structure: Structure) -> CLLocationDistance {
        guard let userLocation = locationManager.lastLocation else { return .infinity }
        let structureLocation = mapPointManager.mapPoints.first { $0.landmark == structure.number }?.coordinate
        let structureCLLocation = CLLocation(latitude: structureLocation?.latitude ?? 0, longitude: structureLocation?.longitude ?? 0)
        return userLocation.distance(from: structureCLLocation)
    }

    // Show the eye icon based on which filter
    func toggleEyeIconState() {
        switch eyeIconState {
        case .all:
            eyeIconState = .visited
        case .visited:
            eyeIconState = .unopened
        case .unopened:
            eyeIconState = .unvisited
        case .unvisited:
            eyeIconState = .all
        }
        showPopup(for: eyeIconState)
    }
    
    func toggleVirtualTourSortState() {
        virtualTourSortState = virtualTourSortState == .all ? .favorites : .all
        showPopup(for: virtualTourSortState)
    }
    
    
    // Change eye icon color based on which filter
    func getEyeIconColor() -> Color {
        switch eyeIconState {
        case .all:
            return isDarkMode ? .white : .black
        case .visited:
            return .green
        case .unopened:
            return Color.blue.opacity(0.7)
        case .unvisited:
            return .red
        }
    }

    // Change eye popup message based on which filter
    func getPopupMessage() -> String {
           if isAdventureModeEnabled {
               switch eyeIconState {
               case .all: return "All"
               case .visited: return "Visited"
               case .unopened: return "Unopened"
               case .unvisited: return "Unvisited"
               }
           } else {
               return virtualTourSortState == .all ? "All" : "Favorites"
           }
       }

    func showPopup(for state: Any) {
        withAnimation {
            showEyePopup = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showEyePopup = false
            }
        }
    }
}


// MARK: - View Extension & Structs

// Cut off rounded corner shape
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }
}

// View that comes up when filter is changed
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
    
    var popupBackground: Color {
        isDarkMode ? Color.black : Color.white
    }
}

// Used above
struct RoundedCornerShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}


// Search bar custom implementation
struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var isDarkMode: Bool

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

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UISearchBarDelegate {
        var parent: SearchBar

        init(_ parent: SearchBar) {
            self.parent = parent
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            parent.text = searchText
        }
    }
}

// Custom UISearchBar to hide the "X" clear button
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


// Custom toggle between grid and list view
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
            
            // Text overlay
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

class ImageLoader: ObservableObject {
    @Published var image: Image?
    @Published var isLoading = false
    
    private var cancellable: AnyCancellable?
    
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
    
    func cancel() {
        cancellable?.cancel()
    }
    
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


// allow notification from MapView to update a structure via adventure mode
extension Notification.Name {
    static let structureVisited = Notification.Name("StructureVisited")
}

// MARK: - Preview
struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(structureData: StructureData(), locationManager: LocationManager(mapPointManager: MapPointManager(), structureData: StructureData()), mapPointManager: MapPointManager(), isDarkMode: .constant(false), isAdventureModeEnabled: .constant(false))
    }
}

