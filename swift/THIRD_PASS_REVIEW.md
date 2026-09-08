# Third design pass — active review, not approved

Integrated baseline: `55a9a50` (app source `8155917`, UI `8b2f9eb`). Android retirement and Glur dependency removal remain inherited. This is a local design branch; no discovery algorithm, persistence format, location policy, publication, or signing change is intended.

Latest opening alternative after `eb577ac`: a three-structure preview with bounded photographs and selectable thumbnails, pending live inspection. The coordinator rejected the `eb577ac` opening as generic; it is not an accepted design. Its content-sized Tour correction is retained. The new opening has separate output under `ThirdPass/OpeningAlternative/`.

Previous review revision after `3df3ae6`: accurate opening copy, uncropped Tensile photograph, and content-sized Tour cards. This revision has its own `ThirdPass/ReviewRevision/` output and has not been installed or reviewed live.

Current shipping source contains only the selected composition. The A/B/C branches below preserve the experiments; their launch selector is no longer present in shipping source. The post-round-three offline cleanup has separate build outputs and has not been installed or visually tested. Both simulators still have the reviewed `706052c` build.

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

## Offline cleanup after round-three review

The coordinator requested source cleanup while the Mac remains locked. No simulator interaction or unlock attempt was made during this work.

- Verified and preserved `design/field-guide` (`66eea5a`), `design/canyon-ramble` (`73d9beb`), and `design/archive-atlas` (`a837743`) before removing the A/B/C switches, old compositions, numbered-marker mode, overview control, and unused Tour-to-Map callback from shipping views. The selected editorial introduction, continuous Tour, native tabs, stories, data, and discovery policy remain.
- The scroll view previously owned a hosting controller whose view was added without controller containment. It now uses `UIViewControllerRepresentable`, adds the hosting controller as a child, and explicitly detaches the child/clears its SwiftUI root when dismantled. This avoids relying on an orphaned controller for lifecycle and trait propagation.
- Reduce Motion is passed explicitly from the parent SwiftUI environment into both the native camera and the hosted atlas; it no longer depends on a separate hosting root independently resolving that value. Enabling Reduce Motion also stops a camera animation in progress and snaps to the target. Live motion verification remains open.
- Extracted `CanyonAtlasGeometry` as the shared illustration/marker/scroll transform. The existing 2000×4519 dimensions, 1.09 calibration, fit/focus scales, and focus anchor are preserved. Native scrolling now uses the same marker position as drawing, including on resize. A corrected bound prevents an inverted scroll range when the viewport is taller than the entire canvas. Changes to a selected place's resolved point also request recentering.
- The hosted canvas explicitly ignores its own safe-area inset; the enclosing scroll surface still clips to the page's safe area. This keeps its drawing coordinates equal to the native scroll calculations after adding controller containment. Needs a fresh live comparison against round-three stills.
- At the smallest text sizes, the scaled 130-point card could become shorter than the fixed 84-point photo plus 36 points of padding. It now has a 120-point minimum. The normal-size composition remains 130 points. Onboarding artwork already has a positive 240-point minimum (194 for comparison imagery after picker allowance) and scrolls when content cannot fit; no speculative layout rewrite was made. Actual compact/landscape layout remains unverified.

The new `swift/scripts/check-atlas.sh` checks 75 combinations of viewport and selected point: focused anchors, selected-point visibility, interior recentering, and end/tall-viewport bounds. It passes; log: `/Volumes/SSK Drive/Developer/Redesign/ThirdPass/offline-atlas-checks.log`. These are geometry checks, not gesture, controller-lifecycle, or visual tests. The established data/location checks passed at `706052c`, and no Core/Data, Core/Location, persistence, or catalog files changed in this cleanup.

Offline cleanup validation: Debug (`debug-final-build.log`) and Release (`release-build.log`) arm64 simulator builds both pass. `git diff --check` passes. Core and bundled assets have no diff from `706052c`.

New build output: `/Volumes/SSK Drive/Developer/Redesign/ThirdPass/OfflineCleanup/DerivedData/Build/Products/Debug-iphonesimulator/Poly Canyon.app`. Build logs and source/binary manifest are in `ThirdPass/OfflineCleanup/`. The original round-three output and captures are retained separately. **Do not describe the cleanup binary as installed or its UI as verified.**

Still required when unlocked: install this exact cleanup build; check host re-entry after tab switches and large-text changes, selections 1/17/31 after resize, manual map scroll and card swipe, Reduce Motion (including changing it during movement), normal/compact/large-text and contrast layouts, remaining canyon/near/denied/no-fix flows, gallery gestures, and independent coordinator approval. Earlier keyboard/zoom checks belong to round three and do not substitute for the changed host's live QA.

## Focused review revision after `3df3ae6`

The coordinator requested two separate refinements while the Mac remains locked. No simulator interaction, unlock attempt, generated app screenshot, or live-layout measurement was performed for this revision. The `3df3ae6` Debug/Release apps remain intact under `ThirdPass/OfflineCleanup/`.

### Opening copy and source-photo review

Opening heading: **Explore Poly Canyon.**

Opening explanation: **Walk among student-built architectural experiments in the hills behind Cal Poly.**

This identifies the destination and what is there without attributing construction of the canyon itself to students. The repeated Cal Poly/San Luis Obispo caption is removed. The green/gold typography, restrained reveal, and subsequent photograph/drawing research interaction remain.

Compared the actual bundled `M-6`, `M-5`, `M-7`, and `tensile2` photos, decoded to external inspection copies in `ThirdPass/ReviewRevision/SourcePhotos/` because the image viewer could not directly read HEIC. These are source-photo inspection copies, not app screenshots or modified bundled assets.

- `M-6` (2200×1467): the full landscape composition shows the tensile canopy, its supporting poles, cables, and hill. Selected for the opening; `scaledToFit` preserves the whole source. Its allocated region can include whitespace; the photograph is not enlarged/cropped vertically just to consume space.
- `M-5` (1467×2200): a slender individual structure with substantial sky; pairing it with a narrow Tensile crop weakened explanation of both. Removed from the opening composition, retained in the catalog.
- `M-7` (2200×1650): clearly shows the dome; retained for its existing research comparison on the next page rather than repeating it in the introduction.
- `tensile2` (2200×1644): shows construction activity and equipment; useful story evidence, less immediately legible as the finished structure on the opening screen. Retained unchanged.

### Tour height: source analysis and sizing contract

The prior `max(120, scaled130)` fixed the photo's minimum space but did not account for text wrapping. At a fixed Dynamic Type size it allocated the same height regardless of width, title, or year. The title and metadata can wrap independently, so that budget was not sufficient evidence of fit. This review does **not** claim a measured iOS clipping threshold while the simulator is unavailable.

The fixed card-height metric is removed. The sizing stack contains all 31 actual catalog entries, using the same `inspectorContent` function as the visible pages. For each entry the layout is:

- Same proposed page width, 18-point padding on each side, 88×84 photo footprint, and 16-point horizontal gap.
- Same title2/medium title, subheadline year plus “Photos & story,” and 6-point vertical gap.
- Unlimited text lines and natural vertical size. The sizing copy substitutes a fixed clear rectangle for the image; it contains no button, image loading, or matched zoom source and is hidden from accessibility/hit testing.

Consequently, the pager's proposed height comes from the tallest natural card at the current width and font environment: `max(84, title-and-metadata natural height) + 36`, maximized across all entries. The visible native page view is an overlay and does not determine or constrain that height. A wider or narrower viewport and each non-accessibility Dynamic Type size trigger normal SwiftUI re-layout. Using all entries keeps the map's available height stable during a swipe between a short and long name.

Long catalog cases explicitly covered by this shared sizing path include Electric Infra-Structure (1965 / 1977), Water Infra-Structure (1965 / 1998), Centering for Center (2022), and Cantilever Deck (1990 / 2024). There is no truncation, fixed line count, reduced font scale, or speculative numerical font table. The existing separate accessibility-size scroll layout remains.

This is source-level sizing analysis, **not** live verification of every Dynamic Type size. Coordinator review must still check XS through XXXL on compact width, actual pager/gesture behavior, remaining map height, and the two longest titles with their multi-year metadata. Also inspect the opening's whitespace/framing and transition in the real app.

Debug and Release arm64 simulator builds both pass (`debug-build.log`, `release-build.log`); `git diff --check` passes. Builds and source/binary mapping for this revision are in `/Volumes/SSK Drive/Developer/Redesign/ThirdPass/ReviewRevision/`. No Core, assets, discovery, permission policy, or native tab behavior changes are included. Prior geometry/data test results remain associated with their respective commits and are not presented as text-layout or interaction tests.

## One considered opening alternative after `eb577ac`

This is one implemented alternative for the next live review, not a sequence of additional speculative rewrites or a visual approval. The locked simulator has not been accessed. `eb577ac` and `3df3ae6` binaries remain preserved in their own output directories.

### Composition and purpose

Title: **Poly Canyon**

Explanation: **A collection of student-built architectural experiments in the hills behind Cal Poly.**

A bounded photograph and its catalog name/year sit between that introduction and a row of three selectable photographic thumbnails. The choices are Tensile (6), Geodesic Dome (7), and Shell House (24), resolved from the existing catalog, including their first image and year. Selecting a thumbnail changes the photograph and caption with a short fade; the selected thumbnail gains a gold outline and accessibility selected trait. There is no autoplay. This introduces the variety of structures through a visitor's choice before the next page demonstrates the archive photograph/drawing comparison. The “Discover their stories” action remains.

The full Tensile and Dome sources were inspected in the previous review. The Shell House source was inspected for this alternative and shows its roof form, base, vegetation, and hill in a landscape composition. All three remain aspect-fit in both the main view and thumbnails; no narrow crop, generated image, fabricated date, or duplicate location caption is introduced.

The older `167b634` welcome source used a distinctive motion-responsive logo (`WelcomeLogo.swift`). That history reinforces the value of a responsive opening. This alternative's response is attached to choosing actual structures. No sensor loop or permission is added.

### Whole-layout budget

The first page no longer uses the previous unbounded `artworkHeight` region. It accounts for the measured heading/explanation height, measured caption height, 40 points of vertical padding, 64-point thumbnail controls, an 8-point photo/caption gap, two 16-point minimum flexible gaps, and the normal footer allowance. The image stage is bounded by a 4:3 proportion and can shrink to 150 points high before scrolling takes over. Accessibility sizes use the natural proportion in the existing vertical scroll flow with inline actions.

| Page width | Image region width | Maximum image-stage height | Thumbnail control height |
| --- | --- | --- | --- |
| 375 pt | 319 pt | 239.25 pt | 64 pt |
| 440 pt | 384 pt | 288 pt | 64 pt |

These are source geometry bounds, **not** measured simulator layouts. The available image height can be smaller after actual text layout. M-6 and M-24 are approximately 3:2 photographs, so their full images occupy less height than the 4:3 stage; M-7 is 4:3. At the maximum stage size the landscape letterbox space is modest, rather than the previous tall image allocation. Remaining screen height is distributed by the two explicit flexible gaps, with thumbnail controls above the footer. Whether that balance feels considered must be judged on the device.

### Validation and handoff limits

Debug and Release arm64 simulator builds pass (`debug-build.log`, `release-build.log`), and `git diff --check` passes. Builds and commit/binary mapping are under `/Volumes/SSK Drive/Developer/Redesign/ThirdPass/OpeningAlternative/`. Only onboarding and this review note change from `eb577ac`; the content-sized Tour is unchanged. Source-photo inspection copies are not app screenshots. No first-page selection, transition, accessibility behavior, or compact layout is marked passed live.

Next live review: inspect the full page at compact and Pro Max sizes; tap all three thumbnails and confirm complete structure framing, caption/year, selection indication, stable footer and spacing; inspect normal and Reduce Motion fades; check large text and scroll reachability; then advance to the existing archive interaction and location stage. Keep the prior Tour, gesture, host, and location QA gaps open. Await coordinator inspection before further design revision.

## Reproduce preserved comparisons

Use the preserved candidate branches/checkouts listed above, with external Xcode, scheme `Poly Canyon`, Debug, an iOS Simulator destination, external DerivedData and the existing external package cache. The `66eea5a` comparison source supports launch-only `-CanyonEdition fieldGuide`, `-CanyonEdition ramble`, or `-CanyonEdition archive`. The isolated B/C checkpoints select their respective composition by default. The current shipping source intentionally has no such switch.

For current-source onboarding replay, `-onboardingProcess NO` remains a launch-only override of the existing onboarding preference; it does not erase saved progress. Use only the existing disposable devices, one at a time. Do not treat old `A/Poly Canyon.app` as the selected or cleanup build.
