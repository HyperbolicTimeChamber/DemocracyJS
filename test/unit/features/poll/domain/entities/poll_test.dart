import 'package:flutter_test/flutter_test.dart';
import 'package:democracy_js/core/enums/poll_status.dart';
import 'package:democracy_js/core/enums/vote_mode.dart';
import 'package:democracy_js/core/enums/results_visibility.dart';
import 'package:democracy_js/features/poll/domain/entities/poll.dart';
import 'package:democracy_js/features/poll/domain/entities/poll_option.dart';

void main() {
  group('Poll', () {
    test('creates with required fields', () {
      final now = DateTime.now();
      final poll = Poll(
        id: 'test-id',
        question: 'What is best?',
        options: [
          const PollOption(id: 'opt-1', text: 'Option A', voteCount: 0),
          const PollOption(id: 'opt-2', text: 'Option B', voteCount: 0),
        ],
        status: PollStatus.draft,
        voteMode: VoteMode.singleChoice,
        resultsVisibility: ResultsVisibility.afterVote,
        createdAt: now,
        updatedAt: now,
      );

      expect(poll.id, 'test-id');
      expect(poll.question, 'What is best?');
      expect(poll.options.length, 2);
      expect(poll.status, PollStatus.draft);
      expect(poll.voteMode, VoteMode.singleChoice);
      expect(poll.resultsVisibility, ResultsVisibility.afterVote);
    });

    test('copyWith creates modified copy', () {
      final now = DateTime.now();
      final poll = Poll(
        id: 'test-id',
        question: 'Original?',
        options: const [],
        status: PollStatus.draft,
        voteMode: VoteMode.singleChoice,
        resultsVisibility: ResultsVisibility.afterVote,
        createdAt: now,
        updatedAt: now,
      );

      final updated = poll.copyWith(status: PollStatus.hosting);
      expect(updated.status, PollStatus.hosting);
      expect(updated.question, 'Original?');
    });

    test('equality works for identical values', () {
      final now = DateTime(2026, 1, 1);
      final a = Poll(
        id: 'id',
        question: 'Q?',
        options: const [],
        status: PollStatus.draft,
        voteMode: VoteMode.singleChoice,
        resultsVisibility: ResultsVisibility.afterVote,
        createdAt: now,
        updatedAt: now,
      );
      final b = Poll(
        id: 'id',
        question: 'Q?',
        options: const [],
        status: PollStatus.draft,
        voteMode: VoteMode.singleChoice,
        resultsVisibility: ResultsVisibility.afterVote,
        createdAt: now,
        updatedAt: now,
      );
      expect(a, equals(b));
    });
  });

  group('PollOption', () {
    test('creates with defaults', () {
      const option = PollOption(id: 'o1', text: 'Yes', voteCount: 0);
      expect(option.id, 'o1');
      expect(option.text, 'Yes');
      expect(option.voteCount, 0);
    });
  });
}
