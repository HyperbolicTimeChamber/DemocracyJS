import 'package:flutter_test/flutter_test.dart';
import 'package:democracy_js/core/enums/results_visibility.dart';

void main() {
  group('ResultsVisibility', () {
    test('label returns human-readable string', () {
      expect(ResultsVisibility.live.label, 'Live');
      expect(ResultsVisibility.afterVote.label, 'After Vote');
      expect(ResultsVisibility.hostControlled.label, 'Host Controlled');
    });

    test('toJson returns camelCase string', () {
      expect(ResultsVisibility.live.toJson(), 'live');
      expect(ResultsVisibility.afterVote.toJson(), 'afterVote');
      expect(ResultsVisibility.hostControlled.toJson(), 'hostControlled');
    });

    test('fromJson parses valid string', () {
      expect(ResultsVisibilityX.fromJson('live'), ResultsVisibility.live);
      expect(ResultsVisibilityX.fromJson('afterVote'), ResultsVisibility.afterVote);
      expect(ResultsVisibilityX.fromJson('hostControlled'), ResultsVisibility.hostControlled);
    });

    test('fromJson throws on invalid string', () {
      expect(() => ResultsVisibilityX.fromJson('invalid'), throwsArgumentError);
    });
  });
}
