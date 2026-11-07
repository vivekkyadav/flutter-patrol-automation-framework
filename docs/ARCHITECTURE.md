# Framework architecture

## Layers

```
┌──────────────────────────────────────────────┐
│ Tests          patrol_test/{smoke,functional,native}/*_test.dart
│                What the user does and what must be true.
├──────────────────────────────────────────────┤
│ Flows          CompassAppRobot.searchTrips(), .bookAmalfiCoast()
│                Multi-screen journeys reused by many tests.
├──────────────────────────────────────────────┤
│ Screen robots  support/robots/*_robot.dart
│                The only place that knows selectors and gestures.
├──────────────────────────────────────────────┤
│ Support        compass_harness.dart · test_config.dart · test_data.dart · tags.dart
├──────────────────────────────────────────────┤
│ Patrol         finders ($), native automator ($.platform), JUnit runner
├──────────────────────────────────────────────┤
│ App under test lib/ (upstream + one bug fix), development configuration (local JSON data)
└──────────────────────────────────────────────┘
```

Rules:

- Test files contain **no selectors** — only robot calls and assertions.
- Robots return nothing UI-specific to tests except `PatrolFinder`s for
  assertions; actions are `Future<void>` methods named after user intent
  (`tapBookNewTrip`, `toggleActivity`, `swipeToDelete`).
- Robots never assert business outcomes on their own; small `expect…` helpers
  exist only where they hide a selector.

## Why "robots"

The robot pattern is the Flutter community's equivalent of the Page Object
Model. It fits Flutter better than page objects built around locators because
a Flutter "screen" is a widget tree, and finders are composed from widget
types, keys and text.

## Selector strategy (in order of preference)

1. **Keys exported by the app** — `bookingButtonKey`, `searchFormSubmitButtonKey`,
   `addGuestsKey`, `confirmButtonKey`. Importing the constant means a rename in
   the app breaks compilation of the tests instead of failing at runtime.
2. **Data-derived keys** — `ValueKey('<activity-ref>-checkbox')`, `ValueKey(continentName)`.
3. **Widget types** — `HomeScreen`, `ResultCard`, `HomeButton` scoped to a screen.
4. **Visible text** — only for user-facing content (destination names, snackbars).
5. **`MaterialLocalizations`** for framework widgets (date picker labels), never
   hard-coded English.

No coordinates, no XPath, no index-based selectors except within a narrowly
scoped parent (the two text fields of the date range dialog).

## Test isolation and data

- Android Test Orchestrator: each test runs in a new app process. The tests
  use the local-data configuration, which keeps all state in memory, so a new
  process is a clean state. `clearPackageData` is deliberately off: its
  `pm clear` raced the previous process's teardown and got the next test's
  process killed (see the 2026-11-07 entry in the execution log). Turn it back on only if
  tests start persisting data (e.g. SharedPreferences in the staging config).
- `launchCompass()` starts the app with `providersLocal` (in-memory repositories
  seeded from `assets/*.json`), the same way the upstream integration test does.
- Every test therefore starts with: user "Sofie", one booking "Alaska, North America".
- Dates are relative to today (`today + 7`, `today + 9`) so they are always valid.
- Expectations that depend on catalogue data are read from the app's asset at
  runtime (`TestData.destinationNamesFor`).
- Device-wide settings changed by a test (dark mode) are restored in `finally`.

## Synchronisation

- Patrol actions wait for the target to be visible (`visibleTimeout`, 20 s) and
  then "try settle" (`SettlePolicy.trySettle`): pump until idle or until the
  timeout, without failing on endless animations such as spinners.
- Screen robots expose `waitUntilLoaded()` that waits for a screen-specific
  ready signal (for example the continent carousel on the search form).
- One fixed delay remains (share sheet, 2 s) because the Android chooser has no
  stable selector across API levels; it is listed as technical debt.

## Configuration

| Setting | Where |
|---|---|
| Timeouts, settle policy, logs | `patrol_test/support/test_config.dart` |
| App id / bundle id / test dir | `app/pubspec.yaml` → `patrol:` |
| Android runner + orchestrator | `app/android/app/build.gradle` |
| Suites | `TestTags` + `patrol test --tags` |
| CI device | `.github/workflows/android-patrol.yml` (API 34, Pixel 6, x86_64) |

## Extending

- **New screen:** add `robots/<screen>_robot.dart`, expose it from
  `CompassAppRobot`, export it from `compass_app_robot.dart`.
- **New scenario:** add a `*_test.dart` under the right suite folder and give it
  at least one tag; reuse flows before adding new ones.
- **New environment (staging):** add a `launchCompassStaging()` that uses
  `providersRemote`, start the Dart server in CI and forward the port with
  `adb reverse tcp:8080 tcp:8080`.
