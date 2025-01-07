/*
 DetailBody implements the main scrollable content for structure browsing. It provides both grid and list 
 viewing modes with dynamic filtering and sorting. The view adapts its display based on adventure mode, 
 showing highlight sections for recently visited or nearby structures. It also handles structure blurring 
 for unvisited locations when in adventure mode within the safe zone.
*/

import SwiftUI
import CoreLocation
import Combine

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
            // Show highlight sections based on current mode and sort state
            if shouldShowRecentlyVisited {
                HighlightStructuresRow(
                    title: "Recently Visited",
                    structures: dataStore.getRecentlyVisitedStructures()
                ) { structure in
                    onStructureSelected(structure)
                }
                .padding(.top, 10)
            }
            
            else if shouldShowNearbyUnvisited {
                HighlightStructuresRow(
                    title: "Nearby Unvisited",
                    structures: dataStore.getNearbyUnvisitedStructures()
                ) { structure in
                    onStructureSelected(structure)
                }
                .padding(.top, 10)
            }
            
            // Display structures in selected view mode
            if isGridView {
                gridView
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
                spacing: 15
            ) {
                ForEach(structures, id: \.id) { structure in
                    StructureGridItem(structure: structure)
                        .onTapGesture {
                            onStructureSelected(structure)
                        }
                }
                .shadow(color: appState.isDarkMode ? .white.opacity(0.2) : .black.opacity(0.4),
                        radius: 5, x: 0, y: 3)
            }
            .padding(.horizontal, 20)
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
            sortState: sortState
        )
    }
    
    // MARK: - Display Logic
    
    // Show recently visited section in adventure mode on visited tab
    private var shouldShowRecentlyVisited: Bool {
        return sortState == .visited 
            && dataStore.hasVisitedStructures 
            && appState.adventureModeEnabled
    }
    
    // Show nearby unvisited section in adventure mode within safe zone
    private var shouldShowNearbyUnvisited: Bool {
        return sortState == .unvisited
            && dataStore.hasUnvisitedStructures
            && appState.adventureModeEnabled
            && locationService.canUseLocation
    }
}

/**
 * StructureGridItem
 *
 * Individual grid cell with blur logic. If adventure mode + safe zone + unvisited => blur image.
 * If visited & not opened => small blue dot. If visited & opened => checkmark. 
 * If virtual tour => no blur, etc.
 */
struct StructureGridItem: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    
    let structure: Structure
    private let imageLoader = ImageLoader()
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Decide if blur is needed
            if shouldBlur {
                blurredImage
            } else {
                normalImage
            }
            
            // Overlays for visited state
            if structure.isVisited {
                if structure.isOpened {
                    Image("Check")
                        .resizable()
                        .frame(width: 13, height: 13)
                        .padding(12)
                } else {
                    // Blue circle if visited but not opened
                    Circle()
                        .fill(Color.blue.opacity(0.7))
                        .frame(width: 10, height: 10)
                        .shadow(color: .white.opacity(1), radius: 1, x: 0, y: 0)
                        .padding(12)
                }
            }
        }
        // Additional overlay for number + title, if you want
        .overlay(
            VStack(alignment: .leading, spacing: 4) {
                Text("\(structure.number)")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                Text(structure.title)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .padding([.horizontal, .bottom], 10),
            alignment: .bottomLeading
        )
        .onAppear {
            imageLoader.load(imageName: structure.images[0])
        }
        .onDisappear {
            imageLoader.cancel()
        }
    }
    
    // MARK: - Image Builders
    
    private var normalImage: some View {
        Image(structure.images[0])
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: itemWidth, height: itemHeight)
            .cornerRadius(15)
            .clipped()
            .overlay(
                Group {
                    if imageLoader.isLoading {
                        ProgressView()
                    }
                }
            )
    }
    
    private var blurredImage: some View {
        Image(structure.images[0])
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: itemWidth, height: itemHeight)
            .glur(radius: 6.0, offset: 0.6, interpolation: 0.4, direction: .down)
            .cornerRadius(15)
            .clipped()
            .overlay(
                Group {
                    if imageLoader.isLoading {
                        ProgressView()
                    }
                }
            )
    }
    
    // MARK: - Logic
    
    private var shouldBlur: Bool {
        guard appState.adventureModeEnabled else {
            // Virtual Tour => never blur
            return false
        }
        // If user is not in the safe zone, don't blur
        guard let loc = locationService.lastLocation,
              locationService.isWithinSafeZone(coordinate: loc.coordinate) else {
            return false
        }
        // If structure is not visited => blur
        return !structure.isVisited
    }
    
    private var itemWidth: CGFloat {
        (UIScreen.main.bounds.width - 45) / 2
    }
    private var itemHeight: CGFloat {
        (UIScreen.main.bounds.width - 60) / 2
    }
}

/**
 * StructureListItem
 *
 * Individual list item with visit indicators and like buttons.
 */
struct StructureListItem: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataStore: DataStore
    
    let structure: Structure
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Text("\(structure.number)")
                .foregroundColor(appState.isDarkMode ? .white : .black)
                .font(.system(size: 18, weight: .thin))
            
            Text(structure.title)
                .foregroundColor(appState.isDarkMode ? .white : .black)
                .font(.system(size: 23, weight: .semibold))
                .padding(.leading, 10)
            
            Spacer()
            
            // Adventure mode => show visit indicators
            if appState.adventureModeEnabled {
                if structure.isVisited && !structure.isOpened {
                    Circle()
                        .fill(Color.blue.opacity(0.7))
                        .frame(width: 8, height: 8)
                        .padding(.trailing, 5)
                }
                
                Image(systemName: "figure.walk")
                    .foregroundColor(structure.isVisited ? .green : .red)
                    .font(.title2)
                    .padding(.trailing, 10)

            // Virtual tour => show like button
            } else {
                Button(action: {
                    dataStore.toggleLike(for: structure.id)
                }) {
                    Image(systemName: structure.isLiked ? "heart.fill" : "heart")
                        .foregroundColor(structure.isLiked ? .red :
                                         (appState.isDarkMode ? .white : .black))
                        .font(.system(size: 22))
                }
                .padding(.trailing, 10)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(appState.isDarkMode ? Color.black : Color.white)
        .onTapGesture(perform: onTap)
    }
}

// MARK: - ImageLoader
// No idea if this actually helps or is fluff
class ImageLoader: ObservableObject {
    @Published var image: Image?
    @Published var isLoading = false
    
    private var cancellable: AnyCancellable?
    
    func load(imageName: String) {
        guard image == nil else { return }
        isLoading = true
        
        cancellable = Future<UIImage, Error> { promise in
            if let uiImage = UIImage(named: imageName) {
                promise(.success(uiImage))
            } else {
                promise(.failure(NSError(domain: "ImageLoading",
                                         code: 0,
                                         userInfo: [NSLocalizedDescriptionKey: "Image not found"])))
            }
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            self?.isLoading = false
            if case let .failure(error) = completion {
                print("Error loading image: \(error)")
            }
        } receiveValue: { [weak self] uiImage in
            self?.image = Image(uiImage: uiImage)
        }
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}

