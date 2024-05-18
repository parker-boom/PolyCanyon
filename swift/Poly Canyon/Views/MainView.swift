// MARK: MainView.swift
// This file defines the MainView structure for the "Arch Graveyard" app, serving as the primary interface after onboarding. It orchestrates the user navigation through a tab view setup.

// Notable features include:
// - A tab view integrating MapView, DetailView, and SettingsView, controlled by user selections.
// - Customized tab bar facilitating switching between these views, with dynamic styling based on the dark mode setting.

// This view utilizes SwiftUI's declarative syntax for clean and efficient UI code, essential for a responsive user experience in navigating the architectural structures.





// MARK: Code
import SwiftUI
import Combine

struct MainView: View {
    // MARK: - Properties
    
    @State private var selection = 1
    @StateObject private var structureData = StructureData()
    @StateObject private var mapPointManager = MapPointManager()
    @Binding var isDarkMode: Bool
    @Binding var isAdventureModeEnabled: Bool
    
    @StateObject private var keyboardManager = KeyboardManager()
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if selection == 0 {
                    MapView(isDarkMode: $isDarkMode, isAdventureModeEnabled: $isAdventureModeEnabled, structureData: structureData, mapPointManager: mapPointManager)
                } else if selection == 1 {
                    DetailView(structureData: structureData, isDarkMode: $isDarkMode, isAdventureModeEnabled: $isAdventureModeEnabled)
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



struct CustomTabBar: View {
    // MARK: - Properties
    
    let tabBarHeight: CGFloat = 50 // Adjust this value to your desired height
    let onTabSelected: (Int) -> Void
    @Binding var selection: Int
    let isDarkMode: Bool
    
    // MARK: - Body
    
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


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(isDarkMode: .constant(true), isAdventureModeEnabled: .constant(false))
    }
}
