import CoreGraphics

@main struct MapCameraChecks {
    static func main() {
        for viewport in [CGSize(width: 375, height: 480), CGSize(width: 440, height: 810), CGSize(width: 900, height: 400)] {
            let layout = CanyonMapGeometry(size: viewport)
            for point in [CGPoint.zero, CGPoint(x: 1000, y: 2200), CGPoint(x: 1900, y: 4400)] {
                let center = layout.position(point)
                let rect = CanyonMapGeometry.zoomRect(center: center, viewport: viewport)
                precondition(abs(rect.midX - center.x) < 0.00001 && abs(rect.midY - center.y) < 0.00001)
                precondition(abs(viewport.width / rect.width - viewport.height / rect.height) < 0.00001)
                precondition(abs(viewport.width / rect.width - 2.4) < 0.00001)
            }
        }
        let layout = CanyonMapGeometry(size: CGSize(width: 400, height: 903.8))
        precondition(abs(layout.position(CGPoint(x: 1000, y: 2000)).x - 218) < 0.00001)
        precondition(abs(layout.position(CGPoint(x: 1000, y: 2000)).y - 436) < 0.00001)
        print("PASS: map fit/calibration and camera centering preserve aspect and center across compact, tall and landscape viewports")
    }
}
