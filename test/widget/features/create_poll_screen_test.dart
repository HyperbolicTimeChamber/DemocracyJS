import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:democracy_js/features/poll/presentation/screens/create_poll_screen.dart';

void main() {
  Widget wrap(Widget child) {
    return ProviderScope(child: MaterialApp(home: child));
  }

  group('CreatePollScreen', () {
    testWidgets('has question input field', (tester) async {
      await tester.pumpWidget(wrap(const CreatePollScreen()));
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('has add option button', (tester) async {
      await tester.pumpWidget(wrap(const CreatePollScreen()));
      expect(find.text('Add Option'), findsOneWidget);
    });
  });
}
