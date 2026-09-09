#!/bin/bash
set -euo pipefail
repo="$(cd "$(dirname "$0")/../.." && pwd)"
# xcrun respects DEVELOPER_DIR when supplied, otherwise the selected Xcode.
build_root="${POLYCANYON_BUILD_ROOT:-$repo/swift/.build}"
checks="$build_root/Checks/PolyCanyon"
cache="$build_root/DerivedData/PolyCanyon/ModuleCache.noindex"
mkdir -p "$checks"
data="$repo/swift/Poly Canyon/Core/Data"
xcrun swiftc -module-cache-path "$cache" "$data/Models.swift" "$data/CatalogPersistence.swift" \
 "$repo/swift/Tests/ModelChecks.swift" -o "$checks/model-checks"
"$checks/model-checks" "$data"
xcrun swiftc -module-cache-path "$cache" "$data/Models.swift" "$data/CatalogPersistence.swift" \
 "$data/DataStore.swift" "$repo/swift/Poly Canyon/Core/AppState.swift" \
 "$repo/swift/Poly Canyon/Core/Location/LocationSamplePolicy.swift" \
 "$repo/swift/Tests/StoreChecks.swift" -o "$checks/store-checks"
"$checks/store-checks" "$data" "$repo/swift/Tests/Fixtures/Legacy"
# Replay the iOS authorization enum on macOS; the fake manager never invokes OS location APIs.
# Real iOS builds still perform normal SDK availability checking.
xcrun swiftc -Xfrontend -disable-availability-checking -module-cache-path "$cache" "$data/Models.swift" "$data/CatalogPersistence.swift" \
 "$data/DataStore.swift" "$repo/swift/Poly Canyon/Core/Location/LocationSamplePolicy.swift" \
 "$repo/swift/Poly Canyon/Core/Location/LocationService.swift" \
 "$repo/swift/Tests/LocationReplayChecks.swift" -o "$checks/location-replay-checks"
"$checks/location-replay-checks" "$data"
xcrun swiftc -module-cache-path "$cache" "$repo/swift/Poly Canyon/Core/OnboardingFlow.swift" \
 "$repo/swift/Tests/OnboardingChecks.swift" -o "$checks/onboarding-checks"
"$checks/onboarding-checks"
