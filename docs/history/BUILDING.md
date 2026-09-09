> Historical record. This describes an earlier review, not current setup or release instructions. See the [current documentation](../README.md).

# Build and run locally

Use the existing `Poly Canyon.xcodeproj` and `Poly Canyon` scheme. The app remains in Swift 5 language mode with an iOS 16 deployment target. No Firebase setup is required.

On a clean checkout with Xcode selected:

```bash
python3 swift/scripts/check-data.py
bash swift/scripts/check-models.sh
bash swift/scripts/check-atlas.sh
bash swift/scripts/run-simulator.sh build
bash swift/scripts/run-simulator.sh run
```

Outputs default to ignored `swift/.build/`. Run mode selects an available iPhone simulator; pass a UUID or set `POLYCANYON_SIMULATOR_ID` to choose one. Build-only mode uses a generic simulator destination. Set `DEVELOPER_DIR` to override the selected Xcode and `POLYCANYON_BUILD_ROOT` to choose the output root.

On Parker's Mac, keep all subsequent script outputs on the external drive:

```bash
export DEVELOPER_DIR='/Volumes/SSK Drive/Applications/Xcode.app/Contents/Developer'
export POLYCANYON_BUILD_ROOT='/Volumes/SSK Drive/Developer'
```

With the installed external Xcode and iOS 26.5 runtime:

```bash
DEVELOPER_DIR='/Volumes/SSK Drive/Applications/Xcode.app/Contents/Developer' \
POLYCANYON_BUILD_ROOT='/Volumes/SSK Drive/Developer' \
  bash swift/scripts/run-simulator.sh run A94E4457-3DC6-496A-8F51-4B13D52DD557
```

That device is the existing iPhone 17 Pro running iOS 26.5. Substitute another installed simulator UUID as needed. Set `DEVELOPER_DIR` explicitly because the system selection may still point to internal Xcode. Use `build` instead of `run` to skip simulator boot, app installation, and launch.

With those overrides, the script writes DerivedData, package checkouts, build results, and launch logs under `/Volumes/SSK Drive/Developer`. It preserves the simulator's existing app data and does not install Xcode or runtimes. Signing is disabled for the simulator build only; project signing settings are unchanged.

## Focused regression checks

```bash
bash swift/scripts/check-models.sh
bash swift/scripts/check-atlas.sh
```

Compiles the production models, persistence, store, settings, and location service into isolated macOS checks, including deterministic replay of the actual bundled map coordinates. Tests use temporary files and defaults rather than simulator/user progress. GitHub Actions runs the same checks and Release builds automatically.

## Verification and release preparation

Debug and Release simulator builds and an unsigned Release device archive passed. The app was tested on the existing iOS 18.6 and iOS 26.5 simulators. See [current release](REDESIGN_RELEASE.md) for distribution status. Older review reports are historical.

The final iOS 26.5 preview uses `serve-sim` at `http://localhost:3200` while its terminal is running. The older test simulator is shut down after testing.

For a local unsigned device archive:

```bash
DEVELOPER_DIR='/Volumes/SSK Drive/Applications/Xcode.app/Contents/Developer' xcodebuild \
  -project 'swift/Poly Canyon.xcodeproj' -scheme 'Poly Canyon' \
  -configuration Release -destination 'generic/platform=iOS' \
  -derivedDataPath '/Volumes/SSK Drive/Developer/DerivedData/PolyCanyon' \
  -clonedSourcePackagesDirPath '/Volumes/SSK Drive/Developer/Packages/PolyCanyon' \
  -archivePath '/Volumes/SSK Drive/Developer/Archives/PolyCanyon-refactor-20260907.xcarchive' \
  CODE_SIGNING_ALLOWED=NO archive
```

For distribution, verify the committed marketing/build version against App Store Connect and the [current release handoff](REDESIGN_RELEASE.md). Earlier version-mismatch notes describe a historical checkout. Then configure valid signing and archive without `CODE_SIGNING_ALLOWED=NO`; validate through Xcode Organizer. Upload and submission are separate release actions.

Release-preparation audit, replay-test boundaries, draft metadata and exact account-dependent Xcode/App Store Connect steps: [RELEASE_PREPARATION.md](RELEASE_PREPARATION.md). The shared scheme has no XCTest target; use the script above for regression checks.
