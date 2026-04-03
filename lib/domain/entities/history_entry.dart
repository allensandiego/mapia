import 'package:freezed_annotation/freezed_annotation.dart';
import 'api_request.dart';
import 'api_response.dart';

part 'history_entry.freezed.dart';
part 'history_entry.g.dart';

@freezed
class HistoryEntry with _$HistoryEntry {
  const factory HistoryEntry({
    required String id,
    required ApiRequest request,
    required ApiResponse response,
    required DateTime timestamp,
  }) = _HistoryEntry;

  factory HistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$HistoryEntryFromJson(json);
}
