import '../support/compass_app_robot.dart';
import '../support/compass_test.dart';

void main() {
  compassTest(
    'app keeps the open booking after going to the background and coming back',
    tags: [TestTags.native],
    ($) async {
      await launchCompass($);
      final app = CompassAppRobot($);
      await app.home.waitUntilLoaded();
      await app.home.openBooking(TestData.defaultBookingName);
      await app.booking.waitUntilLoaded();

      // OS-level actions: these leave the Flutter app, which plain
      // integration_test cannot do.
      await $.platform.mobile.pressHome();
      await $.platform.mobile.openApp();

      await app.booking.waitUntilLoaded();
      app.booking.expectDestination(TestData.defaultBookingDestination);
    },
  );
}
