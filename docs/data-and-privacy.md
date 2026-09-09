# Data and privacy

## Content authority

| Content | Source |
| --- | --- |
| Shipping structure histories and image selections | `swift/Poly Canyon/Core/Data/structuresList.json` |
| Shipping historical sites | `swift/Poly Canyon/Core/Data/ghostStructures.json` |
| Shipping map coordinates and tags | `swift/Poly Canyon/Core/Data/mapPoints.json` |
| Shipping images | `swift/Poly Canyon/Assets.xcassets/` |
| Original research, photos, and map artwork | `assets/` |
| Historical Android content | `assets/retired-android/` |

There are 31 structure identities, six historical sites, and 231 map records. Reference and platform image arrays differ intentionally. `check-data.py` checks these relationships and verifies the preservation manifest. Source originals are retained when an unused iOS export is removed.

Some historical map records contain sentinel coordinates, and historical sites 105 and 106 have no discovery tags. Runtime location validation excludes unusable coordinates; the replay suite covers the 35 discoverable structures. Preserve original records until a sourced correction is available.

## On-device data

The maintained 6.0 app stores visit progress locally and uses UserDefaults for settings. It does not upload location, run analytics, or require an account. Location updates run only while the app is active and tracking is enabled; the app does not request Always permission or declare background location.

The privacy manifest declares required UserDefaults access under CA92.1, with no tracking or collected data. Revisit both the manifest and App Store privacy answers if networking or an SDK is introduced. User-initiated website and support links leave the app.

## Historical services

Retiring Android removed its executable code, Firebase configuration, dependencies, and signing files from the current tree. It does not modify previously installed binaries or invalidate credentials in old Git history. The [Android retirement record](android-retirement.md) distinguishes preserved content from the old distribution and account scope.

The public [privacy policy](https://polycanyon.com/privacy) must describe the released version. Coordinate a changed App Store privacy label with the release it describes.
