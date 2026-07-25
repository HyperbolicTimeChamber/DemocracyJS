import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:democracy_js/core/enums/poll_status.dart';
import 'package:democracy_js/core/enums/vote_mode.dart';
import 'package:democracy_js/core/enums/results_visibility.dart';
import 'poll_option.dart';

part 'poll.freezed.dart';

@freezed
class Poll with _$Poll {
  const factory Poll({
    required String id,
    required String question,
    required List<PollOption> options,
    required PollStatus status,
    required VoteMode voteMode,
    required ResultsVisibility resultsVisibility,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Poll;
}
