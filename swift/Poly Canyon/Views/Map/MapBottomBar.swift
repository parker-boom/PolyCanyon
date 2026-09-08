import SwiftUI
import Zoomable
struct MapBottomBar: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationService: LocationService
    @EnvironmentObject var dataStore: DataStore
    @Binding var currentStructureIndex: Int

    // Base width is iPhone 13/14 width (390)
    private let baseWidth: CGFloat = 390

    private var scaleFactor: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return min(max(screenWidth / baseWidth, 1.0), 1.3)
    }

    private var contentPadding: CGFloat {
        24 * scaleFactor
    }

    private var emojiSize: CGFloat {
        44 * scaleFactor
    }

    private var titleSize: CGFloat {
        20 * scaleFactor
    }

    private var subtitleSize: CGFloat {
        15 * scaleFactor
    }

    private var circleSize: CGFloat {
        45 * scaleFactor
    }

    private var verticalPadding: CGFloat {
        16 * scaleFactor
    }

    private var nearbyTitleSize: CGFloat {
        24 * scaleFactor
    }

    private var nearbySubtitleSize: CGFloat {
        20 * scaleFactor
    }

    private var thumbnailBaseSize: CGFloat {
        75 * scaleFactor
    }

    private var thumbnailNumberSize: CGFloat {
        14 * scaleFactor
    }

    private func thumbnailSize(for index: Int) -> CGFloat {
        let baseSize = thumbnailBaseSize
        if index == 0 {
            return baseSize
        } else if index == 2 {
            return baseSize * (55/75)
        } else {
            return baseSize * (65/75)
        }
    }

    private func moveToNextStructure() {
        guard !dataStore.structures.isEmpty else { return }
        withAnimation {
            currentStructureIndex = (currentStructureIndex + 1) % dataStore.structures.count
        }
    }

    private func moveToPreviousStructure() {
        guard !dataStore.structures.isEmpty else { return }
        withAnimation {
            currentStructureIndex = (currentStructureIndex - 1 + dataStore.structures.count) % dataStore.structures.count
        }
    }

    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    appState.isDarkMode ?
                    Color.black.opacity(0.7) :
                    Color(white: 0.93)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(appState.isDarkMode ? 0.15 : 0.95),
                                    Color.white.opacity(0.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(appState.isDarkMode ? 0.4 : 0.8),
                                    Color(white: 0.6).opacity(appState.isDarkMode ? 0.15 : 0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                )
                .shadow(
                    color: (appState.isDarkMode ? Color.white : Color.black).opacity(0.25),
                    radius: 10,
                    x: 0,
                    y: 4
                )
                .overlay(
                    Group {
                        if !appState.adventureModeEnabled {
                            virtualTourInactiveContent
                        } else {
                            switch locationService.adventureLocationState {
                            case .notVisiting:
                                notVisitingContent
                            case .onTheWay:
                                onTheWayContent
                            case .almostThere:
                                almostThereContent
                            case .exploring:
                                if locationService.isLocationPermissionDenied {
                                    permissionDeniedContent
                                } else {
                                    nearbyStructuresContent
                                }
                            }
                        }
                    }
                )
        }
    }

    private var virtualTourInactiveContent: some View {
        HStack(spacing: 10 * scaleFactor) {
            Text("🚶‍♂️")
                .font(.system(size: emojiSize))

            VStack(alignment: .leading, spacing: 6 * scaleFactor) {
                Text("Take a Virtual Tour")
                    .font(.system(size: titleSize, weight: .bold))
                    .foregroundColor(appState.isDarkMode ? .white : .black)

                Text("Walk through virtually")
                    .font(.system(size: subtitleSize, weight: .medium))
                    .foregroundColor(appState.isDarkMode ? .white.opacity(0.8) : .black.opacity(0.7))
            }

            Spacer()

            Circle()
                .fill(appState.isDarkMode ? Color.white.opacity(0.15) : Color.black.opacity(0.05))
                .frame(width: circleSize, height: circleSize)
                .overlay(
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18 * scaleFactor, weight: .black))
                        .foregroundColor(appState.isDarkMode ? .white : .black)
                )
        }
        .padding(.horizontal, contentPadding)
        .padding(.vertical, verticalPadding)
        .contentShape(Rectangle())
        .onTapGesture {
            appState.isVirtualWalkthrough.toggle()
        }
    }

    private var permissionDeniedContent: some View {
        HStack(spacing: 10 * scaleFactor) {
            Text("😕")
                .font(.system(size: emojiSize))

            Text("Location access needed for live map")
                .font(.system(size: titleSize, weight: .bold))
                .foregroundColor(appState.isDarkMode ? .white : .black)

            Spacer()

            Circle()
                .fill(appState.isDarkMode ? Color.white.opacity(0.15) : Color.black.opacity(0.05))
                .frame(width: circleSize, height: circleSize)
                .overlay(
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18 * scaleFactor, weight: .black))
                        .foregroundColor(appState.isDarkMode ? .white : .black)
                )
        }
        .padding(.horizontal, contentPadding)
        .padding(.vertical, verticalPadding)
        .contentShape(Rectangle())
        .onTapGesture {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
    }

    private var notVisitingContent: some View {
        HStack(spacing: 14 * scaleFactor) {
            Text("🗺️")
                .font(.system(size: emojiSize))

            Text("Explore virtually before you visit?")
                .font(.system(size: titleSize, weight: .bold))
                .foregroundColor(appState.isDarkMode ? .white : .black)

            Spacer()

            Circle()
                .fill(appState.isDarkMode ? Color.white.opacity(0.15) : Color.black.opacity(0.05))
                .frame(width: circleSize, height: circleSize)
                .overlay(
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18 * scaleFactor, weight: .black))
                        .foregroundColor(appState.isDarkMode ? .white : .black)
                )
        }
        .padding(.horizontal, contentPadding)
        .padding(.vertical, verticalPadding)
        .contentShape(Rectangle())
        .onTapGesture {
            appState.isVirtualWalkthrough.toggle()
        }
    }

    private var onTheWayContent: some View {
        HStack(spacing: 14 * scaleFactor) {
            Text("🚶‍♂️")
                .font(.system(size: emojiSize))

            Text("On your way? We're getting everything ready!")
                .font(.system(size: titleSize, weight: .bold))
                .foregroundColor(appState.isDarkMode ? .white : .black)

            Spacer()
        }
        .padding(.horizontal, contentPadding)
        .padding(.vertical, verticalPadding)
    }

    private var almostThereContent: some View {
        HStack(spacing: 14 * scaleFactor) {
            Text("🎯")
                .font(.system(size: emojiSize))

            Text("Almost there! Your live location will appear soon")
                .font(.system(size: titleSize, weight: .bold))
                .foregroundColor(appState.isDarkMode ? .white : .black)

            Spacer()
        }
        .padding(.horizontal, contentPadding)
        .padding(.vertical, verticalPadding)
    }

    private var nearbyStructuresContent: some View {
        HStack(spacing: 12 * scaleFactor) {
            (Text("Nearby")
                .font(.system(size: nearbyTitleSize, weight: .bold))
                + Text("\nStructures")
                .font(.system(size: nearbySubtitleSize, weight: .medium)))
                .foregroundColor(appState.isDarkMode ? .white : .black)
                .multilineTextAlignment(.leading)
                .frame(width: 100 * scaleFactor, alignment: .leading)

            HStack(spacing: 10 * scaleFactor) {
                ForEach(locationService.nearbyStructures) { nearby in
                    if let structure = dataStore.structures.first(where: { $0.number == nearby.structureNumber }) {
                        Button {
                            appState.activeFullScreenView = .structInfo
                            appState.structInfoNum = structure.number
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(structure.images[0])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(
                                        width: thumbnailSize(for: locationService.nearbyStructures.firstIndex(of: nearby) ?? 0),
                                        height: thumbnailSize(for: locationService.nearbyStructures.firstIndex(of: nearby) ?? 0)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                    .overlay(
                                        Text("#\(structure.number)")
                                            .font(.system(size: thumbnailNumberSize, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(6 * scaleFactor)
                                            .shadow(color: .black, radius: 2)
                                            .shadow(color: .white.opacity(0.3), radius: 1),
                                        alignment: .bottomTrailing
                                    )

                                if structure.isVisited {
                                    if structure.isOpened {
                                        Image("Check")
                                            .resizable()
                                            .frame(width: 10 * scaleFactor, height: 10 * scaleFactor)
                                            .padding(6 * scaleFactor)
                                    } else {
                                        Circle()
                                            .fill(Color.blue.opacity(0.7))
                                            .frame(width: 8 * scaleFactor, height: 8 * scaleFactor)
                                            .shadow(color: .white.opacity(1), radius: 1)
                                            .padding(6 * scaleFactor)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, contentPadding)
        .padding(.vertical, verticalPadding)
    }
}
