import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:democracy_js/features/poll/domain/entities/poll_option.dart';

part 'poll_option_model.freezed.dart';
part 'poll_option_model.g.dart';

@freezed
class PollOptionModel with _$PollOptionModel {
  const factory PollOptionModel({
    required String id,
    required String text,
    @Default(0) int voteCount,
  }) = _PollOptionModel;

  factory PollOptionModel.fromJson(Map<String, dynamic> json) =>
      _$PollOptionModelFromJson(json);

  factory PollOptionModel.fromEntity(PollOption entity) => PollOptionModel(
        id: entity.id,
        text: entity.text,
        voteCount: entity.voteCount,
      );
}

extension PollOptionModelX on PollOptionModel {
  PollOption toEntity() => PollOption(
        id: id,
        text: text,
        voteCount: voteCount,
      );
}
