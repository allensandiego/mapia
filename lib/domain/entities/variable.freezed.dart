// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'variable.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Variable _$VariableFromJson(Map<String, dynamic> json) {
  return _Variable.fromJson(json);
}

/// @nodoc
mixin _$Variable {
  String get key => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;
  bool get isSecret => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  /// Serializes this Variable to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Variable
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VariableCopyWith<Variable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VariableCopyWith<$Res> {
  factory $VariableCopyWith(Variable value, $Res Function(Variable) then) =
      _$VariableCopyWithImpl<$Res, Variable>;
  @useResult
  $Res call(
      {String key,
      String value,
      bool enabled,
      bool isSecret,
      String description});
}

/// @nodoc
class _$VariableCopyWithImpl<$Res, $Val extends Variable>
    implements $VariableCopyWith<$Res> {
  _$VariableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Variable
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? value = null,
    Object? enabled = null,
    Object? isSecret = null,
    Object? description = null,
  }) {
    return _then(_value.copyWith(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      isSecret: null == isSecret
          ? _value.isSecret
          : isSecret // ignore: cast_nullable_to_non_nullable
              as bool,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VariableImplCopyWith<$Res>
    implements $VariableCopyWith<$Res> {
  factory _$$VariableImplCopyWith(
          _$VariableImpl value, $Res Function(_$VariableImpl) then) =
      __$$VariableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String key,
      String value,
      bool enabled,
      bool isSecret,
      String description});
}

/// @nodoc
class __$$VariableImplCopyWithImpl<$Res>
    extends _$VariableCopyWithImpl<$Res, _$VariableImpl>
    implements _$$VariableImplCopyWith<$Res> {
  __$$VariableImplCopyWithImpl(
      _$VariableImpl _value, $Res Function(_$VariableImpl) _then)
      : super(_value, _then);

  /// Create a copy of Variable
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? value = null,
    Object? enabled = null,
    Object? isSecret = null,
    Object? description = null,
  }) {
    return _then(_$VariableImpl(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      isSecret: null == isSecret
          ? _value.isSecret
          : isSecret // ignore: cast_nullable_to_non_nullable
              as bool,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VariableImpl implements _Variable {
  const _$VariableImpl(
      {required this.key,
      this.value = '',
      this.enabled = true,
      this.isSecret = false,
      this.description = ''});

  factory _$VariableImpl.fromJson(Map<String, dynamic> json) =>
      _$$VariableImplFromJson(json);

  @override
  final String key;
  @override
  @JsonKey()
  final String value;
  @override
  @JsonKey()
  final bool enabled;
  @override
  @JsonKey()
  final bool isSecret;
  @override
  @JsonKey()
  final String description;

  @override
  String toString() {
    return 'Variable(key: $key, value: $value, enabled: $enabled, isSecret: $isSecret, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VariableImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.isSecret, isSecret) ||
                other.isSecret == isSecret) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, key, value, enabled, isSecret, description);

  /// Create a copy of Variable
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VariableImplCopyWith<_$VariableImpl> get copyWith =>
      __$$VariableImplCopyWithImpl<_$VariableImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VariableImplToJson(
      this,
    );
  }
}

abstract class _Variable implements Variable {
  const factory _Variable(
      {required final String key,
      final String value,
      final bool enabled,
      final bool isSecret,
      final String description}) = _$VariableImpl;

  factory _Variable.fromJson(Map<String, dynamic> json) =
      _$VariableImpl.fromJson;

  @override
  String get key;
  @override
  String get value;
  @override
  bool get enabled;
  @override
  bool get isSecret;
  @override
  String get description;

  /// Create a copy of Variable
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VariableImplCopyWith<_$VariableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
