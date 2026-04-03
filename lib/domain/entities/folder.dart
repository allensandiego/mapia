import 'package:freezed_annotation/freezed_annotation.dart';
import 'api_request.dart';

part 'folder.freezed.dart';
part 'folder.g.dart';

@freezed
class Folder with _$Folder {
  const factory Folder({
    required String id,
    required String name,
    @Default([]) List<ApiRequest> requests,
    @Default('') String description,
  }) = _Folder;

  factory Folder.fromJson(Map<String, dynamic> json) => _$FolderFromJson(json);
}
