# Build and run locally

Use the existing `Poly Canyon.xcodeproj` and `Poly Canyon` scheme. The app remains in Swift 5 language mode with an iOS 16 deployment target. No Firebase setup is required.

With the installed external Xcode and iOS 26.5 runtime:

```bash
DEVELOPER_DIR='/Volumes/SSK Drive/Applications/Xcode.app/Contents/Developer' \
  bash swift/scripts/run-simulator.sh run A94E4457-3DC6-496A-8F51-4B13D52DD557
```

That device is the existing iPhone 17 Pro running iOS 26.5. Substitute another installed simulator UUID as needed. Set `DEVELOPER_DIR` explicitly because the system selection may still point to internal Xcode. Use `build` instead of `run` to skip simulator boot, app installation, and launch.

The script writes DerivedData, package checkouts, build results, and launch logs under `/Volumes/SSK Drive/Developer`. It preserves the simulator's existing app data and does not install Xcode or runtimes. Signing is disabled for the simulator build only; project signing settings are unchanged.

## Focused regression checks

```bash
bash swift/scripts/check-models.sh
```

Compiles the production models, persistence, store, settings, and location-sample policy into isolated macOS checks. Tests use temporary files and defaults rather than simulator/user progress. See [REFACTOR.md](REFACTOR.md) for coverage and release limitations.

## Verification and release preparation

Debug and Release simulator builds and an unsigned Release device archive passed. The app was tested on the existing iOS 18.6 and iOS 26.5 simulators. Read [REFACTOR.md](REFACTOR.md) for the exact verification matrix, artifact locations, and physical-device/account requirements.

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

For distribution, first resolve the source/listing version mismatch and select the next marketing/build version in the authorized developer account. Then configure valid signing and archive without `CODE_SIGNING_ALLOWED=NO`; validate through Xcode Organizer. Upload and submission are separate release actions.
