# Combined app and security review candidate

8 September 2026. Merged committed `redesign/visual-ios` **82114ed** into the isolated `maintenance/security-lts` worktree, starting from cleanup **4262b50**. This is a coordinator review candidate, not approval to release or publish.

The upstream changes are `30f83cb` (navigation, Tour and onboarding) and `82114ed` (Tour controls and onboarding headings). The merge had no conflicts. All nine upstream files match that revision byte for byte; the Android removal and all preserved content survive. The app checkout was neither edited nor switched. The local recovery tag `archive/android-before-retirement-20260908` remains at **80e12df**.

## Combined verification

- Data check passed: 31 structures, six historical structures, 231 map points and all iOS image references.
- All 166 archived Android files match their original SHA-256 checksums.
- Existing model, persistence, store and foreground-location replay checks passed, including all 35 discoverable structures. Historical structures 105/106 still have no discovery coordinates.
- Generic Debug simulator build passed with Xcode 26.6 and the iOS 26.5 SDK. Only warning: skipped AppIntents metadata extraction because there is no AppIntents framework dependency.
- Built bundle remains version 6.0 (1), with When In Use location permission and no background/Always keys. No archived Android files, Firebase configuration, signing containers, npm manifests or matches for the scoped credential-pattern scan were found. This is not proof that every possible secret format is absent.
- Diff whitespace check passed. No simulator was created, booted, installed to or controlled; no signing, account, remote or publishing action was performed.

Artifacts use `/Volumes/SSK Drive/Developer/SecurityLTS`. Logs:

- `/Volumes/SSK Drive/Developer/SecurityLTS-integration-data.log`
- `/Volumes/SSK Drive/Developer/SecurityLTS-integration-checks.log`
- `/Volumes/SSK Drive/Developer/SecurityLTS-integration-build.log`

## Review boundaries

[Second-pass evidence](swift/SECOND_PASS_REVIEW.md) describes the UI task's verification and remaining hands-on checks. This integration adds build/data/regression validation, not a new visual or physical-device review.

[Security cleanup](SECURITY_CLEANUP.md) records the earlier 4262b50 audit. Its finding that both Swift packages were actively used applied before the new UI merge: the new Tour removes the last Glur import/call, while the project still retains the Glur dependency. This merge preserves upstream project settings; coordinator can review unused Glur separately. Zoomable remains used. No dependency change was folded into integration.

Exposed historical Android signing material and old-client/backend review remain owner actions. The earlier verified 95 GitHub alerts have not been rescanned or changed by this local merge. Publication, default-branch integration, signing and final approval remain separate.
