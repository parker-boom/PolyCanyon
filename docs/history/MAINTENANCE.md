> Historical record. This describes an earlier review, not current setup or release instructions. See the [current documentation](../README.md).

# Keeping Poly Canyon maintainable

Keep the working offline architecture small. Bundled content, one local progress snapshot and the foreground-only location service are enough for this archive. The interface uses native SwiftUI and UIKit; no backend or external package is required.

## Content ownership

| Content | Runtime authority / editing rule |
| --- | --- |
| Current iOS catalog | `swift/Poly Canyon/Core/Data/structuresList.json` and `ghostStructures.json` are what iOS ships. Bundled static research wins over saved copies; only user progress merges by stable number. |
| Current iOS map | `swift/Poly Canyon/Core/Data/mapPoints.json`, paired with the map illustration exports and representative points in LocationService. Review geographic coordinates and image pixels together. |
| iOS image selections | The shipped catalog's Images/images arrays reference names in `Assets.xcassets`. Preserve source originals in `assets/photos`; image arrays intentionally differ between platforms. |
| Reference/source archive | `assets/data` and original photos/artwork preserve source material. These are not an automatically authoritative replacement for a reviewed platform change. |
| Retired Android archive | Catalogs and images survive under `assets/retired-android/`; the executable project and dependencies are removed. See its README for checksums and recovery tag. Old distributed Android binaries and backend configuration remain separate, unaudited scopes. |
| Website | Owns long-form research, source links and web presentation. App owns offline map/location/visit behavior. Coordinate edits to shared identities, coordinates, captions and photo provenance explicitly; no shared backend is needed. |

Never renumber a structure to reorder it: IDs connect map tags, user progress and website references. For a research correction, update the intended runtime file, review the reference/other-platform differences, then run both checks. A new photo requires a reviewed source, an iOS export and a catalog reference. A changed map illustration requires checking pixel alignment, not just latitude/longitude.

Measured on 8 September 2026:

- All three map JSON copies match semantically: 231 points each. Reference and iOS ghost JSON match: six records. No equivalent ghost catalog was found in the legacy React Native data directory.
- All structure copies contain the same 31 identities. Compared with `assets/data`, iOS image arrays differ for 1, 6, 7, 9, 22, 25, 27, 29 and 31; description and fun fact differ for 12 (Gunite Bridge). Preserve the reviewed iOS narrative instead of bulk-copying the reference file.
- Android image arrays differ from `assets/data` for 1, 7, 27 and 29.
- Ghosts 105/106 lack tagged discovery points. Legacy untagged map records 124/125/127 have negative latitudes and `(-100,-100)` image pixels. They are outliers, not corrected coordinates; existing canyon gating excludes them from visit awards. Their intended provenance remains unresolved. Do not invent replacements.

`python3 swift/scripts/check-data.py` reports these differences and validates identity uniqueness, map references/coordinate ranges, constructed map image names and asset file references. It uses only Python's standard library and runs on Linux or macOS. `bash swift/scripts/check-models.sh` runs the richer production Swift replay and persistence tests on macOS with Xcode. GitHub Actions runs all three scripts plus Release simulator and device builds on each pull request. The workflow needs no signing secrets.

## Shipped asset audit

The initial iOS imagesets contained 219,730,025 encoded image bytes. There were no byte-identical duplicates among those imageset files. Eleven unused photo exports totaling **11,289,414 bytes (10.77 MiB)** were removed from the iOS asset catalog. Each name was absent from all app Swift source and shipped JSON; reviewed dynamic naming applies to map variants and catalog-selected images, not these names. Every source original remains:

| Removed iOS imageset | Preserved source |
| --- | --- |
| C-29 | assets/photos/Close/C-29.jpg |
| treeHouse1 | assets/photos/Other/treeHouse1.jpg |
| electric5 | assets/photos/Other/electric5.png |
| momentMonument4 | assets/photos/Other/momentMonument4.jpg |
| restrooms3 | assets/photos/Other/restrooms3.jpg |
| electric4 | assets/photos/Other/electric4.jpg |
| centeringCenter4 | assets/photos/Other/centeringCenter4.jpg |
| entryArch4 | assets/photos/Other/entryArch4.jpg |
| tensile4 | assets/photos/Other/tensile4.jpg |
| greenHouse3 | assets/photos/Other/greenHouse3.jpg |
| geodesicDome4 | assets/photos/Other/geodesicDome4.jpg |

Remaining imageset source bytes: 208,440,611. This is a source payload reduction, not a measured App Store download reduction; asset compilation/thinning changes package size. SatelliteMapNN (7,976,463 bytes) and SatelliteMap (7,946,878 bytes) are the largest retained images. The `NN` variants are constructed at runtime for the hide-numbers toggle and must not be deleted based on a literal-name search. The unused partyHat export stays because no separate original was found. No artwork was resized or recompressed, and no research was deleted.

## Portable build setup

Scripts use `DEVELOPER_DIR` if supplied, otherwise the machine's selected Xcode. `POLYCANYON_BUILD_ROOT` defaults to the ignored `swift/.build/` directory; its DerivedData, Packages, Checks and Logs subdirectories contain build outputs. `run-simulator.sh build` uses a generic simulator destination and needs no saved device UUID. `run` accepts a UUID or `POLYCANYON_SIMULATOR_ID`; without either, it selects a booted available iPhone or the first available iPhone. It never installs runtimes.

On Parker's Mac, keep outputs external by setting both variables from [BUILDING.md](BUILDING.md). No machine-specific defaults or signing secrets are required by a clean checkout.

## Release boundaries

The retained iOS source and prior locally built binary have been audited for no telemetry. Android retirement does not update or disable previously distributed binaries. See [security cleanup](SECURITY_CLEANUP.md). Android and the currently published iOS 5.4 remain separate privacy/release scopes. The approved website URLs are `https://polycanyon.com/privacy` and `https://polycanyon.com/support`. Those routes and the 6.0 feature media are published on the production website. Do not change live 5.4 labels early. See [REDESIGN_RELEASE.md](REDESIGN_RELEASE.md) for the current release.
