# Release preparation — 8 September 2026

> Historical review/release evidence. Some feature proposals, favorites references, version details and build paths below predate the current foreground-only, no-favorites app. Preserve this record; use [REDESIGN_RELEASE.md](REDESIGN_RELEASE.md) for the current release handoff and [SECURITY_CLEANUP.md](../SECURITY_CLEANUP.md) for Android retirement.

Local preparation only. No push, upload, App Store metadata changes or submission occurred. The refactor baseline is commit `881c41d` on `maintenance/revive-ios`; subsequent preparation is on `maintenance/release-preparation`.

## Approved scope: location only while using the app

Parker approved removing background location entirely. The app stops GPS whenever its scene becomes inactive or backgrounded and resumes the selected mode with current permission on return. It never requests Always authorization and has no location background capability. Existing Always-authorized installations remain usable without a Settings change, but receive the same foreground-only behavior.

The useful nearby/permission-based Adventure versus Virtual recommendation is preserved. The extra Always/follow-up onboarding page is removed; Welcome → Location → Mode Selection → Finish remains. Discovery algorithms, map tags/coordinates, completion behavior, accuracy settings and distance filters are unchanged, as explicitly requested after Parker's field testing. The earlier [three-year review](THREE_YEAR_REVIEW.md) is historical; its discovery-radius and session-mode redesign proposals are superseded and are not release blockers.

## Confidence from existing data

Run `bash swift/scripts/check-models.sh`. Three executables check production models/persistence, store/settings, and the location service. The replay replaces only location hardware and supplies a clock, isolated notification center, temporary save directory and the actual bundled JSON. It exercises the same permission, lifecycle, geometry, throttle, notification and save decisions used by the app.

The replay covers all 231 map points; every tagged coordinate resolves to its own structure, untagged trail points award nothing, and all 35 discoverable structures persist across relaunch. Scenarios include denied/restricted/When In Use/Always authorization; onboarding without awarding visits; virtual mode and late callbacks; stale, future, invalid and inaccurate fixes; throttling; no updates or visit awards while inactive/backgrounded, including near the canyon; permission changes while away; foreground restart; stale-dot clearing; failed GPS saves; alert suppression and retry. Store tests additionally cover failed full reset, day counting, future-schema protection and migration from checked-in legacy-format fixtures. Fixtures use actual catalog content with synthetic progress, not private user saves.

The macOS replay compiler disables availability checking only for the replay executable so it can represent the iOS-only When In Use enum; its fake manager never calls OS location hardware. Normal iOS Debug/Release builds retain SDK availability checks. These are command-line checks, not an XCTest target; Xcode's Test action does not run them.

Earlier iOS 18.6/26.5 simulator checks cover onboarding, navigation, galleries, permission revocation and persistence. Replay establishes deterministic application behavior, not radio/GPS accuracy, OS suspension delivery, battery consumption, real reduced-accuracy behavior or physical multitouch. Physical testing is unavailable; those remain explicitly unverified, not a reason to repeat simulator testing indefinitely. Ghosts 105/106 have no tagged map points and cannot be awarded through the supplied map data.

## Xcode configuration audit

Inspected project settings, resolved Release build settings, source, dependencies and generated app/archive contents. Effective settings are saved locally in `/Volumes/SSK Drive/Developer/PolyCanyon-release-settings.json`.

| Area | Actual configuration / decision |
| --- | --- |
| Identity | Display name Poly Canyon; bundle `Parker-Jones.Arch-Graveyard`; preserve the existing app identity. |
| Versions | Source 5.2, build 6. The setup task verified App Store Connect app 6499063781: 5.4, build 2, Ready for Distribution. The checkout is therefore older than the live marketing version. Select a later marketing version and confirm an unused build against the complete build history before signing the release; this pass leaves the source numbers unchanged. |
| Signing | Automatic; team `8AMGSY9U5K`; Apple Development identity; no pinned profile or custom entitlements file. Development identity is normal before Organizer distribution signing; do not replace it with a guessed distribution certificate. |
| Platforms | iPhone, portrait, iOS 16 minimum; iOS/iOS Simulator SDKs; no Catalyst. Default Designed for iPhone compatibility flags for Mac/Vision remain enabled. They do not establish tested support or confirm live store availability; inspect those availability pages before a release decision. |
| Release | Swift 5, complete concurrency checks, optimized whole-module compilation, dSYM symbols, product validation, no DEBUG condition, no testability. Effective previews are off in Release. |
| Scheme | Shared Poly Canyon scheme: Debug launch/analyze; Release profile/archive. No launch arguments, simulated location file or private user scheme required. |
| Info.plist | Generated standard keys plus `Poly-Canyon-Info.plist`; no UIBackgroundModes or Always-location usage descriptions. Generated launch screen/scene manifest. No ATS exceptions or unrelated sensitive permission keys. |
| Location prompts | When In Use only: “While Poly Canyon is open, your location shows where you are on the map and marks structures you visit.” Virtual browsing works without permission. No Always request or background-tracking copy remains. |
| Icon/assets | Existing AppIcon and AccentColor; iPhone icon slots and 1024-pixel marketing icon supplied. No iPad product support implied by unused catalog slots. Research, map and photo references are bundled for offline use. |
| Dependencies | Glur 1.1.0, Zoomable revision `27463744a1c82e550959703153bd6f3c62fef906`; resolved lockfile shared. Firebase/Shimmer removed; Shiny replaced by local code. All three applicable MIT notices bundled under Core/Licenses. |
| Privacy | Manifest declares UserDefaults reason CA92.1, no tracking or collected data. App and pinned library source audit found no networking/upload client, analytics or advertising integration. Coordinates are used locally; save files contain visit/favorite state, not a GPS trail. |
| Export compliance | No app encryption implementation or network client found; `ITSAppUsesNonExemptEncryption` remains unset. Account owner must confirm the export answers for the final signed binary before making that declaration. |
| Support | In-app contact now opens `parker.jones@live.com`, as approved by Parker. The setup task verified App Store support URL https://polycanyon.com/support, marketing URL https://polycanyon.com/download, and privacy URL https://bit.ly/3xJY4VQ. Their content/reachability remains unverified here: the browser fetch could not open support/privacy, and download exposed only a JavaScript shell. |

The privacy manifest is a binary declaration, not a replacement for the App Store privacy questionnaire. Based on this binary's source, “Data Not Collected” is the proposed answer; review the pinned SDKs and any release changes before updating the account. Apple defines collection in relation to data transmitted off-device. [Apple privacy guidance](https://developer.apple.com/app-store/app-privacy-details/).

## Account-dependent steps — no publication

The setup task verified Parker Jones, team `8AMGSY9U5K`, active membership (renewal 9 August 2027), and the Program License Agreement accepted on 8 September 2026. The earlier “PLA Update available” blocker is resolved. The setup task reopened Manage Certificates successfully: the error is gone, the certificate table is empty, and no certificates were created. A Paid Apps agreement-expired banner also appeared, but this audit does not establish it as a blocker for this free app. New social-media age-rating questions remain to review.

1. In Xcode → Settings → Apple Accounts, refresh the existing team after the agreement update. Any new agreement or legal declaration remains the authorized account holder's decision.
2. In Xcode → Settings → Apple Accounts → Parker Jones → team → Manage Certificates, refresh and confirm signing certificates after the agreement is resolved. Do not revoke existing certificates. In the project navigator, select the blue Poly Canyon project → TARGETS Poly Canyon → Signing & Capabilities. Confirm Automatic signing and the existing team/bundle identity. A lack of registered test devices can block development provisioning; it does not mean a physical iPhone is required to prepare App Store distribution.
3. In App Store Connect → Apps → Poly Canyon (6499063781), confirm the already-observed 5.4/build 2 version and inspect the complete TestFlight build history. Then set the chosen Version and unique Build in Xcode target → General → Identity. Do not create a second app record or invent a replacement bundle ID.
4. In Product → Scheme → Edit Scheme → Archive, confirm Release. Select Any iOS Device (arm64), then Product → Archive. Window → Organizer → Archives shows the result. The current local archive is unsigned and is not an uploadable distribution artifact. Signed archive validation still depends on certificates, provisioning and Apple services. Stop before any upload/distribution action under the current no-publication instruction. [Apple archive guidance](https://help.apple.com/xcode/mac/current/en.lproj/devf37a1db04.html), [signing workflow](https://help.apple.com/xcode/mac/current/en.lproj/dev60b6fbbc7.html).
5. Review App Store Connect fields separately: General → App Information (name/subtitle/category/age rating), App Privacy (questionnaire/privacy policy URL), the iOS version page (description, keywords, support URL, screenshots, What's New, review contact/notes and build), Pricing and Availability (including Mac/Vision availability), and export compliance. These values are not controlled by Xcode's display name, category or privacy manifest. [Apple app-information reference](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information), [export compliance](https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance/).

## Live metadata differences

The setup task verified the current subtitle as “Explore like never before!”, primary/secondary categories Navigation/Education, age rating 4+, standard Apple EULA and DSA non-trader status. The content-rights answer currently says the app does not contain, show or access third-party content. Review that answer against the actual research and photo provenance before release; this audit does not establish ownership or authorize changing a legal declaration. The current age rating is an observed listing value, not a replacement for answering the new questionnaire.

A proposed next release is **5.5, build 1**, subject to checking all uploaded versions/builds in TestFlight for availability. It is a proposal only; source version/build remain 5.2/6 until that check is complete.

The setup task read the current What's New as “- Design village schedule fix”; it must be replaced for the next version. Existing review notes reference a prior location-button rejection and discuss Continue, virtual tour and no notifications. The revised review notes below explain the current flow. The old version uses automatic release; a future version's release option should be reviewed explicitly before submission.

Current App Privacy declares precise location, not linked to identity, used for Analytics and Other Purposes. That conflicts with the refactored source's local-only behavior. App Store Connect warns that non-policy privacy changes become publicly available immediately, so **leave live privacy unchanged during this preparation** and coordinate any correction with the actual release. The existing privacy policy content also needs review before asserting it matches the new binary.

## Approved metadata for the upcoming version

Parker approved the website privacy policy `https://polycanyon.com/privacy`, the website support/contact page for Support URL (retain `https://polycanyon.com/support`), and removal of location-collection declarations for the new binary. Prepare App Privacy as **Data Not Collected**, with no location category declared as collected. Coordinate those live changes with the new release; do not replace the labels describing still-published 5.4 during this preparation. The approved privacy URL replaces the old bit.ly policy URL. The text-only web fetch exposed a JavaScript shell for `/privacy`; it did not verify the rendered policy content. Support/contact content also remains unverified by that fetch.

On-device location remains required for Adventure Mode's map position and visit detection while the app is active. Keep only the When In Use prompt; all background capability and Always-request code is removed. “Data Not Collected” describes the absence of developer/third-party off-device collection, not the absence of on-device GPS use.

Rechecked the archived Release binary's linked libraries and undefined symbols, the app source and the pinned Glur/Zoomable source: no Firebase, analytics SDK, telemetry URL/client or networking calls found. The binary links only Apple/system frameworks; the UI libraries are statically included. This is source/binary evidence, not packet-capture certification of operating-system services. The release archive contains the no-collection privacy manifest and no Firebase configuration/resource.

## Proposed store copy — draft, not submitted

**Subtitle:** Explore Cal Poly's canyon

**Description:** Explore the experimental architecture of Cal Poly's Poly Canyon. Browse the illustrated map, read the stories behind 31 structures and six historical ghost structures, and view photos on your own time. Take a virtual tour from anywhere, or use Adventure Mode while the app is open during a canyon visit to mark discoveries. Save favorites and keep your visit progress on your device. The map, stories and photos are available offline.

**What's New:** A simpler Poly Canyon experience, focused on the canyon. This update removes Rate Structures and the past Design Village event, improves progress saving and recovery, keeps location use inside the active app, and adds easier photo navigation.

**Review notes:** No sign-in or purchase is required. Location is optional for virtual browsing; Adventure Mode uses location to mark visits in the canyon only while the app is active. Location updates stop when the app is inactive, locked or backgrounded. The app never asks for Always permission; existing Always grants are accepted without enabling background tracking. Data stays on the device. Ghost entries 105/106 can be browsed but have no discovery points in the supplied map. This update removes a past event and the rating deck; existing favorites and visit progress migrate locally.

Confirm support/privacy URLs, contact details, content rights, screenshots, age-rating responses and the final version before submitting anything. Do not claim completed VoiceOver, large-text, Mac/Vision, GPS or battery certification from this pass.

## Verification history and current checks

Earlier commits passed Debug/Release builds, unsigned archives and simulator migration/gallery checks. Background-visit tests in those historical logs describe the removed implementation and are no longer acceptance criteria.

Current production replay checks pass inactive/background stop, foreground restart, denied permission on return, existing Always grants, virtual mode, stale/inaccurate fixes, failed saves, migration and relaunch. All 231 map points and 35 discoverable structures retain their prior behavior. Debug and Release simulator builds and the final unsigned archive passed. Archive: `/Volumes/SSK Drive/Developer/Archives/PolyCanyon-foreground-20260908.xcarchive`. Its generated Info.plist has neither UIBackgroundModes nor an Always usage-description key. Binary inspection found no Always request or background-location setter; the approved support email remains.

On iOS 18.6, the actual OS While Using prompt displayed the new in-app wording; a nearby fix still recommended Adventure; Mode Selection advanced directly to Finish without another permission page. A new nearby structure-2 visit was ignored while backgrounded and recorded after foreground return. Permission denial routed automatically to Virtual; manual Adventure/Virtual switching, browsing, detail, gallery, settings and guided tour remained usable. The iOS 26.5 preview was updated to the final Debug build. No discovery or content changes were made.

Logs: `/Volumes/SSK Drive/Developer/PolyCanyon-foreground-{checks,debug,release,archive}.log`. Only warning: Xcode skipped AppIntents metadata extraction because the app has no AppIntents framework dependency. Current simulator screenshots are `/tmp/polycanyon-{mode,map,browse,detail,gallery,settings,tour}-foreground.png`; temporary paths may expire. Earlier screenshot/log files can show obsolete background behavior. Physical GPS/battery behavior remains unproven; no physical device is required to run this suite.
