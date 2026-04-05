// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'variable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VariableImpl _$$VariableImplFromJson(Map<String, dynamic> json) =>
    _$VariableImpl(
      key: json['key'] as String,
      value: json['value'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? true,
      isSecret: json['isSecret'] as bool? ?? false,
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$$VariableImplToJson(_$VariableImpl instance) =>
    <String, dynamic>{
      'key': instance.key,
      'value': instance.value,
      'enabled': instance.enabled,
      'isSecret': instance.isSecret,
      'description': instance.description,
    };
