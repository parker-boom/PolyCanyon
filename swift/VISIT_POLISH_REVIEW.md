# Visit polish review — 2026-09-09

Based on `0d894fb`, on `design/remix`.

## Changes

- In-person introduction now reads “You’re ready to explore Poly Canyon” with one direct map-use sentence. Removed the redundant permission-page paragraph.
- Local example position follows bundled map path points 3 → 2 → 1 toward Entry Arch over 4.5 seconds. The actual shared DiscoveryBanner appears at the top until second 8; the example repeats every 9 seconds. Example state never writes visits or device location.
- Banner opens an Entry Arch story preview with recordsOpening disabled. Real discovery actions retain their original routing and dismissal behavior.
- Recenter stays above conditional Fit map. Existing camera and scale-based visibility logic is unchanged.
- Location dot retains its 14-point core, calibration and visibility logic; refined green, fixed white outline, softer halo and slower pulse. Reduced Motion uses a static dot.

## Verification

Debug simulator build passed (`VisitPolish/debug-final.log`), and git diff --check passed. Installed the final build on the sole existing review device EDC62B4C-7EB2-41B4-B997-7660D21504C7, iOS 26.5.

Live review in this iteration confirmed recenter remains at preview coordinate (747,163) while Fit appears/disappears below it at (747,199); the refined dot was inspected at overview and recentered zoom. No new true-pinch test was performed.

Final installed build: inspected moving example and arrival banner; tapped banner to open Entry Arch, closed the story, and dismissed the static Reduced Motion banner successfully. Copy and controls fit at normal text size. Restored Reduce Motion off; text size remains 3. Prior broader acceptance remains separate from this narrow review.

Used existing user-enabled permission state; did not accept a permission prompt, tap Start my visit, reset progress, or change saved tracking preferences. Onboarding replay uses the temporary -onboardingProcess NO launch argument. No new simulator or runtime changes in this polish pass.

## Installed provenance

Both installed binaries exactly match the successful build:

- `Poly Canyon` SHA-256: `6df30b161e93eebcdf5da6c992b39cf52b30e7db63733f2201270cb3c5d997e1`
- `Poly Canyon.debug.dylib` SHA-256: `0af995b8d7789e30b8c92e923bff7c393a49b321757b9627947da7c0e6a7fee6`

Artifact directory: `/Volumes/SSK Drive/Developer/Redesign/ThirdPass/VisitPolish/`. The post-commit `manifest.txt` records the exact commit and archived application path.

## Handoff

Simulator ownership released after this review. It is left on the in-person example with normal motion, without starting a visit. Coordinator should prepare virtual onboarding for Parker. No publication or release approval is implied.
