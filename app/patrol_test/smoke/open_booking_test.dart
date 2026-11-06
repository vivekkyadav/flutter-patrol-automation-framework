import '../support/compass_app_robot.dart';
import '../support/compass_harness.dart';

void main() {
  compassTest(
    'opening an existing booking shows its details and Home returns to the list',
    tags: [TestTags.smoke],
    ($) async {
      await launchCompass($);
      final app = CompassAppRobot($);

      await app.home.waitUntilLoaded();
      await app.home.openBooking(TestData.defaultBookingName);

      await app.booking.waitUntilLoaded();
      app.booking.expectDestination(TestData.defaultBookingDestination);
      expect(app.booking.shareButton, findsOneWidget);

      await app.booking.goHome();
      await app.home.waitUntilLoaded();
      app.home.expectBooking(TestData.defaultBookingName);
    },
  );
}
