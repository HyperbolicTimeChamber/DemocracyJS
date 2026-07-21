import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/shared/widgets/poll_card.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('PollCard', () {
    testWidgets('displays question and status', (tester) async {
      await tester.pumpWidget(wrap(
        PollCard(
          question: 'Best color?',
          status: PollStatus.completed,
          optionCount: 4,
          onTap: () {},
        ),
      ));
      expect(find.text('Best color?'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(
        PollCard(
          question: 'Q?',
          status: PollStatus.draft,
          optionCount: 2,
          onTap: () => tapped = true,
        ),
      ));
      await tester.tap(find.byType(PollCard));
      expect(tapped, isTrue);
    });
  });
}
