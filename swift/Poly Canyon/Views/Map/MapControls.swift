import SwiftUI
import Zoomable
struct ScaleSlider: View {
    @EnvironmentObject var appState: AppState

    private let snapPoints: [CGFloat] = [1.0, 1.25, 1.5, 1.75, 2.0]
    private let mainPoints: [CGFloat] = [1.0, 1.5, 2.0]
    private let lightFeedback = UIImpactFeedbackGenerator(style: .light)
    private let rigidFeedback = UIImpactFeedbackGenerator(style: .rigid)

    var body: some View {
        GeometryReader { geometry in
            // Container using mapToolbarButton style
            RoundedRectangle(cornerRadius: 20)
                .fill(appState.isDarkMode ? Color.black.opacity(0.7) : Color(white: 0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            Color.gray.opacity(0.025)
                        )
                )
                .overlay(
                    ZStack(alignment: .leading) {
                        // Timeline track - 15% darker
                        Rectangle()
                            .fill(appState.isDarkMode ?
                                Color.white.opacity(0.4) : // Increased from 0.25
                                Color.black.opacity(0.25))  // Increased from 0.15
                            .frame(height: 3)
                            .padding(.horizontal, 16)

                        // Main points (larger circles)
                        HStack(spacing: (geometry.size.width - 32) / 2) {
                            ForEach(0..<3) { i in
                                Circle()
                                    .fill(appState.isDarkMode ? Color.white.opacity(0.4) : Color.black.opacity(0.2))
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .padding(.horizontal, 16)

                        // Tick marks (smaller lines)
                        HStack(spacing: (geometry.size.width - 32) / 4) {
                            ForEach(0..<5) { i in
                                if i % 2 == 1 {
                                    Rectangle()
                                        .fill(appState.isDarkMode ? Color.white.opacity(0.3) : Color.black.opacity(0.15))
                                        .frame(width: 2, height: 4)
                                } else {
                                    Color.clear
                                        .frame(width: 2, height: 4)
                                }
                            }
                        }
                        .padding(.horizontal, 16)

                        // Draggable circle - matching toolbar button style
                        Circle()
                            .fill(appState.isDarkMode ? Color.black.opacity(0.7) : Color(white: 0.90))
                            .overlay(
                                Circle()
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
                                Circle()
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(appState.isDarkMode ? 0.5 : 0.1),
                                                Color(white: 0.6).opacity(appState.isDarkMode ? 0.2 : 0.3)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(
                                color: (appState.isDarkMode ? Color.white : Color.black).opacity(0.1),
                                radius: 8
                            )
                            .shadow(
                                color: (appState.isDarkMode ? Color.white : Color.black).opacity(0.1),
                                radius: 1
                            )
                            .frame(width: 35, height: 35)
                            .overlay(
                                Text("×\(String(format: "%.1f", appState.mapScale))")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(appState.isDarkMode ? .white : .black)
                            )
                            .offset(x: (geometry.size.width - 20) * (appState.mapScale - 1.0))
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { gesture in
                                        let oldValue = appState.mapScale
                                        let newValue = 1.0 + gesture.location.x / (geometry.size.width - 20)
                                        appState.mapScale = max(1.0, min(2.0, newValue))

                                        if snapPoints.contains(where: { point in
                                            (oldValue < point && newValue >= point) ||
                                            (oldValue > point && newValue <= point)
                                        }) {
                                            lightFeedback.impactOccurred()
                                        }
                                    }
                                    .onEnded { _ in
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            let targetValue = snapPoints.min(by: { abs($0 - appState.mapScale) < abs($1 - appState.mapScale) }) ?? 1.0
                                            appState.mapScale = targetValue
                                            rigidFeedback.impactOccurred()
                                        }
                                    }
                            )
                    }
                )
        }
        .frame(height: 15)  // Match the container height reduction
    }
}

struct MapToolbar: View {
    @EnvironmentObject var appState: AppState
    @Binding var isFullScreen: Bool

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                HStack(spacing: 0) {
                    Button(action: { appState.mapIsSatellite.toggle() }) {
                        HStack(spacing: 0) {
                            Image(systemName: "map.fill")
                                .frame(width: 44)
                                .foregroundColor(!appState.mapIsSatellite ? .black : .gray)
                                .scaleEffect(!appState.mapIsSatellite ? 1.1 : 1.0)

                            Image(systemName: "globe.americas.fill")
                                .frame(width: 44)
                                .foregroundColor(appState.mapIsSatellite ? .black : .gray)
                                .scaleEffect(appState.mapIsSatellite ? 1.1 : 1.0)
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .frame(height: 32)
                        .mapToolbarButton()
                    }
                }

                Button(action: { appState.mapShowNumbers.toggle() }) {
                    Group {
                        if !appState.mapShowNumbers {
                            Image(systemName: "number")
                        } else {
                            Text("13")
                                .font(.system(size: 18, weight: .semibold))
                                .overlay(
                                    Line()
                                        .rotation(.degrees(90))
                                        .stroke(appState.isDarkMode ? .white : .black, lineWidth: 2)
                                        .frame(width: 15, height: 15)
                                )
                        }
                    }
                    .frame(width: 32, height: 32)
                    .mapToolbarButton(isActive: !appState.mapShowNumbers)
                }
            }

            Spacer()

            // Scale slider (no longer needs bindings)
            ScaleSlider()
                .frame(width: 120, height: 15)
                .padding(.trailing, 4)

            Button(action: { isFullScreen.toggle() }) {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 32, height: 32)
                    .mapToolbarButton()
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 16)
        .toolbarBackground()
    }
}


// Add this struct for the diagonal line
struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return path
    }
}

struct BottomRoundedRectangle: Shape, InsettableShape {
    let cornerRadius: CGFloat
    var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        var path = Path()

        // Top left corner - sharp
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))

        // Top edge
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))

        // Right edge and bottom right corner - rounded
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 0),
            endAngle: Angle(degrees: 90),
            clockwise: false
        )

        // Bottom edge
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))

        // Bottom left corner - rounded
        path.addArc(
            center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 90),
            endAngle: Angle(degrees: 180),
            clockwise: false
        )

        // Left edge
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))

        return path
    }

    func inset(by amount: CGFloat) -> Self {
        var shape = self
        shape.insetAmount = amount
        return shape
    }
}
