/*
 DetailView serves as the main container for browsing and filtering structures. It manages the search, sort,
 and view mode states while coordinating between the header controls and scrollable content. The view handles
 structure selection and popup presentation, adapting its display based on the current app mode. It provides 
 a unified interface for both virtual tour and adventure mode experiences.
*/

import SwiftUI
import CoreLocation

struct DetailView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var sortState: SortState = .all
    @State private var isGridView = true

    var body: some View {
        ZStack(alignment: .top) {
            // Background color to fill any gaps
            Color(appState.isDarkMode ? .black : .white)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 10)

                // Main content
                ScrollView {
                    
                        DetailBody(
                            searchText: searchText,
                            sortState: sortState,
                            isGridView: isGridView,
                            onStructureSelected: { structure in
                                appState.activeFullScreenView = .structInfo
                                appState.structInfoNum = structure.id
                            }
                        )
                        .padding(.top, 110)
                    
                    
                }
            }
            
            
            // Header
            DetailHeaderView(
                searchText: $searchText,
                sortState: $sortState,
                isGridView: $isGridView
            )
            .frame(maxWidth: .infinity)
            .zIndex(1)
        }
    }
}



// MARK: - Preview
struct Detailiew_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Light Mode Preview
            DetailView()
                .environmentObject({
                    let state = AppState()
                    state.isDarkMode = false
                    return state
                }())
                .environmentObject(DataStore.shared)
                .environmentObject(LocationService.shared)
                .previewDisplayName("Light Mode")
                
            // Dark Mode Preview
            DetailView()
                .environmentObject({
                    let state = AppState()
                    state.isDarkMode = true
                    return state
                }())
                .environmentObject(DataStore.shared)
                .environmentObject(LocationService.shared)
                .previewDisplayName("Dark Mode")
        }
    }
}
