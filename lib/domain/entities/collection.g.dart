// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CollectionImpl _$$CollectionImplFromJson(Map<String, dynamic> json) =>
    _$CollectionImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      environmentId: json['environmentId'] as String?,
      variables: (json['variables'] as List<dynamic>?)
              ?.map((e) => Variable.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      folders: (json['folders'] as List<dynamic>?)
              ?.map((e) => Folder.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      requests: (json['requests'] as List<dynamic>?)
              ?.map((e) => ApiRequest.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CollectionImplToJson(_$CollectionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'environmentId': instance.environmentId,
      'variables': instance.variables,
      'folders': instance.folders,
      'requests': instance.requests,
    };
