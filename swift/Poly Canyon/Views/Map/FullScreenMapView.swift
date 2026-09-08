import SwiftUI
import Zoomable
struct FullScreenMapView: View {
    @EnvironmentObject var appState: AppState
    let mapImage: String
    let geometry: GeometryProxy
    let onClose: () -> Void

    @ObservedObject var circlePositionStore: CirclePositionStore
    @State private var showTools: Bool = false

    var body: some View {
        ZStack {
            // Base map layer
            MapWithLocationDot(
                mapImage: mapImage,
                geometry: geometry,
                currentWalkthroughMapPoint: nil,
                circlePositionStore: circlePositionStore
            )
            .zoomable(minZoomScale: 1.0, doubleTapZoomScale: 2.0)

            // Bottom controls overlay
            VStack {
                Spacer()

                HStack {
                    // Tools button with expanding overlay
                    Button(action: { withAnimation(.spring()) { showTools.toggle() }}) {
                        Image(systemName: showTools ? "xmark" : "gearshape.fill")
                            .font(.system(size: showTools ? 16 : 22, weight: showTools ? .bold : .semibold))
                            .frame(width: showTools ? 32 : 44, height: showTools ? 32 : 44)
                            .glassButton(isActive: showTools)
                    }
                    .overlay(alignment: .top) {
                        if showTools {
                            VStack(spacing: 12) {
                                Button(action: { appState.mapIsSatellite.toggle() }) {
                                    Image(systemName: appState.mapIsSatellite ? "map.fill" : "globe.americas.fill")
                                        .font(.system(size: 22))
                                        .frame(width: 44, height: 44)
                                        .glassButton()
                                }

                                Button(action: { appState.mapShowNumbers.toggle() }) {
                                    Group {
                                        if !appState.mapShowNumbers {
                                            Image(systemName: "number")
                                        } else {
                                            Text("13")
                                                .overlay(
                                                    Line()
                                                    .rotation(.degrees(90))
                                                    .stroke(appState.isDarkMode ? .white : .black, lineWidth: 3)
                                                    .frame(width: 18, height: 18))
                                        }
                                    }
                                    .font(.system(size: 22))
                                    .frame(width: 44, height: 44)
                                    .glassButton()
                                }
                            }
                            .offset(y: -120)
                        }
                    }

                    Spacer()

                    // Minimize button
                    Button(action: onClose) {
                        Image(systemName: "arrow.down.right.and.arrow.up.left")
                            .font(.system(size: 22, weight: .bold))
                            .frame(width: 44, height: 44)
                            .glassButton()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}
