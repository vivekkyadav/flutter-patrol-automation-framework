import '../support/compass_app_robot.dart';
import '../support/compass_test.dart';

void main() {
  compassTest(
    'app launches on the home screen with the signed-in user and default booking',
    tags: [TestTags.smoke],
    ($) async {
      await launchCompass($);
      final app = CompassAppRobot($);

      await app.home.waitUntilLoaded();
      app.home.expectTitle(TestData.userTripsTitle);
      app.home.expectBooking(TestData.defaultBookingName);
      expect(app.home.logoutButton, findsOneWidget);
    },
  );
}
