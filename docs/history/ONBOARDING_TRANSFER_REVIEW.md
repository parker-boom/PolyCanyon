> Historical record. This describes an earlier review, not current setup or release instructions. See the [current documentation](../README.md).

# Onboarding transfer candidate

Superseded by Parker’s hands-on review and [the focused refinement candidate](HANDS_ON_REFINEMENT_REVIEW.md).

Base b9d67ed, design/remix. Candidate for independent review, not user-ready or release approval. This note supersedes the earlier onboarding review's gesture and demo conclusions.

## Changes

The five-page sequence now uses white backgrounds and direct descriptions of Cal Poly's architectural experiments. The map lesson shares the actual TourStructureCard with Tour: square photography, dates, adjacent card edge, and native horizontal scrolling. Tapping opens the actual StructureExperience with progress recording disabled. Selection follows the story back into both the map and cards. Accessibility arrows synchronize that same selection; the final one-line synchronization fix is included in both final builds.

The historical Entry Arch lesson opens the existing immersive StructureGallery at photo 3 of 5; it no longer simulates zoom in place. Actual gallery paging and close return to the same onboarding page. Existing photos, catalog, research, and location policy are preserved.

Story paging retains its native TabView. Interactive dismissal is disabled; the explicit close button remains. A direction-gated native pan recognizer on the title and first two full-width photos supplies missed horizontal page requests. It rejects vertical movement before beginning and excludes the horizontal photo rail. A selection guard avoids an extra step when native paging already completed. Temporary diagnostic logging was removed.

## Investigation and rejected approaches

The original candidate repeatedly ignored Blade reverse-title swipes. Disabling interactive dismissal improved reverse swipes but did not resolve a delivered diagonal gesture (input event 98). A SwiftUI DragGesture fallback then stole vertical scrolling (delivered event 104); that version was rejected. The replacement native recognizer gates by initial velocity, rather than waiting until the gesture ends to reject vertical motion.

OnboardingTransfer/gesture-trace.txt records the instrumented investigation, including horizontal translation, origin selection, and the native-selection guard. Separate input evidence showed one missing preview gesture was never delivered (no new HID event); that does not explain all failures. Do not classify every missed swipe as tooling.

## Live review

Earlier passes in this iteration inspected the largest accessibility size, with Reduce Motion enabled: Cantilever Deck wrapped fully, explicit arrows worked, and the fixed Continue remained reachable. Switching back to normal text revealed the map/card selection mismatch; the final change updates previewSelection inside changeSample. That final line is source/build verified; the largest-size transition was not repeated after its installation.

Final clean Debug build on the existing iOS 26.5 ProMax:
- All five white onboarding pages fit at normal text. Explicit virtual choice completed to Tour without enabling tracking.
- Real card swipe moved the map; tapping Sun Dial opened its real story. Explicit previous action and later diagonal swipes moved between Sun Dial and Cantilever Deck. Closing retained Cantilever Deck in both the map and centered card.
- Historical photograph opened Entry Arch 3/5, advanced to 4/5, and closed back to the white lesson.
- Blade title reverse diagonal moved to Techite Bridge; Techite hero forward diagonal returned to Blade. Mostly vertical dragging scrolled to Blade photo 2 and its rail without paging. Photo 2 opened at 2/4. A reverse edge drag on the settled story after closing the gallery moved to Techite Bridge without dismissing the story.
- A drag sent immediately during gallery dismissal did not page; repeating after the story settled succeeded.
- Two initial reverse drags in the onboarding Sun Dial preview stayed at Sun Dial, including delivered event 133. Later forward and reverse drags succeeded. This remains an unresolved intermittent result: do not claim the gesture defect fully eliminated.
- Normal text size restored to 3, Reduce Motion restored off. Contrast and transparency overrides off. Native AX inspection worked; VoiceOver speech/focus and true two-finger pinch were not tested.

## Evidence and remaining review

External artifacts: /Volumes/SSK Drive/Developer/Redesign/ThirdPass/OnboardingTransfer. debug-final.log and release-final.log both succeeded. regressions-final.log contains the existing model/store/onboarding/location checks. final-input-events.json records final delivered inputs. manifest.txt identifies the committed source and immutable Debug/Release copies, plus installed binary verification.

Independent review must repeat initial/opening and diagonal story swipes, including the three-item onboarding preview, rather than accepting isolated successful gestures. Compact-device visual review and actual two-finger pinch remain open. The separate visit-tracking test remains blocked pending direct authorization; it was not enabled by UI, CLI, or onboarding completion. No push, publish, new runtime/device, extra server, or video.
