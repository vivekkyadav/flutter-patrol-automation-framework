import '../support/compass_app_robot.dart';
import '../support/compass_harness.dart';

void main() {
  compassTest(
    'Share Trip opens the system share sheet and the app recovers after closing it',
    tags: [TestTags.native, TestTags.androidOnly],
    ($) async {
      await launchCompass($);
      final app = CompassAppRobot($);
      await app.home.waitUntilLoaded();
      await app.home.openBooking(TestData.defaultBookingName);
      await app.booking.waitUntilLoaded();

      await app.booking.share();

      // The Android share sheet is a separate system UI. Wait for it to be
      // on screen, close it with the hardware back button (native action),
      // and wait for the app to be resumed before checking its state.
      await ShareSheetRobot($).closeWithBack();

      await app.booking.waitUntilLoaded();
      app.booking.expectDestination(TestData.defaultBookingDestination);
      app.booking.expectNoShareError();
    },
  );
}
