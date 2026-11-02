import 'dart:convert';

import 'package:compass_app/config/assets.dart';
import 'package:flutter/services.dart';

/// Known, deterministic data from the development configuration.
///
/// Values here come from `lib/data/services/local/local_data_service.dart`,
/// `lib/data/repositories/booking/booking_repository_local.dart` and the JSON
/// files in `assets/`. If the app's seed data changes, this is the one file
/// to update.
abstract final class TestData {
  static const userName = 'Sofie';
  static const userTripsTitle = "Sofie's Trips";

  /// Booking created automatically on first load (first destination in
  /// destinations.json, which is in North America).
  static const defaultBookingName = 'Alaska, North America';
  static const defaultBookingDestination = 'Alaska';

  static const europe = 'Europe';
  static const asia = 'Asia';

  /// First Europe destination in destinations.json.
  static const amalfiCoast = 'Amalfi Coast';
  static const amalfiCoastRef = 'amalfi-coast';

  /// Two Amalfi Coast activities: one daytime, one evening.
  static const scenicBoatTourRef = 'scenic-boat-tour';
  static const scenicBoatTour = 'Scenic Boat Tour';
  static const romanticDinnerRef = 'romantic-dinner-with-a-view';
  static const romanticDinner = 'Romantic Dinner with a View';

  /// A trip a week from now, so the dates are always valid in the picker
  /// (the picker only allows today .. today + 365 days).
  static DateTime get tripStart => _today.add(const Duration(days: 7));
  static DateTime get tripEnd => _today.add(const Duration(days: 9));

  static DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Destination names for [continent], in the order the app lists them.
  ///
  /// Read from the same asset the app uses, so expectations never drift
  /// from the data under test.
  static Future<List<String>> destinationNamesFor(String continent) async {
    final raw = await rootBundle.loadString(Assets.destinations);
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return [
      for (final destination in list)
        if (destination['continent'] == continent)
          destination['name'] as String,
    ];
  }
}
