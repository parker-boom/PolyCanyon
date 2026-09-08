import SwiftUI
import Glur
struct StructureGridItem: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    @EnvironmentObject var dataStore: DataStore

    let structure: Structure

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
    }

    // MARK: - Image Builders

    private var normalImage: some View {
        Image(structure.images.first ?? "")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: itemWidth, height: itemHeight)
            .glur(radius: 6.0, offset: 0.6, interpolation: 0.4, direction: .down)
            .cornerRadius(15)
            .clipped()
    }

    private var blurredImage: some View {
        Image(structure.images.first ?? "")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: itemWidth, height: itemHeight)
            .blur(radius: 1.9)
            .cornerRadius(15)
            .clipped()
    }

    private var ghostStructureImage: some View {
        Image(structure.images.first ?? "")
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
