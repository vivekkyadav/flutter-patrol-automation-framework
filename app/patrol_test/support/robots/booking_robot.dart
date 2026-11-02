import 'package:compass_app/ui/booking/widgets/booking_screen.dart';
import 'package:compass_app/ui/core/ui/home_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

/// Robot for the Booking details screen.
class BookingRobot {
  BookingRobot(this.$);

  final PatrolIntegrationTester $;

  PatrolFinder get screen => $(BookingScreen);
  PatrolFinder get shareButton => $(const ValueKey('share-button'));
  PatrolFinder get homeButton => screen.$(HomeButton);
  PatrolFinder get chosenActivitiesHeading => $('Your chosen activities');

  Future<void> waitUntilLoaded() async {
    await screen.waitUntilVisible();
    await chosenActivitiesHeading.waitUntilVisible();
  }

  Future<void> share() => shareButton.tap();

  Future<void> goHome() => homeButton.tap();

  void expectDestination(String destinationName) =>
      expect(screen.$(destinationName), findsWidgets);

  Future<void> expectActivityListed(String activityName) async {
    final activity = await screen.$(activityName).scrollTo();
    expect(activity, findsOneWidget);
  }

  void expectNoShareError() =>
      expect($('Error while sharing booking'), findsNothing);
}
