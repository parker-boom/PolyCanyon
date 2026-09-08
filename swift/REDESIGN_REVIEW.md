# Poly Canyon 6.0 final verification handoff

App source is committed as `76dde70` on `redesign/visual-ios`. Later commits update verification documentation only. The coordinator accepted the visual direction and final copy. Independent read-only source review reported **No findings**. No source change was needed during the final simulator checks.

## Current verification result

- Debug, Release simulator, and unsigned device archive passed after the final copy edits; only the known AppIntents metadata warning. See `REDESIGN_RELEASE.md` for exact logs/archive.
- Production data/model/migration/location replay passed: 31 structures, 6 historical structures, 231 map points, 35 discoverable structures. Core discovery thresholds, tags, awards, research JSON and stored identities are unchanged.
- Final compact fallback on iPhone SE/iOS18.2 passed: optional-location onboarding; map-to-story navigation; readable solid native header and Close; gallery photo1→2; gallery→story→map dismissal.
- Two actual fresh installs on disposable iPhone17ProMax/iOS26.5 were recorded. Each showed its own native When In Use permission prompt and grant, directly authorized by Parker. Canyon coordinates produced the canyon recommendation, real Entry Arch discovery, visited catalog state and Your visit=1/recording ON. A separate uninstall/reinstall with public Seattle coordinates produced the remote recommendation, full map/tour/story/photo/search browsing, and Your visit=0/recording OFF.
- Canyon visit count and walkthrough selection survived process relaunch. Additional lifecycle check: with recording enabled, the app was visibly on the Home screen while a synthetic canyon fix was delivered; no progress file had been created while backgrounded. After foregrounding and a new fix, Entry Arch was discovered and count became1.
- System appearance was switched to dark through Simulator and confirmed as `dark` via read-only `simctl ui appearance`. The app consistently remained light, with readable selected tabs, hero status/navigation and settings. Gallery retained its intentional black canvas/white controls. System appearance was restored to light. Baseline/current `PCContainerView` intentionally force light; no partial dark support was introduced.
- Final native screenshots were visually inspected at1320×2868. JPEG exports have no alpha and leave app content unchanged. Raw PNG captures are retained as evidence.

## Limits

No physical iPhone/GPS/battery field test was available. Automated scroll/drag gestures were unreliable (including `noWindowsAvailable`/image dragging), so no new successful swipe or full catalog-scroll validation is claimed. Prior largest-text and reduced-motion/transparency observations are listed in the historical record below; no full VoiceOver certification is claimed. Simulator control intermittently returned ScreenCaptureKit capture errors; reconnecting restored control, and raw recordings were checked for actual content/integrity. These tool pauses are trimmed from the final edit.

Signing remains unresolved: this Mac needs a valid signing identity/private key and matching profile. The archive is unsigned and not distributable. No push, upload or release occurred.

## Final media

External folder: `/Volumes/SSK Drive/Developer/Redesign/Media/`.

- `canyon-journey-raw.mov`: actual first installation,197.172seconds,1320×2868,H.264,silent; end frame/container integrity verified.
- `washington-journey-raw.mov`: independent fresh installation,185.093seconds,1320×2868; playable.
- `AppStore/01-map.jpg`, `02-structures.jpg`, `03-shell-house.jpg`, `04-walkthrough.jpg`, `05-your-visit.jpg`, `06-onboarding.jpg`, `07-recorded-visit.jpg`: final capture set. The welcome image is an untouched frame from the actual fresh-install recording. The recorded-visit still comes from the separate final lifecycle check.
- `poly-canyon-two-journeys-2x.mp4`:121.55seconds,1320×2868,H.264,30fps,silent. Actual UI footage plays at2×; external scenario cards identify simulated Poly Canyon and Washington locations. Tool pauses and unsuccessful drag attempts are cut; app content is not altered. Both raw files and the adjacent provenance JSON retain source ranges. Native screenshots and output journey/title/ending frames were independently inspected. This is simulator demonstration footage, not physical field testing.

## Storage resolution

Parker directly approved removal of the unused iOS18.6 runtime after automatic review requested exact authorization. Supported deletion of runtime disk ID`7049879A-24AA-46AB-BAD0-BAD3BE40E265` succeeded;18.2 and26.5 remain. All saved18.6 device data remain, but those devices need the runtime reinstalled to launch. Free internal space recovered to8.5GiB (about7.2GiB after capture work). No manual runtime/cache directory deletion or further simulator relocation occurred. Obsolete task-created SE18.6 was separately deleted with coordinator authorization; original user devices/saves were not reset.

---

# Historical review and environment record


The redesign uses the illustrated map as a continuous canvas, photographs as the catalog and story surfaces, and native navigation above them. Custom Liquid Glass is restricted to walkthrough controls on iOS 26; older systems use regular material. Reduce Transparency uses opaque controls. The walkthrough title retains restrained gradient blur, disabled with Reduce Transparency. There is no favorites UI, list mode, mode picker, reset-likes control, CAD logo, or credits dashboard. Stored favorites remain inert for safe decoding.

## Visual and interaction review

Reviewed in the running app on iPhone 17 Pro / iOS 26.5 and a task-created iPhone SE / iOS 18.6:

- Fresh compact onboarding, optional location explanation, actual permission denial, and immediate usable map afterward.
- Map overview, map-to-story entry, story dismissal, native tab navigation, photographs and full offline research.
- Catalog search by name; on-screen keyboard and result selection; Shell House and Entry Arch stories; bundled license text.
- Gallery page controls, disabled first-page previous control, full-screen dismissal, double-tap zoom and return to fit. Automated drag/swipe did not reliably produce a page change; physical multitouch is unavailable and no successful swipe validation is claimed.
- Largest accessibility text on the compact story and gallery: content scrolls and close/page controls remain reachable. The legacy photo-under-navigation experiment exposed low-contrast close controls and was replaced by standard solid navigation on iOS 16–25. That final fallback compiles; its compact rerun remains pending the permission review below.
- Reduce Motion, Reduce Transparency, and Increase Contrast enabled through simulator Settings on iOS 26.5; map and walkthrough reviewed with those settings. The walkthrough marker is static with Reduce Motion, controls are opaque with Reduce Transparency, and text stays readable.
- Walkthrough next-stop map recentering reviewed; restored walkthrough position after relaunch observed. Independent read-only code review identified retained zoom state across stops; the final map uses structure identity and explicit recentering.
- Accessibility labels inspected for structure numbers/names, photo count, prior/next, close, and navigation. No claim of a complete VoiceOver or physical-device certification.

The production model/migration/location replay covers all 231 real map points and all 35 discoverable structures, foreground/inactive/background transitions, permission changes, invalid fixes, virtual mode, notifications, save failures, migration, and relaunch. No location thresholds, tags, awards, or research JSON changed. Ghosts 105/106 still have no tagged discovery coordinates.

## Review captures

Development screenshots, not final App Store assets:

`/Volumes/SSK Drive/Developer/Redesign/Review/`

- `01-walkthrough.png`
- `02-map.png`
- `03-structures.png`
- `04-shell-house.png`
- `05-your-visit.png`
- `compact-permission.png`
- `06-onboarding-welcome.png` (before final copy refinement)
- `v2-structures.png`
- `v2-entry-arch.png`
- `v2-walkthrough.png`
- `v3-your-visit.png` (final simplified copy)

The first five are genuine 1206×2622 iPhone 17 Pro captures. Final store-size captures and the approved two-scenario 2x walkthrough are pending final copy review and direct permission approval. No fake functionality or physical field-test claims.

## Environment incident and verified repair

Only the task-created disposable simulator is affected. Existing simulator saves and permission state were not reset.

- UDID: `94C94200-5FC4-4784-9443-8F6D3146B45F`
- Name/type: `iPhone SE Poly Canyon Review`, iPhone SE (3rd generation), iOS 18.6.
- During the incident the default path was a symlink: `/Users/parkerjones/Library/Developer/CoreSimulator/Devices/94C94200-5FC4-4784-9443-8F6D3146B45F`.
- Target: `/Volumes/SSK Drive/Developer/Redesign/Simulators/94C94200-5FC4-4784-9443-8F6D3146B45F`.
- This task moved its shutdown directory after an install failed with only 234 MiB internal free. The coordinator's pause arrived while the move was running; it completed before cancellation. No other device was moved. It has not been booted from the symlink.
- Supported `simctl delete` was then attempted under coordinator direction. It failed with NSCocoaErrorDomain 513 / EPERM while writing a `Deleting-…` marker in the external directory. This attempt did not complete cleanup; the verified recovery below subsequently resolved it. No manual recursive deletion was performed.
- The device was initially frozen pending controlled recovery. It contains only disposable test state (fresh onboarding/pending permission), not user progress. The completed permission capture is already external.
- Direct simulator screenshot writes to external storage also returned NSCocoaErrorDomain 513. Coordinator authorized unique system-temp staging, then moving verified captures externally. This workflow works.
- An earlier Release simulator build exhausted internal Apple asset-compiler/CoreSimulator scratch storage despite external DerivedData. After recovery, Release simulator and fresh unsigned device archive both passed. See REDESIGN_RELEASE.md for current logs; signing remains unresolved.

## Remaining release work

Parker explicitly approved the simulator When In Use action after automatic approval review rejected it. The two fresh synthetic-location scenarios must resume on a safely working disposable simulator; do not reuse/reset existing user saves. Final footage is gated on coordinator approval. Signing needs an available certificate/private key and matching provisioning profile; no credentials, profiles, live privacy labels, uploads, or release were changed.


### Recovery completed

After coordinator-authorized storage relief, the external backup was copied to a separate internal staging directory. All 7,639 regular files were SHA256-verified and symlink targets compared. Only the verified default symlink was replaced with the restored directory. Supported `simctl delete` then succeeded, and a new clean default-set iPhone SE Poly Canyon Review was created with UDID `B50C0E32-2F25-491B-95D4-6556BFFE0559`. It booted and launched normally. The external backup remains preserved; no device-directory symlink remains. Existing devices/saves were not reset. The original 17 Pro's Reduce Motion, Reduce Transparency, and Increase Contrast settings were restored to off after review; status override was cleared.

Parker's affirmative permission authorization relayed from the coordinating task was again rejected as tool-history rather than direct user approval. A direct approval question is pending in this task. The new disposable simulator is at the actual When In Use prompt with synthetic Entry Arch coordinates; no permission grant has been bypassed.

### Coordinator visual iteration

The catalog now uses one consistent two-column photographic grid, with one column only at accessibility text sizes; no view-mode toggle. Removed the catalog slogan and replaced the tall header with inline native navigation and visible search. Hero pages now include a fixed light status-bar scrim on iOS26 to keep black status content readable across photographs. Walkthrough marker scale is compensated for the map's enlargement, and Reduce Motion changes reset the pulse while mounted. The original map asset was inspected: structure17 really is its northern edge, with1 at the south; no arbitrary middle scroll was shown. Map options include Reset zoom.

### Final review and scoped copy refinement

Independent read-only review of the integrated diff and v2 captures reported **No findings**. The coordinator accepted the grid, hero contrast and visual direction, then requested direct onboarding copy and shorter settings explanations. Final captures must reflect that refinement. Production data, model/migration/replay checks remain passing; no core or catalog changes were made.

The final copy refinement is implemented: welcome uses “Explore Poly Canyon”, the direct offline explanation and “Continue”; settings keeps a short recording/privacy footer and modest links. Debug, Release simulator, and unsigned archive passed after those edits. `v3-your-visit.png` verifies denied permission leaves recording off with the explicit Settings action. The compact welcome is updated but obscured by the retained system prompt; relaunch did not dismiss it. Direct approval is still pending, and no substitute footage or permission bypass was used.

### Appearance and compact follow-up

The coordinator accepted `v3-your-visit.png` and approved the existing map plus v2 catalog/story/walkthrough stills for website use. No distribution or upload was authorized.

Both baseline and current `Routing/PCContainerView.swift:16` force light appearance for the app. `StructureGallery.swift` intentionally presents a dark gallery with white controls on black. The story scrim therefore belongs to the light presentation. No partial dark-mode support was added; source remains identical to the validated app commit. Actual behavior under system-dark settings is not newly verified, because computer use reported the Mac locked before that check.

For the remaining compact fallback check, the pending-permission task-created iOS18.6 simulator was shut down with its data preserved. The existing iPhone SE (3rd generation), iOS18.2, `CD9C41A1-FFD1-4197-B6BE-2F2130B35DDB`, booted successfully, received the final Debug app, and launched successfully. It was not erased or reset. This verifies installation/launch only: the final legacy navigation appearance, dismissal, and compact accessibility interaction were not rechecked because the Mac locked. Prior compact observations above remain prior-version evidence. No alternate UI-control route or permission workaround was used.

The requested interaction promo and near/far permission journeys are incomplete. Approved stills are useful independent website media; no slideshow is being represented as an interaction walkthrough. The unlock request and direct permission question remain pending without repeated requests. Signing/provisioning and final App Store-size captures also remain outstanding.

### Resumed live verification

Parker directly authorized both simulator When In Use grants in this task. The prior permission-approval gate is resolved. No grant has yet been performed in the new journey simulator.

On the final app, existing SE/iOS18.2 verified: optional-location onboarding, map-to-Shell-House entry, readable solid native story header and close control, dark gallery with white controls, photo1→2, gallery dismissal to story, and story dismissal to map. Evidence: `Review/compact-final-story.png`. Automated coordinate scroll calls returned `noWindowsAvailable`; no new scroll/swipe success is claimed.

After exact identity verification, the coordinator authorized supported deletion of obsolete task-created SE18.6 `B50C0E32-2F25-491B-95D4-6556BFFE0559`; deletion succeeded and recovered approximately3GiB. Existing user devices and saves were preserved. New disposable iPhone17ProMax/iOS26.5 `EDC62B4C-7EB2-41B4-B997-7660D21504C7` was created, booted, freshly installed and launched with synthetic Entry Arch coordinates. Initializing that device exhausted internal headroom again. First recording failed to create a file (NSURLErrorDomain -3000); no video file existed. A UI screenshot also failed image-destination creation. Capture attempts stopped and the new device was shut down. It retains fresh onboarding state. Further recording awaits safe storage recovery, not permission approval.
