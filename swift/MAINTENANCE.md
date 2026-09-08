# Keeping Poly Canyon maintainable

Keep the working offline architecture small. Bundled content, one local progress snapshot and the foreground-only location service are enough for this archive. A visual refresh is separate work; no backend, cross-platform rewrite or scheduled maintenance service was introduced.

## Content ownership

| Content | Runtime authority / editing rule |
| --- | --- |
| Current iOS catalog | `swift/Poly Canyon/Core/Data/structuresList.json` and `ghostStructures.json` are what iOS ships. Bundled static research wins over saved copies; only user progress merges by stable number. |
| Current iOS map | `swift/Poly Canyon/Core/Data/mapPoints.json`, paired with the map illustration exports and representative points in LocationService. Review geographic coordinates and image pixels together. |
| iOS image selections | The shipped catalog's Images/images arrays reference names in `Assets.xcassets`. Preserve source originals in `assets/photos`; image arrays intentionally differ between platforms. |
| Reference/source archive | `assets/data` and original photos/artwork preserve source material. These are not an automatically authoritative replacement for a reviewed platform change. |
| Legacy Android | `react/src/Core/Data/structuresList.json` and `react/src/Core/Location/mapPoints.json`. React Native/Android is not currently rebuilt or audited. Firebase packages and a location-logging implementation remain; do not promise iOS privacy or feature behavior there. Whether that implementation runs in the distributed Android binary has not been established. |
| Website | Owns long-form research, source links and web presentation. App owns offline map/location/visit behavior. Coordinate edits to shared identities, coordinates, captions and photo provenance explicitly; no shared backend is needed. |

Never renumber a structure to reorder it: IDs connect map tags, user progress and website references. For a research correction, update the intended runtime file, review the reference/other-platform differences, then run both checks. A new photo requires a reviewed source, an iOS export and a catalog reference. A changed map illustration requires checking pixel alignment, not just latitude/longitude.

Measured on 8 September 2026:

- All three map JSON copies match semantically: 231 points each. Reference and iOS ghost JSON match: six records. No equivalent ghost catalog was found in the legacy React Native data directory.
- All structure copies contain the same 31 identities. Compared with `assets/data`, iOS image arrays differ for 1, 6, 7, 9, 22, 25, 27, 29 and 31; description and fun fact differ for 12 (Gunite Bridge). Preserve the reviewed iOS narrative instead of bulk-copying the reference file.
- Android image arrays differ from `assets/data` for 1, 7, 27 and 29.
- Ghosts 105/106 lack tagged discovery points. Legacy untagged map records 124/125/127 have negative latitudes and `(-100,-100)` image pixels. They are outliers, not corrected coordinates; existing canyon gating excludes them from visit awards. Their intended provenance remains unresolved. Do not invent replacements.

`python3 swift/scripts/check-data.py` reports these differences and validates identity uniqueness, map references/coordinate ranges, constructed map image names and asset file references. It uses only Python's standard library and runs on Linux or macOS. `bash swift/scripts/check-models.sh` runs the richer production Swift replay and persistence tests on macOS with Xcode. No hosted CI workflow was added: this repository had no existing CI, and runner/billing access was not verified. The dependency-free data check is ready to add to an existing CI job without signing secrets or a new service.

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

Only the new iOS binary has been audited for no telemetry. Android and the currently published iOS 5.4 remain separate privacy/release scopes. The approved website URLs are `https://polycanyon.com/privacy` and `https://polycanyon.com/support`. The website task reports those routes implemented locally but not published yet; the app release depends on website publication and checking the rendered pages. Do not change live 5.4 labels early. See [RELEASE_PREPARATION.md](RELEASE_PREPARATION.md) for the proposed metadata and account-dependent steps.
