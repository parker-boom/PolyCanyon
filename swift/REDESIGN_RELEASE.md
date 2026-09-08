# Poly Canyon 6.0 — local release preparation

Prepared 8 September 2026 for independent review. No upload, account mutation, live privacy change or submission occurred.

## Identity and distribution

Source version **6.0/build 1** is newer than previously verified live 5.4/build 2. Confirm this pair is unused against complete App Store Connect build history before distribution. Bundle `Parker-Jones.Arch-Graveyard`, automatic signing, team `8AMGSY9U5K`, iPhone portrait, minimum iOS 16 are retained.

Read-only Xcode preferences associate Parker Jones with that paid Individual team, but cached data does not verify current live authentication or membership. `security find-identity -v -p codesigning` returned **0 valid identities** in this pass: certificates/provisioning remain a concrete distribution blocker. An unsigned archive is not uploadable distribution proof. Earlier account verification is documented in RELEASE_PREPARATION.md; it was not repeated live here.

Explicit external Xcode: `/Volumes/SSK Drive/Applications/Xcode.app`, 26.6 (17F113), installed iOS SDK 26.5. This meets Apple's current Xcode/SDK 26 minimum. Updated age-rating questions are required for submission. Content rights, export compliance, availability and legal declarations still need account-owner review. [Apple requirements](https://developer.apple.com/news/upcoming-requirements/)

## Privacy and links

Checked-in manifest declares UserDefaults reason CA92.1, no tracking and no collected data. Preserve the live 5.4 privacy labels during preparation; coordinate Data Not Collected for the new binary at release. Basic guide use remains offline. Optional foreground location is local; website links open external pages. Recheck final binary and rendered policy before submission.

Approved privacy: https://polycanyon.com/privacy. Support: https://polycanyon.com/support. Contact: parker.jones@live.com.

## Draft store copy

**Subtitle:** Explore Cal Poly’s canyon

**Description:** Explore the experimental architecture of Cal Poly’s Poly Canyon. Find structures on the illustrated map, discover their stories through photographs, and take a virtual walkthrough from anywhere.

Bring the guide into the canyon to follow your location and record the structures you visit. Location is optional and used only while the app is active. Maps, photographs, stories, and your visit progress stay available offline.

**What's New:** A new look for Poly Canyon, with a full-screen illustrated map, more room for photography, simpler navigation, and a welcoming way to explore from anywhere. Location stays within the active app, and your existing visit progress stays on your device.

**Review notes:** No account or purchase is required. Tap “Continue” during onboarding. “Explore without location” opens the guide without requesting permission. “Use my location” requests While Using permission; after granting it, “Start exploring” finishes setup. If permission is declined, “Explore the canyon” continues without location. Map, catalog, photographs and virtual walkthrough remain usable without permission. “Your visit” offers “Record visits” and system Settings access when permission is denied. Foreground location shows position and records nearby discoveries; updates stop while inactive/backgrounded. No Always request or background-location capability exists. Visit progress migrates locally. Ghost entries 105/106 are browsable but have no discovery coordinates.

Reconcile copy with the final reviewed UI and binary before submission.

## Captures and verification

Preferred App Store portrait captures: **1320 × 2868**. The 6.9-inch class also accepts 1290 × 2796 and 1260 × 2736. Apple permits 1–10 PNG/JPEG screenshots without alpha. A 6.5-inch set is required only if the 6.9-inch set is absent. Capture genuine functionality without debug overlays. [Apple screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/)

Final handoff must attach final commit, production replay/migration checks, Debug/Release and archive results, simulator/accessibility observations, screenshots, and concrete blockers. No physical iPhone was available; hardware GPS/battery behavior is unverified. Disclose the known unused AppIntents metadata warning if emitted.

## Cleanup and review

Unused legacy list/favorites/mode/settings/onboarding views were removed after checking external type references and confirming no uncommitted edits. Original files remain in git baseline 167b634 and external backups under `/Volumes/SSK Drive/Developer/Redesign/Source-backups`. The Color(hex:) helper remains harmlessly unused; the old progress renderer is removed. Models, stored favorites fields, migration and discovery algorithms were not changed by this cleanup.

No skill named “code” was found. `/Users/parkerjones/.codex/skills/.system/review-agent/SKILL.md` exists and was read. Its review must be read-only, cover the complete diff plus relevant callers/tests, report demonstrated actionable regressions with precise changed-line locations and severity, and state material test gaps. It prohibits modifications/commits/pushes/redelegation during review. With no qualifying defects, report “No findings.” The parent reports that independent code review found one P2 map zoom-retention issue, subsequently corrected, followed by visual review fixes.

### Live Xcode account inspection

The Accounts UI was subsequently inspected read-only: Parker Jones Developer Team, Certificates/Identifiers/Profiles selected, **9 Provisioned Devices**. Manage Certificates opened normally with an **empty certificate table**, without an authentication or agreement error. It was closed without creating certificates or downloading profiles. The next concrete step is obtaining a usable signing identity with its private key on this Mac (import an existing identity or authorize creation through Manage Certificates), followed by automatic provisioning and signed archive validation. This evidence does not establish an absent-device blocker or independently confirm online membership renewal. No certificate/account mutation occurred.

### Integrated preparation checks

The existing `/Volumes/SSK Drive/Developer/Redesign-model-checks.log` reports passing catalog merge/duplicate IDs/atomic round trip/corruption preservation, bundled decode and ghost persistence, reset rollback/legacy migration/future-schema protection, store visit/day-count/search/invalid-location checks, and foreground-only replay. Replay covers all 231 map points and 35 discoverable structures, untagged trails, notification/save integration and relaunch. Ghosts 105/106 remain without tagged coordinates. Final unchanged-core checks and subsequent successful builds are recorded below.

Seven more dead legacy map/control/progress files were removed after reference checks, clean-baseline verification and local backup. Discovery/awards code in DataStore was untouched.

### Final verification — 8 September 2026

| Check | Result | Evidence |
| --- | --- | --- |
| Catalog integrity | PASS: 31 structures, 6 ghosts, 231 points, all iOS image references; no identity differences | `/Volumes/SSK Drive/Developer/Redesign/Logs/final-data-checks.log` |
| Production models, migration/store and location replay | PASS, including all 231 points and 35 discoverable structures | `/Volumes/SSK Drive/Developer/Redesign/Logs/final-model-checks.log` |
| Latest Debug | PASS at 02:31 local with approved copy refinements | `/Volumes/SSK Drive/Developer/Redesign/Logs/copy-debug.log` |
| Final Release simulator | PASS at 02:32 local, including approved copy refinements | `/Volumes/SSK Drive/Developer/Redesign/Logs/copy-release.log` |
| Final unsigned Release device archive | PASS at 02:32 local, including approved copy refinements | `/Volumes/SSK Drive/Developer/Redesign/Logs/copy-archive.log` |
| Signing probe | FAILED: no matching iOS App Development profile for Parker-Jones.Arch-Graveyard; provisioning updates deliberately not allowed | `/Volumes/SSK Drive/Developer/Redesign-signed-check.log`, line 53 |

Final archive: `/Volumes/SSK Drive/Developer/Redesign/Archives/PolyCanyon-6.0-1-copy-final.xcarchive`. Both final Release commands explicitly selected external Xcode, external `DerivedData/Release`, external pinned `Packages/PolyCanyon`, and `CODE_SIGNING_ALLOWED=NO`; no provisioning updates or upload occurred. The only warning in each successful final Release log is skipped AppIntents metadata extraction because no AppIntents.framework dependency exists. No zero-warning claim is made.

The final archive was inspected directly: arm64 executable; version 6.0/build 1; bundle Parker-Jones.Arch-Graveyard; iOS 16 minimum; iPhone family/portrait; AppIcon/Assets.car; structuresList.json, ghostStructures.json and mapPoints.json; all three MIT notices; CA92.1/no-collection/no-tracking privacy manifest. The location prompt says the app shows map position and marks structures while open. No UIBackgroundModes or Always usage-description key exists. Project team is 8AMGSY9U5K in both configurations. `codesign -dv` confirms the app is not signed; no embedded provisioning profile exists. This is intentionally an unsigned review archive, not a distributable artifact.

The earlier failed Release attempt (`final-release-simulator.log`, lines 737–752) is historical: Apple's asset compiler exhausted internal CoreSimulator scratch despite external DerivedData. The parent/coordinator subsequently recovered storage with authorized cleanup and controlled simulator repair. No storage cleanup was performed by this audit. Final archive completion left approximately 3.3 GiB internally. The earlier failure/cleanup warnings do not apply to the successful retry but remain preserved in its separate log.

Current status: **candidate for independent review; not distributable**. Final simulator interaction/capture signoff remains with the parent. Signing identity/provisioning and signed archive validation remain unresolved. Physical GPS/battery validation remains unavailable. Live privacy, legal declarations, store metadata and release remain unchanged.
