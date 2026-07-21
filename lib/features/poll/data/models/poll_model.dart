import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/enums/vote_mode.dart';
import 'package:local_poll/core/enums/results_visibility.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'poll_option_model.dart';

part 'poll_model.freezed.dart';
part 'poll_model.g.dart';

@freezed
class PollModel with _$PollModel {
  const factory PollModel({
    required String id,
    required String question,
    required List<PollOptionModel> options,
    required String status,
    required String voteMode,
    required String resultsVisibility,
    required String createdAt,
    required String updatedAt,
  }) = _PollModel;

  factory PollModel.fromJson(Map<String, dynamic> json) =>
      _$PollModelFromJson(json);

  factory PollModel.fromEntity(Poll entity) => PollModel(
        id: entity.id,
        question: entity.question,
        options:
            entity.options.map((o) => PollOptionModel.fromEntity(o)).toList(),
        status: entity.status.toJson(),
        voteMode: entity.voteMode.toJson(),
        resultsVisibility: entity.resultsVisibility.toJson(),
        createdAt: entity.createdAt.toIso8601String(),
        updatedAt: entity.updatedAt.toIso8601String(),
      );
}

extension PollModelX on PollModel {
  Poll toEntity() => Poll(
        id: id,
        question: question,
        options: options.map((o) => o.toEntity()).toList(),
        status: PollStatusX.fromJson(status),
        voteMode: VoteModeX.fromJson(voteMode),
        resultsVisibility: ResultsVisibilityX.fromJson(resultsVisibility),
        createdAt: DateTime.parse(createdAt),
        updatedAt: DateTime.parse(updatedAt),
      );
}
