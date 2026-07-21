import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/enums/vote_mode.dart';
import 'package:local_poll/core/enums/results_visibility.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:local_poll/features/poll/domain/entities/poll_option.dart';
import 'package:local_poll/features/poll/domain/entities/vote.dart';
import 'package:local_poll/features/voting/domain/usecases/process_vote.dart';

void main() {
  late ProcessVote processVote;

  setUp(() {
    processVote = ProcessVote();
  });

  group('ProcessVote', () {
    test('increments vote count for selected option', () {
      final now = DateTime.now();
      final poll = Poll(
        id: 'p1',
        question: 'Q?',
        options: const [
          PollOption(id: 'o1', text: 'A', voteCount: 0),
          PollOption(id: 'o2', text: 'B', voteCount: 0),
        ],
        status: PollStatus.hosting,
        voteMode: VoteMode.singleChoice,
        resultsVisibility: ResultsVisibility.afterVote,
        createdAt: now,
        updatedAt: now,
      );

      final vote = Vote(
        id: 'v1',
        pollId: 'p1',
        optionIds: const ['o1'],
        voterIp: '192.168.1.5',
        timestamp: now,
      );

      final result = processVote(poll: poll, vote: vote);
      expect(result.options[0].voteCount, 1);
      expect(result.options[1].voteCount, 0);
    });

    test('increments multiple options for multipleChoice', () {
      final now = DateTime.now();
      final poll = Poll(
        id: 'p1',
        question: 'Q?',
        options: const [
          PollOption(id: 'o1', text: 'A', voteCount: 0),
          PollOption(id: 'o2', text: 'B', voteCount: 0),
          PollOption(id: 'o3', text: 'C', voteCount: 0),
        ],
        status: PollStatus.hosting,
        voteMode: VoteMode.multipleChoice,
        resultsVisibility: ResultsVisibility.afterVote,
        createdAt: now,
        updatedAt: now,
      );

      final vote = Vote(
        id: 'v1',
        pollId: 'p1',
        optionIds: const ['o1', 'o3'],
        voterIp: '192.168.1.5',
        timestamp: now,
      );

      final result = processVote(poll: poll, vote: vote);
      expect(result.options[0].voteCount, 1);
      expect(result.options[1].voteCount, 0);
      expect(result.options[2].voteCount, 1);
    });
  });
}
