import 'package:compass_app/ui/results/widgets/result_card.dart';
import 'package:compass_app/ui/results/widgets/results_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

/// Robot for the destination results grid.
class ResultsRobot {
  ResultsRobot(this.$);

  final PatrolIntegrationTester $;

  PatrolFinder get screen => $(ResultsScreen);
  PatrolFinder get cards => $(ResultCard);

  /// Result cards display the destination name in upper case.
  PatrolFinder card(String destinationName) =>
      $(ResultCard).containing(destinationName.toUpperCase());

  Future<void> waitUntilLoaded() async {
    await screen.waitUntilVisible();
    await cards.first.waitUntilVisible();
  }

  Future<void> openDestination(String destinationName) async {
    final target = await card(destinationName).scrollTo();
    await target.tap();
  }

  void expectDestinationListed(String destinationName) =>
      expect(card(destinationName), findsOneWidget);

  void expectDestinationNotListed(String destinationName) =>
      expect(card(destinationName), findsNothing);
}
