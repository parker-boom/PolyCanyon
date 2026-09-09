# Android retirement

The maintained application is iOS only. The current tree contains no React Native application, Gradle project or wrapper, Android manifest, JavaScript package manifest, Metro/Babel configuration, Firebase client configuration, or Android signing key. CI builds only iOS.

Original content remains in [assets/retired-android](../assets/retired-android/README.md): 166 files with a SHA-256 preservation manifest, including alternate photo exports, maps, launcher artwork, and historical event content. These are not an executable project and are not bundled into iOS. Older campaign designs are clearly separated in [promotional/archive](../promotional/archive/README.md).

The archive tag `archive/android-before-retirement-20260908` preserves the pre-retirement source in GitHub. Other archived design tags preserve unselected prototypes; they are not active branches. Do not restore or execute the old tooling as part of app setup.

## Old distribution and accounts

The retired tree contained exposed Android signing material. Removing it from main does not revoke it or erase Git history. Its remediation depends on the original Play Console signing setup. The historical Firebase service likewise belongs to old-client and data ownership, not the maintained app’s runtime.

Those account facts cannot be certified by a source cleanup. No key revocation, Play Console signing reset, or historical data deletion is claimed here. The [dated retirement audit](history/SECURITY_CLEANUP.md) preserves the original evidence without treating its old alert counts as current status.
