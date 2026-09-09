> Historical record. This describes an earlier review, not current setup or release instructions. See the [current documentation](../README.md).

# Final photo and onboarding polish — 2026-09-09

Base: `ab4a514`, branch `design/remix`.

## Result

- Story header progressively blurs only the original hero photograph, using three softly masked image blur layers. Removed the material wash and the unused navigation-bar surface that flashed during the opening morph. Kept a 44-point accessible close control. iOS 26 automatic top scroll-edge fading is disabled. No new dependency.
- Virtual introduction crossfades three bundled real photographs (M-19, M-6, M-23) every six seconds with a 1.4-second fade. Reduced Motion holds the first photograph. Copy: “Explore a canyon of ideas.”
- Tour, story/photo, and in-person visit pages each have a heading, single explanatory sentence, and separate “Try it out” prompt. Tour explicitly says “Take a virtual tour”; accessibility text sizes retain the truthful arrow instruction.
- Visit notification now remains available for 9.5 seconds after the 4.5-second approach and repeats every 15 seconds. Reduced Motion retains its static arrival and local dismissal behavior.
- Permission-stage action consistently reads “Continue,” preserving the prior App Review wording reported by the coordinator. System permissions and journey logic are unchanged.

## Real review and corrections

Reviewed solely on EDC62B4C-7EB2-41B4-B997-7660D21504C7 / iOS 26.5 through native controls and the existing live preview. No saved marketing captures were produced.

First round: inspected intro photographs and an in-progress crossfade, Tour layout and actual card swipe, photo-demo layout and gallery opening, static Reduced Motion introduction across separate observations, and static in-person notification layout. All copy and actions fit at normal text size.

Header review exposed both a system scroll fade and a pale navigation-bar flash during the actual collection-card morph. Removed those surfaces and rebuilt. Reinspection covered a transition frame, settled Entry Arch header, vertical scrolling without the wash, horizontal paging to Techite Bridge, photo gallery opening/closing, and the close action. Inspected the moving visit example and tapped its longer-lived notification to open Entry Arch.

Final wording-only rebuild installed and launched successfully. Verified Continue in the permission explanation. Left the app on the journey choice via temporary -onboardingProcess NO replay, with Reduce Motion off and text size 3. No permission acceptance, Start my visit, progress reset, or saved journey completion during this pass.

This pass did not repeat the earlier maximum-text, pinch, physical-device or full-app coverage. The coordinator's core checks passed in FinalRelease/Logs/models.log, atlas.log and data.log; core inputs were not changed here.

## Builds and provenance

Final Debug simulator build, Release simulator build, and unsigned Release device archive all passed. Logs and exact post-commit artifact manifest are in `/Volumes/SSK Drive/Developer/Redesign/ThirdPass/FinalPhotoPolish/`.

Installed Debug binaries match the successful build:

- `Poly Canyon`: `6df30b161e93eebcdf5da6c992b39cf52b30e7db63733f2201270cb3c5d997e1`
- `Poly Canyon.debug.dylib`: `3dec21b26bb22beae3d8300e6a445d5d326475d5d0c775ab25f764f2a3dd3de9`

## Handoff

Simulator ownership RELEASED. Coordinator may prepare virtual onboarding and capture the final Debug app. GitHub push, signing, App Store submission and website work remain with the coordinator. This pass performs no push or upload.
