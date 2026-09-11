# Architecture

The app is native SwiftUI with UIKit scroll views for map and photo gestures. It has no external packages or backend.

## Source layout

| Location under `swift/Poly Canyon/` | Responsibility |
| --- | --- |
| `Core/AppState.swift`, `Core/AppView.swift` | Shared app settings and app presentation |
| `Core/OnboardingFlow.swift` | Explicit onboarding stages and permission outcomes |
| `Core/Data/` | Bundled catalogs, models, local progress, and migration |
| `Core/Location/` | Foreground location updates, sample validation, and discovery |
| `Routing/`, `Views/MainView.swift` | Main navigation |
| `Views/Map/` | Illustrated/satellite maps, camera geometry, native gestures, and virtual tour |
| `Views/Detail/`, `Views/Shared/` | Collection, shared structure presentation, galleries, and discovery notices |
| `Views/Onboarding/`, `Views/Settings/` | Introduction and contextual information |
| `Assets.xcassets/` | Shipped image exports and map variants |

## Exploration and presentation

In-person and virtual exploration share the same structure content. Onboarding captures the chosen experience, then introduces the relevant controls. Location permission is a separate state; map and collection presentation must not infer permission from a chosen tab.

The virtual tour moves a camera over the map as the selected structure changes. `CanyonMapViewport` bridges to a UIKit scroll view for pinch, pan, and double-tap gestures. Geometry helpers keep geographic positions and illustration pixels aligned. Map variants without printed numbers are selected dynamically; a literal asset-name search does not identify all map usage.

Structure presentation and photo selection are shared across entry points. Keep those paths consistent when changing transitions, dismiss controls, or gallery behavior.

## Content and progress

`DataStore` combines bundled research with progress loaded through `CatalogPersistence`. Stable structure numbers connect the catalog, map, and saved discoveries. Bundled content wins over old saved descriptions; only personal progress migrates. Snapshot writes are atomic, unsupported schema versions are guarded, and unreadable files are preserved for recovery.

`LocationService` accepts updates while the app is active and tracking is enabled. `LocationSamplePolicy` rejects unusable samples before discovery. The deterministic replay checks exercise the production service against bundled coordinates.

See [data and privacy](data-and-privacy.md) for source ownership and [setup](setup.md) for checks.

## Appearance and onboarding

`AppState.theme` persists System, Light, or Dark in UserDefaults; new and upgraded installations default to System. The root presentation applies the choice to onboarding, sheets, maps, and stories. Illustrated maps use the existing matching light/dark artwork.

The 6.1 onboarding revision runs once for existing users without deleting visits or preferences. Completion stores the revision. OS location authorization is unchanged; the flow handles existing authorization and denial.

The app icon source is `swift/Poly Canyon/AppIcon.icon`, editable in Apple Icon Composer. Xcode compiles its appearances and creates compatibility images for earlier iOS versions. The `Icon` image asset is its in-app onboarding preview.
