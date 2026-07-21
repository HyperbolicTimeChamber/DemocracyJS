// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VoteModelImpl _$$VoteModelImplFromJson(Map<String, dynamic> json) =>
    _$VoteModelImpl(
      id: json['id'] as String,
      pollId: json['pollId'] as String,
      optionIds:
          (json['optionIds'] as List<dynamic>).map((e) => e as String).toList(),
      voterIp: json['voterIp'] as String,
      timestamp: json['timestamp'] as String,
    );

Map<String, dynamic> _$$VoteModelImplToJson(_$VoteModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pollId': instance.pollId,
      'optionIds': instance.optionIds,
      'voterIp': instance.voterIp,
      'timestamp': instance.timestamp,
    };
