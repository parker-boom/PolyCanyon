/*
 MapComponents provides the supporting UI elements for the map interface. It includes the virtual tour 
 navigation bar, structure visit notifications, nearby structure overlays, and achievement popups. These 
 components adapt to the current theme and provide consistent interaction patterns across the map experience.
*/

import SwiftUI

// MARK: - Virtual Tour Navigation
struct VirtualWalkThroughBar: View {
    @EnvironmentObject var appState: AppState
    
    let structure: Structure
    let onNext: () -> Void
    let onPrevious: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background container
                RoundedRectangle(cornerRadius: 25)
                    .fill(appState.isDarkMode ? Color.black : Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 5)
                
                // Navigation controls
                HStack(spacing: 0) {
                    arrowButton(direction: .previous)
                    
                    Spacer()
                    
                    structureInfo
                    
                    Spacer()
                    
                    arrowButton(direction: .next)
                }
                .padding(.horizontal, 15)
            }
            .frame(width: geometry.size.width, height: 120)
        }
        .frame(height: 120)
        .padding(.bottom, 10)
    }
    
    // Structure preview with title
    private var structureInfo: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                // Structure thumbnail
                Image(structure.mainPhoto)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                
                // Structure details
                VStack(alignment: .leading, spacing: 5) {
                    Text("#\(structure.number)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(appState.isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
                    
                    Text(structure.title)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(appState.isDarkMode ? .white : .black)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(10)
            .background(appState.isDarkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
            .cornerRadius(20)
        }
    }
    
    // Navigation arrow button
    private func arrowButton(direction: ArrowDirection) -> some View {
        Button(action: direction == .next ? onNext : onPrevious) {
            Image(systemName: direction == .next ? "chevron.right" : "chevron.left")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(appState.isDarkMode ? .white : .black)
                .frame(width: 40, height: 40)
                .background(appState.isDarkMode ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2))
                .clipShape(Circle())
        }
    }
    
    private enum ArrowDirection {
        case next, previous
    }
}

// MARK: - Visit Notification
struct VisitedStructurePopup: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    
    let structure: Structure
    @Binding var isPresented: Bool
    @Binding var showStructPopup: Bool
    @Binding var selectedStructure: Structure?
    let onDismiss: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 10) {
                // Dismiss button
                Button(action: {
                    withAnimation {
                        onDismiss()
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 28))
                        .foregroundColor(appState.isDarkMode ? .white : .black)
                }
                .padding(.leading, 15)
                
                // Structure preview with details
                Button(action: {
                    selectedStructure = structure
                    showStructPopup = true
                    dataStore.markStructureAsOpened(structure.number)
                    onDismiss()
                }) {
                    HStack {
                        // Structure thumbnail
                        Image(structure.mainPhoto)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .cornerRadius(10)
                        
                        // Visit notification
                        VStack(alignment: .leading) {
                            Text("Just Visited!")
                                .font(.system(size: 14))
                                .foregroundColor(appState.isDarkMode ? .white.opacity(0.6) : .black.opacity(0.8))
                            
                            Text(structure.title)
                                .font(.system(size: 24))
                                .fontWeight(.semibold)
                                .foregroundColor(appState.isDarkMode ? .white : .black)
                                .lineLimit(2)
                        }
                        .frame(maxWidth: geometry.size.width - 250, alignment: .leading)
                        .padding(.leading, 10)
                        
                        // Structure number
                        Text(String(structure.number))
                            .font(.system(size: 28))
                            .fontWeight(.bold)
                            .foregroundColor(appState.isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
                            .padding(.leading, 5)
                        
                        Spacer()
                        
                        // Navigation indicator
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20))
                            .foregroundColor(appState.isDarkMode ? .white : .black)
                    }
                }
            }
            .frame(width: geometry.size.width - 30)
            .background(appState.isDarkMode ? Color.black : Color.white)
            .cornerRadius(15)
            .shadow(color: appState.isDarkMode ? .white.opacity(0.2) : .black.opacity(0.4),
                    radius: 5, x: 0, y: 3)
            .padding(.horizontal, 15)
            .padding(.bottom, 15)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .frame(height: 120)
    }
}

// MARK: - Nearby Structures
struct NearbyUnvisitedView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var locationService: LocationService
    
    @Binding var selectedStructure: Structure?
    @Binding var showStructPopup: Bool
    let nearbyUnvisitedStructures: [Structure]
    
    var body: some View {
        VStack {
            // Structure thumbnails row
            HStack {
                ForEach(nearbyUnvisitedStructures, id: \.id) { structure in
                    Spacer()
                    
                    // Structure preview with number
                    ZStack(alignment: .bottomTrailing) {
                        Image(structure.mainPhoto)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(15)
                        
                        // Structure number overlay
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
                        selectedStructure = structure
                        showStructPopup = true
                    }
                    
                    Spacer()
                }
            }
            
            // Section title
            Text("Nearby Unvisited")
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

// MARK: - Achievement Popup
struct AllStructuresVisitedPopup: View {
    @EnvironmentObject var appState: AppState
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            if isPresented {
                VStack {
                    // Achievement message
                    Text("Congratulations!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(appState.isDarkMode ? .white : .black)
                    
                    Text("You have visited all structures!")
                        .foregroundColor(appState.isDarkMode ? .white : .black)
                    
                    // Celebration icon
                    Image("partyHat")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                }
                .frame(width: 300, height: 200)
                .background(appState.isDarkMode ? Color.black : Color.white)
                .cornerRadius(20)
                .shadow(color: appState.isDarkMode ? Color.white : Color.black, radius: 10)
                .onTapGesture {
                    isPresented = false
                }
            }
        }
    }
}

struct MapBackgroundLayer: View {
    let isDarkMode: Bool
    let isSatelliteView: Bool
    
    var body: some View {
        ZStack {
            Color(isDarkMode ? .black : .white)
                .edgesIgnoringSafeArea(.all)
            
            if isSatelliteView {
                Image("BlurredBG")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct MapControlButtons: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    
    @Binding var isSatelliteView: Bool
    @Binding var isVirtualWalkthroughActive: Bool
    @Binding var showNearbyUnvisitedView: Bool
    
    let onUpdateMapPoint: () -> Void
    let onUpdateNearbyPoints: () -> Void
    
    var body: some View {
        ZStack {
            // Adventure mode controls
            if locationService.canUseLocation {
                Button(action: {
                    withAnimation {
                        showNearbyUnvisitedView.toggle()
                        if showNearbyUnvisitedView {
                            onUpdateNearbyPoints()
                        }
                    }
                }) {
                    MapControlButton(
                        systemName: showNearbyUnvisitedView ? "xmark.circle.fill" : "mappin.circle.fill"
                    )
                }
                .padding(.top, -10)
            }
            
            // Virtual tour controls
            if !appState.adventureModeEnabled {
                Button(action: {
                    withAnimation {
                        isVirtualWalkthroughActive.toggle()
                        if isVirtualWalkthroughActive {
                            onUpdateMapPoint()
                        }
                    }
                }) {
                    MapControlButton(
                        systemName: isVirtualWalkthroughActive ? "xmark.circle.fill" : "figure.walk.circle.fill"
                    )
                }
                .padding(.leading, 15)
            }
            
            // Map type toggle
            Button(action: { isSatelliteView.toggle() }) {
                MapControlButton(
                    systemName: isSatelliteView ? "map.fill" : "globe.americas.fill"
                )
            }
            .padding(.top, -10)
            .frame(maxWidth: .infinity, alignment: .topTrailing)
        }
    }
}

struct MapStatusOverlay: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    let geometry: GeometryProxy
    
    var body: some View {
        VStack {
            Spacer()
            if locationService.isLocationPermissionDenied {
                BottomMessage(text: "Enable location services", geometry: geometry)
            } else if !locationService.canUseLocation {
                BottomMessage(text: "Enter the area of Poly Canyon", geometry: geometry)
            }
        }
    }
}

struct MapStructureOverlays: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    
    @Binding var selectedStructure: Structure?
    @Binding var showStructPopup: Bool
    let showNearbyUnvisitedView: Bool
    let nearbyUnvisitedMapPoints: [MapPoint]
    let isVirtualWalkthroughActive: Bool
    let currentStructureIndex: Int
    let onNext: () -> Void
    let onPrevious: () -> Void
    
    var body: some View {
        ZStack {
            // Nearby structures overlay
            if showNearbyUnvisitedView, !nearbyUnvisitedMapPoints.isEmpty {
                NearbyUnvisitedView(
                    selectedStructure: $selectedStructure,
                    showStructPopup: $showStructPopup,
                    nearbyUnvisitedStructures: mapPointsToStructures(nearbyUnvisitedMapPoints)
                )
                .padding(.top, 75)
                .transition(.move(edge: .top))
            }
            
            // Virtual walkthrough interface
            if isVirtualWalkthroughActive {
                VStack {
                    Spacer()
                    VirtualWalkThroughBar(
                        structure: dataStore.structures[currentStructureIndex],
                        onNext: onNext,
                        onPrevious: onPrevious,
                        onTap: {
                            selectedStructure = dataStore.structures[currentStructureIndex]
                            showStructPopup = true
                        }
                    )
                    .transition(.move(edge: .bottom))
                }
            }
        }
    }
    
    private func mapPointsToStructures(_ mapPoints: [MapPoint]) -> [Structure] {
        mapPoints.compactMap { mp in
            dataStore.structures.first { $0.number == mp.landmark }
        }
    }
}

struct MapControlButton: View {
    @EnvironmentObject var appState: AppState
    let systemName: String
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 24))
            .frame(width: 50, height: 50)
            .foregroundColor(appState.isDarkMode ? .white : .black)
            .background(appState.isDarkMode ? Color.black : Color.white)
            .cornerRadius(15)
            .padding()
            .shadow(color: appState.isDarkMode ? .white.opacity(0.6) : .black.opacity(0.8),
                    radius: 5, x: 0, y: 0)
    }
}

struct StatusMessage: View {
    @EnvironmentObject var appState: AppState
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .fontWeight(.semibold)
            .padding()
            .background(appState.isDarkMode ? Color.black : Color.white)
            .foregroundColor(appState.isDarkMode ? .white : .black)
            .cornerRadius(10)
            .shadow(color: appState.isDarkMode ? .white.opacity(0.6) : .black.opacity(0.8),
                    radius: 5, x: 0, y: 0)
    }
}

struct BottomMessage: View {
    @EnvironmentObject var appState: AppState
    let text: String
    let geometry: GeometryProxy
    
    var body: some View {
        Text(text)
            .fontWeight(.semibold)
            .padding()
            .background(appState.isDarkMode ? Color.black : Color.white)
            .foregroundColor(appState.isDarkMode ? .white : .black)
            .cornerRadius(10)
            .shadow(color: appState.isDarkMode ? .white.opacity(0.6) : .black.opacity(0.8),
                    radius: 5, x: 0, y: 0)
            .position(x: geometry.size.width / 2, y: geometry.size.height - 50)
    }
}

// MARK: - Example of an Overlay Using Shared Alerts
struct MapAlertsOverlay: View {
    @Binding var showAdventureModeAlert: Bool
    @Binding var showRateStructuresPopup: Bool
    @Binding var showVirtualWalkthroughPopup: Bool
    
    @Binding var hasShownAdventureModeAlert: Bool
    @Binding var hasShownVirtualWalkthroughPopup: Bool
    
    @Binding var isVirtualWalkthroughActive: Bool
    @Binding var showStructureSwipingView: Bool
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var locationService: LocationService
    
    var body: some View {
        Group {
            if showAdventureModeAlert {
                // Reusing global CustomAlert from SharedAlerts
                CustomAlert(
                    icon: "figure.walk",
                    iconColor: .green,
                    title: "Enable Background Location",
                    subtitle: "Tracks the structures you visit even when the app is closed.",
                    primaryButton: .init(title: "Allow") {
                        locationService.requestAlwaysAuthorization()
                        appState.adventureModeEnabled = true
                        UserDefaults.standard.set(true, forKey: "adventureModeEnabled")
                        showAdventureModeAlert = false
                        hasShownAdventureModeAlert = true
                    },
                    secondaryButton: .init(title: "Cancel") {
                        showAdventureModeAlert = false
                        hasShownAdventureModeAlert = true
                    },
                    isPresented: $showAdventureModeAlert
                )
            }
            
            if showRateStructuresPopup {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                
                CustomAlert(
                    icon: "heart.fill",
                    iconColor: .red,
                    title: "Rate Structures",
                    subtitle: "Swipe through and rate the structures to customize your experience!",
                    primaryButton: .init(title: "Start Rating") {
                        showStructureSwipingView = true
                        showRateStructuresPopup = false
                        appState.hasShownRateStructuresPopup = true
                    },
                    secondaryButton: .init(title: "Maybe Later") {
                        showRateStructuresPopup = false
                        appState.hasShownRateStructuresPopup = true
                    },
                    isPresented: $showRateStructuresPopup
                )
            }
            
            if showVirtualWalkthroughPopup {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                
                CustomAlert(
                    icon: "figure.walk",
                    iconColor: .blue,
                    title: "Virtual Walkthrough",
                    subtitle: "Go through each structure as if you were there in person.",
                    primaryButton: .init(title: "Start Walkthrough") {
                        showVirtualWalkthroughPopup = false
                        isVirtualWalkthroughActive = true
                        hasShownVirtualWalkthroughPopup = true
                    },
                    secondaryButton: .init(title: "Maybe Later") {
                        showVirtualWalkthroughPopup = false
                        hasShownVirtualWalkthroughPopup = true
                    },
                    isPresented: $showVirtualWalkthroughPopup
                )
            }
        }
    }
}
