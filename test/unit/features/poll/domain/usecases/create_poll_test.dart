import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/enums/vote_mode.dart';
import 'package:local_poll/core/enums/results_visibility.dart';
import 'package:local_poll/core/errors/app_exceptions.dart';
import 'package:local_poll/features/poll/domain/usecases/create_poll.dart';

void main() {
  group('CreatePoll', () {
    late CreatePoll createPoll;

    setUp(() {
      createPoll = CreatePoll();
    });

    test('creates poll with valid inputs', () {
      final poll = createPoll(
        question: 'Best language?',
        voteMode: VoteMode.singleChoice,
        resultsVisibility: ResultsVisibility.afterVote,
      );

      expect(poll.question, 'Best language?');
      expect(poll.status, PollStatus.draft);
      expect(poll.voteMode, VoteMode.singleChoice);
      expect(poll.resultsVisibility, ResultsVisibility.afterVote);
      expect(poll.options, isEmpty);
      expect(poll.id, isNotEmpty);
    });

    test('throws on empty question', () {
      expect(
        () => createPoll(
          question: '',
          voteMode: VoteMode.singleChoice,
          resultsVisibility: ResultsVisibility.afterVote,
        ),
        throwsA(isA<PollException>()),
      );
    });

    test('throws on question exceeding max length', () {
      expect(
        () => createPoll(
          question: 'x' * 501,
          voteMode: VoteMode.singleChoice,
          resultsVisibility: ResultsVisibility.afterVote,
        ),
        throwsA(isA<PollException>()),
      );
    });
  });
}
