import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var locationService: LocationService
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) private var openURL
    @State private var pendingPermission = false

    private var recording: Bool { appState.adventureModeEnabled && locationService.hasLocationPermission }
    private var visitCount: Int {
        dataStore.structures.filter { $0.isVisited }.count + dataStore.ghostStructures.filter { $0.isVisited }.count
    }

    var body: some View {
        Form {
            Section {
                HStack(alignment: .firstTextBaseline) {
                    Text("\(visitCount)").font(.largeTitle.weight(.semibold)).monospacedDigit()
                    Text(visitCount == 1 ? "structure visited" : "structures visited").foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
                Toggle("Record visits", isOn: Binding(get: { recording }, set: { enabled in setRecording(enabled) }))
                if locationService.isLocationPermissionDenied {
                    Button("Enable location in Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                    }
                }
            } footer: {
                Text("Visits are recorded while the app is open. Your progress stays on this device.")
            }

            Section("About this guide") {
                NavigationLink("Credits & licenses") { GuideCreditsView() }
                Link("Explore the website", destination: URL(string: "https://polycanyon.com")!)
            }
            Section {
                Link("Help & support", destination: URL(string: "https://polycanyon.com/support")!)
                Link("Email Parker", destination: URL(string: "mailto:parker.jones@live.com")!)
                Link("Privacy", destination: URL(string: "https://polycanyon.com/privacy")!)
            }
            Section {
                Text("Poly Canyon \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "")")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Your visit")
        .scrollContentBackground(.hidden)
        .background(colorScheme == .dark ? Color(red: 0.09, green: 0.11, blue: 0.10) : Color(red: 0.97, green: 0.96, blue: 0.92))
        .tint(colorScheme == .dark ? Color(red: 0.59, green: 0.77, blue: 0.62) : Color(red: 0.16, green: 0.30, blue: 0.23))
        .onChange(of: locationService.locationStatus) { _ in
            guard pendingPermission else { return }
            if locationService.hasLocationPermission {
                pendingPermission = false
                setRecording(true)
            } else if locationService.isLocationPermissionDenied {
                pendingPermission = false
            }
        }
    }

    private func setRecording(_ enabled: Bool) {
        if enabled && !locationService.hasLocationPermission {
            if locationService.isLocationPermissionDenied {
                if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
            } else {
                pendingPermission = true
                locationService.requestInitialPermission()
            }
            return
        }
        pendingPermission = false
        appState.adventureModeEnabled = enabled
        locationService.setMode(enabled ? .adventure : .virtualTour)
    }
}

private struct GuideCreditsView: View {
    var body: some View {
        List {
            Section {
                Text("Created by Parker Jones.")
                Text("Cal Poly, San Luis Obispo\nCollege of Architecture and Environmental Design")
                    .foregroundStyle(.secondary)
            }
            Section("Open source") {
                ForEach(["Glur", "Zoomable", "Shiny"], id: \.self) { name in
                    NavigationLink(name) {
                        ScrollView {
                            Text(license(named: name))
                                .font(.callout)
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                        }
                        .navigationTitle(name)
                        .navigationBarTitleDisplayMode(.inline)
                    }
                }
            }
        }
        .navigationTitle("Credits & licenses")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func license(named name: String) -> String {
        let url = Bundle.main.url(forResource: name, withExtension: "txt", subdirectory: "Licenses")
            ?? Bundle.main.url(forResource: name, withExtension: "txt")
        guard let url, let text = try? String(contentsOf: url, encoding: .utf8) else {
            return "License text could not be loaded. Please contact parker.jones@live.com."
        }
        return text
    }
}
