# iOS setup (one time, on a Mac with Xcode)

Patrol on iOS runs through an XCUITest target called `RunnerUITests`. Creating a
target is done in Xcode, so it is not automated in this repository yet. Steps
follow the [official Patrol guide](https://patrol.leancode.co/documentation#ios-setup);
values for this app are filled in.

- Bundle id: `com.example.compassApp` (already set in `app/pubspec.yaml` → `patrol.ios.bundle_id`)
- Minimum iOS deployment target for `RunnerUITests`: same as `Runner` (≥ 13.0)

## Steps

1. `cd app && flutter pub get`
2. Open `app/ios/Runner.xcworkspace` in Xcode.
3. **File → New → Target… → UI Testing Bundle**
   - Product Name: `RunnerUITests`
   - Organization Identifier: same as `Runner` (`com.example`)
   - Target to be Tested: `Runner`, Language: **Objective-C**
4. Delete `RunnerUITestsLaunchTests.m` (Move to Trash, through Xcode).
5. Set `RunnerUITests` → Build Settings → iOS Deployment Target = `Runner`'s value.
6. Replace `RunnerUITests/RunnerUITests.m` with:

   ```objc
   @import XCTest;
   @import patrol;
   @import ObjectiveC.runtime;

   #if !defined(PATROL_INTEGRATION_TEST_IOS_RUNNER)
   #import "PatrolIntegrationTestIosRunner.h"
   #endif

   PATROL_INTEGRATION_TEST_IOS_RUNNER(RunnerUITests)
   ```

7. CocoaPods: in `app/ios/Podfile`, inside `target 'Runner' do … end`, add

   ```ruby
   target 'RunnerUITests' do
     inherit! :complete
   end
   ```

8. `flutter build ios --config-only patrol_test/smoke/app_launch_test.dart`
9. `cd ios && pod install --repo-update`
10. In Xcode, make sure each build configuration of `RunnerUITests` uses the same
    configuration set as `Runner`.
11. `RunnerUITests` → Build Phases: add two Run Script phases, named
    `xcode_backend build` and `xcode_backend embed_and_thin`, ordered as in the
    Patrol guide:

    ```sh
    /bin/sh "$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh" build
    /bin/sh "$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh" embed_and_thin
    ```

12. Disable **parallel execution** for the test action in every scheme
    (Product → Scheme → Edit Scheme → Test → Options), as it breaks Patrol.
13. `RunnerUITests` → Build Settings → set **User Script Sandboxing** to **No**.

## Run

```bash
cd app
patrol test --device "iPhone 16" --exclude-tags android-only
```

Commit the Xcode project changes (`ios/Runner.xcodeproj`, `ios/RunnerUITests/`,
`ios/Podfile`) and record the first result in [EXECUTION_LOG.md](EXECUTION_LOG.md)
to close gate G7.
