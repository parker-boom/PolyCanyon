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
        VStack(spacing: 8) {
            HStack(spacing: 15) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.black)
                    .font(.system(size: 20))
                
                TextField("Search structures...", text: $searchText)
                    .font(.system(size: 17))
                    .foregroundColor(appState.isDarkMode ? .white : .black)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                }
            )
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 0)
            .padding(.horizontal, 15)
            .padding(.top, 12)
            
            HStack(spacing: 12) {
                FilterButton(sortState: $sortState)
                
                Spacer()
                
                ViewModePicker(isGridView: $isGridView)
            }
            .padding(.horizontal, 15)
            .padding(.bottom, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(white: 0.65).opacity(0.75))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                )
                .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 5)
        )
        .padding(.horizontal, 10)
    }
}

struct FilterButton: View {
    @EnvironmentObject var appState: AppState
    @Binding var sortState: SortState
    
    var filterText: String {
        switch sortState {
        case .all: return "All"
        case .visited: return "Visited"
        case .favorites: return "Liked"
        }
    }
    
    var filterIcon: String {
        switch sortState {
        case .all: return "circle.fill"
        case .visited: return "checkmark.circle.fill"
        case .favorites: return "heart.fill"
        }
    }
    
    var filterColor: Color {
        switch sortState {
        case .all: return .blue
        case .visited: return .green
        case .favorites: return .pink
        }
    }
    
    var body: some View {
        Menu {
            Button(action: { sortState = .all }) {
                Label("All", systemImage: "circle.fill")
            }
            
            if appState.adventureModeEnabled {
                Button(action: { sortState = .visited }) {
                    Label("Visited", systemImage: "checkmark.circle.fill")
                }
            }
            
            Button(action: { sortState = .favorites }) {
                Label("Liked", systemImage: "heart.fill")
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: filterIcon)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.35), radius: 2, x: 0, y: 0)
                
                Text(filterText)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black.opacity(0.8))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.3))
                }
            )
        }
    }
}

struct ViewModePicker: View {
    @Binding var isGridView: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: { isGridView = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "square.grid.2x2.fill")
                    if isGridView {
                        Text("Grid")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                )
                
            }
            .foregroundColor(isGridView ? .black : .gray)

            
            
            Button(action: { isGridView = false }) {
                HStack(spacing: 6) {
                    Image(systemName: "list.bullet")
                    if !isGridView {
                        Text("List")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                )
            }
            .foregroundColor(!isGridView ? .black : .gray)
        }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.3))
                }
            )
    }
}

// Helper for frosted-glass effect
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
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
                        Image(structure.images[0])
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
