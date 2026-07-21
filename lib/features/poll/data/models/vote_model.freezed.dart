// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vote_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VoteModel _$VoteModelFromJson(Map<String, dynamic> json) {
  return _VoteModel.fromJson(json);
}

/// @nodoc
mixin _$VoteModel {
  String get id => throw _privateConstructorUsedError;
  String get pollId => throw _privateConstructorUsedError;
  List<String> get optionIds => throw _privateConstructorUsedError;
  String get voterIp => throw _privateConstructorUsedError;
  String get timestamp => throw _privateConstructorUsedError;

  /// Serializes this VoteModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VoteModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VoteModelCopyWith<VoteModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoteModelCopyWith<$Res> {
  factory $VoteModelCopyWith(VoteModel value, $Res Function(VoteModel) then) =
      _$VoteModelCopyWithImpl<$Res, VoteModel>;
  @useResult
  $Res call(
      {String id,
      String pollId,
      List<String> optionIds,
      String voterIp,
      String timestamp});
}

/// @nodoc
class _$VoteModelCopyWithImpl<$Res, $Val extends VoteModel>
    implements $VoteModelCopyWith<$Res> {
  _$VoteModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VoteModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pollId = null,
    Object? optionIds = null,
    Object? voterIp = null,
    Object? timestamp = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      pollId: null == pollId
          ? _value.pollId
          : pollId // ignore: cast_nullable_to_non_nullable
              as String,
      optionIds: null == optionIds
          ? _value.optionIds
          : optionIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      voterIp: null == voterIp
          ? _value.voterIp
          : voterIp // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VoteModelImplCopyWith<$Res>
    implements $VoteModelCopyWith<$Res> {
  factory _$$VoteModelImplCopyWith(
          _$VoteModelImpl value, $Res Function(_$VoteModelImpl) then) =
      __$$VoteModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String pollId,
      List<String> optionIds,
      String voterIp,
      String timestamp});
}

/// @nodoc
class __$$VoteModelImplCopyWithImpl<$Res>
    extends _$VoteModelCopyWithImpl<$Res, _$VoteModelImpl>
    implements _$$VoteModelImplCopyWith<$Res> {
  __$$VoteModelImplCopyWithImpl(
      _$VoteModelImpl _value, $Res Function(_$VoteModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of VoteModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pollId = null,
    Object? optionIds = null,
    Object? voterIp = null,
    Object? timestamp = null,
  }) {
    return _then(_$VoteModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      pollId: null == pollId
          ? _value.pollId
          : pollId // ignore: cast_nullable_to_non_nullable
              as String,
      optionIds: null == optionIds
          ? _value._optionIds
          : optionIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      voterIp: null == voterIp
          ? _value.voterIp
          : voterIp // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VoteModelImpl implements _VoteModel {
  const _$VoteModelImpl(
      {required this.id,
      required this.pollId,
      required final List<String> optionIds,
      required this.voterIp,
      required this.timestamp})
      : _optionIds = optionIds;

  factory _$VoteModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$VoteModelImplFromJson(json);

  @override
  final String id;
  @override
  final String pollId;
  final List<String> _optionIds;
  @override
  List<String> get optionIds {
    if (_optionIds is EqualUnmodifiableListView) return _optionIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_optionIds);
  }

  @override
  final String voterIp;
  @override
  final String timestamp;

  @override
  String toString() {
    return 'VoteModel(id: $id, pollId: $pollId, optionIds: $optionIds, voterIp: $voterIp, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoteModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pollId, pollId) || other.pollId == pollId) &&
            const DeepCollectionEquality()
                .equals(other._optionIds, _optionIds) &&
            (identical(other.voterIp, voterIp) || other.voterIp == voterIp) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, pollId,
      const DeepCollectionEquality().hash(_optionIds), voterIp, timestamp);

  /// Create a copy of VoteModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VoteModelImplCopyWith<_$VoteModelImpl> get copyWith =>
      __$$VoteModelImplCopyWithImpl<_$VoteModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VoteModelImplToJson(
      this,
    );
  }
}

abstract class _VoteModel implements VoteModel {
  const factory _VoteModel(
      {required final String id,
      required final String pollId,
      required final List<String> optionIds,
      required final String voterIp,
      required final String timestamp}) = _$VoteModelImpl;

  factory _VoteModel.fromJson(Map<String, dynamic> json) =
      _$VoteModelImpl.fromJson;

  @override
  String get id;
  @override
  String get pollId;
  @override
  List<String> get optionIds;
  @override
  String get voterIp;
  @override
  String get timestamp;

  /// Create a copy of VoteModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VoteModelImplCopyWith<_$VoteModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
