import 'package:compass_app/ui/auth/logout/widgets/logout_button.dart';
import 'package:compass_app/ui/home/widgets/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

/// Robot for the Home screen ("Sofie's Trips" with the booking list).
///
/// Robots hide *how* to find and drive widgets; tests only describe *what*
/// the user does. Selectors prefer the app's own key constants
/// (`bookingButtonKey`) and widget types over raw text where possible.
class HomeRobot {
  HomeRobot(this.$);

  final PatrolIntegrationTester $;

  PatrolFinder get screen => $(HomeScreen);
  PatrolFinder get bookNewTripButton => $(const ValueKey(bookingButtonKey));
  PatrolFinder get logoutButton => $(LogoutButton);
  PatrolFinder bookingTile(String bookingName) => $(HomeScreen).$(bookingName);

  Future<void> waitUntilLoaded() async {
    await screen.waitUntilVisible();
    await bookNewTripButton.waitUntilVisible();
  }

  Future<void> tapBookNewTrip() => bookNewTripButton.tap();

  Future<void> openBooking(String bookingName) =>
      bookingTile(bookingName).tap();

  /// Swipes a booking from right to left, which deletes it.
  Future<void> swipeToDelete(String bookingName) async {
    final tile = bookingTile(bookingName);
    await tile.waitUntilVisible();
    await $.tester.drag(tile.first, const Offset(-600, 0));
    await $.pumpAndSettle();
  }

  void expectTitle(String title) => expect($(title), findsOneWidget);

  void expectBooking(String bookingName) =>
      expect(bookingTile(bookingName), findsOneWidget);

  void expectNoBooking(String bookingName) =>
      expect(bookingTile(bookingName), findsNothing);
}
