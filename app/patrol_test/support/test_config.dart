import 'package:patrol/patrol.dart';

/// Central place for timeouts and tester behaviour.
///
/// The Compass app loads images and Google Fonts over the network, so the
/// first frames on a cold CI emulator can be slow. Timeouts are kept
/// generous here rather than sprinkled across individual tests.
abstract final class TestConfig {
  static const existsTimeout = Duration(seconds: 20);
  static const visibleTimeout = Duration(seconds: 20);
  static const settleTimeout = Duration(seconds: 15);

  static const patrolTesterConfig = PatrolTesterConfig(
    existsTimeout: existsTimeout,
    visibleTimeout: visibleTimeout,
    settleTimeout: settleTimeout,
    // Do not fail when a frame keeps animating (spinners, image fades):
    // pump until settled or until the timeout, then continue.
    settlePolicy: SettlePolicy.trySettle,
    printLogs: true,
  );
}
