import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:local_poll/core/constants/app_constants.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/enums/vote_mode.dart';
import 'package:local_poll/core/enums/results_visibility.dart';
import 'package:local_poll/features/poll/data/repositories/poll_repository_impl.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:local_poll/features/poll/domain/entities/poll_option.dart';
import 'package:local_poll/features/poll/domain/entities/vote.dart';
import 'dart:io';

void main() {
  late PollRepositoryImpl repository;
  late Box pollsBox;
  late Box votesBox;

  setUp(() async {
    final tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);
    pollsBox = await Hive.openBox(AppConstants.pollsBox);
    votesBox = await Hive.openBox(AppConstants.votesBox);
    repository = PollRepositoryImpl(pollsBox: pollsBox, votesBox: votesBox);
  });

  tearDown(() async {
    await pollsBox.clear();
    await votesBox.clear();
    await Hive.close();
  });

  Poll makePoll({String id = 'p1'}) {
    final now = DateTime.now();
    return Poll(
      id: id,
      question: 'Test?',
      options: const [
        PollOption(id: 'o1', text: 'A', voteCount: 0),
        PollOption(id: 'o2', text: 'B', voteCount: 0),
      ],
      status: PollStatus.draft,
      voteMode: VoteMode.singleChoice,
      resultsVisibility: ResultsVisibility.afterVote,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('PollRepositoryImpl', () {
    test('createPoll stores and returns poll', () async {
      final poll = makePoll();
      final result = await repository.createPoll(poll);
      expect(result.id, poll.id);

      final stored = await repository.getPoll(poll.id);
      expect(stored, isNotNull);
      expect(stored!.question, 'Test?');
    });

    test('getAllPolls returns all stored polls', () async {
      await repository.createPoll(makePoll(id: 'p1'));
      await repository.createPoll(makePoll(id: 'p2'));

      final polls = await repository.getAllPolls();
      expect(polls.length, 2);
    });

    test('updatePoll modifies existing poll', () async {
      final poll = makePoll();
      await repository.createPoll(poll);

      final updated = poll.copyWith(status: PollStatus.hosting);
      await repository.updatePoll(updated);

      final result = await repository.getPoll(poll.id);
      expect(result!.status, PollStatus.hosting);
    });

    test('deletePoll removes poll', () async {
      await repository.createPoll(makePoll());
      await repository.deletePoll('p1');

      final result = await repository.getPoll('p1');
      expect(result, isNull);
    });

    test('submitVote stores vote', () async {
      final vote = Vote(
        id: 'v1',
        pollId: 'p1',
        optionIds: const ['o1'],
        voterIp: '192.168.1.5',
        timestamp: DateTime.now(),
      );

      final result = await repository.submitVote(vote);
      expect(result.id, 'v1');
    });

    test('hasVoted returns true for duplicate IP', () async {
      final vote = Vote(
        id: 'v1',
        pollId: 'p1',
        optionIds: const ['o1'],
        voterIp: '192.168.1.5',
        timestamp: DateTime.now(),
      );
      await repository.submitVote(vote);

      expect(await repository.hasVoted('p1', '192.168.1.5'), isTrue);
      expect(await repository.hasVoted('p1', '192.168.1.6'), isFalse);
    });

    test('getVotesForPoll returns only matching votes', () async {
      final v1 = Vote(
        id: 'v1',
        pollId: 'p1',
        optionIds: const ['o1'],
        voterIp: '1.1.1.1',
        timestamp: DateTime.now(),
      );
      final v2 = Vote(
        id: 'v2',
        pollId: 'p2',
        optionIds: const ['o2'],
        voterIp: '2.2.2.2',
        timestamp: DateTime.now(),
      );
      await repository.submitVote(v1);
      await repository.submitVote(v2);

      final result = await repository.getVotesForPoll('p1');
      expect(result.length, 1);
      expect(result.first.id, 'v1');
    });
  });
}
