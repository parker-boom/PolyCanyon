# Source assets

This directory preserves reference research, original photographs, map artwork and historical platform exports. Platform bundles are maintained separately; no synchronization happens automatically.

- `data/structuresList.json`: reference descriptions and image selections for 31 structures.
- `data/ghostStructures.json`: six historical structures.
- `data/mapPoints.json`: geographic coordinates, illustration pixels and discovery tags.
- `photos/`: source photographs. Preserve these when pruning an unused iOS export.
- `map/` and `app icon/`: original artwork and exports.
- [retired-android/](retired-android/README.md): preserved Android catalogs, images and historical Design Village text, with original-path checksums.

The iOS runtime reads `swift/Poly Canyon/Core/Data/*.json` and `swift/Poly Canyon/Assets.xcassets`. The structure catalogs differ: see [content ownership and measured differences](../swift/MAINTENANCE.md) before copying or editing them. Historical CSV files mentioned in older documentation are not present in this checkout; use the actual JSON files above.

The unused legacy `data/GoogleService-Info.plist` was removed during Android retirement. The maintained iOS app does not bundle or use Firebase configuration.

Run `python3 swift/scripts/check-data.py` from the repository root to validate shipped iOS references, report reference/archive differences and verify preserved Android content checksums. Do not merge catalogs simply to make the difference report empty.
