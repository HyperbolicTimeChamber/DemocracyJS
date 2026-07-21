// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'poll_option_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PollOptionModel _$PollOptionModelFromJson(Map<String, dynamic> json) {
  return _PollOptionModel.fromJson(json);
}

/// @nodoc
mixin _$PollOptionModel {
  String get id => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  int get voteCount => throw _privateConstructorUsedError;

  /// Serializes this PollOptionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PollOptionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PollOptionModelCopyWith<PollOptionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PollOptionModelCopyWith<$Res> {
  factory $PollOptionModelCopyWith(
          PollOptionModel value, $Res Function(PollOptionModel) then) =
      _$PollOptionModelCopyWithImpl<$Res, PollOptionModel>;
  @useResult
  $Res call({String id, String text, int voteCount});
}

/// @nodoc
class _$PollOptionModelCopyWithImpl<$Res, $Val extends PollOptionModel>
    implements $PollOptionModelCopyWith<$Res> {
  _$PollOptionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PollOptionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? voteCount = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      voteCount: null == voteCount
          ? _value.voteCount
          : voteCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PollOptionModelImplCopyWith<$Res>
    implements $PollOptionModelCopyWith<$Res> {
  factory _$$PollOptionModelImplCopyWith(_$PollOptionModelImpl value,
          $Res Function(_$PollOptionModelImpl) then) =
      __$$PollOptionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String text, int voteCount});
}

/// @nodoc
class __$$PollOptionModelImplCopyWithImpl<$Res>
    extends _$PollOptionModelCopyWithImpl<$Res, _$PollOptionModelImpl>
    implements _$$PollOptionModelImplCopyWith<$Res> {
  __$$PollOptionModelImplCopyWithImpl(
      _$PollOptionModelImpl _value, $Res Function(_$PollOptionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PollOptionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? voteCount = null,
  }) {
    return _then(_$PollOptionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      voteCount: null == voteCount
          ? _value.voteCount
          : voteCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PollOptionModelImpl implements _PollOptionModel {
  const _$PollOptionModelImpl(
      {required this.id, required this.text, this.voteCount = 0});

  factory _$PollOptionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PollOptionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String text;
  @override
  @JsonKey()
  final int voteCount;

  @override
  String toString() {
    return 'PollOptionModel(id: $id, text: $text, voteCount: $voteCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PollOptionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.voteCount, voteCount) ||
                other.voteCount == voteCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, text, voteCount);

  /// Create a copy of PollOptionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PollOptionModelImplCopyWith<_$PollOptionModelImpl> get copyWith =>
      __$$PollOptionModelImplCopyWithImpl<_$PollOptionModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PollOptionModelImplToJson(
      this,
    );
  }
}

abstract class _PollOptionModel implements PollOptionModel {
  const factory _PollOptionModel(
      {required final String id,
      required final String text,
      final int voteCount}) = _$PollOptionModelImpl;

  factory _PollOptionModel.fromJson(Map<String, dynamic> json) =
      _$PollOptionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get text;
  @override
  int get voteCount;

  /// Create a copy of PollOptionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PollOptionModelImplCopyWith<_$PollOptionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
