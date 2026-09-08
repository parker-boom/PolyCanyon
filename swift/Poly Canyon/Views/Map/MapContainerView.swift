import SwiftUI
import Zoomable
struct MapContainerView<Content: View>: View {
    @EnvironmentObject var appState: AppState
    @Binding var isFullScreen: Bool
    let content: Content

    @ObservedObject var circlePositionStore: CirclePositionStore

    init(isSatelliteView: Binding<Bool>,
         hideNumbers: Binding<Bool>,
         isFullScreen: Binding<Bool>,
         circlePositionStore: CirclePositionStore,
         @ViewBuilder content: () -> Content) {

        self._isFullScreen = isFullScreen
        self.circlePositionStore = circlePositionStore
        self.content = content()
    }

    private func calculateAnchorPoint(in geometry: GeometryProxy) -> UnitPoint {
        if circlePositionStore.isDotVisible,
           let circleX = circlePositionStore.circleX,
           let circleY = circlePositionStore.circleY {

            let mapSize = calculateRenderedMapSize(in: geometry)
            let xOffset = (geometry.size.width - mapSize.width) / 2
            let yOffset = (geometry.size.height - mapSize.height) / 2

            // Convert to relative coordinates within the actual map content
            let relativeX = (circleX - xOffset) / mapSize.width
            let relativeY = (circleY - yOffset) / mapSize.height

            // Clamp Y to prevent white space when zooming
            let safeY = min(max(relativeY, 0.0), 1.0)

            return UnitPoint(x: relativeX, y: safeY)
        } else {
            // When no dot, anchor at bottom
            return UnitPoint(x: 0.5, y: 1.0)
        }
    }

    private func calculateZoomOffset(for scale: CGFloat, in geometry: GeometryProxy, anchorPoint: UnitPoint) -> CGSize {
        guard scale > 1.0 else { return .zero }

        let mapSize = calculateRenderedMapSize(in: geometry)
        let scaledWidth = mapSize.width * scale

        // Calculate how much we can move without showing white space
        let maxXOffset = (scaledWidth - mapSize.width) / 2

        // Calculate desired offset based on anchor point
        let desiredXOffset = (scaledWidth - mapSize.width) * (0.5 - anchorPoint.x)

        // Clamp the offset to prevent white space
        let clampedXOffset = max(-maxXOffset, min(maxXOffset, desiredXOffset))

        return CGSize(width: clampedXOffset, height: 0)  // Still letting baseOffset handle Y
    }

    private func calculateRenderedMapSize(in geometry: GeometryProxy) -> CGSize {
        let originalWidth: CGFloat = 2000
        let originalHeight: CGFloat = 4519
        let aspectRatio = originalWidth / originalHeight

        let availableWidth = geometry.size.width
        let availableHeight = geometry.size.height

        if availableWidth / availableHeight > aspectRatio {
            // Width is proportionally larger than height, so we're height-constrained
            let height = availableHeight
            let width = height * aspectRatio
            return CGSize(width: width, height: height)
        } else {
            // Height is proportionally larger than width, so we're width-constrained
            let width = availableWidth
            let height = width / aspectRatio
            return CGSize(width: width, height: height)
        }
    }

    var body: some View {
        GeometryReader { containerGeometry in
            VStack(spacing: 0) {
                // Calculate dynamic offset:
                let mapHeight = containerGeometry.size.height - 44  // space for your toolbar
                let midY = mapHeight / 2
                let maxOffset = containerGeometry.size.height * 0.12  // ±10% is max shift
                let defaultOffset = containerGeometry.size.height * -0.15  // always want 10% down if no dot

                let baseOffset: CGFloat = {
                    guard circlePositionStore.isDotVisible,
                          let circleY = circlePositionStore.circleY else {
                        return defaultOffset
                    }

                    let delta = circleY - midY
                    let normalized = delta / midY

                    // Make middle section adjustment more subtle
                    let adjustedNormalized = if abs(normalized) < 0.5 {
                        // Reduce by 25% instead of 50%
                        normalized * 0.75
                    } else {
                        normalized
                    }

                    let clamped = max(-1, min(1, adjustedNormalized))
                    return -clamped * maxOffset
                }()


                let anchorPoint = calculateAnchorPoint(in: containerGeometry)
                let zoomOffset = calculateZoomOffset(for: appState.mapScale, in: containerGeometry, anchorPoint: anchorPoint)
                let xAdjusted = zoomOffset.width * 0.65

                // Our actual scrollable content
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    content
                        .frame(width: containerGeometry.size.width,
                               height: mapHeight)
                        .offset(y: baseOffset)
                        .scaleEffect(
                            appState.mapScale,
                            anchor: anchorPoint
                        )
                        .offset(x: xAdjusted, y: zoomOffset.height)
                        .animation(.easeInOut(duration: 0.4), value: baseOffset)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: appState.mapScale)
                }
                .clipped()

                // The bottom toolbar (unchanged)
                MapToolbar(
                    isFullScreen: $isFullScreen
                )
            }
            .background(appState.isDarkMode ? Color.black : .white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
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
            .shadow(
                color: (appState.isDarkMode ? Color.white : Color.black).opacity(0.15),
                radius: 2,
                x: 0,
                y: 1
            )
        }
        // The container still only takes 70% of screen height
        .frame(height: UIScreen.main.bounds.height * 0.7)
    }
}


// New ScaleSlider component
