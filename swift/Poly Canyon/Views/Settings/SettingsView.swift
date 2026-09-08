import SwiftUI

/// Presented by the main experience as a compact information sheet.
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @State private var pendingPermission = false
    @State private var showsCredits = false

    private var recording: Bool { appState.adventureModeEnabled && locationService.hasLocationPermission }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(locationTitle).font(.headline)
                    Text(locationDescription).font(.callout).foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
                if locationService.isLocationPermissionDenied {
                    Button("Open location settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                    }
                } else {
                    Button(recording ? "Stop marking my visits" : "Mark places I visit") {
                        setRecording(!recording)
                    }
                }
            } header: { Text("Location & visits") }
            Section {
                Button("Credits & licenses") { showsCredits = true }
                Link("Poly Canyon website", destination: URL(string: "https://polycanyon.com")!)
                Link("Help & support", destination: URL(string: "https://polycanyon.com/support")!)
                Link("Privacy", destination: URL(string: "https://polycanyon.com/privacy")!)
            } footer: {
                Text("Poly Canyon \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "")")
            }
        }
        .navigationTitle("Info")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        .scrollContentBackground(.hidden)
        .background(.white)
        .tint(Color(red: 0.15, green: 0.27, blue: 0.21))
        .sheet(isPresented: $showsCredits) {
            NavigationStack {
                GuideCreditsView()
                    .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showsCredits = false } } }
            }
        }
        .onChange(of: locationService.locationStatus) { _ in
            guard pendingPermission else { return }
            if locationService.hasLocationPermission {
                pendingPermission = false
                setRecording(true)
            } else if locationService.isLocationPermissionDenied {
                pendingPermission = false
            }
        }
        .onDisappear { pendingPermission = false }
        .preferredColorScheme(.light)
    }

    private var locationTitle: String {
        if locationService.isLocationPermissionDenied { return "Explore without location" }
        if pendingPermission { return "Choose location access" }
        return recording ? "Your visits appear on the map" : "Mark the places you visit"
    }

    private var locationDescription: String {
        if locationService.isLocationPermissionDenied {
            return "Explore the map and stories from anywhere. Allow location in Settings to see your position and mark the places you visit."
        }
        if recording {
            return "As you reach a structure, it is marked visited. Location is used only while the app is open; your progress stays on this device."
        }
        return "Use location to see where you are and mark the structures you visit. Or explore the map and stories from anywhere."
    }

    private func setRecording(_ enabled: Bool) {
        if enabled && !locationService.hasLocationPermission {
            pendingPermission = true
            locationService.requestInitialPermission()
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
