// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ApiResponseImpl _$$ApiResponseImplFromJson(Map<String, dynamic> json) =>
    _$ApiResponseImpl(
      statusCode: (json['statusCode'] as num).toInt(),
      statusMessage: json['statusMessage'] as String,
      body: json['body'] as String,
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      durationMs: (json['durationMs'] as num).toInt(),
      sizeBytes: (json['sizeBytes'] as num).toInt(),
      cookies: (json['cookies'] as List<dynamic>?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          const [],
      contentType: json['contentType'] as String?,
    );

Map<String, dynamic> _$$ApiResponseImplToJson(_$ApiResponseImpl instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'statusMessage': instance.statusMessage,
      'body': instance.body,
      'headers': instance.headers,
      'durationMs': instance.durationMs,
      'sizeBytes': instance.sizeBytes,
      'cookies': instance.cookies,
      'contentType': instance.contentType,
    };
