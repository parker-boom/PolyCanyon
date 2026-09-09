# Latest follow-up

See [Onboarding pages and regression review](ONBOARDING_PAGES_REVIEW.md) for the new five-page onboarding, measured iterations, final bottom-edge/gallery fixes, and current open checks. Historical build-only and appearance notes below describe earlier states.

# Second feedback review

This revision supersedes the earlier onboarding and Tour compositions. It is a handoff for independent review, not a release or a claim that every device/gesture has passed.

## Implemented

- Three-stage onboarding: existing logo/title, explicit foreground location choice, then a short visit or virtual introduction. The primary action is immediately available. Virtual choice is explicit, denied/no-fix paths remain usable, and destination intent is consumed once. Maximum-text instructions refer to the chooser instead of the standard carousel.
- Map uses its available content height with floating information, appearance, and location controls. One native camera owns zoom, pan, fit and centering. Single selection waits for double-tap zoom to fail; accessible structure buttons remain available. Centering requires a fresh permitted canyon fix.
- Tour has a top-right glass chooser, a restrained selected-marker ring, and swipable glass photo cards showing name and exact catalog dates. Menu, map tap, card swipe and story paging synchronize selection. Maximum accessibility text uses a focused map summary and a readable text card with accessible next/previous actions.
- Collection cards place numbers on images, with names and exact dates below. Historical entries begin collapsed. Map and Collection information carry their context as presentation data, avoiding stale first-sheet content.
- All story entry paths use a shared full-screen pager with X dismissal. Filtered search preserves its result order/query. Photos use an item-based presentation so the tapped index is correct on the first opening and on reopening. Hero photo counts are removed; dates are prominent; the research disclosure is a clear section. Page preloading does not mark adjacent stories opened.
- Photographs retain their actual aspect ratio. A shared native zoom surface limits panning to the image, allows page swipes at fit scale, and reserves drag for panning when enlarged.

## Defects actually reproduced and corrected

1. Baseline 2df8671: tapping Underground House photo 2 opened photo 1.
2. Centered map appeared zoomed but could not pan: its pre-applied scale was independent of Zoomable's identity drag state.
3. Double-tapping beside a structure could open its story instead of zooming.
4. Existing photo zoom gesture prevented the tested photo-page swipe.
5. First integrated onboarding primary button inherited dark-on-dark text; corrected and reinspected.
6. First integrated Map information sheet could show Collection copy; corrected with item-based context and reinspected.
7. First native photo canvas included letterboxing in its pan bounds; fitted image bounds corrected and reinspected.

The established Zoomable dependency was inspected, not removed. Its independent transform and gesture ownership could not provide a single centering/reset state or reliable nested paging in the reproduced cases. The shipping map/photo surfaces now use the shared native scroll/zoom controller; other dependencies and licenses are preserved.

## Live evidence

Existing ProMax EDC62B4C-7EB2-41B4-B997-7660D21504C7, iOS 26.5, one booted simulator. Existing serve-sim server at localhost:3200 was reused. Browser-coordinate taps/drags and Simulator accessibility actions were used. No video was recorded.

| Scenario | Observed result |
| --- | --- |
| Canyon foreground permission | Actual Allow While Using App prompt accepted under Parker's direct authorization; fresh canyon feedback → walking introduction → Map. |
| Washington foreground permission | Actual second prompt accepted under direct authorization; remote feedback → virtual introduction → Tour. |
| Explicit virtual choice, maximum text | Both actions reachable by scrolling; virtual alternative → virtual intro → Tour. |
| Tour card swipe | Underground House → Sun Dial changed card and marker together. |
| Story paging and return | Sun Dial → Gunite Bridge; closing returned to Gunite Bridge in Tour. |
| First/last chooser | Entry Arch and Moment Monument selected with correct cards and visible markers. |
| Tour map tap | Moment Monument → Entry Arch updated card and marker. |
| Direct photos, multiple structures | Gunite Bridge 3/3 first opening, then 2/3 reopening; Spire Array 4/4; Underground House 2/4 on the exact original failure path. |
| Final photo gesture pass | Underground House 2→3 via drag; drawing double-tap zoom; pan bounded to image; double-tap fit; swipe to 4/4, Next disabled. |
| Map zoom/pan/reset | Double-tap at the prior conflicting target zoomed; drag moved the map; Show whole canyon reframed the complete map. |
| Unavailable location | Washington showed a clear unavailable-position alert and no fabricated user pin. |
| Map accessibility | Accessible Geodesic Dome target opened the correct shared story. |
| Full research | Geodesic Dome disclosure exposed description, additional fact, builders and advisors. |
| Information context | Corrected Map first opening showed Location & visits; Collection showed guide/credits and no location controls. |
| Historical section | Initially collapsed in accessibility tree; expand exposed six historical entries; collapse removed them again. |
| Search | Native Under query returned Underground House; shared story and correct second photo; dismissal retained Under query. Clear text and Close remained separate native actions. |
| Maximum text | Title, location actions, virtual intro and Tour card readable/reachable. Focused map summary preserved. |
| Reduce Motion | Browser switch taps did not change the setting; native accessible switch did (Value 1). Accessible Next structure updated map/card. Setting restored to Value 0 afterward. |

## Automated / build evidence

External outputs: `/Volumes/SSK Drive/Developer/Redesign/ThirdPass/SecondFeedback/`.

- `debug-build.log`, `release-build.log`: unsigned arm64 generic iOS Simulator builds with the external Xcode, isolated DerivedData and existing package cache. Both succeeded. Final binary/source hashes are in `manifest.txt`.
- `regressions.log`: catalog decoding, exact multi-year/unknown-date presentation, atomic persistence, rollback, migration, saved progress, one-time onboarding destination, production foreground location replay, stale/denied/Always/background behavior, all 231 map points, 35 discoverable structures; new explicit-choice/no-fix/remote/revocation/request-gating onboarding checks passed.
- `geometry.log`: 75 existing Tour transform cases and new map calibration/center/aspect cases for compact, tall and landscape viewports passed.
- `git diff --check` passed. Catalog JSON, photographs and research source text were not edited.

## Open checks / limits

- Two-finger pinch was not directly synthesized. The available CUA input surface provides single-pointer drag/tap; Simulator I/O menu exposed no pinch action. Native pinch recognizers are enabled, but double-tap/drag evidence is not a substitute for a real two-finger check. Independent reviewer should exercise pinch on map and photos.
- Existing SE CD9C41A1-FFD1-4197-B6BE-2F2130B35DDB is unavailable after Parker authorized removing its iOS 18.2 runtime. No runtime was reinstalled and no replacement simulator was created. Compact-device live review remains open; compact geometry checks are not a screenshot/layout substitute.
- Final center-then-pan plus Turn off live test is pending separate approval. Automatic approval review rejected enabling Mark places I visit as beyond the two explicitly authorized synthetic permission tests. The requested simulator-only tracking authorization is pending in this task; no workaround was used. Earlier canyon centering was observed, the old centered-pan defect reproduced, and the replacement camera's drag/reset behavior verified independently, but the final combined tracking sequence is not claimed passed.
- Denied/no-fix/revocation transitions are covered by production/model regressions; fresh live denied/no-fix journeys were not repeated in this round.
- Animated morph smoothness and actual increased-contrast device behavior need independent visual review. Native source/destination image IDs and Reduce Motion gates are implemented; no video evidence exists.

## Native search decision

Kept system behavior. UIKit documents UITextField.clearButtonMode, but SwiftUI's public search API and the installed SwiftUI interface expose no corresponding native search clear-button modifier. No private hierarchy introspection, global appearance override or replacement search field was introduced.

Sources: [Apple search APIs](https://developer.apple.com/documentation/swiftui/search), [UIKit clearButtonMode](https://developer.apple.com/documentation/uikit/uitextfield/clearbuttonmode).

## Bottom tab background follow-up

The fitted horizontal Tour carousel now allows its glass-card shadows to draw beyond its scroll bounds (`scrollClipDisabled`, already inside the iOS 17+ branch). The separate bottom padding, white page, and native tab bar remain unchanged. This is the smallest source correction for the independently reproduced hard shadow edge; visual confirmation across tabs and Reduce Transparency remains pending. The coordinator owns Simulator; this follow-up is built externally only and is not installed. Artifacts are under `/Volumes/SSK Drive/Developer/Redesign/ThirdPass/TabBackground/`.


## Independent-review regressions: appearance and story paging

Coordinator reproduced on installed 15d1542: Tour Entry Arch → Techite Bridge → story → photo 3/5 → swipe photo 4/5 → gallery X left black presentation surroundings and pale unreadable text on the white story. The state persisted across screenshots. The developer also observed the supplied broken state directly. Gallery used presentation-wide `preferredColorScheme(.dark)` inside a nested full-screen zoom presentation, while the story has a fixed white paper surface and trait-dependent ink. Correction under review: gallery uses a local dark environment; the white story presentation explicitly prefers light. Repeated open/swipe/dismiss checks are required before closure.

Coordinator also reported horizontal story drags over Techite title and hero did not page, despite working Tour/gallery drags. Developer's first drag on the same installed broken state moved Techite Bridge → Blade and the native accessibility tree confirmed Blade, so a blanket paging failure is not reproduced. This remains an explicit regression investigation, not a checked-off assumption. Repeated title/hero drags and post-gallery return must be observed.
