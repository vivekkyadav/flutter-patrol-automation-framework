#!/usr/bin/env bash
# Runs the Patrol suite against a connected Android device or emulator.
#
# Usage (from the repository root or from app/):
#   scripts/run_android_tests.sh                 # all tests
#   PATROL_TAGS=smoke scripts/run_android_tests.sh
#   PATROL_TAGS='regression && !native' scripts/run_android_tests.sh
#
# Used locally and by .github/workflows/android-patrol.yml.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../app"

for tool in flutter patrol adb; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "error: '$tool' not found on PATH." >&2
    echo "See README.md > Run the tests locally." >&2
    exit 1
  fi
done

if ! adb devices | awk 'NR>1 && $2=="device"' | grep -q .; then
  echo "error: no Android device/emulator connected (adb devices is empty)." >&2
  exit 1
fi

args=(test --verbose)
if [[ -n "${PATROL_TAGS:-}" ]]; then
  args+=(--tags "$PATROL_TAGS")
fi

# Diagnostics: stream logcat for the whole run (the emulator's ring buffer
# only holds the last few minutes) and, on failure, capture activity state and
# a screenshot. Written under build/app/reports/androidTests/, which CI
# uploads as the patrol-android-reports artifact.
diag_dir="build/app/reports/androidTests/diagnostics"
mkdir -p "$diag_dir"
adb logcat -c || true
adb logcat -v threadtime > "$diag_dir/logcat.txt" 2>&1 &
logcat_pid=$!

echo "Running: patrol ${args[*]}"
status=0
patrol "${args[@]}" || status=$?

kill "$logcat_pid" 2>/dev/null || true
wait "$logcat_pid" 2>/dev/null || true

if [[ $status -ne 0 ]]; then
  echo "patrol exited with $status; saving diagnostics to app/$diag_dir" >&2
  adb shell dumpsys activity activities > "$diag_dir/dumpsys_activity.txt" 2>&1 || true
  adb shell dumpsys activity processes > "$diag_dir/dumpsys_processes.txt" 2>&1 || true
  adb exec-out screencap -p > "$diag_dir/screen_on_failure.png" 2>/dev/null || true
  adb shell ls /data/tombstones > "$diag_dir/tombstones.txt" 2>&1 || true
  # Short index of crash signatures for a quick look in the artifact.
  grep -E 'FATAL EXCEPTION|Fatal signal|has died|ANR in|crash|tombstone' \
    "$diag_dir/logcat.txt" > "$diag_dir/crash_summary.txt" 2>/dev/null || true
fi

exit "$status"
