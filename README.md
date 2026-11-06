# Flutter Mobile Test Automation Framework — Patrol + Dart

[![Android Patrol tests](https://github.com/vivekkyadav/flutter-patrol-automation-framework/actions/workflows/android-patrol.yml/badge.svg)](https://github.com/vivekkyadav/flutter-patrol-automation-framework/actions/workflows/android-patrol.yml)

A cross-platform UI test automation framework for a real, open-source Flutter
application, built with [Patrol](https://patrol.leancode.co) (by LeanCode).

The goal of this repository is not only to automate a few screens, but to show
how a maintainable mobile automation framework is **designed, justified,
executed in CI and documented**:

- a deliberate tool choice, recorded as an Architecture Decision Record
  ([ADR-001](docs/ADR-001-why-patrol.md))
- a layered design (tests → flows → screen robots → app) with deterministic test data
- functional, negative and native (OS-level) scenarios
- tagged suites (`smoke`, `regression`, `native`) runnable locally and in GitHub Actions
- honest, evidence-based status reporting ([Execution log](docs/EXECUTION_LOG.md))

---

## Project status

| Gate | Description | Status |
|---|---|---|
| G1 | Application selected, source vendored, licence checked | ✅ Done |
| G2 | Patrol integrated (pubspec, Android runner, orchestrator) | ✅ Done — verified by a local emulator run |
| G3 | First Patrol test passes on an Android emulator | ✅ Done locally (API 34 emulator, 2026-11-07) — ⏳ CI run pending |
| G4 | Framework architecture (robots, flows, config, tags) | ✅ Done |
| G5 | Functional coverage: 12 smoke + regression scenarios (8 files) | ✅ 12/12 pass locally — ⏳ CI run pending |
| G6 | Native interactions: 4 scenarios (background, dark mode, back, share sheet) | ✅ 4/4 pass locally — ⏳ CI run pending |
| G7 | iOS simulator execution | ⏳ Needs Xcode setup — see [iOS setup](docs/IOS_SETUP.md) |
| G8 | CI: GitHub Actions, emulator, JUnit summary, report artifacts | ✅ Workflow written — ⏳ first run pending |
| G9 | Reporting beyond JUnit (Allure) and stability metrics | 🗺️ Roadmap |

> **Every pass claim here links to a recorded run.** The
> [execution log](docs/EXECUTION_LOG.md) records each verified result
> (local runs now; CI results once the workflow has run).

---

## Application under test

**Compass** — a travel planning and booking sample app from the official
[flutter/samples](https://github.com/flutter/samples/tree/main/compass_app)
repository (BSD-3-Clause, © The Flutter Authors). It was chosen because it
behaves like a real product rather than a demo:

- several screens: trip list, search form, results grid, activity picker, booking details
- form validation, a date range picker, horizontal and vertical scrolling, swipe-to-delete
- MVVM architecture with `go_router` navigation and dependency injection
- a **development configuration with local JSON data**, so tests do not depend on a live backend
- OS integration points: the system share sheet, dark mode and the Android back button

The app source lives in [`app/`](app/) with only the changes Patrol needs (see
[Changes to the upstream app](#changes-to-the-upstream-app)). Upstream snapshot:
`flutter/samples@21c71902` (October 2026).

## Technology stack

| Area | Choice |
|---|---|
| UI test framework | Patrol 4.x (`patrol`, `patrol_cli`) |
| Language | Dart (same language as the app) |
| Test runner on Android | `PatrolJUnitRunner` + AndroidX Test Orchestrator |
| Design pattern | Screen robots + reusable flows |
| CI | GitHub Actions, Android emulator (API 34) via `reactivecircus/android-emulator-runner` |
| Reports | JUnit XML + Gradle HTML report (artifacts), JUnit summary on the PR/run |

---

## Why Patrol?

Short version: the app is written in Flutter, its source code is available, and
the tests must reach both **Flutter widgets** and the **operating system**
(home button, permissions, dark mode, system dialogs). Patrol is designed for
exactly that combination, and it keeps the whole stack in one language with no
extra automation server.

```
Previous attempt:  TypeScript → WebdriverIO → Appium server → Flutter driver → app
This project:      Dart tests → Patrol (native runner + Flutter test binding) → app
```

Full reasoning, alternatives and trade-offs: **[ADR-001 — Why Patrol](docs/ADR-001-why-patrol.md)**.

### How it compares

| | Patrol | Flutter `integration_test` | Appium Flutter Driver | Appium Flutter Integration Driver | Appium UiAutomator2 / XCUITest | Maestro | Selenium / Playwright |
|---|---|---|---|---|---|---|---|
| Finds Flutter widgets by type/key/text | Yes | Yes | Yes (via Dart VM service) | Yes | Only via accessibility/semantics | Only via accessibility/semantics | No (web only) |
| Native OS interactions (permissions, home, notifications, settings) | Built in | No | Via switching to native context | Via underlying native driver | Yes | Yes | No |
| Test language | Dart | Dart | Any Appium client | Any Appium client | Any Appium client | YAML | JS/Java/Python… |
| Extra server / process | No | No | Appium server | Appium server | Appium server | Maestro CLI | Browser driver |
| Needs app source or a special build | Yes | Yes | Yes (driver extension enabled) | Yes (test server in the app) | No — works on any APK/IPA | No | n/a |
| Best fit | Flutter teams owning the code | Pure in-app flows | Teams with Appium infrastructure | Teams with Appium infrastructure | Black-box testing of any mobile app | Fast black-box flows | Web apps |

### Why not the others (for *this* project)

- **Flutter `integration_test`** — Patrol builds on it, but plain `integration_test`
  cannot leave the Flutter view: no permission dialogs, notifications, home button
  or system settings, and no test isolation between tests.
- **Appium Flutter Driver / Flutter Integration Driver** — valid, maintained tools,
  especially where Appium infrastructure already exists. Here they would add an
  Appium server, a separate client language and context switching between Flutter
  and native, while still requiring a special app build. My earlier framework on
  this stack (WebdriverIO + Appium Flutter drivers) did not reach stable execution;
  that experience is context for this choice, **not** proof that Appium is unstable.
- **Appium UiAutomator2 / XCUITest** — the right choice for black-box testing of an
  APK/IPA you don't own. With source access, Patrol's direct widget finders are more
  precise than relying on semantics labels.
- **Maestro** — quick to start and black-box, but YAML flows and accessibility-only
  selectors make a reusable, typed framework (robots, data helpers) harder to build.
- **Selenium / Playwright** — browser automation tools. They do not drive native
  Android/iOS apps. (Patrol itself uses Playwright under the hood for Flutter **web**.)

---

## Architecture

```
flutter-patrol-automation-framework/
├── .github/workflows/android-patrol.yml   # CI: analyze, unit tests, Patrol on emulator
├── scripts/run_android_tests.sh           # one command for local and CI runs
├── docs/                                  # ADR, architecture, strategy, iOS, execution log
└── app/                                   # Compass app (upstream) + Patrol
    ├── lib/                               # application code (one bug fix, see below)
    ├── android/app/src/androidTest/…/MainActivityTest.java   # Patrol ↔ JUnit bridge
    └── patrol_test/
        ├── support/
        │   ├── compass_harness.dart       # compassTest() wrapper + launchCompass()
        │   ├── compass_app_robot.dart     # facade over all robots + multi-screen flows
        │   ├── robots/                    # one robot per screen (selectors live here only)
        │   ├── test_data.dart             # seed data, dates, asset-driven expectations
        │   ├── test_config.dart           # timeouts and settle policy
        │   └── tags.dart                  # smoke / regression / native / android-only
        ├── smoke/
        ├── functional/
        └── native/
```

A test reads like the user journey; selectors never appear in test files:

```dart
compassTest('user books Amalfi Coast …', tags: [TestTags.smoke, TestTags.regression], ($) async {
  await launchCompass($);
  final app = CompassAppRobot($);

  await app.searchTrips(continent: TestData.europe, guests: 2);
  await app.results.openDestination(TestData.amalfiCoast);
  await app.activities.toggleActivity(TestData.scenicBoatTourRef);
  await app.activities.confirm();

  await app.booking.waitUntilLoaded();
  app.booking.expectDestination(TestData.amalfiCoast);
});
```

Details: [Architecture](docs/ARCHITECTURE.md) · [Test strategy](docs/TEST_STRATEGY.md)

## Test inventory

| Suite | File | Scenario |
|---|---|---|
| smoke | `smoke/app_launch_test.dart` | App opens on the trip list with the user and default booking |
| smoke | `smoke/open_booking_test.dart` | Open an existing booking, return home |
| smoke, regression | `functional/create_booking_test.dart` | End-to-end booking with two activities |
| regression | `functional/search_form_validation_test.dart` | Search disabled until form complete · guest counter floor · continent deselect |
| regression | `functional/results_filter_test.dart` | Results contain only the chosen continent (expectations read from app assets) |
| regression | `functional/activities_selection_test.dart` | Confirm enabled only with ≥1 activity; select/unselect |
| regression | `functional/delete_booking_test.dart` | Swipe to delete + confirmation snackbar |
| regression | `functional/navigation_test.dart` | Home/back buttons; abandoning a flow creates no booking |
| native | `native/app_lifecycle_test.dart` | Background with Home, reopen, state kept |
| native | `native/dark_mode_test.dart` | App follows system dark mode (restored afterwards) |
| native, android-only | `native/system_back_test.dart` | Android back on search returns to trip list |
| native, android-only | `native/share_sheet_test.dart` | Share Trip opens the system sheet; app recovers |

---

## Run the tests locally (Android)

Prerequisites: Flutter (stable, Dart ≥ 3.9), Android SDK, an emulator or device,
JDK 17.

```bash
git clone https://github.com/vivekkyadav/flutter-patrol-automation-framework.git
cd flutter-patrol-automation-framework/app

flutter pub get
flutter pub global activate patrol_cli      # add ~/.pub-cache/bin to PATH
patrol doctor                               # Android checks should be green

# start an emulator, then from the repository root:
scripts/run_android_tests.sh                       # everything
PATROL_TAGS=smoke scripts/run_android_tests.sh     # smoke suite only

# or a single file while developing:
cd app && patrol develop -t patrol_test/functional/create_booking_test.dart
```

On **Windows** (no bash), run Patrol directly from `app/`. Pass `--device`
when Chrome/Edge are also listed as devices, otherwise Patrol prompts for one:

```powershell
patrol test --device emulator-5554                  # everything
patrol test --device emulator-5554 --tags smoke     # smoke suite only
```

The Android emulator on Windows needs **Windows Hypervisor Platform**
(`Enable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform -All`
as Administrator, then restart); `emulator -accel-check` should report WHPX.

Reports: `app/build/app/reports/androidTests/connected/debug/index.html` (HTML) and
`app/build/app/outputs/androidTest-results/` (JUnit XML).

iOS: see [docs/IOS_SETUP.md](docs/IOS_SETUP.md) (one-time Xcode target setup).

## Continuous integration

[`android-patrol.yml`](.github/workflows/android-patrol.yml) runs on every push and
pull request:

1. **Static checks** — `flutter analyze` (compiles and type-checks the app *and*
   all Patrol tests) and the app's upstream unit tests.
2. **Android E2E** — boots a Pixel 6 / API 34 emulator with KVM, runs the Patrol
   suite, uploads JUnit/HTML reports and publishes a test summary.

Run it manually with a tag expression from the **Actions** tab
(`workflow_dispatch` → `tags`).

---

## Changes to the upstream app

What Patrol needs, plus one bug fix found by the suite:

- `pubspec.yaml`: removed the monorepo-only `resolution: workspace` and
  `analysis_defaults` entries; added `patrol` to `dev_dependencies` and a
  `patrol:` configuration block.
- `android/app/build.gradle`: Patrol test runner, `clearPackageData`, Android
  Test Orchestrator, no minification for debug, Java 11 target.
- `android/settings.gradle`, `gradle-wrapper.properties`: Gradle 8.14.3,
  AGP 8.11.1, Kotlin 2.2.20 — the minimums Flutter 3.47 accepts.
- **Bug fix** in `lib/ui/home/widgets/home_screen_container.dart`: a booking
  created via Search → Booking → Home did not appear on the Home list until
  the app restarted, because the container kept one `HomeViewModel` alive for
  the lifetime of the `/` page. It now reloads when the route is rebuilt.
  Found by `create_booking_test`; upstream's own
  `integration_test/app_local_data_test.dart` failed the same way.
- `android/app/src/androidTest/.../MainActivityTest.java`: Patrol's JUnit bridge
  (from the official setup guide).
- Removed the desktop and web platform folders, which this project does not test.

## Engineering decisions & lessons learned

- **Validation gates before breadth.** The previous Appium-based attempt grew
  complex before it ran reliably. This project tracks gates (G1–G9) and does not
  mark a gate done without evidence.
- **Deterministic data over clever waits.** Tests use the app's local-data
  configuration, Patrol's per-test app restart (orchestrator + `clearPackageData`),
  and read expectations from the same JSON the app loads.
- **Date pickers in text-input mode.** Tapping calendar day numbers breaks around
  month ends; typing dates using `MaterialLocalizations` works on any day.
- **Device-wide side effects are always undone** (dark mode is restored in `finally`).
- **Keep the Appium comparison fair.** Documented capabilities, personal experience
  and measured results are kept separate.

## Roadmap

- [ ] First green CI run on Android; record results in the execution log (G3, G5, G6, G8)
- [ ] iOS simulator run (G7) and a macOS CI job
- [ ] Staging configuration: login/logout against the bundled Dart server (`adb reverse`)
- [ ] Allure reporting via a custom `PatrolJUnitRunner` (Patrol's Android Allure integration)
- [ ] Flakiness metrics: N repeated CI runs, pass rate per test
- [ ] Measured comparison: the same 5 scenarios in Appium + WebdriverIO vs Patrol
      (implementation effort, run time, stability) — published with methodology

## Credits and licence

- Compass app: © The Flutter Authors, BSD-3-Clause — see
  [`app/LICENSE-compass-app`](app/LICENSE-compass-app).
- Patrol: © LeanCode, Apache-2.0.
- Test framework, documentation and CI in this repository: © vivekkyadav, MIT — see [LICENSE](LICENSE).
