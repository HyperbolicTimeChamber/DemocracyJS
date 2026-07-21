// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'poll_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PollModel _$PollModelFromJson(Map<String, dynamic> json) {
  return _PollModel.fromJson(json);
}

/// @nodoc
mixin _$PollModel {
  String get id => throw _privateConstructorUsedError;
  String get question => throw _privateConstructorUsedError;
  List<PollOptionModel> get options => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get voteMode => throw _privateConstructorUsedError;
  String get resultsVisibility => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PollModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PollModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PollModelCopyWith<PollModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PollModelCopyWith<$Res> {
  factory $PollModelCopyWith(PollModel value, $Res Function(PollModel) then) =
      _$PollModelCopyWithImpl<$Res, PollModel>;
  @useResult
  $Res call(
      {String id,
      String question,
      List<PollOptionModel> options,
      String status,
      String voteMode,
      String resultsVisibility,
      String createdAt,
      String updatedAt});
}

/// @nodoc
class _$PollModelCopyWithImpl<$Res, $Val extends PollModel>
    implements $PollModelCopyWith<$Res> {
  _$PollModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PollModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? question = null,
    Object? options = null,
    Object? status = null,
    Object? voteMode = null,
    Object? resultsVisibility = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      options: null == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as List<PollOptionModel>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      voteMode: null == voteMode
          ? _value.voteMode
          : voteMode // ignore: cast_nullable_to_non_nullable
              as String,
      resultsVisibility: null == resultsVisibility
          ? _value.resultsVisibility
          : resultsVisibility // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PollModelImplCopyWith<$Res>
    implements $PollModelCopyWith<$Res> {
  factory _$$PollModelImplCopyWith(
          _$PollModelImpl value, $Res Function(_$PollModelImpl) then) =
      __$$PollModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String question,
      List<PollOptionModel> options,
      String status,
      String voteMode,
      String resultsVisibility,
      String createdAt,
      String updatedAt});
}

/// @nodoc
class __$$PollModelImplCopyWithImpl<$Res>
    extends _$PollModelCopyWithImpl<$Res, _$PollModelImpl>
    implements _$$PollModelImplCopyWith<$Res> {
  __$$PollModelImplCopyWithImpl(
      _$PollModelImpl _value, $Res Function(_$PollModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PollModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? question = null,
    Object? options = null,
    Object? status = null,
    Object? voteMode = null,
    Object? resultsVisibility = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$PollModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      options: null == options
          ? _value._options
          : options // ignore: cast_nullable_to_non_nullable
              as List<PollOptionModel>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      voteMode: null == voteMode
          ? _value.voteMode
          : voteMode // ignore: cast_nullable_to_non_nullable
              as String,
      resultsVisibility: null == resultsVisibility
          ? _value.resultsVisibility
          : resultsVisibility // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PollModelImpl implements _PollModel {
  const _$PollModelImpl(
      {required this.id,
      required this.question,
      required final List<PollOptionModel> options,
      required this.status,
      required this.voteMode,
      required this.resultsVisibility,
      required this.createdAt,
      required this.updatedAt})
      : _options = options;

  factory _$PollModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PollModelImplFromJson(json);

  @override
  final String id;
  @override
  final String question;
  final List<PollOptionModel> _options;
  @override
  List<PollOptionModel> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  final String status;
  @override
  final String voteMode;
  @override
  final String resultsVisibility;
  @override
  final String createdAt;
  @override
  final String updatedAt;

  @override
  String toString() {
    return 'PollModel(id: $id, question: $question, options: $options, status: $status, voteMode: $voteMode, resultsVisibility: $resultsVisibility, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PollModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.question, question) ||
                other.question == question) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.voteMode, voteMode) ||
                other.voteMode == voteMode) &&
            (identical(other.resultsVisibility, resultsVisibility) ||
                other.resultsVisibility == resultsVisibility) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      question,
      const DeepCollectionEquality().hash(_options),
      status,
      voteMode,
      resultsVisibility,
      createdAt,
      updatedAt);

  /// Create a copy of PollModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PollModelImplCopyWith<_$PollModelImpl> get copyWith =>
      __$$PollModelImplCopyWithImpl<_$PollModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PollModelImplToJson(
      this,
    );
  }
}

abstract class _PollModel implements PollModel {
  const factory _PollModel(
      {required final String id,
      required final String question,
      required final List<PollOptionModel> options,
      required final String status,
      required final String voteMode,
      required final String resultsVisibility,
      required final String createdAt,
      required final String updatedAt}) = _$PollModelImpl;

  factory _PollModel.fromJson(Map<String, dynamic> json) =
      _$PollModelImpl.fromJson;

  @override
  String get id;
  @override
  String get question;
  @override
  List<PollOptionModel> get options;
  @override
  String get status;
  @override
  String get voteMode;
  @override
  String get resultsVisibility;
  @override
  String get createdAt;
  @override
  String get updatedAt;

  /// Create a copy of PollModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PollModelImplCopyWith<_$PollModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
