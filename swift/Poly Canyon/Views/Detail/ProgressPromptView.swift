import SwiftUI
import Glur
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
