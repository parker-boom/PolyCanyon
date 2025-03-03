// RootRouter.swift
import SwiftUI

struct RootRouter: View {
    @Binding var designVillageMode: Bool?
    let eventStartDate: Date
    let eventEndDate: Date
    @AppStorage("PCOnboardingComplete") private var pcOnboardingComplete: Bool = false
    @State private var currentDate = Date()
    
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    private var isDesignVillageWeekend: Bool {
        return currentDate >= eventStartDate && currentDate <= eventEndDate
    }
    
    private var unwrappedDVMode: Binding<Bool> {
        Binding(
            get: { designVillageMode ?? true },
            set: { designVillageMode = $0 }
        )
    }

    var body: some View {
        Group {
            if isDesignVillageWeekend {
                if !pcOnboardingComplete {
                    DVAppView(designVillageMode: .constant(true))
                } else if let dvMode = designVillageMode {
                    if dvMode {
                        DVAppView(designVillageMode: unwrappedDVMode)
                    } else {
                        PCContainerView()
                    }
                } else {
                    DVPromptView { userChoice in
                        designVillageMode = userChoice
                        UserDefaults.standard.set(userChoice, forKey: "designVillageModeOverride")
                    }
                }
            } else {
                PCContainerView()
            }
        }
        .onAppear {
            currentDate = Date()
        }
        .onReceive(timer) { _ in
            currentDate = Date()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            currentDate = Date()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
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
