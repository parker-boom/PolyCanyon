# Retired Android content archive

Android is retired and will not be deployed. This directory contains content only: all 166 image, image-key and catalog/map files from the retired project, preserved byte for byte. Keeping alternate image encodings avoids guessing which exports contain unique details. Existing original photographs, research and artwork elsewhere under `assets/` remain untouched.

- `src/Core/Data/structuresList.json`: historical Android image selections; deliberately not merged into the iOS catalog.
- `src/Core/Location/mapPoints.json`: historical map coordinates.
- `src/assets/`: photographs, map exports, icon and image key.
- `android/app/src/main/res/`: historical launcher artwork.
- `src/routing/DesignVillage/Images/` and [historical event text](design-village-text.md): event images and prose.
- [preservation.json](preservation.json): every original path, preserved path and SHA-256 checksum. `python3 swift/scripts/check-data.py` verifies these files as well as the live iOS references.

Nothing here is bundled into the iOS app. These are reference materials, not an installable Android project or current event instructions.

Full source and tooling are recoverable from the annotated tag `archive/android-before-retirement-20260908` (commit `80e12df`). Inspect it with `git show archive/android-before-retirement-20260908:react/<path>` in a private terminal; the old tree contains exposed signing material. Do not restore it into a shipping branch or execute the old tooling. The tag is published on GitHub. See [security cleanup](../../docs/android-retirement.md) for outstanding account actions.
