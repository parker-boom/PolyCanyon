import SwiftUI

struct ProgressBar: View {
    @EnvironmentObject var dataStore: DataStore
    let width: CGFloat
    
    private let barHeight: CGFloat = 8
    private let phase = Animation.linear(duration: 2).repeatForever(autoreverses: false)
    
    @State private var animationOffset: CGFloat = 0
    
    private var progress: CGFloat {
        CGFloat(dataStore.visitedCount) / 31.0
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(dataStore.visitedCount)")
                .font(.system(size: 14, weight: .bold))
            
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: barHeight / 2)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: width - 80, height: barHeight)
                
                // Animated progress
                RoundedRectangle(cornerRadius: barHeight / 2)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "FF8C00"),  // Dark Orange
                                Color(hex: "FFA500"),  // Orange
                                Color(hex: "FFD700"),  // Gold
                                Color(hex: "FFA500"),  // Orange
                                Color(hex: "FF8C00"),  // Dark Orange
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: (width - 80) * progress, height: barHeight)
                    .overlay(
                        GeometryReader { geometry in
                            // Animated shine effect
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0),
                                            .white.opacity(0.5),
                                            .white.opacity(0)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 20)
                                .offset(x: -20 + (animationOffset * (geometry.size.width + 40)))
                                .opacity(progress > 0 ? 1 : 0)
                        }
                    )
                    .mask(
                        RoundedRectangle(cornerRadius: barHeight / 2)
                            .frame(width: (width - 80) * progress, height: barHeight)
                    )
            }
            
            Text("31")
                .font(.system(size: 14, weight: .bold))
        }
        .frame(width: width)
        .onAppear {
            withAnimation(phase) {
                animationOffset = 1
            }
        }
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            // Preview with different widths
            ProgressBar(width: 300)
            ProgressBar(width: 200)
            ProgressBar(width: 150)
        }
        .padding()
        .environmentObject(DataStore.shared)
    }
}
