/*
 DetailComponents provides reusable UI components for the detail view hierarchy. It includes the header 
 controls (search, sort, view mode), highlight rows for structure collections, and custom UI elements like
 the search bar and toggle styles. These components adapt their appearance based on the current theme and
 app mode settings.
*/

import SwiftUI
import Combine
import CoreLocation
import Glur

/*
 DetailHeaderView manages the top control bar with search, sort and view mode toggles. It provides a 
 unified interface for filtering and organizing structure content while maintaining consistent styling
 with the current theme.
*/
struct DetailHeaderView: View {
    @EnvironmentObject var appState: AppState
    
    @Binding var searchText: String
    @Binding var sortState: SortState
    @Binding var isGridView: Bool
    
    var body: some View {
        HStack {
            // Sort menu with dynamic options based on mode
            SortButton(sortState: $sortState)
            
            // Search field with clear button
            SearchBar(
                text: $searchText,
                placeholder: "Search structures..."
            )
            .frame(maxWidth: .infinity)
            
            // Clear search text button
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                  to: nil, from: nil, for: nil)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(appState.isDarkMode ? .white : .black)
                        .font(.system(size: 20, weight: .semibold))
                        .padding(.trailing, 5)
                }
            }
            
            // Toggle between grid and list views
            Toggle(isOn: $isGridView) {
                Text("View Mode")
            }
            .toggleStyle(CustomToggleStyle()) 
        }
        .background(appState.isDarkMode ? Color.black : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: appState.isDarkMode ? .white.opacity(0.2) : .black.opacity(0.4),
                radius: 5, x: 0, y: 3)
        .padding(.horizontal, 10)
        .padding(.bottom, -5)
    }
}

/*
 HighlightStructuresRow displays a horizontal scrolling collection of structures with consistent styling.
 Used for showing groups like "Recently Visited" or "Nearby Unvisited" with thumbnails and structure numbers.
*/
struct HighlightStructuresRow: View {
    @EnvironmentObject var appState: AppState
    
    let title: String
    let structures: [Structure]
    let onTap: (Structure) -> Void
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                ForEach(structures, id: \.id) { structure in
                    Spacer()
                    
                    // Structure thumbnail with number overlay
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
                    .shadow(color: appState.isDarkMode ? .white.opacity(0.1) : .black.opacity(0.2),
                            radius: 4, x: 0, y: 0)
                    .onTapGesture {
                        onTap(structure)
                    }
                    
                    Spacer()
                }
            }
            
            Text(title)
                .font(.headline)
                .foregroundColor(appState.isDarkMode ? .white : .black)
                .padding(.top, 5)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(10)
        .background(appState.isDarkMode ? Color.black : Color.white)
        .cornerRadius(15)
        .shadow(color: appState.isDarkMode ? .white.opacity(0.2) : .black.opacity(0.4),
                radius: 5, x: 0, y: 3)
        .frame(maxWidth: UIScreen.main.bounds.width - 20)
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
    }
}

// MARK: - Custom UI Components

/*
 SearchBar provides a minimal search input field that adapts to the current theme.
 Removes default search bar styling for a cleaner look.
*/
struct SearchBar: UIViewRepresentable {
    @EnvironmentObject var appState: AppState
    @Binding var text: String
    var placeholder: String
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = CustomUISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.autocapitalizationType = .none
        searchBar.searchBarStyle = .minimal
        
        // Clean up default search bar styling
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBar.setImage(UIImage(), for: .search, state: .normal)
        searchBar.tintColor = .clear
        
        let textField = searchBar.searchTextField
        textField.backgroundColor = .clear
        textField.borderStyle = .none
        textField.textColor = appState.isDarkMode ? .white : .black
        let placeholderAttr: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: placeholderAttr)
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
        init(_ parent: SearchBar) { self.parent = parent }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            parent.text = searchText
        }
    }
}

// Remove clear button from search bar
class CustomUISearchBar: UISearchBar {
    override func layoutSubviews() {
        super.layoutSubviews()
        if let textField = self.value(forKey: "searchField") as? UITextField,
           let clearButton = textField.value(forKey: "clearButton") as? UIButton {
            clearButton.isHidden = true
        }
    }
}

/*
 CustomToggleStyle provides a themed toggle button for switching between grid and list views.
 Uses SF Symbols to show the current view mode.
*/
struct CustomToggleStyle: ToggleStyle {
    @EnvironmentObject var appState: AppState
    
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack {
                Image(systemName: configuration.isOn ? "square.grid.2x2" : "list.bullet")
                    .foregroundColor(appState.isDarkMode ? .white : .black)
                    .font(.system(size: 28, weight: .bold))
                    .frame(width: 44, height: 44)
                    .background(appState.isDarkMode ? Color.black : Color.white)
                    .cornerRadius(8)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(height: 44)
        .background(appState.isDarkMode ? Color.black.opacity(0.1) : Color.white.opacity(0.9))
        .cornerRadius(10)
        .padding(.trailing, 5)
    }
}

/*
 SortButton provides a menu for filtering structures based on the current app mode.
 Shows different options for adventure mode vs virtual tour mode.
*/
struct SortButton: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @Binding var sortState: SortState
    
    var body: some View {
        Menu {
            // Always show "All" option
            Button(action: {
                sortState = .all
            }) {
                Label("All", systemImage: "circle.fill")
            }
            
            // Adventure mode options
            if appState.adventureModeEnabled {
                if dataStore.hasVisitedStructures {
                    Button(action: {
                        sortState = .visited
                    }) {
                        Label("Visited", systemImage: "checkmark.circle")
                    }
                }
                if dataStore.hasUnvisitedStructures {
                    Button(action: {
                        sortState = .unvisited
                    }) {
                        Label("Unvisited", systemImage: "xmark.circle")
                    }
                }
            }
            
            // Show favorites in both modes
            if dataStore.hasLikedStructures {
                Button(action: {
                    sortState = .favorites
                }) {
                    Label("Favorites", systemImage: "heart.fill")
                }
            }
        } label: {
            Image(systemName: {
                switch sortState {
                case .all: return "circle.fill"
                case .favorites: return "heart.fill"
                case .visited: return "checkmark.circle"
                case .unvisited: return "xmark.circle"
                }
            }())
            .foregroundColor({
                switch sortState {
                case .all: return appState.isDarkMode ? .white : .black
                case .favorites: return .red
                case .visited: return .green
                case .unvisited: return .red
                }
            }())
            .font(.system(size: 28, weight: .semibold))
            .padding(5)
            .cornerRadius(8)
        }
        .padding(.leading, 5)
    }
}