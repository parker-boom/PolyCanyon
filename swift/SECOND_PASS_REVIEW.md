# Second design pass — review candidate

The guide now has a stable Map, Tour, and Collection. Tour leads with photography and keeps each stop connected to the original canyon map. White surfaces, restrained green controls, and native navigation carry through the collection, stories, onboarding, and small Info sheet.

The first pass is preserved at `review/visual-ios-first-pass` (`80e12df`). Its media and unsigned archive remain untouched. This candidate is on `redesign/visual-ios`; no remote publication or release upload has occurred.

## Design decisions

- **Native navigation:** iOS 26 uses three icon-only primary tabs with explicit tab accessibility labels and a separate native Search role. Search opens the shared collection/search surface and focuses immediately. Closing Search returns to the originating tab, following the native behavior. iOS 16–25 keeps labeled native tabs and search within Collection.
- **Tour comparison:** both photo-led and map-led alternatives ran on the same iOS 26.5 simulator. The map-led version made Tour feel too similar to Map and separated the photograph from its title. The selected photo-led version gives the images room and uses a smaller locator with surrounding structures. Its camera translates over the existing map; it does not invent a route. The alternate implementation and captures are preserved outside the app.
- **Spatial continuity:** native horizontal photo paging, previous/next controls, and the locator share the same persisted stop index. The map action opens the matching position in Map; a fresh request recenters even for the same stop. “Whole canyon” restores the overview. Native photo-to-story and story-to-gallery transitions use actual photograph sources where available. Offscreen gallery sources and Reduce Motion use standard transitions.
- **Collection:** the title chrome is gone; visited marks and the unvisited filter remain beside the photographs. Search state cannot invisibly filter the normal Collection destination. All original research and photographs remain available offline.
- **Location agency:** onboarding explains foreground use, then visibly responds to permission and a usable location before explicit entry. It distinguishes canyon, nearby, wider recommendation area, remote, and no-fix states. A small Info sheet replaces the standalone visit destination and prominent recording switch, with explicit enable/pause actions, privacy, support, and complete licenses.
- **Compact and accessibility layouts:** Tour leaves room for its map action on compact phones, uses a shorter photo and concise progress at accessibility sizes, and Collection becomes one column. At accessibility sizes, onboarding actions follow the explanation in the scroll view instead of occupying most of the screen in a pinned footer. Normal-size onboarding keeps its bottom actions.

Apple references: [tab bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars), [search activation](https://developer.apple.com/documentation/swiftui/view/tabviewsearchactivation(_:)), [native transitions](https://developer.apple.com/videos/play/wwdc2024/10145/). Availability was checked against the installed iOS 26.5 SDK. The icon-only tabs are an intentional visual choice; their accessibility names are retained.

## Verification

- Actual iOS 26.5 simulator comparison of both Tour treatments, including refinement of map clipping and locator scale.
- Native Search focuses, filters by name/number, lays out with the software keyboard, opens a story, and dismisses cleanly.
- Tour previous/next, story/gallery entry and dismissal, map handoff, overview restoration, visited marks, and the unvisited filter checked in the simulator.
- Fresh synthetic canyon onboarding: foreground permission, truthful no-fix response, canyon response before entry, then an actual Entry Arch discovery from a subsequent location sample.
- Fresh synthetic Washington onboarding: remote response before entry and recording paused afterward. Both simulator permission grants were directly authorized by Parker. These are synthetic tests, not physical GPS validation.
- iOS 18.2 compact fallback: map, labeled tabs, collection search, solid story header, gallery controls, double-tap zoom, next photo after zoom, and safe dismissal when the current photo has no visible story thumbnail.
- Largest accessibility text, Reduce Motion, and Reduce Transparency reviewed; modified simulator preferences restored afterward.
- Final Debug and Release simulator builds and an unsigned device archive pass. The final archive is `/Volumes/SSK Drive/Developer/Redesign/Archives/PolyCanyon-second-pass-final.xcarchive`.
- Existing data/model checks pass: 31 structures, 6 historical structures, all image references, persistence/migration checks, and foreground-only location replay across all 231 map points.
- Independent read-only review found two state issues; both were fixed. Final review found no additional demonstrated regressions.

### Practical limits

Automated drags and wheel scrolling did not reliably produce touch gestures in Simulator. Swiping between Tour photos, pinch/pan, interactive return gestures, long-content scrolling, and full VoiceOver should receive a hands-on pass. Button navigation and double-tap zoom are verified; unsuccessful drag attempts are not counted as passes. No physical-device GPS, signing, App Store submission, or final promotional video is claimed here.

## Evidence

Review captures and build logs live on the external drive:

`/Volumes/SSK Drive/Developer/Redesign/SecondPass/`

[Open the visual review and 56-second transition study](</Volumes/SSK Drive/Developer/Redesign/SecondPass/Review/README.md>).

The `Review` folder contains the native simulator captures; `Work` retains comparison source and build logs. Candidate screenshots are review material, not final App Store assets. First-pass media remains in `/Volumes/SSK Drive/Developer/Redesign/Media/`.

## Coordinator refinement after the reviewed candidate

Tour now uses a quiet current-stop/total indicator, a native chevron on its story action, and a map symbol on the Canyon map control. The repeated onboarding brand kicker is removed on every page; headings already establish the place. No location, navigation, or discovery behavior changed.

The refinement passes a Debug simulator build and diff whitespace checks. Its build log is `SecondPass/Work/build-chrome-refinement.log`. Live visual review is pending because the Mac was locked when Simulator access was attempted. Existing screenshots, transition study, Release build, and unsigned archive document the preceding `30f83cb` candidate, not this follow-up. Final media remains on hold.
