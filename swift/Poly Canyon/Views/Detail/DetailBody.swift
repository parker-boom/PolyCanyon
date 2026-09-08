/*
 DetailBody implements the main scrollable content for structure browsing. It provides both grid and list 
 viewing modes with dynamic filtering and sorting. The view adapts its display based on adventure mode, 
 showing highlight sections for recently visited or nearby structures. It also handles structure blurring 
 for unvisited locations when in adventure mode within the safe zone.
*/

import SwiftUI

struct DetailBody: View {
    // MARK: - Properties
    let searchText: String
    let sortState: SortState
    let isGridView: Bool
    let onStructureSelected: (Structure) -> Void
    
    // MARK: - Environment Objects
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var locationService: LocationService
    
    var body: some View {
        ScrollView {
            // Display structures in selected view mode
            if isGridView {
                VStack(spacing: 0) {
                    if appState.adventureModeEnabled && locationService.isInPolyCanyonArea {
                        ProgressPromptView()
                            .padding(.horizontal, 0)
                            .padding(.top, 5)
                            .padding(.bottom, 5)
                    }
                    gridView
                }
            } else {
                listView
            }
        }
        .background(appState.isDarkMode ? Color.black : Color.white)
    }
    
    
    // Grid layout with blur effects for unvisited structures
    private var gridView: some View {
        let structures = filteredStructures()
        
        return VStack {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2),
                spacing: 10
            ) {
                ForEach(structures, id: \.id) { structure in
                    Button { onStructureSelected(structure) } label: {
                        StructureGridItem(structure: structure)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(structure.title)
                }
                .shadow(color: appState.isDarkMode ? .white.opacity(0.2) : .black.opacity(0.7),
                        radius: 5, x: 0, y: 0)
            }
            .padding(.horizontal, 25)
            .padding(.top, 10)
            .padding(.bottom, 30)
        }
    }
    
    // List layout with visit indicators and like buttons
    private var listView: some View {
        let structures = filteredStructures()
        
        return VStack(spacing: 0) {
            ForEach(structures, id: \.id) { structure in
                Divider()
                    .background(appState.isDarkMode ? Color.white.opacity(0.3) : Color.black.opacity(0.4))
                
                StructureListItem(
                    structure: structure,
                    onTap: { onStructureSelected(structure) }
                )
            }
            Divider()
        }
        .padding(.top, 5)
    }
    
    // Apply search and sort filters to structures
    private func filteredStructures() -> [Structure] {
        dataStore.getFilteredStructures(
            searchText: searchText,
            sortState: sortState,
            distance: locationService.isInPolyCanyonArea ? { locationService.getDistance(to: $0) } : nil
        )
    }
}
