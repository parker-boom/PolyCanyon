
// MARK: DetailView.swift
// This file defines the DetailView for the "Arch Graveyard" app, providing detailed information about each architectural structure. It offers a dynamic view switch between a grid and a list layout, accommodating user preferences for viewing the structure data.

// Notable features include:
// - Dynamic search functionality allowing filtering of structures based on text input.
// - Switchable view modes between a grid and a list layout, enhancing user interaction based on preference.
// - Integration of onboarding and tutorial overlays to guide first-time users.
// - Reactive updates to the UI and data model in response to user interactions and system notifications, especially in adventure mode where structures are marked as visited.

// This view is central to displaying detailed information about the structures in a user-friendly format, incorporating interactive elements like search bars and custom view toggles, which make the application engaging and accessible.





// MARK: Code
import SwiftUI

struct DetailView: View {
    // MARK: - Properties
    
    // BINDING
    @ObservedObject var structureData: StructureData
    @Binding var isDarkMode: Bool
    @Binding var isAdventureModeEnabled: Bool
    
    // STATE
    @State private var searchText = ""
    @State private var isGridView = true
    @State private var selectedStructure: Structure?
    @State private var showPopup = false
    @State private var showOnboardingImage = false
    
    // eye icon
    @State private var showEyePopup = false
    @State private var eyeIconState: EyeIconState = .all
    enum EyeIconState {
        case all
        case visited
        case unvisited
    }
    
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
           (isDarkMode ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                
                HStack {
                    // Eye icon in a rounded square
                    Button(action: toggleEyeIconState) {
                        Image(systemName: "eye")
                            .foregroundColor(getEyeIconColor())
                            .font(.system(size: 28, weight: .semibold))
                            .padding(5)
                            .cornerRadius(8)
                    }
                    .padding(.leading, 5)
                    
                    // Search Bar UI
                    SearchBar(text: $searchText, placeholder: "Search structures...", isDarkMode: isDarkMode)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 5)
                    
                    // Toggle for grid and list view
                    Toggle(isOn: $isGridView, label: {
                        Text("View Mode")  // Optional: You can hide this if not needed
                    })
                    .toggleStyle(CustomToggleStyle(isDarkMode: isDarkMode))
 
                    
                }
                .background(isDarkMode ? Color.black : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: isDarkMode ? .white.opacity(0.2) : .black.opacity(0.4), radius: 5, x: 0, y: 3)
                .shadow(color: isDarkMode ? .white.opacity(0.3) : .black.opacity(0.4), radius: 3, x: 0, y: -2)
                .padding(.horizontal, 10)
                .padding(.bottom, -5)

                
                
                                    
                // Scroll view that displays either grid or list view
                ScrollView {
                    if isGridView {
                        gridView
                    } else {
                        listView
                    }
                }

                
                // present pop up
                .sheet(isPresented: $showPopup) {
                    StructPopUp(structure: selectedStructure, isDarkMode: $isDarkMode){}
                        .background(isDarkMode ? Color.black : Color.white)
                        .edgesIgnoringSafeArea(.all)
                }
            }
            .background(isDarkMode ? Color.black : Color.white)
            
            // MARK: - On Appear
            .onAppear {
                // load the structures from CSV on the first open
                if structureData.structures.count < 30 {
                    structureData.loadStructuresFromCSV()
                }
                
                // show onboarding image
                if !UserDefaults.standard.bool(forKey: "detailOnboardingImageShown") {
                    showOnboardingImage = true
                }
                
                // accept notifications to mark as visited if adventure mode enabled
                if isAdventureModeEnabled {
                    NotificationCenter.default.addObserver(forName: .structureVisited, object: nil, queue: .main) { [self] notification in
                        if let landmarkId = notification.object as? Int {

                            
                            if let index = structureData.structures.firstIndex(where: { $0.number == landmarkId }) {
                                structureData.structures[index].isVisited = true
                            }
                        }
                    }
                }
            }
            
            // show onboarding image with white background
            if showOnboardingImage {
                Color.white.opacity(1)
                    .edgesIgnoringSafeArea(.all)
                
                Image("DetailPopUp")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width)
                    .onTapGesture {
                        
                        // dismiss onboarding image when clicke
                        withAnimation {
                            showOnboardingImage = false
                            UserDefaults.standard.set(true, forKey: "detailOnboardingImageShown")
                        }
                    }
            }
        }
        .overlay(
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
    
    var gridView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
            ForEach(structureData.structures.filter { structure in
                let searchMatch = searchText.isEmpty ? true : structure.title.localizedCaseInsensitiveContains(searchText) || String(structure.number).contains(searchText)
                
                switch eyeIconState {
                case .all:
                    return searchMatch
                case .visited:
                    return searchMatch && structure.isVisited
                case .unvisited:
                    return searchMatch && !structure.isVisited
                }
            }, id: \.id) { structure in
                ZStack(alignment: .bottomLeading) {
                    ZStack(alignment: .topTrailing) {
                        Image(structure.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: (UIScreen.main.bounds.width - 45) / 2, height: (UIScreen.main.bounds.width - 60) / 2)
                            .clipped()
                            .cornerRadius(15)
                            .blur(radius: structure.isVisited ? 0 : 3)
                        
                        if structure.isVisited && !structure.isOpened {
                            Circle()
                                .fill(Color.green.opacity(0.8))
                                .frame(width: 10, height: 10)
                                .shadow(color: .white.opacity(1), radius: 1, x: 0, y: 0)
                                .shadow(color: .white.opacity(0.7), radius: 2, x: 0, y: 0)
                                .shadow(color: .white.opacity(0.8), radius: 4, x: 0, y: 0)
                                .padding(10)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text("\(structure.number)")
                                .font(.system(size: 22))
                                .fontWeight(.semibold)
                                .foregroundColor(isDarkMode ? .white : .black)
                            
                            Spacer()
                        }
                        
                        Text(structure.title)
                            .font(.system(size: 18))
                            .foregroundColor(isDarkMode ? .white : .black)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .allowsTightening(true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
                    .padding(.top, 5)
                    .frame(maxWidth: .infinity)
                    .background(isDarkMode ? Color.black.opacity(1) : Color.white.opacity(1))
                    .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
                }
                .onTapGesture {
                    selectedStructure = structure
                    if let index = structureData.structures.firstIndex(where: { $0.id == structure.id }) {
                        structureData.objectWillChange.send()
                        structureData.structures[index].isOpened = true
                    }
                    showPopup = true
                    
                    // Generate haptic feedback
                    let impactMed = UIImpactFeedbackGenerator(style: .rigid)
                    impactMed.impactOccurred()
                }
            }
            .shadow(color: isDarkMode ? .white.opacity(0.1) : .black.opacity(0.2), radius: 6, x: 0, y: 0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 30)
    }
    
    var listView: some View {
        VStack(spacing: 0) {
            ForEach(structureData.structures.filter { structure in
                let searchMatch = searchText.isEmpty ? true : structure.title.localizedCaseInsensitiveContains(searchText) || String(structure.number).contains(searchText)
                
                switch eyeIconState {
                case .all:
                    return searchMatch
                case .visited:
                    return searchMatch && structure.isVisited
                case .unvisited:
                    return searchMatch && !structure.isVisited
                }
            }, id: \.id) { structure in
                
                Divider()
                    .background(isDarkMode ? Color.white.opacity(0.3) : Color.black.opacity(0.4))
                
                // show number then title
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
                    
                    if structure.isVisited && !structure.isOpened {
                        Circle()
                            .fill(Color.blue.opacity(0.7))
                            .frame(width: 8, height: 8)
                            .padding(.trailing, 5)
                    }
                    
                    // walking figure green if visited
                    Image(systemName: "figure.walk")
                        .foregroundColor(structure.isVisited ? .green : .red)
                        .font(.title2)
                        .padding(.trailing, 10)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(isDarkMode ? Color.black : Color.white)
                
                // show pop up if clicked
                .onTapGesture {
                    selectedStructure = structure
                    if let index = structureData.structures.firstIndex(where: { $0.id == structure.id }) {
                        structureData.objectWillChange.send()
                        structureData.structures[index].isOpened = true
                    }
                    showPopup = true
                    
                    // Generate haptic feedback
                    let impactMed = UIImpactFeedbackGenerator(style: .rigid)
                    impactMed.impactOccurred()
                }
            }
            Divider()
        }
        .padding(.top, 5)
    }
    
    func toggleEyeIconState() {
        switch eyeIconState {
        case .all:
            eyeIconState = .visited
        case .visited:
            eyeIconState = .unvisited
        case .unvisited:
            eyeIconState = .all
        }
        showPopup(for: eyeIconState)
    }
    
    
    func getEyeIconColor() -> Color {
        switch eyeIconState {
        case .all:
            return isDarkMode ? .white : .black
        case .visited:
            return .green
        case .unvisited:
            return .red
        }
    }
    
    func getPopupMessage() -> String {
        switch eyeIconState {
        case .all:
            return "All"
        case .visited:
            return "Visited"
        case .unvisited:
            return "Unvisited"
        }
    }
    
    func showPopup(for state: EyeIconState) {
        let message: String
        switch state {
        case .all:
            message = "All"
        case .visited:
            message = "Visited"
        case .unvisited:
            message = "Unvisited"
        }
        
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



struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var isDarkMode: Bool

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.autocapitalizationType = .none
        searchBar.searchBarStyle = .minimal

        // Customize the search bar's appearance based on isDarkMode
        searchBar.barTintColor = isDarkMode ? .black : .white
        searchBar.tintColor = isDarkMode ? .white : .black
        searchBar.setImage(UIImage(systemName: "magnifyingglass")?.withTintColor(isDarkMode ? .white : .black, renderingMode: .alwaysOriginal), for: .search, state: .normal)

        let textField = searchBar.searchTextField
        textField.textColor = isDarkMode ? .white : .black
        textField.backgroundColor = isDarkMode ? UIColor(white: 0.2, alpha: 1.0) : .white

        // Set the placeholder color based on isDarkMode
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: isDarkMode ? UIColor.white.withAlphaComponent(0.7) : UIColor.black.withAlphaComponent(0.7)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: placeholderAttributes)

        // Add a done button to the keyboard
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: context.coordinator, action: #selector(Coordinator.doneButtonTapped))
        toolbar.items = [flexSpace, doneButton]
        textField.inputAccessoryView = toolbar

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

        @objc func doneButtonTapped() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}



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


// MARK: - Structure

// define Structure, which holds all the information for
struct Structure: Identifiable, Codable {
    let number: Int
    let title: String
    let imageName: String
    let closeUp: String
    let description: String
    let year: String
    var isVisited: Bool = false
    var isOpened: Bool = false
    
    var id: Int { number }
}

// allow notification from MapView to update a structure via adventure mode
extension Notification.Name {
    static let structureVisited = Notification.Name("StructureVisited")
}

// MARK: - Preview
struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(structureData: StructureData(), isDarkMode: .constant(false), isAdventureModeEnabled: .constant(false))
    }
}

