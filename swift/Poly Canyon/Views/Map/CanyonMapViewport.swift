import SwiftUI
import UIKit

/// One camera owns pinch, pan, double-tap, fit and location centering. Applying a
/// separate SwiftUI scale before Zoomable left its drag recognizer at identity.
struct CanyonMapViewport<Canvas: View>: UIViewControllerRepresentable {
    let request: UUID
    let focus: CGPoint?
    var canvasSize: CGSize? = nil
    let select: (CGPoint) -> Void
    @ViewBuilder let canvas: () -> Canvas
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var dataStore: DataStore

    func makeUIViewController(context: Context) -> MapViewportController {
        MapViewportController()
    }
    func updateUIViewController(_ controller: MapViewportController, context: Context) {
        controller.host.rootView = AnyView(canvas().environmentObject(dataStore).ignoresSafeArea())
        controller.canvasSize = canvasSize
        controller.select = select
        controller.animate = !reduceMotion
        if controller.request != request {
            controller.request = request
            controller.focus = focus
            controller.needsCameraUpdate = true
        }
        controller.view.setNeedsLayout()
    }
    static func dismantleUIViewController(_ controller: MapViewportController, coordinator: ()) {
        controller.scroll.delegate = nil
        controller.host.willMove(toParent: nil)
        controller.host.view.removeFromSuperview()
        controller.host.removeFromParent()
        controller.host.rootView = AnyView(EmptyView())
    }
}

final class MapViewportController: UIViewController, UIScrollViewDelegate {
    let scroll = UIScrollView()
    let host = UIHostingController(rootView: AnyView(EmptyView()))
    var request: UUID?
    var focus: CGPoint?
    var canvasSize: CGSize?
    var needsCameraUpdate = true
    var animate = false
    var select: (CGPoint) -> Void = { _ in }
    private var previousSize = CGSize.zero
    private var previousCanvas = CGSize.zero

    override func loadView() {
        view = scroll
        scroll.minimumZoomScale = 1
        scroll.maximumZoomScale = 6
        scroll.bouncesZoom = true
        scroll.contentInsetAdjustmentBehavior = .never
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.backgroundColor = .clear
        scroll.delegate = self
        scroll.panGestureRecognizer.isEnabled = false
        addChild(host)
        scroll.addSubview(host.view)
        host.didMove(toParent: self)
        host.view.backgroundColor = .clear
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(zoomAtTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delaysTouchesBegan = true
        scroll.addGestureRecognizer(doubleTap)
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(selectAtTap(_:)))
        singleTap.require(toFail: doubleTap)
        scroll.addGestureRecognizer(singleTap)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = scroll.bounds.size
        guard size.width > 0, size.height > 0 else { return }
        let content = canvasSize ?? size
        let resized = previousSize != size || previousCanvas != content
        if resized {
            scroll.setZoomScale(1, animated: false)
            host.view.frame = CGRect(origin: .zero, size: content)
            scroll.contentSize = content
            previousSize = size
            previousCanvas = content
            centerContent()
        }
        if resized || needsCameraUpdate {
            needsCameraUpdate = false
            if let focus {
                let rect = CanyonMapGeometry.zoomRect(center: focus, viewport: size)
                scroll.zoom(to: rect, animated: animate && !resized)
            } else {
                scroll.setZoomScale(1, animated: animate && !resized)
                scroll.setContentOffset(CGPoint(x: -scroll.contentInset.left, y: -scroll.contentInset.top), animated: animate && !resized)
            }
        }
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { host.view }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // At fit size, horizontal gestures belong to a surrounding photo pager.
        // Pinch and double-tap remain active; once zoomed, drag pans this canvas.
        scrollView.panGestureRecognizer.isEnabled = scrollView.zoomScale > 1.01
        centerContent()
    }
    private func centerContent() {
        let horizontal = max(0, (scroll.bounds.width - host.view.frame.width) / 2)
        let vertical = max(0, (scroll.bounds.height - host.view.frame.height) / 2)
        scroll.contentInset = UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
    @objc private func selectAtTap(_ gesture: UITapGestureRecognizer) {
        select(gesture.location(in: host.view))
    }
    @objc private func zoomAtTap(_ gesture: UITapGestureRecognizer) {
        if scroll.zoomScale > 1.01 {
            scroll.setZoomScale(1, animated: animate)
            scroll.setContentOffset(CGPoint(x: -scroll.contentInset.left, y: -scroll.contentInset.top), animated: animate)
        } else {
            let point = gesture.location(in: host.view)
            let size = scroll.bounds.size
            scroll.zoom(to: CanyonMapGeometry.zoomRect(center: point, viewport: size), animated: animate)
        }
    }
}
