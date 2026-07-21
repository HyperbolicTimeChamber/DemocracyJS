import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/app.dart';

void main() {
  testWidgets('App smoke test - renders Local Poll text', (WidgetTester tester) async {
    await tester.pumpWidget(const LocalPollApp());
    expect(find.text('Local Poll'), findsOneWidget);
  });
}
