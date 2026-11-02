# Test strategy

## Scope

In scope (development configuration, local data):

| Feature | Covered by |
|---|---|
| App start, user header, trip list | `smoke/app_launch_test.dart` |
| View booking details | `smoke/open_booking_test.dart`, `native/app_lifecycle_test.dart` |
| Create booking end to end | `functional/create_booking_test.dart` |
| Search form rules | `functional/search_form_validation_test.dart` |
| Results filtering | `functional/results_filter_test.dart` |
| Activity selection rules | `functional/activities_selection_test.dart` |
| Delete booking | `functional/delete_booking_test.dart` |
| Navigation and abandoning a flow | `functional/navigation_test.dart`, `native/system_back_test.dart` |
| OS integration | `native/*` (background/foreground, dark mode, system back, share sheet) |

Out of scope for now (roadmap):

- Login/logout and HTTP error handling — need the staging configuration and the
  bundled Dart server.
- Visual/golden testing, accessibility audits, performance.
- iOS-specific native behaviour (pending iOS setup).

## Test types and tags

| Tag | Purpose | When it runs |
|---|---|---|
| `smoke` | App is usable: launch, open booking, create booking | Every push; first in the pipeline when split |
| `regression` | Business rules, negative cases, navigation | Every push / PR |
| `native` | OS-level behaviour Patrol adds over `integration_test` | Every push / PR |
| `android-only` | Uses Android-only APIs (system back) or Android UI | Excluded on iOS: `--exclude-tags android-only` |

## Negative and edge cases included

- Submitting an incomplete search form is impossible (button disabled at each step).
- Guest counter cannot go below zero.
- Deselecting a continent invalidates the form again.
- Confirm is disabled with zero activities; unselecting returns to zero.
- Leaving the activity screen via Home creates no booking.
- Android back from the search form returns home instead of closing the app.

## Flakiness policy

- A test that fails intermittently is fixed or quarantined (`skip:` with a linked
  issue) within one working day — never retried silently.
- No fixed sleeps except where documented in [ARCHITECTURE.md](ARCHITECTURE.md#synchronisation).
- Stability target before calling the suite "stable": 5 consecutive green CI runs.

## Entry / exit criteria for a pull request

- `flutter analyze` clean (no errors or warnings).
- App unit tests green.
- Patrol Android suite green; JUnit summary attached to the run.
