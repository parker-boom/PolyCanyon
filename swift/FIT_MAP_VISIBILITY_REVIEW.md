# Fit map visibility handoff

Base 25d06b4; design/remix. Only requested behavior changed: Fit map is hidden at fitted scale and visible when zoomed in.

MapViewportController reports its actual UIScrollView.zoomScale relative to minimumZoomScale (0.01 tolerance) through the existing zoom delegate and camera-layout path. UIKit layout completes before the SwiftUI visibility update; queued callbacks read the current camera scale rather than a captured/stale value. Pinch, double-tap, programmatic recenter, fit, and resize therefore share the same camera signal. No location, tracking, progress, Tour, card, or story behavior changed.

Live on the existing iOS 26.5 simulator: Fit map absent at initial fit; double-tap zoom made it appear; pressing Fit map hid it; another double-tap zoom showed it and double-tap zoom-out hid it again. Native accessibility confirmed each appearance/removal. Actual two-finger pinch and location recenter were not separately exercised; both use the same delegate signal. No tracking or permission prompt was accepted and no progress reset occurred.

Debug unsigned simulator build passed. External artifacts: /Volumes/SSK Drive/Developer/Redesign/ThirdPass/FitMapVisibility/debug-final.log and manifest.txt, plus the immutable commit-named Debug app. Manifest records the exact commit and matching installed executable/dylib hashes. No new Release build was needed for this narrow local handoff.

UI ownership released at final handoff. Installed app is on Map at fit scale. Coordinator owns the requested simulator restart and synthetic inside-canyon onboarding setup for Parker’s hands-on test; neither was performed here. Website media coordination remains deferred to coordinator.
