import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:local_poll/features/poll/domain/entities/vote.dart';

part 'vote_model.freezed.dart';
part 'vote_model.g.dart';

@freezed
class VoteModel with _$VoteModel {
  const factory VoteModel({
    required String id,
    required String pollId,
    required List<String> optionIds,
    required String voterIp,
    required String timestamp,
  }) = _VoteModel;

  factory VoteModel.fromJson(Map<String, dynamic> json) =>
      _$VoteModelFromJson(json);

  factory VoteModel.fromEntity(Vote entity) => VoteModel(
        id: entity.id,
        pollId: entity.pollId,
        optionIds: entity.optionIds,
        voterIp: entity.voterIp,
        timestamp: entity.timestamp.toIso8601String(),
      );
}

extension VoteModelX on VoteModel {
  Vote toEntity() => Vote(
        id: id,
        pollId: pollId,
        optionIds: optionIds,
        voterIp: voterIp,
        timestamp: DateTime.parse(timestamp),
      );
}
