import 'package:democracy_js/core/errors/app_exceptions.dart';
import 'package:democracy_js/features/poll/domain/entities/vote.dart';
import 'package:uuid/uuid.dart';

class SubmitVote {
  static const _uuid = Uuid();

  Vote call({
    required String pollId,
    required List<String> optionIds,
    required String voterIp,
  }) {
    if (optionIds.isEmpty) {
      throw const VoteException('Must select at least one option');
    }
    if (voterIp.isEmpty) {
      throw const VoteException('Voter IP is required');
    }

    return Vote(
      id: _uuid.v4(),
      pollId: pollId,
      optionIds: optionIds,
      voterIp: voterIp,
      timestamp: DateTime.now(),
    );
  }
}
