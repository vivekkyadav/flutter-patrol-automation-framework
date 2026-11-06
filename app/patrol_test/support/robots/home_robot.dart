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

  /// The title includes the user's name, which is also loaded asynchronously.
  Future<void> expectTitle(String title) async {
    await $(title).waitUntilExists();
    expect($(title), findsOneWidget);
  }

  /// Waits for [bookingName] to appear in the list, then asserts it is unique.
  ///
  /// The Home view model loads bookings asynchronously, and the "Book New
  /// Trip" button that [waitUntilLoaded] waits for is rendered before the
  /// list arrives, so a synchronous check here races the load.
  Future<void> expectBooking(String bookingName) async {
    await bookingTile(bookingName).waitUntilExists();
    expect(bookingTile(bookingName), findsOneWidget);
  }

  /// Asserts [bookingName] is not listed. Only meaningful once the list has
  /// loaded: call [expectBooking] for a booking that should be present first,
  /// or run it after an action that already settled the list (e.g. a delete).
  void expectNoBooking(String bookingName) =>
      expect(bookingTile(bookingName), findsNothing);
}
