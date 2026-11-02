import 'package:compass_app/ui/activities/widgets/activities_screen.dart';
import 'package:compass_app/ui/core/ui/back_button.dart';
import 'package:compass_app/ui/core/ui/home_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

/// Robot for the Activities screen (daytime and evening activity lists).
class ActivitiesRobot {
  ActivitiesRobot(this.$);

  final PatrolIntegrationTester $;

  PatrolFinder get screen => $(ActivitiesScreen);
  PatrolFinder get confirmButton => $(const Key(confirmButtonKey));
  PatrolFinder get backButton => screen.$(CustomBackButton);
  PatrolFinder get homeButton => screen.$(HomeButton);

  /// Each activity checkbox is keyed `<activity-ref>-checkbox` by the app.
  PatrolFinder checkbox(String activityRef) =>
      $(ValueKey('$activityRef-checkbox'));

  Future<void> waitUntilLoaded() async {
    await screen.waitUntilVisible();
    await confirmButton.waitUntilVisible();
  }

  /// Taps an activity's checkbox; tapping again unselects it.
  Future<void> toggleActivity(String activityRef) async {
    final target = await checkbox(activityRef).scrollTo();
    await target.tap();
  }

  Future<void> confirm() => confirmButton.tap();

  Future<void> goBack() => backButton.tap();

  Future<void> goHome() => homeButton.tap();

  bool get isConfirmEnabled =>
      $.tester.widget<FilledButton>(confirmButton).onPressed != null;

  /// Bottom bar text, for example "2 selected".
  void expectSelectedCount(int count) =>
      expect($('$count selected'), findsOneWidget);
}
