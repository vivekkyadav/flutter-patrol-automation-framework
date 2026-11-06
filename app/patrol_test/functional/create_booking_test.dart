import '../support/compass_app_robot.dart';
import '../support/compass_test.dart';

void main() {
  compassTest(
    'user books Amalfi Coast with a daytime and an evening activity end to end',
    tags: [TestTags.smoke, TestTags.regression],
    ($) async {
      await launchCompass($);
      final app = CompassAppRobot($);

      await app.searchTrips(continent: TestData.europe, guests: 2);
      await app.results.openDestination(TestData.amalfiCoast);

      await app.activities.waitUntilLoaded();
      await app.activities.toggleActivity(TestData.scenicBoatTourRef);
      await app.activities.toggleActivity(TestData.romanticDinnerRef);
      app.activities.expectSelectedCount(2);
      await app.activities.confirm();

      await app.booking.waitUntilLoaded();
      app.booking.expectDestination(TestData.amalfiCoast);
      await app.booking.expectActivityListed(TestData.scenicBoatTour);
      await app.booking.expectActivityListed(TestData.romanticDinner);

      await app.booking.goHome();
      await app.home.waitUntilLoaded();
      app.home.expectBooking('${TestData.amalfiCoast}, ${TestData.europe}');
      app.home.expectBooking(TestData.defaultBookingName);
    },
  );
}
