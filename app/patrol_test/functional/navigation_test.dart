import '../support/compass_app_robot.dart';
import '../support/compass_test.dart';

void main() {
  group('In-app navigation', () {
    compassTest(
      'Home button on the search form returns to the trip list',
      tags: [TestTags.regression],
      ($) async {
        await launchCompass($);
        final app = CompassAppRobot($);
        await app.home.waitUntilLoaded();
        await app.home.tapBookNewTrip();
        await app.search.waitUntilLoaded();

        await app.search.goHome();
        await app.home.waitUntilLoaded();
      },
    );

    compassTest(
      'Back on the activities screen returns to the results',
      tags: [TestTags.regression],
      ($) async {
        await launchCompass($);
        final app = CompassAppRobot($);
        await app.searchTrips(continent: TestData.europe);
        await app.results.openDestination(TestData.amalfiCoast);
        await app.activities.waitUntilLoaded();

        await app.activities.goBack();
        await app.results.waitUntilLoaded();
        app.results.expectDestinationListed(TestData.amalfiCoast);
      },
    );

    compassTest(
      'Home on the activities screen abandons the flow without creating a booking',
      tags: [TestTags.regression],
      ($) async {
        await launchCompass($);
        final app = CompassAppRobot($);
        await app.searchTrips(continent: TestData.europe);
        await app.results.openDestination(TestData.amalfiCoast);
        await app.activities.waitUntilLoaded();
        await app.activities.toggleActivity(TestData.scenicBoatTourRef);

        await app.activities.goHome();
        await app.home.waitUntilLoaded();
        app.home.expectNoBooking('${TestData.amalfiCoast}, ${TestData.europe}');
      },
    );
  });
}
