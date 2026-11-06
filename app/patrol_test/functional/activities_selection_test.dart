import '../support/compass_app_robot.dart';
import '../support/compass_test.dart';

void main() {
  compassTest(
    'Confirm is enabled only while at least one activity is selected',
    tags: [TestTags.regression],
    ($) async {
      await launchCompass($);
      final app = CompassAppRobot($);
      await app.searchTrips(continent: TestData.europe);
      await app.results.openDestination(TestData.amalfiCoast);
      await app.activities.waitUntilLoaded();

      app.activities.expectSelectedCount(0);
      expect(app.activities.isConfirmEnabled, isFalse);

      await app.activities.toggleActivity(TestData.scenicBoatTourRef);
      app.activities.expectSelectedCount(1);
      expect(app.activities.isConfirmEnabled, isTrue);

      // Tapping the same activity again unselects it.
      await app.activities.toggleActivity(TestData.scenicBoatTourRef);
      app.activities.expectSelectedCount(0);
      expect(app.activities.isConfirmEnabled, isFalse);
    },
  );
}
