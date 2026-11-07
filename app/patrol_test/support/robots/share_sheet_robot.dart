import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:patrol/patrol.dart';

/// Robot for the Android system share sheet (a separate, native activity:
/// `com.android.intentresolver/.ChooserActivity` on Android 14 / API 34).
///
/// The sheet takes about 1.5 s to appear even on an accelerated emulator and
/// longer on CI, so nothing here uses a fixed delay. Instead it follows the
/// app's own lifecycle, which the OS drives:
///
/// * the chooser comes to the front -> the app's activity is paused ->
///   Flutter reports [AppLifecycleState.inactive] (or later states);
/// * the chooser finishes -> the app is resumed ->
///   [AppLifecycleState.resumed].
///
/// It deliberately makes **no native view-tree queries** (`waitUntilVisible`,
/// `getNativeViews`). Those go through Android accessibility, which can switch
/// Flutter semantics on mid-test and fail flutter_test's end-of-test check
/// ("A SemanticsHandle was active at the end of the test"). Seen 1–2 times
/// in 10–15 local runs when such queries were used.
class ShareSheetRobot {
  ShareSheetRobot(this.$);

  final PatrolIntegrationTester $;

  static const timeout = Duration(seconds: 30);
  static const _pollInterval = Duration(milliseconds: 100);

  AppLifecycleState? get _lifecycle => $.tester.binding.lifecycleState;

  /// Waits until the share sheet has taken the foreground from the app.
  Future<void> waitUntilOpen() => _waitFor(
    () => _lifecycle != AppLifecycleState.resumed,
    'the share sheet to take the foreground (app no longer resumed)',
  );

  /// Waits for the sheet to open, closes it with the hardware Back button and
  /// waits until the app is back in the foreground.
  ///
  /// If Back is injected while the chooser window is still gaining focus,
  /// Android's input dispatcher holds the key until that window is focused,
  /// so it always reaches the sheet, not the app underneath.
  Future<void> closeWithBack() async {
    await waitUntilOpen();
    await $.platform.android.pressBack();
    await _waitFor(
      () => _lifecycle == AppLifecycleState.resumed,
      'the app to return to the foreground (AppLifecycleState.resumed)',
    );
    await $.pumpAndSettle();
  }

  Future<void> _waitFor(bool Function() condition, String what) async {
    final deadline = DateTime.now().add(timeout);
    while (!condition()) {
      if (DateTime.now().isAfter(deadline)) {
        throw TimeoutException(
          'Timed out after ${timeout.inSeconds}s waiting for $what; '
          'lifecycle is $_lifecycle',
          timeout,
        );
      }
      // Pump so lifecycle callbacks from the platform are processed.
      await $.pump(_pollInterval);
    }
  }
}
