import SwiftUI
import UIKit

/// A fading system blur keeps the moving atlas visible beneath the status bar.
struct CanyonTopBlur: UIViewRepresentable {
    func makeUIView(context: Context) -> FadingBlurView { FadingBlurView() }
    func updateUIView(_ view: FadingBlurView, context: Context) { }
}

final class FadingBlurView: UIVisualEffectView {
    private let fade = CAGradientLayer()
    init() {
        super.init(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        isUserInteractionEnabled = false
        fade.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        fade.locations = [0, 0.3, 1]
        layer.mask = fade
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func layoutSubviews() {
        super.layoutSubviews()
        fade.frame = bounds
    }
}
