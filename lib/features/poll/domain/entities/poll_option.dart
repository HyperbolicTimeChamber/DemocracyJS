import 'package:freezed_annotation/freezed_annotation.dart';

part 'poll_option.freezed.dart';

@freezed
class PollOption with _$PollOption {
  const factory PollOption({
    required String id,
    required String text,
    @Default(0) int voteCount,
  }) = _PollOption;
}
