# Poly Canyon 6.0 design review candidate

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
