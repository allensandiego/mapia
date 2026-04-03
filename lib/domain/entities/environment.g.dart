// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EnvironmentImpl _$$EnvironmentImplFromJson(Map<String, dynamic> json) =>
    _$EnvironmentImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      variables: (json['variables'] as List<dynamic>?)
              ?.map((e) => Variable.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$EnvironmentImplToJson(_$EnvironmentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'variables': instance.variables,
    };
