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

### 2026-11-06 — first GitHub Actions run (CI)

- **Run:** [Android Patrol tests #1](https://github.com/vivekkyadav/flutter-patrol-automation-framework/actions/runs/42299586045),
  push of `0c2190c` to `main`.
- **Result:** ✅ success. Job "Analyze + unit tests" (analyze, 67 unit tests)
  passed in about 2 min. Job "Patrol on Android emulator" (API 34, Pixel 6, KVM, all tags)
  passed in about 13.5 min. The JUnit and HTML reports were uploaded as the `patrol-android-reports` artifact.
- **Issue:** the "Patrol Android results" check was not published.
  `mikepenz/action-junit-report` needs `checks: write`, and the default
  `GITHUB_TOKEN` is read-only on new repositories. Fix: added a workflow-level
  `permissions:` block (`contents: read`, `checks: write`). Verify on the next run.
- **Gates closed:** G3, G5, G6 and G8 (CI).

### 2026-11-06 — CI run #2: share sheet flake (investigated locally)

- **Run:** [#2](https://github.com/vivekkyadav/flutter-patrol-automation-framework/actions/runs/42302026511), push of `5617557`.
  Attempt 1 failed before any test ran: the system-image download on the runner was corrupt
  ("Error on ZipFile unknown archive"). Attempt 2: the "Patrol Android results" check was published
  (the `checks: write` fix works) with 15/15 passed, but the job failed with
  "Expected 16 tests, received 15. Test instrumentation process crashed" on
  `native/share_sheet_test`. The emulator logged a gfxstream `glWaitSync error 0x501` shortly before.
- **Local reproduction** (API 34, `-gpu swiftshader_indirect`, `-no-window`, animations off):

  | Variant | Runs | Passed | Notes |
  |---|---|---|---|
  | Original test (fixed 2 s delay, then Back) | 10 | 10 | chooser took 1.4–1.9 s to display; Back sometimes only ~0.1 s after it |
  | Native view-tree queries on the chooser package | 10 + 15 | 8 + 11 | "A SemanticsHandle was active at the end of the test" (1–2×); 3× "instrumentation crashed" |
  | **Lifecycle-based** (final) | 15 | **15** | cold emulator |
  | Full suite with the final version, back to back | 2 | **16/16, 16/16** | 8m 33s, 8m 30s |

- **Findings:**
  1. The fixed 2 s delay before Back has almost no margin even on an accelerated emulator,
     so on the slower CI runner Back can arrive while the chooser is still launching.
     Fix: `ShareSheetRobot` waits until the app leaves `resumed` (chooser in front),
     presses Back, then waits for `AppLifecycleState.resumed` before asserting.
  2. Native view-tree queries (`waitUntilVisible`/`getNativeViews`) run through Android
     accessibility and can switch Flutter semantics on mid-test, which fails flutter_test's
     end-of-test check. The robot avoids them.
  3. The "instrumentation process crashed" signature reproduced locally (3/15) on an emulator
     that had already run about 25 instrumentations. Logcat:
     `ActivityTaskManager: Destroy timeout of remove-task` for the previous instrumentation's task,
     then `Killing <new pid>:com.example.compass_app ... remove task` before the new test
     process attached. That is a teardown race in the Orchestrator/`clearPackageData` cycle,
     not the share-sheet logic. It did not occur on a cold emulator (0 in 15 + 32 test runs).
- **Diagnostics added:** `scripts/run_android_tests.sh` now streams logcat for the whole run
  and, on failure, saves `dumpsys activity`, a screenshot, the tombstone list and a crash-signature
  grep under `app/build/app/reports/androidTests/diagnostics/` (uploaded by CI).
- **Open:** if CI shows the remove-task kill again, the next step is to test the suite without
  `clearPackageData`. The local-data configuration persists nothing to disk (SharedPreferences
  is only used by the remote/staging providers), so per-test isolation would still come from
  the Orchestrator's fresh process.

### 2026-11-07 — CI run #3: instrumentation crashes traced to `clearPackageData`

- **Run:** [#3](https://github.com/vivekkyadav/flutter-patrol-automation-framework/actions/runs/42317960410), commit `8ccc5f2`.
  "Expected 16 tests, received 14": "Test instrumentation process crashed" for
  `navigation_test` ("Back on the activities screen…") and `search_form_validation_test`
  ("tapping the selected continent again…"). 14/14 reported tests passed. Run #2's victim was
  `share_sheet_test`, so the victim varies.
- **Root cause** (from local logcat, comparing a killed run with a passing one):
  - Passing run: the previous test's process exits, *then* the Orchestrator's
    `clearPackageData` runs `pm clear` ("Force stopping … clear data").
  - Killed run: `pm clear` arrives ~20 ms *before* the old process exits, while its window CLOSE
    transition is in flight ("removeAppToken: Attempted to remove non-existing token").
    The task is left half-removed. About 1 s later, `ActivityTaskManager: Destroy timeout of
    remove-task` kills the app's process, which by then is the **next** test's freshly
    started process ("Killing <pid> … remove task", "failed to attach").
  - It is a race, so it gets likelier as the emulator slows down over a long run. That matches CI
    (crashes late in the suite) and the local repro (only after about 25 instrumentations).
- **Fix:** removed `testInstrumentationRunnerArguments clearPackageData: "true"`. Isolation
  is unchanged in practice: the Orchestrator still starts a new process per test, and the
  local-data configuration keeps all state in memory (no SharedPreferences, files or DB).
  Documented in `build.gradle` and `docs/ARCHITECTURE.md`. Re-enable it if tests start persisting data.
- **Verification:** 3 full suites back to back on the same long-running emulator
  (about 50 earlier instrumentations, swiftshader, no window): **16/16, 16/16, 16/16**
  (8m11s, 8m03s, 7m53s). 0 `pm clear` runs and 0 remove-task kills in logcat.
- **CI diagnostics:** the script now also prints `crash_summary.txt` (including remove-task
  lines) into the step log, so it can be read without downloading the artifact.

<!--
Template for new entries:

### YYYY-MM-DD — <what was run>
- Run: <link to GitHub Actions run>
- Result: <passed>/<total> passed, duration <mm:ss>
- Failures and fixes: <test> — <root cause> — <fix commit>
- Gates closed: G3 / G5 / G6 / G8
-->
