// Rendering adapted from Shiny (Michael Verges, MIT). See Core/Licenses/Shiny.txt.
import CoreMotion
import SwiftUI

/// The welcome screen owns its motion updates; leaving it or backgrounding cancels them.
struct WelcomeLogo: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var motion = CMMotionManager()
    @State private var position = CGSize.zero

    private var shouldAnimate: Bool { scenePhase == .active && !reduceMotion }
    private let colors: [Color] = [.red, .red, .red] + Array(repeating: [Color.red, .orange, .yellow, .green, .blue, .purple, .pink], count: 3).flatMap { $0 }

    private var logo: some View {
        Image("Icon")
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 200)
            .cornerRadius(40)
    }

    var body: some View {
        logo.foregroundColor(.clear)
            .background {
                GeometryReader { geometry in
                    let radius = max(1, min(geometry.size.width, geometry.size.height) / 2)
                    let height = geometry.frame(in: .global).maxY + geometry.safeAreaInsets.bottom
                    ZStack {
                        Color.pink
                        RadialGradient(gradient: Gradient(colors: colors), center: .center,
                                       startRadius: 1, endRadius: radius)
                            .scaleEffect(max(1, height / radius * 2))
                            .offset(position)
                            .animation(reduceMotion ? nil : .default, value: position)
                    }
                    .mask(logo)
                }
            }
            .accessibilityLabel("Poly Canyon")
            .task(id: shouldAnimate) {
                guard shouldAnimate, motion.isDeviceMotionAvailable else { return }
                motion.deviceMotionUpdateInterval = 0.2
                motion.startDeviceMotionUpdates()
                defer { motion.stopDeviceMotionUpdates() }
                while !Task.isCancelled {
                    if let attitude = motion.deviceMotion?.attitude {
                        position = CGSize(width: -attitude.roll / .pi * 800,
                                          height: -attitude.pitch / .pi * 800)
                    }
                    do { try await Task.sleep(nanoseconds: 200_000_000) }
                    catch { break }
                }
            }
    }
}
