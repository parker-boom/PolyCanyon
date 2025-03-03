import SwiftUI
import Combine

struct DVAppView: View {
    @AppStorage("DVOnboardingComplete") var onboardingComplete: Bool = false
    @AppStorage("DVUserRole") var userRole: DVRole = .visitor
    @Binding var designVillageMode: Bool
    // Track both current hour and current scheme for UI updates
    @State private var currentHour: Int = Calendar.current.component(.hour, from: Date())
    @State private var refreshToggle: Bool = false  // Used to force UI refresh
    
    // Update hour when view appears or becomes active
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            if onboardingComplete {
                DVMain(designVillageMode: $designVillageMode, userRole: $userRole)
            } else {
                DVOnboarding(userRole: $userRole)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        // This id modifier forces SwiftUI to completely recreate the view when refreshToggle changes
        .id(refreshToggle)
        .onAppear {
            print("🔄 App appeared - Checking color scheme...")
            updateColorScheme()
        }
        .onReceive(timer) { _ in
            print("⏱️ Timer fired - Current hour: \(currentHour)")
            let newHour = Calendar.current.component(.hour, from: Date())
            print("⏱️ New hour: \(newHour)")
            if newHour != currentHour {
                print("⏱️ Hour changed from \(currentHour) to \(newHour) - Updating scheme")
                currentHour = newHour
                updateColorScheme()
            } else {
                print("⏱️ Hour unchanged - No update needed")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            print("📱 App entered foreground - Checking color scheme...")
            // Force refresh current hour to ensure accurate time check
            currentHour = Calendar.current.component(.hour, from: Date())
            updateColorScheme()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            print("📱 App became active - Checking color scheme...")
            // Force refresh current hour to ensure accurate time check
            currentHour = Calendar.current.component(.hour, from: Date())
            updateColorScheme()
        }
    }
    
    private func updateColorScheme() {
        // Apply the correct theme based on time (8pm to 7am = dark mode)
        let isDarkMode = (currentHour >= 20 || currentHour < 7)
        let modeLabel = isDarkMode ? "DARK" : "LIGHT"
        print("🎨 Setting color scheme to \(modeLabel) MODE (Hour: \(currentHour))")
        
        let newScheme: DVDesignSystem.ColorScheme = isDarkMode ? .dark : .light
        let currentScheme = DVDesignSystem.Colors.scheme
        
        if currentScheme == newScheme {
            print("🎨 Color scheme was already set to \(modeLabel) MODE - No change needed")
        } else {
            print("🎨 Updating from \(currentScheme == .dark ? "DARK" : "LIGHT") to \(modeLabel) MODE")
            
            // Update the global scheme
            DVDesignSystem.Colors.scheme = newScheme
            
            // Force UI refresh by toggling state
            print("🔁 Forcing UI refresh")
            DispatchQueue.main.async {
                withAnimation {
                    refreshToggle.toggle()
                }
                
                // Post notification for other components to refresh
                NotificationCenter.default.post(name: Notification.Name("DVColorSchemeChanged"), object: nil)
            }
        }
        
        // For testing, output the actual colors being used
        print("📋 Current colors after update:")
        print("- Background: \(DVDesignSystem.Colors.background)")
        print("- Surface: \(DVDesignSystem.Colors.surface)")
        print("- Text: \(DVDesignSystem.Colors.text)")
    }
}

struct DVAppView_Previews: PreviewProvider {
    static var previews: some View {
        DVAppView(designVillageMode: .constant(true))
    }
}
