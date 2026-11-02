# Execution log

Evidence for every status claim in the README. A gate is marked done only with
a link to a run, a log or a report.

## Environment baseline

| Item | Value |
|---|---|
| App source | `flutter/samples` @ `21c71902bb2c7da3cce328ba5946cba2f35a660a` (2026-10-20), `compass_app/app` |
| Patrol (package) | `^4.9.0` (latest on GitHub at time of writing: 4.10.0) |
| Patrol CLI | latest from pub.dev at run time (≥ 4.7.0 required for patrol ≥ 4.9.0) |
| Flutter | stable channel; app requires Dart ≥ 3.9 |
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

<!--
Template for new entries:

### YYYY-MM-DD — <what was run>
- Run: <link to GitHub Actions run>
- Result: <passed>/<total> passed, duration <mm:ss>
- Failures and fixes: <test> — <root cause> — <fix commit>
- Gates closed: G3 / G5 / G6 / G8
-->
