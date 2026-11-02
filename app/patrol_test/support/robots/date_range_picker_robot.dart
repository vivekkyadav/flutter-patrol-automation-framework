import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

/// Robot for Flutter's Material date range picker (`showDateRangePicker`).
///
/// Tapping day numbers in the calendar view is fragile: the same number
/// appears once per visible month, and month boundaries change with the
/// calendar. Instead this robot switches the picker to **text input mode**
/// and types the dates, which is deterministic on any day of the year.
///
/// All labels come from [MaterialLocalizations], so nothing here depends on
/// the exact English wording or on the device's date format.
class DateRangePickerRobot {
  DateRangePickerRobot(this.$);

  final PatrolIntegrationTester $;

  PatrolFinder get _dialog => $(Dialog);

  MaterialLocalizations get _l10n =>
      MaterialLocalizations.of($.tester.element(_dialog.first));

  Future<void> selectRange(DateTime start, DateTime end) async {
    await _dialog.waitUntilVisible();
    final l10n = _l10n;

    // Calendar mode -> text input mode (pencil icon in the picker header).
    await $(find.byTooltip(l10n.inputDateModeButtonLabel)).tap();

    final fields = _dialog.$(TextField);
    await fields.at(0).enterText(l10n.formatCompactDate(start));
    await fields.at(1).enterText(l10n.formatCompactDate(end));

    await _dialog.$(l10n.okButtonLabel).tap();
    await $.pumpAndSettle();
    expect(_dialog, findsNothing, reason: 'Date range picker should close');
  }
}
