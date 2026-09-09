#!/bin/bash
set -euo pipefail
repo="$(cd "$(dirname "$0")/../.." && pwd)"
build_root="${POLYCANYON_BUILD_ROOT:-$repo/swift/.build}"
checks="$build_root/Checks/PolyCanyon"
cache="$build_root/DerivedData/PolyCanyon/ModuleCache.noindex"
mkdir -p "$checks"
xcrun swiftc -module-cache-path "$cache" \
 "$repo/swift/Poly Canyon/Views/Map/CanyonAtlasGeometry.swift" \
 "$repo/swift/Tests/AtlasGeometryChecks.swift" -o "$checks/atlas-checks"
"$checks/atlas-checks"
xcrun swiftc -module-cache-path "$cache" \
 "$repo/swift/Poly Canyon/Views/Map/CanyonMapGeometry.swift" \
 "$repo/swift/Tests/MapCameraChecks.swift" -o "$checks/map-camera-checks"
"$checks/map-camera-checks"
