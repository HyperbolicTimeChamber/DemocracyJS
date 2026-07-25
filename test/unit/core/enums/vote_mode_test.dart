import 'package:flutter_test/flutter_test.dart';
import 'package:democracy_js/core/enums/vote_mode.dart';

void main() {
  group('VoteMode', () {
    test('label returns human-readable string', () {
      expect(VoteMode.singleChoice.label, 'Single Choice');
      expect(VoteMode.multipleChoice.label, 'Multiple Choice');
    });

    test('toJson returns camelCase string', () {
      expect(VoteMode.singleChoice.toJson(), 'singleChoice');
      expect(VoteMode.multipleChoice.toJson(), 'multipleChoice');
    });

    test('fromJson parses valid string', () {
      expect(VoteModeX.fromJson('singleChoice'), VoteMode.singleChoice);
      expect(VoteModeX.fromJson('multipleChoice'), VoteMode.multipleChoice);
    });

    test('fromJson throws on invalid string', () {
      expect(() => VoteModeX.fromJson('invalid'), throwsArgumentError);
    });
  });
}
