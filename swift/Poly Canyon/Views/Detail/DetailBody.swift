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
            // Display structures in selected view mode
            if isGridView {
                VStack(spacing: 0) {
                    if shouldShowLikePrompt {
                        LikePromptView()
                            .padding(.horizontal, 20)
                            .padding(.top, 5)
                            .padding(.bottom, 5)
                    } else if appState.adventureModeEnabled && locationService.isInPolyCanyonArea {
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
        .onChange(of: locationService.isInPolyCanyonArea) { _ in
            dataStore.objectWillChange.send()
        }
    }
    
    private var shouldShowLikePrompt: Bool {
        !appState.adventureModeEnabled || 
        (appState.adventureModeEnabled && !locationService.isInPolyCanyonArea)
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
                    StructureGridItem(structure: structure)
                        .onTapGesture {
                            onStructureSelected(structure)
                        }
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
            sortState: sortState
        )
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
    @EnvironmentObject var dataStore: DataStore
    
    let structure: Structure
    private let imageLoader = ImageLoader()
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Special handling for Ghost Structures entry
            if structure.number == 999 {
                ghostStructureImage
            }
            // Regular structure handling
            else if shouldBlur {
                blurredImage
            } else {
                normalImage
            }
            
            // Overlays for regular structures
            if structure.number != 999 {
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
                
                // Heart overlay for liked structures in virtual tour mode
                if !appState.adventureModeEnabled && structure.isLiked {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .shadow(color: .white.opacity(0.5), radius: 2)
                        .shadow(color: .black.opacity(0.5), radius: 2)
                        .padding(12)
                }
            }
        }
        // Additional overlay for number + title, with special handling for ghost structures
        .overlay(
            VStack(alignment: .leading, spacing: 4) {
                if structure.number == 999 {
                    Text("👻")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                } else {
                    Text("\(structure.number)")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                }
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
    
    private var blurredImage: some View {
        Image(structure.images[0])
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: itemWidth, height: itemHeight)
            .blur(radius: 1.9)
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
    
    private var ghostStructureImage: some View {
        Image(structure.images[0])
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: itemWidth, height: itemHeight)
            .cornerRadius(15)
            .clipped()
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(15)
            )
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
              locationService.isWithinCanyon(coordinate: loc.coordinate) else {
            return false
        }
        // If structure is not visited => blur
        return !structure.isVisited
    }
    
    private var itemWidth: CGFloat {
        (UIScreen.main.bounds.width - 55) / 2
    }
    private var itemHeight: CGFloat {
        (UIScreen.main.bounds.width - 55) / 2
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
            // Show ghost emoji instead of number for ghost structures
            if structure.number == 999 {
                Text("👻")
                    .foregroundColor(appState.isDarkMode ? .white : .black)
                    .font(.system(size: 24))
            } else {
                Text("\(structure.number)")
                    .foregroundColor(appState.isDarkMode ? .white : .black)
                    .font(.system(size: 18, weight: .thin))
            }
            
            Text(structure.title)
                .foregroundColor(appState.isDarkMode ? .white : .black)
                .font(.system(size: 23, weight: .semibold))
                .padding(.leading, 10)
            
            Spacer()
            
            // Don't show indicators for ghost structures entry
            if structure.number != 999 {
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
            // For ghost structures in adventure mode, show discovery count
            else if appState.adventureModeEnabled {
                let visitedCount = dataStore.ghostStructures.filter { $0.isVisited }.count
                let totalCount = dataStore.ghostStructures.count
                
                Text("\(visitedCount)/\(totalCount)")
                    .foregroundColor(appState.isDarkMode ? .white : .black)
                    .font(.system(size: 16))
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

struct LikePromptView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Button(action: {
            appState.activeFullScreenView = .ratings
        }) {
            HStack(spacing: 12) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red.opacity(0.9), .pink.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Pick your favorites")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red.opacity(0.9), .pink.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(.red.opacity(0.9))
                    .shadow(color: .white.opacity(0.5), radius: 2)
                    //.shadow(color: .black.opacity(0.5), radius: 4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .red.opacity(0.15),
                                    .pink.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.6),
                                .white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
            .shadow(
                color: .red.opacity(0.15),
                radius: 8,
                x: 0,
                y: 4
            )
        }
    }
}

struct ProgressPromptView: View {
    private let horizontalPadding: CGFloat = 25 // Match grid padding
    private let internalPadding: CGFloat = 15
    
    var body: some View {
        HStack(spacing: 12) {
            ProgressBar(width: UIScreen.main.bounds.width - (horizontalPadding * 2) - (internalPadding * 2))
        }
        .padding(.vertical, 15)
        .padding(.horizontal, internalPadding)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "FF8C00").opacity(0.35),
                                Color(hex: "FFD700").opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.6),
                            .white.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
        .shadow(
            color: Color(hex: "FF8C00").opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        )
        .padding(.horizontal, horizontalPadding) 
    }
}

