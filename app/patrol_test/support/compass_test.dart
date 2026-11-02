import 'package:compass_app/config/dependencies.dart';
import 'package:compass_app/main.dart';
import 'package:patrol/patrol.dart';
import 'package:provider/provider.dart';

import 'test_config.dart';

export 'package:flutter_test/flutter_test.dart';
export 'package:patrol/patrol.dart';

export 'tags.dart';
export 'test_config.dart';

/// Single entry point for every Compass UI test.
///
/// Wraps [patrolTest] so that all tests share one tester configuration
/// (timeouts, logging) and so a test cannot forget to declare its tags.
void compassTest(
  String description,
  Future<void> Function(PatrolIntegrationTester $) body, {
  required List<String> tags,
  bool? skip,
}) {
  patrolTest(
    description,
    config: TestConfig.patrolTesterConfig,
    tags: tags,
    skip: skip,
    body,
  );
}

/// Starts the Compass app with the **development** configuration.
///
/// The development configuration reads destinations and activities from the
/// JSON files in `assets/` and keeps bookings in memory. Combined with
/// Patrol's `clearPackageData` + Android Test Orchestrator setup, every test
/// starts from the same known state: user "Sofie" with one default booking
/// ("Alaska, North America").
///
/// This mirrors how the upstream `integration_test/app_local_data_test.dart`
/// launches the app, so the framework does not need any change to `lib/`.
Future<void> launchCompass(PatrolIntegrationTester $) async {
  await $.pumpWidgetAndSettle(
    MultiProvider(providers: providersLocal, child: const MainApp()),
  );
}
