# Third design pass — active review, not approved

Integrated baseline: `55a9a50` (app source `8155917`, UI `8b2f9eb`). Android retirement and Glur dependency removal remain inherited. This is a local design branch; no discovery algorithm, persistence format, location policy, publication, or signing change is intended.

## First comparison round

Three functioning compositions were compiled in one Debug binary and selected with launch-only `-CanyonEdition` arguments to avoid repeated asset builds and installation churn. Their view code is shared; isolated source checkpoints select the same compositions by default:

- Field guide: `design/field-guide` at `66eea5a`, full overview with compact story inspector.
- Continuous canyon: `design/canyon-ramble` at `73d9beb`, scrollable map with linked paged stop cards.
- Archive atlas: `design/archive-atlas` at `a837743`, map with floating photo annotation and named stop strip.

Actual iPhone 17 Pro Max / iOS 26.5 inspection: all three introductions and all three Tour compositions were seen. Field-guide onboarding advanced through both explanatory screens and location choice. The Tour changed selected map position via Next and opened a full-screen Cantilever Deck story. Continuous canyon changed selected stop and inspector together via Next. Archive flow advanced through explanation/location to its actual Tour. Native button actions worked; no unavailable touch gesture is marked passed.

Evidence is under `/Volumes/SSK Drive/Developer/Redesign/ThirdPass/`: `A/round1-onboarding-place.png`, `A/round1-tour-overview.png`, `B/round1-onboarding-place.png`, `B/round1-tour.png`, `C/round1-onboarding-place.png`, and `C/round1-tour.png`.

Observed failures and direction:

1. Full overview onboarding shrank the map into a narrow, cluttered strip. Do not use it as the introduction.
2. Warm map backgrounds exposed the white source image boundary during camera movement. Corrected to a white map canvas.
3. The floating archive card and named stop strip obscured the canyon and duplicated navigation. Do not select that Tour composition.
4. Continuous map gives the strongest spatial relationship. Editorial introduction explains the place before imagery; it is the strongest onboarding composition.
5. Initial map math caused a Swift type-check timeout; explicit CGFloat subexpressions fixed it. Debug arm64 build passes.
6. An installation failed during severe host disk pressure. After space recovered, the same saved app installed without erasing data.

## Second round — selected remix in progress

Combine the continuous canyon with editorial onboarding. Introduce an actual Geodesic Dome drawing and a photograph/drawing comparison, grounded in the existing research about hundreds of students and 19,000 bolts. Keep gold as an intentional selection/accent color, increase body-text contrast, reduce map-marker clutter, and provide a scrolling large-text layout with an unambiguous standard story transition when no thumbnail source is visible. Preserve the native icon-only bottom bar.

This round still needs simulator inspection, compact and large-text review, state-flow regression checks, and independent coordinator critique. It is not ready for Parker sign-off.

## Round three — implemented and reviewed checkpoint

Coordinator review found that round two changed the Tour inspector without moving the viewport, drew behind the status area, left excessive empty onboarding space, and duplicated support routes. Those findings were accepted and addressed; this remains a review checkpoint, not final approval.

### Implementation and corrections found during actual review

- Replaced the positioned-child `ScrollViewReader` targets with a native scroll view whose content offset is calculated from the existing calibrated map coordinates. Manual scrolling remains native; selection only recenters when the selected number or viewport size changes. The map respects the top safe area and uses a small end inset, avoiding half a screen of blank canvas at end stops.
- Bounded `SpatialAtlas` to its declared geometry before clipping. Actual inspection found the prior focused illustration could overdraw the location explanation. This fix also applies to the large-text focused Tour.
- Removed all selection markers from the passive location illustration. It no longer suggests an acquired location fix. The location stage now has a continuous white canvas.
- Sized onboarding artwork using measured text height and available screen height. An initial preference-based measurement did not update correctly after the page transition; direct geometry observation fixed it in the next build.
- Kept the photograph/drawing comparison as a fade between distinct sources, with no claimed geometric registration. Either source now opens full screen with the existing zoom behavior. Double-tap enlargement of the drawing was visually verified.
- Added a restrained opening-artwork reveal; Reduce Motion uses opacity without displacement. This is implemented but still needs independent motion review.
- Largest-text review exposed retained scroll position when advancing onboarding; each page now starts at its own heading. Verified after rebuilding. Scroll drawing is clipped below the status area.
- Info now says “Mark the places you visit” when off and keeps one Help & support route, plus website, privacy, and credits. Removed the duplicate direct-email row.

### Actual checks completed

On the existing iPhone 17 Pro Max / iOS 26.5 disposable simulator:

- Final-build selections 17 → 1 → 31 visibly show the selected marker and matching inspector. The viewport moves between distant regions; nearby end stops can correctly share the same clamped viewport. Nothing is drawn behind the status bar in the Tour captures.
- Opening layout, photograph/drawing selection, full-screen drawing, double-tap zoom, and return were inspected during round three.
- Largest accessibility text: opening and research headings/body wrap; advancing starts at the next heading after the correction. The long Water Infra-Structure Tour title, year, and navigation all remain visible. This is not a complete gesture/VoiceOver pass.
- Location no-fix and remote copy were observed. The illustration marker and text-overdraw defects are fixed. Remaining live near/canyon/denied scenarios need fresh third-pass confirmation.
- Search with the actual software keyboard visible: Shell result, zzzz empty result, story open, Back retaining Shell, and Close restoring the originating Tour all verified. No keyboard clipping was observed.
- Standard text size restored after accessibility inspection.

Release arm64 simulator build also passes in `build-remix-round3-release.log`; this is not a device archive or signing validation.

Build: the final reviewed Debug source is `build-remix-round3-scroll-reset.log` (PASS). Earlier round-three logs preserve the read-only environment-key compile failure and subsequent successful corrections. Established catalog/persistence/location replay checks pass in `round3-regressions.log`, including all 231 map points and 35 discoverable structures. The existing data limit remains: ghost structures 105/106 have no tagged coordinates; none were fabricated.

### Evidence and source mapping

Evidence folder: `/Volumes/SSK Drive/Developer/Redesign/ThirdPass/Round3/`.

- `onboarding-place.png`, `onboarding-photo.png`, `onboarding-drawing.png`: refined round-three composition before the subsequent atlas clipping/page-reset fixes; image composition itself is unchanged by those fixes.
- `largest-text-opening.png`: intermediate bounds build, before page-reset correction.
- `largest-text-page-reset.png`, `largest-text-tour-long-title.png`, `tour-stop-17.png`, `tour-stop-1.png`, `tour-stop-31.png`, `search-keyboard-result.png`, `search-keyboard-empty.png`: final Debug build from `build-remix-round3-scroll-reset.log`.
- Final Debug app: `DerivedData/Build/Products/Debug-iphonesimulator/Poly Canyon.app`. Installed successfully on Pro Max and then the existing SE / iOS 18.2 without data erasure. `A/Poly Canyon.app` remains an older prototype.

### Outstanding and simulator handoff

Coordinate clicks recovered using the internal Simulator application path, `/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app`. The earlier persistent `noWindowsAvailable` note is obsolete for clicks. Drag attempts still acted like taps or did not move content; horizontal/vertical scroll attempts likewise did not demonstrate scrolling. Card swipes, manual map panning, pinch, and full VoiceOver behavior are **not** marked passed. No root cause for this input limitation has been proven.

The Pro Max was shut down before booting the existing SE (only one device at a time). The same final Debug app installed and launched successfully on SE, but the Mac locked before screen inspection. CUA explicitly reports that automatic unlock failed and asks the user to unlock manually. Compact visual checks therefore remain blocked; no compact screenshot or pass is claimed. The SE is the current booted simulator; Pro Max is shut down and retains the same app. Do not erase either device.

Independent coordinator review is still required for distant selections, actual card swipe/map gesture continuity, onset transitions, compact layout, Reduce Motion/contrast, and the remaining permission/location scenarios. This document is a concrete committed handoff, not a declaration that the redesign is finished.

## Apple guidance used

- [Build a SwiftUI app with the new design](https://developer.apple.com/videos/play/wwdc2025/323/): use native navigation and reserve glass for controls above content; system sheets and transitions retain context.
- [Motion](https://developer.apple.com/design/human-interface-guidelines/motion): brief feedback should follow the user’s action and clarify spatial change.
- [Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility): reduce camera/depth movement, preserve large text, and keep controls understandable without color alone.

## Reproduce comparisons

Build with external Xcode, scheme `Poly Canyon`, Debug, an iOS Simulator destination, external DerivedData and package cache. Current arm64 comparison output is `/Volumes/SSK Drive/Developer/Redesign/ThirdPass/DerivedData/Build/Products/Debug-iphonesimulator/Poly Canyon.app`. Logs remain alongside it.

Use existing disposable simulator `EDC62B4C-7EB2-41B4-B997-7660D21504C7`, bundle `Parker-Jones.Arch-Graveyard`. Launch-only arguments: `-CanyonEdition fieldGuide`, `-CanyonEdition ramble`, or `-CanyonEdition archive`. Add `-onboardingProcess NO` to replay onboarding without deleting saved progress. Normal launch selects the evolving remix. Do not treat old `A/Poly Canyon.app` as the remix: it preserves the first round.
