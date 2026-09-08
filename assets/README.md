# Source assets

This directory preserves reference research, map artwork, original photographs and historical promotional material. Platform bundles are maintained separately; no synchronization happens automatically.

- `data/structuresList.json`: reference descriptions and image selections for 31 structures.
- `data/ghostStructures.json`: six historical structures.
- `data/mapPoints.json`: geographic coordinates, illustration pixels and discovery tags.
- `photos/`: source photographs. Preserve these when pruning an unused iOS export.
- `map/`, `app icon/`, `onboarding/`, `screenshots/`: original artwork and historical exports; these are not automatically shipped by the current app.

The current iOS runtime reads `swift/Poly Canyon/Core/Data/*.json` and `swift/Poly Canyon/Assets.xcassets`. Legacy Android reads copies under `react/src/Core/`. The structure catalogs differ: see [content ownership and measured differences](../swift/MAINTENANCE.md) before copying or editing them. Historical CSV files mentioned in older documentation are not present in this checkout; use the actual JSON files above.

`data/GoogleService-Info.plist` is a legacy shared configuration. It is not bundled by the refactored iOS app. Android's current behavior and privacy declarations require a separate audit.

Run `python3 swift/scripts/check-data.py` from the repository root to validate the shipped iOS catalog, map references and asset files, and report differences between platform copies. Do not merge catalogs simply to make the difference report empty.
