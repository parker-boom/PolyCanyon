import CoreGraphics

struct CanyonMapGeometry {
    let size: CGSize
    private var scale: CGFloat { min(size.width / 2000, size.height / 4519) }
    func position(_ point: CGPoint) -> CGPoint {
        CGPoint(x: point.x * scale * 1.09 + (size.width - 2000 * scale) / 2,
                y: point.y * scale * 1.09 + (size.height - 4519 * scale) / 2)
    }
    static func zoomRect(center: CGPoint, viewport: CGSize, scale: CGFloat = 2.4) -> CGRect {
        let width = viewport.width / scale
        let height = viewport.height / scale
        return CGRect(x: center.x - width / 2, y: center.y - height / 2, width: width, height: height)
    }
}
