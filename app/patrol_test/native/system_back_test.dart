import '../support/compass_app_robot.dart';
import '../support/compass_test.dart';

void main() {
  compassTest(
    'Android system back on the search form goes to the trip list, not out of the app',
    tags: [TestTags.native, TestTags.androidOnly],
    ($) async {
      await launchCompass($);
      final app = CompassAppRobot($);
      await app.home.waitUntilLoaded();
      await app.home.tapBookNewTrip();
      await app.search.waitUntilLoaded();

      // Hardware/gesture back is sent by the OS, outside Flutter.
      await $.platform.android.pressBack();

      await app.home.waitUntilLoaded();
      app.home.expectBooking(TestData.defaultBookingName);
    },
  );
}
