import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/core/errors/app_exceptions.dart';
import 'package:local_poll/features/poll/domain/usecases/submit_vote.dart';

void main() {
  group('SubmitVote', () {
    late SubmitVote submitVote;

    setUp(() {
      submitVote = SubmitVote();
    });

    test('creates vote with valid inputs', () {
      final vote = submitVote(
        pollId: 'p1',
        optionIds: ['o1'],
        voterIp: '192.168.1.5',
      );

      expect(vote.pollId, 'p1');
      expect(vote.optionIds, ['o1']);
      expect(vote.voterIp, '192.168.1.5');
      expect(vote.id, isNotEmpty);
    });

    test('throws on empty optionIds', () {
      expect(
        () => submitVote(
          pollId: 'p1',
          optionIds: [],
          voterIp: '192.168.1.5',
        ),
        throwsA(isA<VoteException>()),
      );
    });

    test('throws on empty voterIp', () {
      expect(
        () => submitVote(
          pollId: 'p1',
          optionIds: ['o1'],
          voterIp: '',
        ),
        throwsA(isA<VoteException>()),
      );
    });
  });
}
