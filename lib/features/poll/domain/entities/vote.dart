import 'package:freezed_annotation/freezed_annotation.dart';

part 'vote.freezed.dart';

@freezed
class Vote with _$Vote {
  const factory Vote({
    required String id,
    required String pollId,
    required List<String> optionIds,
    required String voterIp,
    required DateTime timestamp,
  }) = _Vote;
}
