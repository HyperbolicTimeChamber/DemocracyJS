import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/core/constants/app_constants.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/enums/vote_mode.dart';
import 'package:local_poll/core/enums/results_visibility.dart';
import 'package:local_poll/core/errors/app_exceptions.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:local_poll/features/poll/domain/entities/poll_option.dart';
import 'package:local_poll/features/poll/domain/usecases/add_option.dart';

void main() {
  late AddOption addOption;
  late Poll basePoll;

  setUp(() {
    addOption = AddOption();
    final now = DateTime.now();
    basePoll = Poll(
      id: 'p1',
      question: 'Test?',
      options: const [],
      status: PollStatus.draft,
      voteMode: VoteMode.singleChoice,
      resultsVisibility: ResultsVisibility.afterVote,
      createdAt: now,
      updatedAt: now,
    );
  });

  group('AddOption', () {
    test('adds option to poll', () {
      final result = addOption(poll: basePoll, text: 'Option A');
      expect(result.options.length, 1);
      expect(result.options.first.text, 'Option A');
      expect(result.options.first.voteCount, 0);
    });

    test('trims whitespace from option text', () {
      final result = addOption(poll: basePoll, text: '  Option B  ');
      expect(result.options.first.text, 'Option B');
    });

    test('throws on empty text', () {
      expect(
        () => addOption(poll: basePoll, text: ''),
        throwsA(isA<PollException>()),
      );
    });

    test('throws on text exceeding max length', () {
      expect(
        () => addOption(poll: basePoll, text: 'x' * 201),
        throwsA(isA<PollException>()),
      );
    });

    test('throws when at hard limit', () {
      var poll = basePoll;
      for (var i = 0; i < AppConstants.optionHardLimit; i++) {
        poll = poll.copyWith(
          options: [...poll.options, PollOption(id: 'o$i', text: 'Opt $i')],
        );
      }
      expect(
        () => addOption(poll: poll, text: 'One more'),
        throwsA(isA<PollException>()),
      );
    });
  });
}
