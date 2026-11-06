import 'package:compass_app/ui/core/ui/home_button.dart';
import 'package:compass_app/ui/search_form/widgets/search_form_guests.dart';
import 'package:compass_app/ui/search_form/widgets/search_form_screen.dart';
import 'package:compass_app/ui/search_form/widgets/search_form_submit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'date_range_picker_robot.dart';

/// Robot for the search form: continent, dates, guests, Search button.
class SearchFormRobot {
  SearchFormRobot(this.$) : _datePicker = DateRangePickerRobot($);

  final PatrolIntegrationTester $;
  final DateRangePickerRobot _datePicker;

  PatrolFinder get screen => $(SearchFormScreen);
  PatrolFinder get searchButton =>
      $(const ValueKey(searchFormSubmitButtonKey));
  PatrolFinder get addGuestButton => $(const ValueKey(addGuestsKey));
  PatrolFinder get removeGuestButton => $(const ValueKey(removeGuestsKey));
  PatrolFinder get homeButton => screen.$(HomeButton);

  /// Continent tiles are keyed by continent name in the app.
  PatrolFinder continentTile(String continent) => $(ValueKey(continent));

  Future<void> waitUntilLoaded() async {
    await screen.waitUntilVisible();
    // Continents load asynchronously; wait for the first tile.
    await continentTile('Europe').waitUntilVisible();
  }

  Future<void> selectContinent(String continent) async {
    // The continent carousel scrolls horizontally; bring the tile into view.
    final tile = await continentTile(
      continent,
    ).scrollTo(scrollDirection: AxisDirection.right);
    await tile.tap();
  }

  /// The "When" row opens the date range picker (its value text changes
  /// from "Add Dates" to the chosen range, the label stays the same).
  PatrolFinder get whenField => screen.$('When');

  Future<void> selectDates(DateTime start, DateTime end) async {
    await whenField.tap();
    await _datePicker.selectRange(start, end);
  }

  Future<void> addGuests(int count) async {
    for (var i = 0; i < count; i++) {
      await addGuestButton.tap();
    }
  }

  Future<void> removeGuests(int count) async {
    for (var i = 0; i < count; i++) {
      await removeGuestButton.tap();
    }
  }

  Future<void> submit() => searchButton.tap();

  Future<void> goHome() => homeButton.tap();

  /// Fills every field and submits.
  Future<void> search({
    required String continent,
    required DateTime start,
    required DateTime end,
    int guests = 1,
  }) async {
    await selectContinent(continent);
    await selectDates(start, end);
    await addGuests(guests);
    await submit();
  }

  /// The guest counter is the [Text] between the - and + buttons.
  ///
  /// The "Who" label sits in an outer Row that also contains both buttons,
  /// so take the *nearest* Row around the - button (find.ancestor lists the
  /// closest ancestor first): its only Text is the counter.
  int get guestCount {
    final quantityRow = find
        .ancestor(of: removeGuestButton, matching: find.byType(Row))
        .first;
    final counter = $(quantityRow).$(Text);
    return int.parse(counter.text!);
  }

  bool get isSearchEnabled =>
      $.tester.widget<FilledButton>(searchButton).onPressed != null;
}
