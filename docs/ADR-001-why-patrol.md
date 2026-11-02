# ADR-001: Use Patrol as the UI test framework for the Compass Flutter app

- **Status:** Accepted
- **Date:** 2026-11-02
- **Deciders:** vivekkyadav

## Context

We need an end-to-end UI automation framework for a Flutter mobile app
(Compass, from `flutter/samples`) that:

1. runs on **Android and iOS** from one test code base;
2. can locate **Flutter widgets** reliably (by type, key, text) — Flutter draws
   its own UI, so the native view hierarchy does not contain normal buttons and
   labels for every widget;
3. can drive the **operating system** as well: home button, app backgrounding,
   permission dialogs, dark mode, notifications, the Android back button and
   system sheets;
4. isolates tests from each other so one failure does not cascade;
5. runs in **CI** on an emulator with standard (JUnit) reports;
6. is maintainable by a small team and easy to read for reviewers.

We have full access to the app's source code and build.

**Prior experience.** An earlier framework built on TypeScript + WebdriverIO +
Appium (Appium Flutter Driver and Appium Flutter Integration Driver) did not
reach reliable execution. Contributing factors were the number of moving layers
(client, Appium server, Flutter driver, app build flags), switching between
Flutter and native contexts, and element identification across platforms. This
is recorded as context, not as evidence about Appium in general.

## Options considered

| Option | Summary |
|---|---|
| A. Patrol | Dart tests on top of Flutter's test binding, plus a native automator (UIAutomator on Android, XCUITest on iOS) and a JUnit/XCTest runner. |
| B. Flutter `integration_test` | Official Flutter package; Dart tests with widget finders, runs on device. |
| C. Appium + Flutter Driver | Appium driver talking to the app's Dart VM service; any client language. |
| D. Appium + Flutter Integration Driver | Appium driver backed by a test server compiled into the app. |
| E. Appium UiAutomator2 / XCUITest | Native black-box automation through accessibility. |
| F. Maestro | YAML flows, black-box, accessibility-based selectors. |
| G. Selenium / Playwright | Browser automation. |

## Decision criteria and assessment

| Criterion | A Patrol | B integration_test | C/D Appium Flutter drivers | E Appium native | F Maestro | G Selenium/Playwright |
|---|---|---|---|---|---|---|
| Flutter widget finders | ✅ | ✅ | ✅ | ⚠️ semantics only | ⚠️ semantics only | ❌ |
| Native/OS interactions | ✅ built in | ❌ | ⚠️ native context switch | ✅ | ✅ | ❌ |
| One language with the app (Dart) | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| No extra server process | ✅ | ✅ | ❌ | ❌ | ⚠️ CLI | n/a |
| Per-test isolation | ✅ orchestrator / restart | ❌ shared process | ⚠️ manual | ⚠️ manual | ✅ | n/a |
| Native reports (JUnit/xcresult) | ✅ | ⚠️ | ✅ via client | ✅ via client | ✅ | n/a |
| Works without app source | ❌ | ❌ | ❌ | ✅ | ✅ | n/a |
| Mobile apps at all | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |

✅ meets · ⚠️ partially / with extra work · ❌ does not meet

## Decision

Use **Patrol** (option A).

It is the only option that meets all six requirements together for an app whose
source we own: Flutter-level finders **and** OS-level automation, Dart-only tests,
no Appium server, test isolation through Android Test Orchestrator, and standard
JUnit output that CI understands.

## Consequences

**Positive**
- Fewer layers to install, version and debug (no Appium server, no client SDK).
- Tests can import the app's own key constants (`bookingButtonKey`, …), so
  selectors stay in sync with the code.
- Native scenarios (backgrounding, dark mode, system back, share sheet) live in
  the same suite as functional ones.
- Each test starts a fresh app process with cleared data — no ordering dependencies.

**Negative / trade-offs**
- Requires source access and a dedicated test build; Patrol cannot test an
  arbitrary third-party APK/IPA. (For that, option E remains the right tool.)
- Tests must be written in Dart; QA engineers coming from JS/Java need ramp-up.
- iOS needs a one-time Xcode `RunnerUITests` target setup.
- `flutter test` cannot run the suite; the Patrol CLI is required.
- Smaller ecosystem than Appium: fewer device-farm plugins and reporting
  integrations (Allure is supported on Android only via a custom runner).

**Neutral**
- Patrol is open source (Apache-2.0) and actively maintained by LeanCode; the
  project pins major versions (`patrol: ^4.9.0`) to control upgrades.

## Validation plan

The decision is confirmed only by evidence, tracked in
[EXECUTION_LOG.md](EXECUTION_LOG.md):

1. First Patrol test green on an Android emulator in CI.
2. Full suite green on 5 consecutive CI runs (stability).
3. iOS simulator run.
4. Optional follow-up: implement 5 identical scenarios in Appium + WebdriverIO
   and compare implementation time, run time and pass rate.

If (1)–(2) cannot be achieved within reasonable effort, this ADR is revisited.
