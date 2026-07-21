import 'package:local_poll/core/constants/app_constants.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/enums/vote_mode.dart';
import 'package:local_poll/core/enums/results_visibility.dart';
import 'package:local_poll/core/errors/app_exceptions.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:uuid/uuid.dart';

class CreatePoll {
  static const _uuid = Uuid();

  Poll call({
    required String question,
    required VoteMode voteMode,
    required ResultsVisibility resultsVisibility,
  }) {
    final trimmed = question.trim();
    if (trimmed.isEmpty) {
      throw const PollException('Question cannot be empty');
    }
    if (trimmed.length > AppConstants.maxQuestionLength) {
      throw PollException(
        'Question cannot exceed ${AppConstants.maxQuestionLength} characters',
      );
    }

    final now = DateTime.now();
    return Poll(
      id: _uuid.v4(),
      question: trimmed,
      options: const [],
      status: PollStatus.draft,
      voteMode: voteMode,
      resultsVisibility: resultsVisibility,
      createdAt: now,
      updatedAt: now,
    );
  }
}
