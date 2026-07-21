// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'poll.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Poll {
  String get id => throw _privateConstructorUsedError;
  String get question => throw _privateConstructorUsedError;
  List<PollOption> get options => throw _privateConstructorUsedError;
  PollStatus get status => throw _privateConstructorUsedError;
  VoteMode get voteMode => throw _privateConstructorUsedError;
  ResultsVisibility get resultsVisibility => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of Poll
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PollCopyWith<Poll> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PollCopyWith<$Res> {
  factory $PollCopyWith(Poll value, $Res Function(Poll) then) =
      _$PollCopyWithImpl<$Res, Poll>;
  @useResult
  $Res call(
      {String id,
      String question,
      List<PollOption> options,
      PollStatus status,
      VoteMode voteMode,
      ResultsVisibility resultsVisibility,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$PollCopyWithImpl<$Res, $Val extends Poll>
    implements $PollCopyWith<$Res> {
  _$PollCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Poll
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
              as List<PollOption>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PollStatus,
      voteMode: null == voteMode
          ? _value.voteMode
          : voteMode // ignore: cast_nullable_to_non_nullable
              as VoteMode,
      resultsVisibility: null == resultsVisibility
          ? _value.resultsVisibility
          : resultsVisibility // ignore: cast_nullable_to_non_nullable
              as ResultsVisibility,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PollImplCopyWith<$Res> implements $PollCopyWith<$Res> {
  factory _$$PollImplCopyWith(
          _$PollImpl value, $Res Function(_$PollImpl) then) =
      __$$PollImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String question,
      List<PollOption> options,
      PollStatus status,
      VoteMode voteMode,
      ResultsVisibility resultsVisibility,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$PollImplCopyWithImpl<$Res>
    extends _$PollCopyWithImpl<$Res, _$PollImpl>
    implements _$$PollImplCopyWith<$Res> {
  __$$PollImplCopyWithImpl(_$PollImpl _value, $Res Function(_$PollImpl) _then)
      : super(_value, _then);

  /// Create a copy of Poll
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
    return _then(_$PollImpl(
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
              as List<PollOption>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PollStatus,
      voteMode: null == voteMode
          ? _value.voteMode
          : voteMode // ignore: cast_nullable_to_non_nullable
              as VoteMode,
      resultsVisibility: null == resultsVisibility
          ? _value.resultsVisibility
          : resultsVisibility // ignore: cast_nullable_to_non_nullable
              as ResultsVisibility,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$PollImpl implements _Poll {
  const _$PollImpl(
      {required this.id,
      required this.question,
      required final List<PollOption> options,
      required this.status,
      required this.voteMode,
      required this.resultsVisibility,
      required this.createdAt,
      required this.updatedAt})
      : _options = options;

  @override
  final String id;
  @override
  final String question;
  final List<PollOption> _options;
  @override
  List<PollOption> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  final PollStatus status;
  @override
  final VoteMode voteMode;
  @override
  final ResultsVisibility resultsVisibility;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Poll(id: $id, question: $question, options: $options, status: $status, voteMode: $voteMode, resultsVisibility: $resultsVisibility, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PollImpl &&
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

  /// Create a copy of Poll
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PollImplCopyWith<_$PollImpl> get copyWith =>
      __$$PollImplCopyWithImpl<_$PollImpl>(this, _$identity);
}

abstract class _Poll implements Poll {
  const factory _Poll(
      {required final String id,
      required final String question,
      required final List<PollOption> options,
      required final PollStatus status,
      required final VoteMode voteMode,
      required final ResultsVisibility resultsVisibility,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$PollImpl;

  @override
  String get id;
  @override
  String get question;
  @override
  List<PollOption> get options;
  @override
  PollStatus get status;
  @override
  VoteMode get voteMode;
  @override
  ResultsVisibility get resultsVisibility;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Poll
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PollImplCopyWith<_$PollImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
