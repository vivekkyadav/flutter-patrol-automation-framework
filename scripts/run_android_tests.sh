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

echo "Running: patrol ${args[*]}"
patrol "${args[@]}"
