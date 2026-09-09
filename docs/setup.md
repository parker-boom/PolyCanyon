# Setup and checks

Use macOS with Xcode and its command-line tools selected. The verified toolchain is Xcode 26.6 with the iOS 26.5 SDK; the deployment target is iOS 16. No third-party packages, JavaScript tools, Firebase configuration, or API keys are needed.

## Run locally

1. Open `swift/Poly Canyon.xcodeproj` from the repository root.
2. Select the **Poly Canyon** scheme and an installed iPhone Simulator.
3. Run the app. For a physical iPhone, choose your development team in Signing & Capabilities.

The equivalent command uses an available iPhone Simulator and preserves its app data:

```sh
bash swift/scripts/run-simulator.sh run
```

Pass a simulator UUID as a second argument, or set `POLYCANYON_SIMULATOR_ID`, to choose a device. Without one, the script prefers an already booted iPhone. It does not install runtimes. Use `build` instead of `run` to compile without booting or launching a simulator.

## Run checks

Run these from the repository root:

```sh
python3 swift/scripts/check-data.py
bash swift/scripts/check-models.sh
bash swift/scripts/check-atlas.sh
bash swift/scripts/run-simulator.sh build
```

The data check validates the shipped catalogs, asset references, map data, and archived-content checksums. The Swift scripts exercise production persistence, migrations, onboarding, location replay, and map geometry. They use temporary test data; they do not change personal visit progress. The shared scheme has no XCTest target; these scripts are the regression suite.

The [iOS workflow](../.github/workflows/ios.yml) runs the same checks, a Release simulator build, and an unsigned iPhone archive on pull requests and pushes to main. It can also be run manually. There are no scheduled runs.

## Build outputs

Scripts write to ignored `swift/.build/` by default. Set `POLYCANYON_BUILD_ROOT` to put generated files on another disk. Set `DEVELOPER_DIR` if you use an Xcode installation other than the system-selected one.

```sh
export DEVELOPER_DIR='/path/to/Xcode.app/Contents/Developer'
export POLYCANYON_BUILD_ROOT='/path/to/build-output'
```

Replace these example paths with your own. Build outputs and signing identities are not repository content. Distribution instructions are in [release](release.md).
