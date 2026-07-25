import 'package:flutter_test/flutter_test.dart';
import 'package:democracy_js/core/enums/poll_status.dart';

void main() {
  group('PollStatus', () {
    test('label returns human-readable string', () {
      expect(PollStatus.draft.label, 'Draft');
      expect(PollStatus.hosting.label, 'Hosting');
      expect(PollStatus.paused.label, 'Paused');
      expect(PollStatus.completed.label, 'Completed');
    });

    test('toJson returns snake_case string', () {
      expect(PollStatus.draft.toJson(), 'draft');
      expect(PollStatus.hosting.toJson(), 'hosting');
      expect(PollStatus.paused.toJson(), 'paused');
      expect(PollStatus.completed.toJson(), 'completed');
    });

    test('fromJson parses valid string', () {
      expect(PollStatusX.fromJson('draft'), PollStatus.draft);
      expect(PollStatusX.fromJson('hosting'), PollStatus.hosting);
      expect(PollStatusX.fromJson('paused'), PollStatus.paused);
      expect(PollStatusX.fromJson('completed'), PollStatus.completed);
    });

    test('fromJson throws on invalid string', () {
      expect(() => PollStatusX.fromJson('invalid'), throwsArgumentError);
    });
  });
}
