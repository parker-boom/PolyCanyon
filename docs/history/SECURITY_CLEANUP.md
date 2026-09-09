> Historical record. This describes an earlier review, not current setup or release instructions. See the [current documentation](../README.md).

# iOS-only security and support cleanup

Audited 8 September 2026, starting at committed `redesign/visual-ios` **80e12df** in an isolated external-drive worktree. This is the PolyCanyon app repository, not PolyCanyonWebsite. Android is retired and will not be deployed. No remote settings, releases, keys, branches or history were changed.

## Findings requiring owner action

**Exposed Android release signing material.** The old tree tracked `react/android/app/upload-key.jks` and non-default store/key passwords in `react/android/gradle.properties`; `react/android/app/build.gradle` uses them for release signing. Treat that key as exposed. The PEM alongside it is a public certificate, not another private key. The debug keystore is also removed with Android. No credential values are reproduced here.

The owner should inspect Play Console App Integrity to establish whether the exposed key is an upload key under Play App Signing or also signs distributed applications. If it is an upload key, request an upload-key reset and review unexpected releases/account activity; if it is an app-signing key, use the applicable signing-key recovery/upgrade process. Review any password reuse separately. Android retirement does not invalidate signatures on old binaries. Local deletion and the recovery tag do not remediate exposure in existing Git history or clones. No revocation, reset, history rewrite or account change was performed. [Android signing and recovery guidance](https://developer.android.com/studio/publish/app-signing).

**Legacy Firebase/backend scope remains unresolved.** Removed `react/android/app/google-services.json`, unused shared `assets/data/GoogleService-Info.plist`, Firebase dependencies and the legacy `FirebaseService.js` helper that could write coordinates, timestamps and a persistent UUID to `user_locations`. There were no `logLocation` call sites in this source snapshot, so the helper alone does not prove collection in any distributed binary. The published Android and older iOS binaries were not reverse-engineered in this cleanup.

Firebase client configuration/API keys are not equivalent to privileged server credentials. Deleting those files is removal of unused configuration, not proof of database protection. The owner still needs to review Firebase Security Rules, IAM, API restrictions, retained historical location data and any old-client access before retiring backend services. Do not revoke blindly if another product still uses that project. [Firebase security checklist](https://firebase.google.com/support/guides/security-checklist) and [API key guidance](https://firebase.google.com/docs/projects/api-keys).

**GitHub alerts remain open remotely.** The authenticated GitHub UI showed **95 open / 16 closed** on 8 September 2026. Its manifest filter assigns all 95 to **`react/package-lock.json`**. All four pages were read: **4 critical, 51 high, 32 moderate, 8 low**. The exact alert mapping appears below. Removing the retired manifest avoids maintaining an unused vulnerable stack; it does not update installed Android apps or mark default-branch alerts resolved. After an authorized merge/push of this cleanup to the default branch, verify the dependency graph and alerts refresh. Do not dismiss them as false positives merely because Android is retired. [GitHub's default-branch scanning behavior](https://docs.github.com/en/code-security/concepts/supply-chain-security/dependabot-alerts).

## Before and after

| Area | Before | Result |
| --- | --- | --- |
| React Native | `react/package.json`: React 18.2.0, React Native 0.74.0, 29 direct dependencies and 15 development dependencies; `react/package-lock.json`: 1,054 package records including the root | Entire executable tree and both manifests removed; no npm installation or upgrade needed |
| Android | `react/android/{build.gradle,settings.gradle,gradle.properties}`, app Gradle/ProGuard/manifests/Kotlin, Gradle 8.6 wrapper/JAR, Android SDK 34/Kotlin 1.9.22 configuration, release/debug signing files | Removed; Android will not be built or deployed |
| JavaScript tooling | Babel, Metro, TypeScript configuration and entry points; npm scripts for Android, iOS, Jest and ESLint; orphan Ruby Bundler configuration (`react/.bundle/config`, no Gemfile) | Removed with React; no React iOS project existed |
| Hosted workflows | No tracked `.github` workflows or Dependabot configuration at the starting commit | No elaborate CI or new service added |
| Swift lint configuration | Two identical `.swiftlint.yml` files, no script, package, build phase or documented invocation | Removed unused duplicate configuration; compiler and regression checks remain |
| Research and media | 166 Android image, image-key and catalog/map files, plus embedded historical Design Village prose | Byte-preserved under `assets/retired-android/`; prose extracted to Markdown; all existing source originals retained |
| iOS dependencies | Native SwiftUI and UIKit | No external packages. The last unused Zoomable reference was removed for 6.0 build 2; historical license acknowledgments are retained. |
| Support docs | README advertised Android, favorites and old cross-platform behavior | Concise iOS README, explicit retirement, archived-content links; old review/release evidence retained with historical notices |

Recovery: annotated local tag **`archive/android-before-retirement-20260908`** points to **80e12df** before any removal. [Content preservation manifest](../../assets/retired-android/preservation.json) records original/preserved paths and SHA-256 for all 166 content files (62,725,159 bytes). The original React tree had 230 tracked files / 63,581,785 bytes. Retaining image variants deliberately favors preservation over a misleading repository-size claim; old blobs also remain in Git history.

## Retained iOS risk review

The current app is foreground-location-only, with local progress, no favorites UI and unchanged discovery behavior. No Firebase SDK/configuration, location upload, analytics, broad network exception or sensitive logging was found in the retained app source. The privacy manifest declares UserDefaults access (CA92.1), no tracking and no collected data. The source supports the proposed “Data Not Collected” disclosure under [Apple's off-device collection definition](https://developer.apple.com/app-store/app-privacy-details/). This is not a claim about the currently distributed 5.4 binary, retired Android, user-initiated external web links or support email.

The 6.0 build 2 project has no external package dependencies. Map and photo gestures use the app's native UIKit scroll view; photo blur and materials use SwiftUI. The unused Zoomable project reference and lockfile were removed. Existing license acknowledgments remain preserved.

Run the automated content, model, location-replay, geometry and Release build checks when changing the app. Review privacy declarations if a future change introduces networking or an SDK.

## Verification

- `python3 swift/scripts/check-data.py`: passed current iOS references (31 structures, six ghosts, 231 map points), existing catalog-difference checks and SHA-256 verification of all 166 archived files. Ghosts 105/106 still lack discovery coordinates; no coordinates were fabricated.
- `bash swift/scripts/check-models.sh`: passed production model, persistence/migration, store and foreground-only location replay, including all 35 discoverable structures.
- Generic Debug simulator build: passed with Xcode 26.6 / iOS 26.5 SDK. Only warning: AppIntents metadata extraction skipped because the app has no AppIntents framework dependency.
- Built-bundle inspection: version 6.0 (1), When In Use location only, no background/Always keys, no legacy credentials/Firebase configuration or archived Android content bundled. A scoped retained-text secret-pattern scan found no matches; this is not a forensic scan of all Git history.
- All compilation outputs/dependencies use dedicated `/Volumes/SSK Drive/Developer/SecurityLTS`; logs are `/Volumes/SSK Drive/Developer/SecurityLTS-checks.log` and `SecurityLTS-build.log`. No simulator device was created, booted, installed to or controlled by this task.

## Verified alert mapping

Every row below belongs to the retired **npm manifest `react/package-lock.json`**, removed by this branch. None is linked into the retained native Swift app. Some packages are build/dev tooling and others can enter the old runtime dependency graph; reachability in old distributed Android binaries was not established. Severity is GitHub's observed advisory severity, not a claim that every path is exploitable in a shipped app.

| Package | Severity | Alert IDs |
| --- | --- | --- |
| `@babel/core` | Low | [#95](https://github.com/parker-boom/PolyCanyon/security/dependabot/95) |
| `@babel/helpers` | Moderate | [#17](https://github.com/parker-boom/PolyCanyon/security/dependabot/17) |
| `@babel/plugin-transform-modules-systemjs` | High | [#78](https://github.com/parker-boom/PolyCanyon/security/dependabot/78) |
| `@babel/runtime` | Moderate | [#16](https://github.com/parker-boom/PolyCanyon/security/dependabot/16) |
| `@grpc/grpc-js` | High | [#90](https://github.com/parker-boom/PolyCanyon/security/dependabot/90), [#91](https://github.com/parker-boom/PolyCanyon/security/dependabot/91) |
| `@protobufjs/utf8` | Moderate | [#79](https://github.com/parker-boom/PolyCanyon/security/dependabot/79) |
| `@xmldom/xmldom` | High | [#66](https://github.com/parker-boom/PolyCanyon/security/dependabot/66), [#73](https://github.com/parker-boom/PolyCanyon/security/dependabot/73), [#74](https://github.com/parker-boom/PolyCanyon/security/dependabot/74), [#75](https://github.com/parker-boom/PolyCanyon/security/dependabot/75), [#76](https://github.com/parker-boom/PolyCanyon/security/dependabot/76) |
| `@xmldom/xmldom` | Moderate | [#131](https://github.com/parker-boom/PolyCanyon/security/dependabot/131) |
| `brace-expansion` | High | [#108](https://github.com/parker-boom/PolyCanyon/security/dependabot/108), [#111](https://github.com/parker-boom/PolyCanyon/security/dependabot/111), [#118](https://github.com/parker-boom/PolyCanyon/security/dependabot/118), [#126](https://github.com/parker-boom/PolyCanyon/security/dependabot/126) |
| `browserslist` | High | [#128](https://github.com/parker-boom/PolyCanyon/security/dependabot/128), [#129](https://github.com/parker-boom/PolyCanyon/security/dependabot/129) |
| `cross-spawn` | High | [#15](https://github.com/parker-boom/PolyCanyon/security/dependabot/15) |
| `decode-uri-component` | Moderate | [#127](https://github.com/parker-boom/PolyCanyon/security/dependabot/127) |
| `fast-xml-parser` | Critical | [#47](https://github.com/parker-boom/PolyCanyon/security/dependabot/47) |
| `fast-xml-parser` | High | [#48](https://github.com/parker-boom/PolyCanyon/security/dependabot/48), [#59](https://github.com/parker-boom/PolyCanyon/security/dependabot/59) |
| `fast-xml-parser` | Low | [#50](https://github.com/parker-boom/PolyCanyon/security/dependabot/50) |
| `fast-xml-parser` | Moderate | [#71](https://github.com/parker-boom/PolyCanyon/security/dependabot/71), [#77](https://github.com/parker-boom/PolyCanyon/security/dependabot/77) |
| `flatted` | High | [#58](https://github.com/parker-boom/PolyCanyon/security/dependabot/58) |
| `image-size` | High | [#18](https://github.com/parker-boom/PolyCanyon/security/dependabot/18), [#119](https://github.com/parker-boom/PolyCanyon/security/dependabot/119), [#120](https://github.com/parker-boom/PolyCanyon/security/dependabot/120) |
| `joi` | Moderate | [#92](https://github.com/parker-boom/PolyCanyon/security/dependabot/92) |
| `js-yaml` | High | [#109](https://github.com/parker-boom/PolyCanyon/security/dependabot/109), [#110](https://github.com/parker-boom/PolyCanyon/security/dependabot/110), [#121](https://github.com/parker-boom/PolyCanyon/security/dependabot/121), [#124](https://github.com/parker-boom/PolyCanyon/security/dependabot/124) |
| `js-yaml` | Moderate | [#25](https://github.com/parker-boom/PolyCanyon/security/dependabot/25), [#26](https://github.com/parker-boom/PolyCanyon/security/dependabot/26), [#103](https://github.com/parker-boom/PolyCanyon/security/dependabot/103), [#104](https://github.com/parker-boom/PolyCanyon/security/dependabot/104) |
| `lodash` | High | [#70](https://github.com/parker-boom/PolyCanyon/security/dependabot/70) |
| `lodash` | Moderate | [#31](https://github.com/parker-boom/PolyCanyon/security/dependabot/31), [#69](https://github.com/parker-boom/PolyCanyon/security/dependabot/69) |
| `minimatch` | High | [#41](https://github.com/parker-boom/PolyCanyon/security/dependabot/41), [#44](https://github.com/parker-boom/PolyCanyon/security/dependabot/44), [#45](https://github.com/parker-boom/PolyCanyon/security/dependabot/45), [#46](https://github.com/parker-boom/PolyCanyon/security/dependabot/46) |
| `nanoid` | High | [#123](https://github.com/parker-boom/PolyCanyon/security/dependabot/123), [#125](https://github.com/parker-boom/PolyCanyon/security/dependabot/125), [#130](https://github.com/parker-boom/PolyCanyon/security/dependabot/130) |
| `nanoid` | Moderate | [#13](https://github.com/parker-boom/PolyCanyon/security/dependabot/13) |
| `node-forge` | High | [#28](https://github.com/parker-boom/PolyCanyon/security/dependabot/28), [#29](https://github.com/parker-boom/PolyCanyon/security/dependabot/29), [#61](https://github.com/parker-boom/PolyCanyon/security/dependabot/61), [#62](https://github.com/parker-boom/PolyCanyon/security/dependabot/62), [#63](https://github.com/parker-boom/PolyCanyon/security/dependabot/63), [#64](https://github.com/parker-boom/PolyCanyon/security/dependabot/64) |
| `node-forge` | Moderate | [#27](https://github.com/parker-boom/PolyCanyon/security/dependabot/27) |
| `on-headers` | Low | [#21](https://github.com/parker-boom/PolyCanyon/security/dependabot/21) |
| `picomatch` | High | [#67](https://github.com/parker-boom/PolyCanyon/security/dependabot/67) |
| `picomatch` | Moderate | [#68](https://github.com/parker-boom/PolyCanyon/security/dependabot/68) |
| `protobufjs` | Critical | [#72](https://github.com/parker-boom/PolyCanyon/security/dependabot/72) |
| `protobufjs` | High | [#81](https://github.com/parker-boom/PolyCanyon/security/dependabot/81), [#82](https://github.com/parker-boom/PolyCanyon/security/dependabot/82), [#85](https://github.com/parker-boom/PolyCanyon/security/dependabot/85), [#86](https://github.com/parker-boom/PolyCanyon/security/dependabot/86), [#94](https://github.com/parker-boom/PolyCanyon/security/dependabot/94) |
| `protobufjs` | Moderate | [#80](https://github.com/parker-boom/PolyCanyon/security/dependabot/80), [#83](https://github.com/parker-boom/PolyCanyon/security/dependabot/83), [#84](https://github.com/parker-boom/PolyCanyon/security/dependabot/84), [#87](https://github.com/parker-boom/PolyCanyon/security/dependabot/87), [#93](https://github.com/parker-boom/PolyCanyon/security/dependabot/93) |
| `send` | Low | [#12](https://github.com/parker-boom/PolyCanyon/security/dependabot/12) |
| `serve-static` | Low | [#11](https://github.com/parker-boom/PolyCanyon/security/dependabot/11) |
| `shell-quote` | Critical | [#88](https://github.com/parker-boom/PolyCanyon/security/dependabot/88) |
| `shell-quote` | High | [#107](https://github.com/parker-boom/PolyCanyon/security/dependabot/107) |
| `undici` | High | [#52](https://github.com/parker-boom/PolyCanyon/security/dependabot/52), [#53](https://github.com/parker-boom/PolyCanyon/security/dependabot/53), [#100](https://github.com/parker-boom/PolyCanyon/security/dependabot/100) |
| `undici` | Low | [#19](https://github.com/parker-boom/PolyCanyon/security/dependabot/19), [#99](https://github.com/parker-boom/PolyCanyon/security/dependabot/99), [#102](https://github.com/parker-boom/PolyCanyon/security/dependabot/102) |
| `undici` | Moderate | [#14](https://github.com/parker-boom/PolyCanyon/security/dependabot/14), [#30](https://github.com/parker-boom/PolyCanyon/security/dependabot/30), [#51](https://github.com/parker-boom/PolyCanyon/security/dependabot/51), [#54](https://github.com/parker-boom/PolyCanyon/security/dependabot/54), [#101](https://github.com/parker-boom/PolyCanyon/security/dependabot/101), [#114](https://github.com/parker-boom/PolyCanyon/security/dependabot/114), [#115](https://github.com/parker-boom/PolyCanyon/security/dependabot/115), [#116](https://github.com/parker-boom/PolyCanyon/security/dependabot/116) |
| `websocket-driver` | Critical | [#105](https://github.com/parker-boom/PolyCanyon/security/dependabot/105) |
| `websocket-driver` | Moderate | [#106](https://github.com/parker-boom/PolyCanyon/security/dependabot/106) |
| `ws` | High | [#97](https://github.com/parker-boom/PolyCanyon/security/dependabot/97), [#98](https://github.com/parker-boom/PolyCanyon/security/dependabot/98) |
| `yaml` | Moderate | [#60](https://github.com/parker-boom/PolyCanyon/security/dependabot/60) |
