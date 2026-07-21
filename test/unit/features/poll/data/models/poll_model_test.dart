import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/enums/vote_mode.dart';
import 'package:local_poll/core/enums/results_visibility.dart';
import 'package:local_poll/features/poll/data/models/poll_model.dart';
import 'package:local_poll/features/poll/data/models/poll_option_model.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:local_poll/features/poll/domain/entities/poll_option.dart';

void main() {
  group('PollModel', () {
    final now = DateTime(2026, 1, 1);

    test('fromJson creates model from JSON map', () {
      final json = {
        'id': 'p1',
        'question': 'Best color?',
        'options': [
          {'id': 'o1', 'text': 'Red', 'voteCount': 3},
          {'id': 'o2', 'text': 'Blue', 'voteCount': 5},
        ],
        'status': 'hosting',
        'voteMode': 'singleChoice',
        'resultsVisibility': 'afterVote',
        'createdAt': '2026-01-01T00:00:00.000',
        'updatedAt': '2026-01-01T00:00:00.000',
      };

      final model = PollModel.fromJson(json);
      expect(model.id, 'p1');
      expect(model.question, 'Best color?');
      expect(model.options.length, 2);
      expect(model.status, 'hosting');
    });

    test('toJson produces valid JSON map', () {
      const model = PollModel(
        id: 'p1',
        question: 'Q?',
        options: [PollOptionModel(id: 'o1', text: 'A', voteCount: 0)],
        status: 'draft',
        voteMode: 'singleChoice',
        resultsVisibility: 'afterVote',
        createdAt: '2026-01-01T00:00:00.000',
        updatedAt: '2026-01-01T00:00:00.000',
      );

      final json = model.toJson();
      expect(json['id'], 'p1');
      expect(json['options'], isList);
      final firstOption = (json['options'] as List).first;
      expect(firstOption is Map ? firstOption['text'] : (firstOption as PollOptionModel).text, 'A');
    });

    test('round-trips entity → model → entity', () {
      final entity = Poll(
        id: 'p1',
        question: 'Q?',
        options: const [PollOption(id: 'o1', text: 'A', voteCount: 2)],
        status: PollStatus.hosting,
        voteMode: VoteMode.singleChoice,
        resultsVisibility: ResultsVisibility.afterVote,
        createdAt: now,
        updatedAt: now,
      );

      final model = PollModel.fromEntity(entity);
      final restored = model.toEntity();

      expect(restored.id, entity.id);
      expect(restored.question, entity.question);
      expect(restored.status, entity.status);
      expect(restored.options.first.voteCount, 2);
    });

    test('round-trips JSON → model → JSON', () {
      final json = {
        'id': 'p1',
        'question': 'Q?',
        'options': [
          {'id': 'o1', 'text': 'A', 'voteCount': 0},
        ],
        'status': 'draft',
        'voteMode': 'singleChoice',
        'resultsVisibility': 'live',
        'createdAt': '2026-01-01T00:00:00.000',
        'updatedAt': '2026-01-01T00:00:00.000',
      };

      final model = PollModel.fromJson(json);
      final output = model.toJson();

      expect(output['id'], json['id']);
      expect(output['status'], json['status']);
      expect(output['resultsVisibility'], json['resultsVisibility']);
    });
  });
}
