import '../support/compass_app_robot.dart';
import '../support/compass_harness.dart';

void main() {
  compassTest(
    'swiping a booking away deletes it and confirms with a snackbar',
    tags: [TestTags.regression],
    ($) async {
      await launchCompass($);
      final app = CompassAppRobot($);
      await app.home.waitUntilLoaded();
      await app.home.expectBooking(TestData.defaultBookingName);

      await app.home.swipeToDelete(TestData.defaultBookingName);

      await $('Booking deleted').waitUntilVisible();
      app.home.expectNoBooking(TestData.defaultBookingName);
    },
  );
}
