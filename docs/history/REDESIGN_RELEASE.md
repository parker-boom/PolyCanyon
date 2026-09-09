> Historical record. This describes an earlier review, not current setup or release instructions. See the [current documentation](../README.md).

# Poly Canyon 6.0

The maintained app is native SwiftUI and UIKit, supports iOS 16 and later, and has no external package dependencies. Visit progress is stored locally. Optional location is used while the app is active; no location data or analytics are uploaded.

## Release

- Bundle: `Parker-Jones.Arch-Graveyard`; App Store ID: `6499063781`.
- Version: **6.0**. Build **2** removes the unused Zoomable dependency from the reviewed build 1 interface.
- Build toolchain: Xcode 26.6, iOS SDK 26.5.
- Apple Distribution signing is configured for Parker Jones's existing team. Build 2 passed local regression checks, Release simulator compilation, signed iPhone archive, signature verification, and App Store upload. The GitHub regression checks and both Release builds passed as well.
- Four approved feature screenshots and the [listing copy](../app-store.md) are saved in [App Store Connect](https://appstoreconnect.apple.com/apps/6499063781/distribution/ios/version/inflight).
- The [website](https://polycanyon.com/app), [privacy policy](https://polycanyon.com/privacy), and [support page](https://polycanyon.com/support) are published.
- Release is manual after Apple review. Content-rights and updated age-rating declarations require the owner's answers before submission. Coordinate the new no-data privacy label with the 6.0 release.

## Development

[Build instructions](BUILDING.md) and [content maintenance](MAINTENANCE.md) are the current development references. GitHub Actions runs content integrity, production persistence/migration, onboarding, location replay, map geometry/camera checks, and unsigned Release simulator and device builds. Distribution signing stays local; CI requires no signing credentials.

Earlier review reports describe intermediate versions and are retained as project history. The final UI and media are based on the approved onboarding, live discovery, virtual tour, collection, and photo presentation.
