// MARK: MainView.swift

import SwiftUI
import Combine

/**
 * MainView
 *
 * Acts as the primary interface of the Poly Canyon app, facilitating navigation between different sections
 * such as MapView, DetailView, and SettingsView. It integrates various managers including LocationManager,
 * MapPointManager, and StructureData to handle app data and user interactions.
 * Supports dark mode and adventure mode settings, and dynamically hides the tab bar when the keyboard is visible.
 */
struct MainView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var locationService: LocationService
    @StateObject private var keyboardManager = KeyboardManager()
    @State private var selection = 1
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selection) {
                MapView(
                    isDarkMode: $appState.isDarkMode,
                    isAdventureModeEnabled: $appState.adventureModeEnabled,
                    structures: dataStore.structures,
                    mapPoints: dataStore.mapPoints
                )
                .tag(0)
                
                DetailView()
                .tag(1)
                
                SettingsView()
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: selection)

            if !keyboardManager.isKeyboardVisible {
                CustomTabBar(
                    onTabSelected: { tabIndex in
                        withAnimation {
                            selection = tabIndex
                        }
                    },
                    selection: $selection,
                    isDarkMode: appState.isDarkMode
                )
                .edgesIgnoringSafeArea(.all)
            }
        }
        .background(appState.isDarkMode ? Color.black : Color.white)
        .preferredColorScheme(appState.isDarkMode ? .dark : .light)
    }
}

// MARK: - CustomTabBar

/**
 * CustomTabBar
 *
 * Provides a custom tab bar for navigation between the main sections of the app.
 * Displays icons for Map, Detail, and Settings views, and adjusts appearance based on the dark mode setting.
 */
struct CustomTabBar: View {
    
    let tabBarHeight: CGFloat = 50
    let onTabSelected: (Int) -> Void
    @Binding var selection: Int
    let isDarkMode: Bool

    var body: some View {
        VStack {
            Spacer()
            
            // Divider line above the tab bar
            Rectangle()
                .fill(isDarkMode ? Color.white : Color(red: 0.3, green: 0.3, blue: 0.3))
                .frame(height: 0.5)
            
            // Tab bar icons
            HStack {
                Spacer()
                
                Image(systemName: selection == 0 ? "map.fill" : "map")
                    .font(.system(size: 32, weight: selection == 0 ? .bold : .regular))
                    .foregroundColor(isDarkMode ? .white : .black)
                    .onTapGesture {
                        onTabSelected(0)
                    }
                    .padding(.top, 10)
                
                Spacer()
                
                Image(systemName: selection == 1 ? "info.circle.fill" : "info.circle")
                    .font(.system(size: 32, weight: selection == 1 ? .bold : .regular))
                    .foregroundColor(isDarkMode ? .white : .black)
                    .onTapGesture {
                        onTabSelected(1)
                    }
                    .padding(.top, 10)
                
                Spacer()
                
                Image(systemName: selection == 2 ? "gearshape.fill" : "gearshape")
                    .font(.system(size: 32, weight: selection == 2 ? .bold : .regular))
                    .foregroundColor(isDarkMode ? .white : .black)
                    .onTapGesture {
                        onTabSelected(2)
                    }
                    .padding(.top, 10)
                
                Spacer()
            }
        }
        .frame(height: tabBarHeight)
        .background(isDarkMode ? Color.black : Color(red: 1, green: 1, blue: 1))
    }
}

// MARK: - KeyboardManager

/**
 * KeyboardManager
 *
 * Observes keyboard visibility changes to manage UI elements accordingly.
 * Specifically used to hide the tab bar when the keyboard is visible to ensure an unobstructed user interface.
 */
class KeyboardManager: ObservableObject {
    @Published var isKeyboardVisible = false
    private var cancellables = Set<AnyCancellable>()
    
    /**
     * Initializes the KeyboardManager and sets up observers for keyboard show and hide notifications.
     */
    init() {
        addKeyboardObservers()
    }
    
    /**
     * Adds observers for keyboard show and hide notifications to update the isKeyboardVisible state.
     */
    private func addKeyboardObservers() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] _ in
                self?.isKeyboardVisible = true
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                self?.isKeyboardVisible = false
            }
            .store(in: &cancellables)
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}

/*
 // MARK: - Preview
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(
            isDarkMode: .constant(true),
            isAdventureModeEnabled: .constant(false),
            structureData: StructureData()
        )
    }
}
*/
