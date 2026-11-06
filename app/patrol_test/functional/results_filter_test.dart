import '../support/compass_app_robot.dart';
import '../support/compass_test.dart';

void main() {
  compassTest(
    'results only contain destinations from the selected continent',
    tags: [TestTags.regression],
    ($) async {
      await launchCompass($);
      final app = CompassAppRobot($);

      // Expected results come from the same asset file the app reads.
      final asia = await TestData.destinationNamesFor(TestData.asia);
      final europe = await TestData.destinationNamesFor(TestData.europe);
      expect(asia, isNotEmpty);

      await app.searchTrips(continent: TestData.asia);

      app.results.expectDestinationListed(asia.first);
      app.results.expectDestinationNotListed(europe.first);
    },
  );
}
