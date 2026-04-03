// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HistoryEntryImpl _$$HistoryEntryImplFromJson(Map<String, dynamic> json) =>
    _$HistoryEntryImpl(
      id: json['id'] as String,
      request: ApiRequest.fromJson(json['request'] as Map<String, dynamic>),
      response: ApiResponse.fromJson(json['response'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$HistoryEntryImplToJson(_$HistoryEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'request': instance.request,
      'response': instance.response,
      'timestamp': instance.timestamp.toIso8601String(),
    };
