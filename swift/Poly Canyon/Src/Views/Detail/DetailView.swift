/*
 DetailView serves as the main container for browsing and filtering structures. It manages the search, sort,
 and view mode states while coordinating between the header controls and scrollable content. The view handles
 structure selection and popup presentation, adapting its display based on the current app mode. It provides 
 a unified interface for both virtual tour and adventure mode experiences.
*/

import SwiftUI
import CoreLocation

struct DetailView: View {
    // MARK: - Environment Objects
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var locationService: LocationService
    
    // MARK: - View State
    @State private var searchText = ""
    @State private var sortState: SortState = .all
    @State private var isGridView = true
    
    // MARK: - Popup State
    @State private var selectedStructure: Structure? = nil
    @State private var showStructPopup = false
    
    var body: some View {
        ZStack {
            // Set background color based on theme
            (appState.isDarkMode ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Search, sort and view mode controls
                DetailHeaderView(
                    searchText: $searchText,
                    sortState: $sortState,
                    isGridView: $isGridView
                )
                
                // Main scrollable content
                DetailBody(
                    searchText: searchText,
                    sortState: sortState,
                    isGridView: isGridView,
                    onStructureSelected: { structure in
                        showStructurePopup(structure)
                    }
                )
            }
            .background(appState.isDarkMode ? Color.black : Color.white)
            
            // Popup overlay when structure is selected
            if showStructPopup, let s = selectedStructure {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showStructPopup = false
                    }
                
                StructPopUp(
                    structureData: dataStore,
                    structure: s,
                    isPresented: $showStructPopup
                )
                .padding(15)
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }
    
    // Show structure details popup and mark as opened if visited
    private func showStructurePopup(_ structure: Structure) {
        selectedStructure = structure
        dataStore.markStructureAsOpened(structure.number)
        showStructPopup = true
        
        // Haptic feedback for selection
        let impactMed = UIImpactFeedbackGenerator(style: .rigid)
        impactMed.impactOccurred()
        
        // Dismiss keyboard if active
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                      to: nil, from: nil, for: nil)
    }
}