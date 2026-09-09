# Release and ownership

Parker Jones maintains the app and its App Store listing. The website is a separate project. Repository changes do not update an installed app; ship a new build when behavior or bundled content changes.

## Prepare a release

1. Run [the regression checks](setup.md) and review any changed UI in Simulator.
2. Set the marketing version and a new build number in the existing Xcode project. Keep bundle identifier `Parker-Jones.Arch-Graveyard` so the update reaches the existing app.
3. Archive Release for a generic iOS device using the team’s valid distribution signing. Use Xcode Organizer to validate and upload; keep certificates and provisioning profiles outside Git.
4. Wait for processing in [App Store Connect](https://appstoreconnect.apple.com/apps/6499063781/distribution/ios/version/inflight), attach the intended build, and verify export compliance, contact details, screenshots, and [listing copy](app-store.md).
5. Confirm content rights, age rating, and privacy answers for the version being submitted. Add it for review, then submit. With manual release selected, publish only after approval and a final listing check.

The CI archive is unsigned and checks compilation; it is not the distribution artifact. The existing shared scheme and bundle identifier are intentional.

## 6.0 build 2 preparation

Verified September 9, 2026: release source is merged into main, local regression checks and signed archive/export passed, and build 2 is uploaded and selected in the saved App Store draft. The approved screenshots and revised copy are saved. [The merged-main workflow](https://github.com/parker-boom/PolyCanyon/actions/runs/34404739513) passed its regression checks and both Release builds.

This is a dated preparation record. App Store Connect is the authority for subsequent review and publication status; the draft was set to manual release. These documentation changes do not change the submitted app binary.

## Ongoing operation

No app backend, recurring scan, or dependency-update service is required. CI runs when code is pushed or reviewed. For another release, check toolchain availability, Apple signing validity, and the support/privacy URLs as part of that release. Respond to reported defects or content corrections with a focused change.

Keep original research and release artifacts. If an update needs correction after publication, build and submit a new version; resetting a Git branch does not roll back an App Store release. Preserve stable catalog IDs and migration compatibility so existing visit progress survives.
