// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll_option_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PollOptionModelImpl _$$PollOptionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PollOptionModelImpl(
      id: json['id'] as String,
      text: json['text'] as String,
      voteCount: (json['voteCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$PollOptionModelImplToJson(
        _$PollOptionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'voteCount': instance.voteCount,
    };
