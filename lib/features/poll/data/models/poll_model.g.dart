// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PollModelImpl _$$PollModelImplFromJson(Map<String, dynamic> json) =>
    _$PollModelImpl(
      id: json['id'] as String,
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => PollOptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String,
      voteMode: json['voteMode'] as String,
      resultsVisibility: json['resultsVisibility'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$$PollModelImplToJson(_$PollModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'options': instance.options,
      'status': instance.status,
      'voteMode': instance.voteMode,
      'resultsVisibility': instance.resultsVisibility,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
