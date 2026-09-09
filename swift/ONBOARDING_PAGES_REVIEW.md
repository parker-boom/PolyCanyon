# Onboarding pages and regression review

Candidate for independent review, not release approval. Checkout: PolyCanyon-field-guide, design/remix. Base e67cc58. Existing iOS 26.5 review device EDC62B4C-7EB2-41B4-B997-7660D21504C7; one localhost:3200 server, external build/cache paths, no videos or runtime downloads.

## Direction and references

Parker rejected the centered, crowded introduction and requested genuinely separate moving screens. The new sequence is title/logo → location question → what the canyon is → navigation demo → photo/story demo. Back and a fixed forward action are always available; the explanation pages can be skipped. Location skip remains explicit. No forced delay or permission gate was added. Normal text fits without scrolling on the existing ProMax; accessibility text scrolls independently above the actions.

- [Apple onboarding guidance](https://developer.apple.com/design/human-interface-guidelines/onboarding): short, optional, interactive introductions. Applied as a three-place map/card demo and a tappable historical photograph, with no progress mutations from either preview.
- [Duolingo screen examples](https://screensdesign.com/showcase/duolingo-language-lessons): inspected the displayed opening/question screenshots. One question, simple progress and a consistent back/forward arrangement informed the structure. We did not copy its lengthy question flow, mascot, gamification or account setup.
- [Apple Liquid Glass adoption](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass): retain native controls and inspect custom backgrounds/scroll boundaries.
- [Apple background extension](https://developer.apple.com/documentation/swiftui/view/backgroundextensioneffect()): extends mirrored, blurred background beyond safe-area edges without enlarging the interactive map.
- [Apple color-scheme environment](https://developer.apple.com/documentation/swiftui/environmentvalues/colorscheme): local gallery appearance avoids propagating a dark preference to the enclosing light story.

Three small local studies are saved externally in OnboardingPages/direction-studies.html: paper pages, full-bleed photographs, and floating cards. Paper pages were selected for readable text and room around the actual content. The full-bleed study competes with location copy; the card study repeats the cramped feeling. Browser security blocked opening the local HTML file, so these are source studies, not claimed rendered browser evidence. No workaround was attempted. The chosen native implementation was built and inspected repeatedly instead.

## Iteration record

1. Split the flow into five stages, added directional slide/fade transitions and Back, persistent actions, real Entry Arch photographs, an interactive three-place atlas preview, and photo enlargement. First live pass caught an over-wide story heading and a sparse map preview centered on Entry Arch.
2. Constrained page width, moved the preview to Tensile/Cantilever Deck/Sun Dial, and added explicit previous/next controls. Live swipe changed Tensile → Cantilever Deck and the map followed; the arrow then moved to Sun Dial. Story heading wrapped, but image sizing still pulled its left edge outward.
3. Bounded image drawing inside GeometryReader. Largest-text review found truncated preview labels; replaced the photo text badge with its accessible symbol and let the map example title wrap between arrows. Cantilever Deck then displayed in full. Large-text copy scrolled to its end while Continue/Start the tour stayed reachable. Corrected the large-text instruction to describe arrows. Normal-text story page then aligned with the other pages and fitted without scrolling.
4. Verified the existing Tour scrollClipDisabled correction removed the sharp gray strip. Collection/Search already scrolled underneath native glass. Map still had a hard white shelf. Extending its interactive canvas removed the shelf but hid Entry Arch behind the tabs; rejected that iteration. Final native backgroundExtensionEffect preserves the fitted canvas and fills behind the glass. Live final check: Entry Arch visible above tabs and tapping it opened Entry Arch, 1976.
5. Scoped gallery dark appearance locally and explicitly kept stories light. Live test exposed unreadable status text on the black gallery; hide the status bar only in the immersive gallery. Returning restores the normal story status bar.

## Live evidence

- Normal text: five distinct pages, separate sliding transitions, correct wrapped headings, primary actions visible without page scrolling. Virtual choice completed to Tour despite an available canyon location.
- Largest accessibility text, Reduce Motion and Increased Contrast were enabled and verified via simulator settings. Title and location choices remained usable; all introduction text could be read by scrolling; Back worked; Cantilever Deck wrapped fully; preview arrows changed selection. Settings restored afterward. VoiceOver speech/focus was not exercised.
- Gallery: Techite Bridge photo 1 → swipe 2 → close returned to the light story. Blade photo 4 opened first at 4/4; closing and reopening photo 3 showed 3/4. No black surroundings or pale-on-white story leak occurred across these cycles.
- Story paging: Techite → Blade across title; Blade → Techite across title; Techite → Blade across hero image. All remained in the story. Closing preserved Blade selection in Tour. The intermittent report was not reproduced in this controlled sequence; no speculative pager rewrite was made.
- Search: typed Under, opened Underground House, scrolled to and opened photo 2 at 2/4, double-tapped to zoom, panned without paging, double-tapped to fit, swiped to 3/4, closed gallery and story. The white story retained its scroll position and Search retained Under.
- Map: double-tap zoom, pan, whole-canyon reset observed during the canvas investigation. Final background-extension build kept the original geometry and opened the correct Entry Arch target at fit.
- Tour bottom edge inspected at rest and during normal card movement; Reduce Transparency showed a clean solid-card fallback. Collection and Search content continued beneath native controls without the hard strip.

## Automated evidence

OnboardingPages/regressions.log: catalog/persistence/rollback/migration, saved progress, onboarding entry/opt-out/no-fix, production foreground location replay, all 231 map points and 35 discoverable structures passed. Extended onboarding checks cover forward/back boundaries and replacing a previous location choice with virtual after going back. No coordinates invented for ghost records 105/106.

OnboardingPages/geometry.log: 75 atlas cases plus map fit/calibration/camera center for compact, tall and landscape viewports passed. These are geometry checks, not compact visual evidence.

Debug and Release arm64 simulator builds use the external Xcode and existing package cache. Final logs and immutable app copies are under /Volumes/SSK Drive/Developer/Redesign/ThirdPass/OnboardingPages. manifest.txt records the final commit and binary hashes. No content/research/photo/catalog source was changed. No push, signing or deployment.

## Independent review still needed

- Actual two-finger pinch on map/photos and final animation smoothness. Single-pointer double-tap/pan is not a substitute.
- Compact-device layout: only the existing ProMax was used. The removed iOS 18.2 runtime was not reinstalled; no additional device was created.
- Fresh live canyon/remote/denied/no-fix completion of the new longer sequence. The underlying routing policy is unchanged and automated cases pass; this round intentionally used explicit virtual completion.
- Tracking enable → center → pan → Turn off remains blocked pending Parker's separate direct authorization. The prior automatic approval review rejected persistent visit tracking as beyond permission-only synthetic tests. Tracking was not enabled by UI, CLI or onboarding workaround in this round.
- Repeat the intermittent story swipe sequence independently, including diagonal and edge drags. Controlled title/hero swipes passed here, but that does not prove every gesture variant.
- Independent visual pass on the final candidate; native accessibility app inspection timed out, so do not treat this as a completed VoiceOver audit.
