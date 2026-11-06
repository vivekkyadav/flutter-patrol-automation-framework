import '../support/compass_app_robot.dart';
import '../support/compass_harness.dart';

void main() {
  group('Search form validation', () {
    compassTest(
      'Search stays disabled until continent, dates and guests are all set',
      tags: [TestTags.regression],
      ($) async {
        await launchCompass($);
        final app = CompassAppRobot($);
        await app.home.waitUntilLoaded();
        await app.home.tapBookNewTrip();
        await app.search.waitUntilLoaded();

        expect(app.search.isSearchEnabled, isFalse, reason: 'empty form');

        await app.search.selectContinent(TestData.europe);
        expect(app.search.isSearchEnabled, isFalse, reason: 'continent only');

        await app.search.selectDates(TestData.tripStart, TestData.tripEnd);
        expect(app.search.isSearchEnabled, isFalse, reason: 'no guests yet');

        await app.search.addGuests(1);
        expect(app.search.isSearchEnabled, isTrue, reason: 'form complete');
      },
    );

    compassTest(
      'guest counter never goes below zero',
      tags: [TestTags.regression],
      ($) async {
        await launchCompass($);
        final app = CompassAppRobot($);
        await app.home.waitUntilLoaded();
        await app.home.tapBookNewTrip();
        await app.search.waitUntilLoaded();

        expect(app.search.guestCount, 0);
        await app.search.removeGuests(1);
        expect(app.search.guestCount, 0);

        await app.search.addGuests(3);
        expect(app.search.guestCount, 3);
        await app.search.removeGuests(2);
        expect(app.search.guestCount, 1);
      },
    );

    compassTest(
      'tapping the selected continent again clears the selection',
      tags: [TestTags.regression],
      ($) async {
        await launchCompass($);
        final app = CompassAppRobot($);
        await app.home.waitUntilLoaded();
        await app.home.tapBookNewTrip();
        await app.search.waitUntilLoaded();
        await app.search.selectDates(TestData.tripStart, TestData.tripEnd);
        await app.search.addGuests(1);

        await app.search.selectContinent(TestData.asia);
        expect(app.search.isSearchEnabled, isTrue);

        await app.search.selectContinent(TestData.asia);
        expect(
          app.search.isSearchEnabled,
          isFalse,
          reason: 'continent was deselected, so the form is incomplete again',
        );
      },
    );
  });
}
