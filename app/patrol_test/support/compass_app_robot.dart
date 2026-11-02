import 'package:patrol/patrol.dart';

import 'robots/activities_robot.dart';
import 'robots/booking_robot.dart';
import 'robots/home_robot.dart';
import 'robots/results_robot.dart';
import 'robots/search_form_robot.dart';
import 'test_data.dart';

export 'robots/activities_robot.dart';
export 'robots/booking_robot.dart';
export 'robots/home_robot.dart';
export 'robots/results_robot.dart';
export 'robots/search_form_robot.dart';
export 'test_data.dart';

/// One object that gives a test access to every screen robot, plus
/// reusable multi-screen flows.
///
/// ```dart
/// final app = CompassAppRobot($);
/// await app.home.tapBookNewTrip();
/// ```
class CompassAppRobot {
  CompassAppRobot(this.$)
    : home = HomeRobot($),
      search = SearchFormRobot($),
      results = ResultsRobot($),
      activities = ActivitiesRobot($),
      booking = BookingRobot($);

  final PatrolIntegrationTester $;
  final HomeRobot home;
  final SearchFormRobot search;
  final ResultsRobot results;
  final ActivitiesRobot activities;
  final BookingRobot booking;

  /// Home -> search form -> results for [continent].
  Future<void> searchTrips({
    String continent = TestData.europe,
    int guests = 1,
  }) async {
    await home.waitUntilLoaded();
    await home.tapBookNewTrip();
    await search.waitUntilLoaded();
    await search.search(
      continent: continent,
      start: TestData.tripStart,
      end: TestData.tripEnd,
      guests: guests,
    );
    await results.waitUntilLoaded();
  }

  /// Home -> ... -> Booking screen for Amalfi Coast with the given activities.
  Future<void> bookAmalfiCoast({
    List<String> activityRefs = const [TestData.scenicBoatTourRef],
  }) async {
    await searchTrips(continent: TestData.europe);
    await results.openDestination(TestData.amalfiCoast);
    await activities.waitUntilLoaded();
    for (final ref in activityRefs) {
      await activities.toggleActivity(ref);
    }
    await activities.confirm();
    await booking.waitUntilLoaded();
  }
}
