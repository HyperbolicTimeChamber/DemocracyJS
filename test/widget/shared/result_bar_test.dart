import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/shared/widgets/result_bar.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('ResultBar', () {
    testWidgets('displays option text and vote count', (tester) async {
      await tester.pumpWidget(wrap(
        const ResultBar(text: 'Option A', voteCount: 5, totalVotes: 10),
      ));
      expect(find.text('Option A'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('displays percentage', (tester) async {
      await tester.pumpWidget(wrap(
        const ResultBar(text: 'Option A', voteCount: 3, totalVotes: 10),
      ));
      expect(find.text('30%'), findsOneWidget);
    });

    testWidgets('handles zero total votes', (tester) async {
      await tester.pumpWidget(wrap(
        const ResultBar(text: 'Option A', voteCount: 0, totalVotes: 0),
      ));
      expect(find.text('0%'), findsOneWidget);
    });
  });
}
