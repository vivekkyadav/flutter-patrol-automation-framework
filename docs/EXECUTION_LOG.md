# Execution log

Evidence for every status claim in the README. A gate is marked done only with
a link to a run, a log or a report.

## Environment baseline

| Item | Value |
|---|---|
| App source | `flutter/samples` @ `21c71902bb2c7da3cce328ba5946cba2f35a660a` (2026-10-20), `compass_app/app` |
| Patrol (package) | `^4.9.0`, resolved to 4.11.0 (`pubspec.lock`) |
| Patrol CLI | latest from pub.dev at run time (≥ 4.7.0 required for patrol ≥ 4.9.0); 4.9.0 used locally |
| Flutter | stable channel (3.47.9 verified); app requires Dart ≥ 3.9 |
| CI device | Android emulator, API 34, `google_apis`, x86_64, Pixel 6 profile |

## Log

### 2026-11-02 — framework authored (not executed)

- Vendored the Compass app and integrated Patrol (pubspec, Gradle runner,
  orchestrator, `MainActivityTest.java`).
- Wrote 17 scenarios in 12 test files, the robot layer, CI workflow and docs.
- Selectors and data were taken from the app's source (keys, widget types,
  seed data, localization strings) and Patrol APIs were checked against
  Patrol's source on GitHub (`leancodepl/patrol`, Nov 2026).
- **Not yet compiled or executed.** The authoring environment had no Flutter SDK
  or Android emulator (Flutter and pub.dev downloads were blocked there).
- Next: push to GitHub and let `android-patrol.yml` run. Expect a short fix-up
  loop on the first run (analyzer findings, timing); record the outcome below.

### 2026-11-06 — first static analysis and unit tests

- Environment: Flutter 3.47.9 stable (Dart 3.13.7), Linux, no Android SDK or emulator.
- `flutter pub get`: resolved.
- `flutter analyze`: 20 errors on first run. Root cause: our `Tags` class
  clashed with `Tags` exported by `flutter_test` (`test_api`), so every
  `Tags.smoke` etc. failed to resolve. Fix: renamed it to `TestTags`.
  After the fix: **No issues found**.
- `flutter test` (the Compass app's own unit and widget tests): **67/67 passed**.
- Patrol UI tests: **still not executed**. They need an Android emulator, which
  runs in the `android-patrol.yml` workflow on GitHub Actions.

### 2026-11-07 — first Patrol run on an Android emulator (local, Windows)

- **Run:** local, not CI. Windows 11 Pro (i5-1135G7, 16 GB RAM), emulator
  accelerated by WHPX.
- **Environment:** Flutter 3.47.9 stable (Dart 3.13.7) · Temurin JDK 17.0.21 ·
  Patrol CLI 4.9.0 · `patrol` package 4.11.0 (resolved from `^4.9.0`,
  now pinned in `pubspec.lock`) · Android emulator 37.2.13 · AVD API 34
  `google_apis` x86_64, Pixel 6 profile (same as CI) · Gradle 8.14.3 / AGP 8.11.1 / Kotlin 2.2.20.
- **Static checks:** `flutter analyze`: no issues. `flutter test`: **67/67 passed**.
- **Builds:** `flutter build apk --release` (54.6 MB) and
  `flutter build appbundle --release` (53.3 MB) succeed. `patrol build android` succeeds.
- **Patrol results (final, after fixes):**

  | Command | Result | Duration |
  |---|---|---|
  | `patrol test --device emulator-5554` (all) | **16/16 passed**, 0 skipped | 6m 56s |
  | `--tags smoke` | 3/3 passed | 1m 55s |
  | `--tags native` | 4/4 passed | 2m 06s |

  The suite has **16 scenarios in 12 files** (12 smoke/regression, 4 native).
  The "17 scenarios" in the 2026-11-02 entry and "13 smoke + regression" in
  the README were miscounts; the README now says 12.
- **Failures and fixes** (each its own commit):
  1. Android build failed: the project pinned Gradle 8.7 / AGP 8.6.0 / Kotlin
     2.1.0, below Flutter 3.47's minimums (8.14 / 8.11.1 / 2.2.20). Bumped to
     those minimums; Flutter still warns that Gradle 9.1, AGP 9.0.1 and Kotlin 2.3.20 will
     be required later. CI uses latest stable Flutter and would have failed the same way.
  2. `patrol build` failed to compile: `support/compass_test.dart` matched
     Patrol's `*_test.dart` pattern and was bundled as a test without `main()`.
     Renamed to `support/compass_harness.dart`.
  3. Timing: `HomeRobot.expectBooking`/`expectTitle` asserted synchronously
     while the Home list loads asynchronously. They now wait (`waitUntilExists`).
     The "abandon flow" navigation test now waits for the list before
     asserting an absence, so it cannot pass vacuously.
  4. **App bug** (smoke `create_booking_test`): a booking created via
     Search → Booking → Home did not appear on Home. `HomeScreenContainer`
     keeps one `HomeViewModel` for the lifetime of the `/` page and never
     reloads it. Upstream's own `integration_test/app_local_data_test.dart`
     ("Create booking") failed the same way on this emulator. Fixed in
     `lib/ui/home/widgets/home_screen_container.dart` (reload when the route is
     rebuilt). Afterwards the upstream integration test passed 3/3 and unit tests 67/67.
  5. `SearchFormRobot.guestCount` read the "Who" label instead of the counter
     (two nested Rows both contain the -/+ buttons) → `FormatException`.
     It now uses the nearest Row around the - button.
- **Environment notes:** with Chrome/Edge installed, `patrol test` asks
  which device to use; pass `--device emulator-5554`. Kotlin's "Could not close incremental caches"
  messages appear because the pub cache (C:) and the project (D:) are on different
  drives. They are harmless; Gradle falls back to a non-incremental build.
- **Gates:** G2, G3 (local), G5 and G6 verified locally. G8 (CI) is still pending the first
  GitHub Actions run.

<!--
Template for new entries:

### YYYY-MM-DD — <what was run>
- Run: <link to GitHub Actions run>
- Result: <passed>/<total> passed, duration <mm:ss>
- Failures and fixes: <test> — <root cause> — <fix commit>
- Gates closed: G3 / G5 / G6 / G8
-->
