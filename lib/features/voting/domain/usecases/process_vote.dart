import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:local_poll/features/poll/domain/entities/poll_option.dart';
import 'package:local_poll/features/poll/domain/entities/vote.dart';

class ProcessVote {
  Poll call({required Poll poll, required Vote vote}) {
    final updatedOptions = poll.options.map((option) {
      if (vote.optionIds.contains(option.id)) {
        return PollOption(
          id: option.id,
          text: option.text,
          voteCount: option.voteCount + 1,
        );
      }
      return option;
    }).toList();

    return poll.copyWith(
      options: updatedOptions,
      updatedAt: DateTime.now(),
    );
  }
}
