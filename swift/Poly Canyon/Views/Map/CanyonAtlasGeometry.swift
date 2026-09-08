import CoreGraphics

/// One transform for the source illustration, its calibrated markers, and scroll targeting.
/// These are presentation coordinates; location/discovery calculations remain unchanged.
struct CanyonAtlasGeometry {
    static let sourceSize = CGSize(width: 2000, height: 4519)
    static let defaultFocus = CGPoint(x: 1000, y: 2200)
    static let endInset: CGFloat = 24
    private static let calibration: CGFloat = 1.09

    let scale: CGFloat
    let origin: CGPoint
    var imageSize: CGSize {
        CGSize(width: Self.sourceSize.width * scale, height: Self.sourceSize.height * scale)
    }

    init(size: CGSize, focus: CGPoint, overview: Bool) {
        if overview {
            scale = min(size.width / Self.sourceSize.width, size.height / Self.sourceSize.height) * 0.93
            origin = CGPoint(x: (size.width - Self.sourceSize.width * scale) / 2,
                             y: (size.height - Self.sourceSize.height * scale) / 2)
        } else {
            scale = size.width / Self.sourceSize.width * 1.4
            origin = CGPoint(x: size.width / 2 - focus.x * Self.calibration * scale,
                             y: size.height * 0.4 - focus.y * Self.calibration * scale)
        }
    }

    func position(for point: CGPoint) -> CGPoint {
        CGPoint(x: origin.x + point.x * Self.calibration * scale,
                y: origin.y + point.y * Self.calibration * scale)
    }

    static func scrollCanvas(width: CGFloat) -> CGSize {
        CGSize(width: width, height: width * sourceSize.height / sourceSize.width)
    }

    static func scrollOffset(focus: CGPoint, viewport: CGSize) -> CGFloat {
        let canvas = scrollCanvas(width: viewport.width)
        let layout = CanyonAtlasGeometry(size: canvas, focus: focus, overview: true)
        let lower = -endInset
        // When the viewport is taller than the entire map, the scroll range collapses.
        let upper = max(lower, canvas.height - viewport.height + endInset)
        return min(max(layout.position(for: focus).y - viewport.height / 2, lower), upper)
    }
}
