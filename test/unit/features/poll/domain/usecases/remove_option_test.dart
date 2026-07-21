import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/enums/vote_mode.dart';
import 'package:local_poll/core/enums/results_visibility.dart';
import 'package:local_poll/core/errors/app_exceptions.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:local_poll/features/poll/domain/entities/poll_option.dart';
import 'package:local_poll/features/poll/domain/usecases/remove_option.dart';

void main() {
  late RemoveOption removeOption;

  setUp(() {
    removeOption = RemoveOption();
  });

  group('RemoveOption', () {
    test('removes option by id', () {
      final now = DateTime.now();
      final poll = Poll(
        id: 'p1',
        question: 'Q?',
        options: const [
          PollOption(id: 'o1', text: 'A'),
          PollOption(id: 'o2', text: 'B'),
        ],
        status: PollStatus.draft,
        voteMode: VoteMode.singleChoice,
        resultsVisibility: ResultsVisibility.afterVote,
        createdAt: now,
        updatedAt: now,
      );

      final result = removeOption(poll: poll, optionId: 'o1');
      expect(result.options.length, 1);
      expect(result.options.first.id, 'o2');
    });

    test('throws when option not found', () {
      final now = DateTime.now();
      final poll = Poll(
        id: 'p1',
        question: 'Q?',
        options: const [PollOption(id: 'o1', text: 'A')],
        status: PollStatus.draft,
        voteMode: VoteMode.singleChoice,
        resultsVisibility: ResultsVisibility.afterVote,
        createdAt: now,
        updatedAt: now,
      );

      expect(
        () => removeOption(poll: poll, optionId: 'nonexistent'),
        throwsA(isA<PollException>()),
      );
    });
  });
}
