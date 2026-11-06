import 'package:flutter/material.dart';

import '../support/compass_app_robot.dart';
import '../support/compass_harness.dart';

void main() {
  compassTest(
    'app follows the system dark mode setting',
    tags: [TestTags.native],
    ($) async {
      await launchCompass($);
      final app = CompassAppRobot($);
      await app.home.waitUntilLoaded();

      Brightness currentBrightness() =>
          Theme.of($.tester.element(app.home.screen)).brightness;

      // Dark mode is a device-wide setting, so always put it back,
      // even if an assertion fails, to keep later tests independent.
      try {
        await $.platform.mobile.disableDarkMode();
        await _waitForBrightness($, currentBrightness, Brightness.light);

        await $.platform.mobile.enableDarkMode();
        await _waitForBrightness($, currentBrightness, Brightness.dark);
      } finally {
        await $.platform.mobile.disableDarkMode();
      }
    },
  );
}

/// The theme switch arrives asynchronously from the OS, so poll for it
/// instead of using a fixed sleep.
Future<void> _waitForBrightness(
  PatrolIntegrationTester $,
  Brightness Function() current,
  Brightness expected, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (current() != expected && DateTime.now().isBefore(deadline)) {
    await $.pump(const Duration(milliseconds: 250));
  }
  expect(current(), expected);
}
