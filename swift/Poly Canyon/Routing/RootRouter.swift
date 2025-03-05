// RootRouter.swift
import SwiftUI

struct RootRouter: View {
    @Binding var designVillageMode: Bool?
    let eventStartDate: Date
    let eventEndDate: Date
    @AppStorage("onboardingProcess") private var pcOnboardingComplete: Bool = false
    @State private var currentDate = Date()
    @State private var forceRefresh: Bool = false  // Added to force view refresh
    
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    private var isDesignVillageWeekend: Bool {
        let isInWeekend = currentDate >= eventStartDate && currentDate <= eventEndDate
        // Store this value in UserDefaults for other components to access
        UserDefaults.standard.set(isInWeekend, forKey: "isDesignVillageWeekend")
        return isInWeekend
    }
    
    private var unwrappedDVMode: Binding<Bool> {
        Binding(
            get: { 
                let value = designVillageMode ?? true
                print("👀 [RootRouter] unwrappedDVMode get: \(value)")
                return value
            },
            set: { newValue in
                print("✏️ [RootRouter] unwrappedDVMode set: \(newValue)")
                designVillageMode = newValue
                // Also update UserDefaults here to ensure it's always in sync
                UserDefaults.standard.set(newValue, forKey: "designVillageModeOverride")
                
                // Force a view refresh when the mode changes
                forceRefresh.toggle()
            }
        )
    }

    var body: some View {
        Group {
            if isDesignVillageWeekend {
                if !pcOnboardingComplete {
                    // Check if there's a specific override first
                    if designVillageMode == false {
                        PCContainerView()
                            .onAppear { print("✅ [RootRouter] Force PCContainerView with override") }
                    } else {
                        DVAppView(designVillageMode: unwrappedDVMode)
                            .onAppear {
                                print("🔍 [RootRouter] DVAppView appeared - designVillageMode: \(String(describing: designVillageMode))")
                                if designVillageMode == nil {
                                    print("🔄 [RootRouter] Setting default DV mode for new user")
                                    designVillageMode = true
                                    UserDefaults.standard.set(true, forKey: "designVillageModeOverride")
                                }
                            }
                    }
                } else if let dvMode = designVillageMode {
                    if dvMode {
                        DVAppView(designVillageMode: unwrappedDVMode)
                            .onAppear { print("✅ [RootRouter] Showing DVAppView with mode: \(dvMode)") }
                    } else {
                        PCContainerView()
                            .onAppear { print("✅ [RootRouter] Showing PCContainerView with mode: \(dvMode)") }
                    }
                } else {
                    DVPromptView { userChoice in
                        print("🔄 [RootRouter] DVPromptView callback with choice: \(userChoice)")
                        designVillageMode = userChoice
                        UserDefaults.standard.set(userChoice, forKey: "designVillageModeOverride")
                        forceRefresh.toggle()  // Force refresh when mode is set
                    }
                    .onAppear { print("🔍 [RootRouter] Using DVPromptView path") }
                }
            } else {
                PCContainerView()
                    .onAppear { print("🗓️ [RootRouter] Outside DV weekend - showing PCContainerView") }
            }
        }
        .id(forceRefresh)  // Force view reconstruction when this changes
        .onAppear {
            print("📱 [RootRouter] onAppear with designVillageMode: \(String(describing: designVillageMode))")
            print("🗓️ [RootRouter] isDesignVillageWeekend: \(isDesignVillageWeekend)")
            print("🔍 [RootRouter] pcOnboardingComplete: \(pcOnboardingComplete)")
            
            if isDesignVillageWeekend {
                print("🗓️ [RootRouter] In Design Village weekend")
                if !pcOnboardingComplete {
                    print("🆕 [RootRouter] Will use !pcOnboardingComplete path with mode: \(String(describing: designVillageMode))")
                } else if let dvMode = designVillageMode {
                    print("🔍 [RootRouter] Will use let dvMode path with dvMode: \(dvMode)")
                } else {
                    print("🔍 [RootRouter] Will use DVPromptView path")
                }
            }
            
            currentDate = Date()
        }
        .onReceive(timer) { _ in
            currentDate = Date()
            // Update the flag in UserDefaults when timer updates
            _ = isDesignVillageWeekend
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            print("📱 [RootRouter] willEnterForeground with designVillageMode: \(String(describing: designVillageMode))")
            currentDate = Date()
            // Update the flag in UserDefaults when returning to foreground
            _ = isDesignVillageWeekend
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            print("📱 [RootRouter] didBecomeActive with designVillageMode: \(String(describing: designVillageMode))")
            currentDate = Date()
            // Update the flag in UserDefaults when becoming active
            _ = isDesignVillageWeekend
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ModeSwitched"))) { _ in
            print("⚡️ [RootRouter] Received ModeSwitched notification")
            print("⚡️ [RootRouter] Current designVillageMode: \(String(describing: designVillageMode))")
            
            // Force the router to reload UserDefaults and refresh its view
            let savedMode = UserDefaults.standard.bool(forKey: "designVillageModeOverride")
            print("⚡️ [RootRouter] UserDefaults value: \(savedMode)")
            
            // Ensure the value is updated if needed
            if designVillageMode != savedMode {
                print("⚡️ [RootRouter] Updating designVillageMode to match UserDefaults")
                designVillageMode = savedMode
            }
            
            // Force UI refresh
            forceRefresh.toggle()  // Use our new mechanism
            currentDate = Date()
        }
    }
}

struct RootRouter_Previews: PreviewProvider {
    static var previews: some View {
        RootRouter(designVillageMode: .constant(nil),
                   eventStartDate: Date(),
                   eventEndDate: Date().addingTimeInterval(86400))
    }
}
