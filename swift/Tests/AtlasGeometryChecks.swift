import CoreGraphics

@main
struct AtlasGeometryChecks {
    static func main() {
        let widths: [CGFloat] = [320, 375, 440, 768, 1024]
        let heights: [CGFloat] = [160, 230, 400, 700, 1200]
        // Cover both ends and the middle of the calibrated drawing, not only the default stop.
        let focuses = [CGPoint(x: 200, y: 0), CGPoint(x: 1000, y: 2200), CGPoint(x: 1750, y: 4100)]
        var checks = 0
        for width in widths {
            for height in heights {
                let viewport = CGSize(width: width, height: height)
                let canvas = CanyonAtlasGeometry.scrollCanvas(width: width)
                for focus in focuses {
                    let focused = CanyonAtlasGeometry(size: viewport, focus: focus, overview: false)
                    let target = focused.position(for: focus)
                    precondition(abs(target.x - width / 2) < 0.001, "Focused marker lost horizontal center")
                    precondition(abs(target.y - height * 0.4) < 0.001, "Focused marker lost vertical anchor")

                    let map = CanyonAtlasGeometry(size: canvas, focus: focus, overview: true)
                    let offset = CanyonAtlasGeometry.scrollOffset(focus: focus, viewport: viewport)
                    let visibleY = map.position(for: focus).y - offset
                    precondition(offset.isFinite && offset >= -CanyonAtlasGeometry.endInset, "Invalid scroll offset")
                    precondition(visibleY >= 0 && visibleY <= height, "Selected marker left the viewport after resize")
                    // If neither end limits scrolling, selection must actually be centered.
                    if offset > -CanyonAtlasGeometry.endInset + 0.001 &&
                        offset < canvas.height - height + CanyonAtlasGeometry.endInset - 0.001 {
                        precondition(abs(visibleY - height / 2) < 0.001, "Interior selection failed to recenter")
                    }
                    checks += 1
                }
            }
        }
        // Regression: a viewport taller than the canvas must not generate an inverted range.
        let tall = CGSize(width: 320, height: 1200)
        precondition(CanyonAtlasGeometry.scrollOffset(focus: .zero, viewport: tall) == -24)
        print("PASS: \(checks) atlas selection/resize cases; focused anchors, visible end stops, and tall-viewport bounds")
    }
}
