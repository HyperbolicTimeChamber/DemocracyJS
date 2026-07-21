import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/shared/widgets/primary_button.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('PrimaryButton', () {
    testWidgets('displays label text', (tester) async {
      await tester.pumpWidget(wrap(
        PrimaryButton(label: 'Submit', onPressed: () {}),
      ));
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;
      await tester.pumpWidget(wrap(
        PrimaryButton(label: 'Go', onPressed: () => pressed = true),
      ));
      await tester.tap(find.text('Go'));
      expect(pressed, isTrue);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(wrap(
        const PrimaryButton(label: 'Go', onPressed: null),
      ));
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(wrap(
        PrimaryButton(label: 'Go', onPressed: () {}, isLoading: true),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Go'), findsNothing);
    });
  });
}
