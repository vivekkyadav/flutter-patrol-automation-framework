import '../support/compass_app_robot.dart';
import '../support/compass_harness.dart';

void main() {
  compassTest(
    'app launches on the home screen with the signed-in user and default booking',
    tags: [TestTags.smoke],
    ($) async {
      await launchCompass($);
      final app = CompassAppRobot($);

      await app.home.waitUntilLoaded();
      await app.home.expectTitle(TestData.userTripsTitle);
      await app.home.expectBooking(TestData.defaultBookingName);
      expect(app.home.logoutButton, findsOneWidget);
    },
  );
}
