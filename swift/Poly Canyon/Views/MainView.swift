// MARK: Overview
/*
    MainView.swift

    This file defines the MainView and CustomTabBar structures, managing the primary interface and navigation for the app.

    MainView:
    - Displays MapView, DetailView, or SettingsView based on user selection.
    - Utilizes LocationManager, MapPointManager, and StructureData to manage app data.
    - Supports dark mode and adventure mode.
    - Hides the tab bar when the keyboard is visible.

    CustomTabBar:
    - Provides navigation between main views using icons.
    - Adjusts appearance based on dark mode setting.

    KeyboardManager:
    - Observes keyboard visibility to manage UI elements.
*/





// MARK: Code
import SwiftUI
import Combine

struct MainView: View {
    @State private var selection = 1
    @StateObject private var locationManager: LocationManager
    @StateObject private var structureData = StructureData()
    @StateObject private var mapPointManager = MapPointManager()
    @Binding var isDarkMode: Bool
    @Binding var isAdventureModeEnabled: Bool

    @StateObject private var keyboardManager = KeyboardManager()

    init(isDarkMode: Binding<Bool>, isAdventureModeEnabled: Binding<Bool>) {
        self._isDarkMode = isDarkMode
        self._isAdventureModeEnabled = isAdventureModeEnabled
        let mapPointManager = MapPointManager()
        let structureData = StructureData()
        self._locationManager = StateObject(wrappedValue: LocationManager(mapPointManager: mapPointManager, structureData: structureData, isAdventureModeEnabled: isAdventureModeEnabled.wrappedValue))
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if selection == 0 {
                    MapView(isDarkMode: $isDarkMode, isAdventureModeEnabled: $isAdventureModeEnabled, structureData: structureData, mapPointManager: mapPointManager, locationManager: locationManager)
                } else if selection == 1 {
                    DetailView(structureData: structureData, locationManager: locationManager, mapPointManager: mapPointManager, isDarkMode: $isDarkMode, isAdventureModeEnabled: $isAdventureModeEnabled)
                } else if selection == 2 {
                    SettingsView(structureData: structureData, mapPointManager: mapPointManager, isDarkMode: $isDarkMode, isAdventureModeEnabled: $isAdventureModeEnabled)
                }
            }

            if !keyboardManager.isKeyboardVisible {
                CustomTabBar(onTabSelected: { tabIndex in
                    withAnimation {
                        selection = tabIndex
                    }
                }, selection: $selection, isDarkMode: isDarkMode)
                .edgesIgnoringSafeArea(.all)
            }
        }
        .background(isDarkMode ? Color.black : Color.white)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}



// MARK: - CustomTabBar
struct CustomTabBar: View {
    
    let tabBarHeight: CGFloat = 50
    let onTabSelected: (Int) -> Void
    @Binding var selection: Int
    let isDarkMode: Bool

    
    var body: some View {
        VStack() {
            Spacer()
            
            Rectangle()
                .fill(isDarkMode ? Color.white : Color(red: 0.3, green: 0.3, blue: 0.3))
                .frame(height: 0.5)
                
            
            
            
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

// MARK: - keyboardManager
// keyboard manager for dismissing tab bar
class KeyboardManager: ObservableObject {
    @Published var isKeyboardVisible = false
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        addKeyboardObservers()
    }
    
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

// MARK: - Preview
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(isDarkMode: .constant(true), isAdventureModeEnabled: .constant(false))
    }
}
