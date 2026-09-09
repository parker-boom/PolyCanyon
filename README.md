# Poly Canyon

An iPhone guide to the experimental architecture of Cal Poly’s Poly Canyon. Explore the illustrated map, read the stories behind 31 structures and six historical sites, and browse photographs from the canyon.

Visit in person to record discoveries while the app is open, or take a virtual walkthrough from anywhere. The maintained iOS app keeps visit progress on your device; its map, research and photos work offline. Location is optional for virtual exploration.

[App Store](https://apps.apple.com/us/app/poly-canyon/id6499063781) · [Poly Canyon website](https://polycanyon.com/)

## Development

Open `swift/Poly Canyon.xcodeproj` in Xcode and select the **Poly Canyon** scheme. The app supports iOS 16 and later. It requires no Firebase account, JavaScript tooling or backend setup.

```sh
python3 swift/scripts/check-data.py
bash swift/scripts/check-models.sh
bash swift/scripts/check-atlas.sh
bash swift/scripts/run-simulator.sh build
```

The Swift checks require macOS and Xcode. Build outputs default to ignored `swift/.build/`; set `POLYCANYON_BUILD_ROOT` to keep them on another drive and `DEVELOPER_DIR` to select Xcode. See [build instructions](swift/BUILDING.md), [content maintenance](swift/MAINTENANCE.md) and [current release evidence](swift/REDESIGN_RELEASE.md). GitHub Actions runs the content and regression checks, a Release simulator build, and an iPhone archive on pull requests and main. No third-party packages or signing secrets are required by CI.

## Android retirement

The React Native/Android app is retired and will not be deployed. Its project, dependencies, build tools and obsolete Firebase configuration have been removed. [Historical content](assets/retired-android/README.md) is preserved alongside the original research, photos and artwork. The local recovery tag is `archive/android-before-retirement-20260908`.

This repository describes the maintained iOS source. Older installed releases may behave differently. [Security findings and remaining account actions](SECURITY_CLEANUP.md) cover the exposed Android signing material, legacy backend and GitHub alerts.
