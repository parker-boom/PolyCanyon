# Poly Canyon refactor

> Historical review/release evidence. Some feature proposals, favorites references, version details and build paths below predate the current foreground-only, no-favorites app. Preserve this record; use [REDESIGN_RELEASE.md](REDESIGN_RELEASE.md) for the current release handoff and [SECURITY_CLEANUP.md](../SECURITY_CLEANUP.md) for Android retirement.

Current behavior: location runs only while the app is active. Background tracking and Always requests were subsequently removed; older background-test rows below are historical evidence of the previous implementation, not current behavior. Automatic nearby/permission mode recommendations and the tested discovery rules remain unchanged. See [RELEASE_PREPARATION.md](RELEASE_PREPARATION.md).

## Changes

- Removed Rate Structures: its card deck, route, state, and browsing prompt. Favorites remain available through the existing heart controls. Gallery swiping and virtual-tour navigation remain.
- Removed Design Village: the dated event router, onboarding prompt, event screens, switch in Settings, and event-only iOS assets. The root now presents Poly Canyon directly.
- Split map rendering, controls, full-screen map, bottom bar, structure cards, and progress prompt into focused source files.
- Made UI state, the data store, location service, and map-position store main-actor owned. Enabled complete concurrency checking while retaining Swift 5 language mode and iOS 16 deployment support.
- Extracted catalog persistence from the observable store. Bundled research is authoritative; saved favorite/visited/opened/timestamp fields merge by stable structure number. A changed data version no longer discards progress. Duplicate saved IDs are handled deterministically.
- Favorites, both visit catalogs, and visit-day statistics now commit together in one versioned `Documents/progress.json` snapshot. Visible state changes only after a successful atomic write, including full reset. Existing `structures.json`, `ghostStructures.json`, and day defaults migrate on the first successful edit; legacy files remain intact. A damaged snapshot can fall back to older legacy progress, with a recovery warning.
- Corrupt JSON is preserved before fallback, without making duplicate recovery copies on every launch. Future snapshot versions and unsafe read failures block writes. Failed automatic visit saves pause until foregrounding or a successful manual save, preventing repeated GPS-triggered alerts. Storage, defaults, bundle, and clock are injectable for tests.
- Unified visit-day accounting. Full progress reset also clears day counts and pending visit notices; favorites reset leaves visits intact. Settings reset removes only owned keys and resets the corresponding live state.
- Removed the store's dependency on the global location service for sorting. Fixed ghost-category search results appearing for unrelated searches.
- Fixed detail routing that assumed structure number minus one was always a valid array index. Empty ghost catalogs have a recoverable screen.
- Removed duplicate image decoding whose result was never displayed. Restored three missing photo assets from original project photos.
- Added descriptive tab and grid accessibility labels and larger tab touch targets. This is an accessibility improvement, not a completed Dynamic Type/VoiceOver certification.
- Location updates reject invalid or old fixes; visits additionally require horizontal accuracy within 50 meters. Virtual mode ignores late location callbacks. Denial, virtual mode, and stale foreground fixes clear location state. Scene changes stop GPS whenever inactive or backgrounded and resume the selected mode with current authorization on return. Permission screens observe authorization directly instead of waiting on asynchronous continuations. Nearest-point lookup no longer uses a coordinate-independent time cache. Physical accuracy thresholds still require a canyon walk test.
- Removed Firebase integrations and unused Shimmer. Replaced Shiny's process-wide motion manager with a welcome-screen-owned, cancellable effect that respects backgrounding and Reduce Motion; retained its MIT notice. Glur 1.1.0 and Zoomable revision 27463744a1c82e550959703153bd6f3c62fef906 are pinned. Package resolution is included in version control.
- Added the app-only UserDefaults required-reason privacy declaration (CA92.1), with no tracking or collected-data declarations. App source contains no networking client or location-upload path. User-initiated system settings/email actions remain.

## Verification

Run `bash swift/scripts/check-models.sh` and `bash swift/scripts/run-simulator.sh run` using the external Xcode described in BUILDING.md.

Passed automated checks cover actual bundled JSON (31 structures, six ghosts, 231 map points), catalog merging, duplicate IDs, progress-aware equality, missing files, corrupt-file preservation, atomic round trips, failed-write rollback for visits/favorites/full reset, legacy migration, future-schema write protection, invalid saved map scales, fresh and returning stores, same-day versus next-day visits, repeated visits, favorites reset, full reset, search, unrelated-default preservation, and invalid/stale/inaccurate location samples. Tests use temporary data and a test-only location-hardware stand-in; they do not prove real GPS behavior.

All asset catalog file references and structure/ghost image references resolve. Project/privacy plists and whitespace checks pass.

Final Debug and Release simulator builds passed using Xcode 26.6. The final Release device archive also passed and contains an arm64 iOS binary, the three research/map JSON files, the restored image catalog, the privacy manifest, and the Shiny license. Complete concurrency checking produced no app-source warnings. The only build warning is Xcode skipping AppIntents metadata extraction because the app has no AppIntents dependency.

Archive: `/Volumes/SSK Drive/Developer/Archives/PolyCanyon-refactor-20260907.xcarchive`. This is deliberately unsigned and cannot be uploaded as-is.

| Check | Result |
| --- | --- |
| iOS 26.5 / iPhone 17 Pro install, launch, map, browsing and live preview | Passed |
| iOS 18.6 / iPhone 16 Pro fresh launch and onboarding | Passed |
| Allow While Using; decline Always; complete onboarding | Passed |
| Simulated ghost 101 visit and relaunch persistence/statistics | Passed |
| Second-pass migration preserves ghost 101 and records ghost 102 in schema 1 snapshot | Passed |
| Historical nearby background visit check | Superseded: current app must record no background visits |
| Inactive/background stops recording; foreground resumes | Current foreground-only acceptance criterion |
| Virtual mode restored after relaunch; new simulated location does not mark a visit | Passed |
| Gallery: five Entry Arch pages, last-page boundary, favorite toggle | Passed |
| Largest accessibility text size: gallery controls remain visible | Passed; not whole-app accessibility certification |
| UI favorites reset preserves ghost visit | Passed |
| Missing saved JSON: full bundled catalog still available | Passed |
| Corrupt JSON: visible recovery warning and preserved unreadable file | Passed; original test save restored afterward |
| Returning adventure user with revoked location permission | Passed: app remains usable |
| Automated model/store/settings/location-policy suite | Passed after final source changes |
| Asset references, project/privacy plists, whitespace checks | Passed |

Simulator validation also found and fixed an overlapping welcome/visit notification and inaccurate permission wording about tracking while the app is closed. The two duplicated galleries now share a single component with accessible page controls and reset their page when the structure changes. Swipe/zoom gestures remain implemented by the original TabView/Zoomable combination, but a physical multitouch gesture test remains advisable.

Logs are under `/Volumes/SSK Drive/Developer`: `PolyCanyon-quality-debug.log`, `PolyCanyon-quality-release.log`, `PolyCanyon-quality-archive.log`, and `PolyCanyon-quality-checks.log`. The iOS 18.6 test simulator was shut down after completion; the iOS 26.5 simulator is retained for the live preview.

## Distribution and remaining validation

The bundle ID remains `Parker-Jones.Arch-Graveyard`, with the existing team setting, iPhone/portrait support, version 5.2/build 6, branding, and core research. Remote source inspection found no newer branch or tag than the supplied repository. Apple's public listing reports 5.4; treat that provenance mismatch as a documented release-preparation limitation, not permission to invent a release version.

No valid local code-signing identity or provisioning profile was available during setup checks. Signed distribution, App Store Connect validation, upload, privacy-label edits, and submission remain account-dependent release work; this refactor does not publish the app. Select the account-backed next marketing/build version before any upload.

Remaining physical-device acceptance checks: a canyon walk with precise/reduced accuracy, actual background/foreground tracking and battery behavior, multitouch gallery gestures, compact-device layouts, and end-to-end VoiceOver. The tested gallery handles large text, but the rest of the inherited interface still uses fixed-size typography in many places. Ghost structures 105 and 106 have no tagged map points in the supplied dataset; this refactor does not invent their coordinates. No measured performance improvement is claimed without comparative profiling.

Apple's current upload toolchain minimum is Xcode 26/iOS 26 SDK; this does not require raising the deployment target from iOS 16. Account-dependent release work includes the current age-rating questionnaire and reconciling the listing's old location/analytics declarations with the new binary's actual behavior. Sources: [upload requirements](https://developer.apple.com/news/upcoming-requirements/), [app privacy](https://developer.apple.com/app-store/app-privacy-details/), [required-reason APIs](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype), [location authorization](https://developer.apple.com/documentation/CoreLocation/requesting-authorization-to-use-location-services).

## Release-preparation follow-up

Baseline committed as `881c41d`; subsequent work is on `maintenance/release-preparation`. The production location service now accepts a hardware interface, clock, defaults, bundle and notification center so replay tests can cover actual decision logic without a physical phone. A shared scheme, clearer When In Use wording, checked-in legacy fixtures, and Glur/Zoomable license notices were added. See [RELEASE_PREPARATION.md](RELEASE_PREPARATION.md) for the expanded checks, effective settings audit, current account status and draft release metadata.
