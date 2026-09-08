#!/bin/bash
set -euo pipefail

# Usage: DEVELOPER_DIR=/path/to/Xcode.app/Contents/Developer bash swift/scripts/run-simulator.sh [build|run] [simulator-uuid]
# Uses an existing simulator; never installs Xcode or runtimes.
mode="${1:-run}"
device="${2:-A94E4457-3DC6-496A-8F51-4B13D52DD557}"
case "$mode" in build|run) ;; *) echo "Usage: $0 [build|run] [simulator-uuid]" >&2; exit 2 ;; esac
repo="$(cd "$(dirname "$0")/../.." && pwd)"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Volumes/SSK Drive/Applications/Xcode.app/Contents/Developer}"
developer_root="/Volumes/SSK Drive/Developer"
derived="$developer_root/DerivedData/PolyCanyon"
packages="$developer_root/Packages/PolyCanyon"
logs="$developer_root/Logs/PolyCanyon"
mkdir -p "$derived" "$packages" "$logs"
export CLANG_MODULE_CACHE_PATH="$derived/ModuleCache.noindex"
stamp="$(date +%Y%m%d-%H%M%S)"

xcodebuild -project "$repo/swift/Poly Canyon.xcodeproj" \
  -scheme 'Poly Canyon' -configuration Debug \
  -destination "platform=iOS Simulator,id=$device" \
  -derivedDataPath "$derived" -clonedSourcePackagesDirPath "$packages" \
  -resultBundlePath "$logs/build-$stamp.xcresult" \
  CODE_SIGNING_ALLOWED=NO build 2>&1 | tee "$logs/build-$stamp.log"

if [[ "$mode" == build ]]; then exit 0; fi
device_state="$(xcrun simctl list devices available -j | python3 -c 'import json,sys; print(next((d["state"] for group in json.load(sys.stdin)["devices"].values() for d in group if d["udid"] == sys.argv[1]), "Unavailable"))' "$device")"
if [[ "$device_state" == Shutdown ]]; then xcrun simctl boot "$device"; fi
xcrun simctl bootstatus "$device" -b
app="$derived/Build/Products/Debug-iphonesimulator/Poly Canyon.app"
bundle_id="$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "$app/Info.plist")"
xcrun simctl install "$device" "$app"
xcrun simctl launch --terminate-running-process "$device" "$bundle_id" \
  2>&1 | tee "$logs/launch-$stamp.log"
echo "Launched $bundle_id on $device. Logs: $logs"
