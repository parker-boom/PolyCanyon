# Final combined review candidate

## Current validated source: Glur removed

Exact source commit: **`8155917468c1a1a8154b59808018bc82d9270d99`**, on `maintenance/security-lts`, following combined merge `ab69240808406b2af7a9b4fad060111910d1625b`. Subsequent report-only commits do not change this validated app source.

Glur had no Swift imports or calls after the final UI pass. Removed its framework build entry, target product dependency, remote package reference/product object and resolved pin. Xcode regenerated `Package.resolved`; the only package is Zoomable at unchanged revision `27463744a1c82e550959703153bd6f3c62fef906`, still an exact project requirement. Its historical `branch: main` resolution metadata does not change that revision requirement. Existing Glur license/credit remains as historical attribution. No UI, source assets or other dependency was changed.

**Incremental unsigned Release archive: PASS.** Archive inspection confirms no Glur resource bundle, Metal library or Glur Swift symbols. Version remains 6.0 (1), foreground-only permission, with no Android archive, legacy Firebase/signing files or scoped credential-pattern matches. Only warning: skipped AppIntents metadata extraction (no AppIntents framework dependency). Package resolution and diff checks passed.

- Current archive: `/Volumes/SSK Drive/Developer/SecurityLTS/Archives/PolyCanyon-integrated-no-glur.xcarchive`.
- Resolution log: `/Volumes/SSK Drive/Developer/SecurityLTS-without-glur-resolve.log`.
- Release/archive log: `/Volumes/SSK Drive/Developer/SecurityLTS-without-glur-archive.log`.

All temporary/cache/build paths stayed external. The prior passing data/model/preservation checks below remain applicable: none of their inputs changed, so identical checks were not repeated. No push, publishing, signing or account action occurred.

## Combined source before dependency removal

8 September 2026. Final source for this round combines:

- Security cleanup: `4262b50be81772d2c57937a7848780af30a69a00`.
- Initial combined merge: `b31dc149989c8c60a5ab00d0d30ac947a6c9fe66` (app source `82114edbf1032af756fb3a7fbd73fb62168de7f1`).
- Final coordinator-selected app source: **`8b2f9eb415ddccaa67f3d2bf424a108b8b939f1b`** — remote onboarding action and accessible Tour locator fixes.

Both merges were conflict-free in `/Volumes/SSK Drive/Projects/PolyCanyon-security-lts`, branch `maintenance/security-lts`. All incoming app files match upstream byte for byte. Android cleanup, original assets and the 166-file archive remain intact. The app checkout was never edited or switched. Recovery tag `archive/android-before-retirement-20260908` remains at `80e12df9fca6b44b688ff27581cdc16442253264`.

## Pre-removal combined verification

- **Data/preservation: PASS.** 31 structures, six historical structures, 231 map points, all iOS image references, and all 166 archived files' original SHA-256 checksums.
- **Existing model/store/location checks: PASS.** Persistence/migration, reset/save failure paths and foreground-only replay including all 35 discoverable structures. Historical structures 105/106 still lack discovery coordinates; none were invented.
- **Release device archive: PASS**, unsigned, Xcode 26.6 / iOS 26.5 SDK, `generic/platform=iOS`, `CODE_SIGNING_ALLOWED=NO`. The archive contains the final merged 8b2f9eb app source plus cleanup.
- **Archive inspection: PASS.** Version 6.0 (1); When In Use location only; no background or Always keys, Android archive, Firebase configuration, signing containers, npm manifests or provisioning profile. A scoped credential-pattern scan of app-bundle files found no matches; this is not an exhaustive secret-detection guarantee.
- **Diff check: PASS.** No whitespace errors. Cleanup/archive files unchanged from 4262b50; final app changes preserved exactly.

Only archive warning: AppIntents metadata extraction skipped because the app has no AppIntents framework dependency. No build errors. Archive payload: 643,998,147 bytes (not an App Store download-size estimate).

All final temporary files, package caches, source packages, DerivedData and archive outputs were explicitly directed to `/Volumes/SSK Drive/Developer/SecurityLTS`. No simulator was created, booted, installed to or controlled; no storage cleanup/deletion was performed.

## Preserved pre-removal artifacts and logs

- Archive: `/Volumes/SSK Drive/Developer/SecurityLTS/Archives/PolyCanyon-integrated-8b2f9eb.xcarchive`.
- Data: `/Volumes/SSK Drive/Developer/SecurityLTS-final-8b2f9eb-data.log`.
- Models/location: `/Volumes/SSK Drive/Developer/SecurityLTS-final-8b2f9eb-checks.log`.
- Release/archive: `/Volumes/SSK Drive/Developer/SecurityLTS-final-8b2f9eb-archive.log`.

Prior b31dc14 combined Debug build, models and data also passed. Their logs remain `/Volumes/SSK Drive/Developer/SecurityLTS-integration-{build,checks,data}.log`. That Debug evidence predates 8b2f9eb; the final source is verified by the new Release archive and regression checks above. No identical extra build was repeated.

## Remaining boundaries

[Second-pass evidence](swift/SECOND_PASS_REVIEW.md) records the app task's visual verification and remaining hands-on gesture/VoiceOver checks. This task adds integration/build validation, not physical GPS testing, signing, release approval or new visual claims. No push, publication, account changes or remote alert updates occurred.

[Security cleanup](SECURITY_CLEANUP.md) records the earlier 4262b50 audit. Its statement that both Swift packages were actively used predates this UI merge: the new Tour removes the last Glur import/call, while the project still retains Glur. The authorized follow-up above removes Glur coherently; this review item is closed. Zoomable remains used.

Historical Android signing exposure, old-client/backend review and eventual default-branch alert refresh remain separate owner actions. The final combined branch is a review candidate for the coordinator.
