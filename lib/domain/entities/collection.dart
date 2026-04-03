import 'package:freezed_annotation/freezed_annotation.dart';
import 'api_request.dart';
import 'folder.dart';
import 'variable.dart';

part 'collection.freezed.dart';
part 'collection.g.dart';

@freezed
class Collection with _$Collection {
  const factory Collection({
    required String id,
    required String name,
    @Default('') String description,
    String? environmentId,
    @Default([]) List<Variable> variables,
    @Default([]) List<Folder> folders,
    @Default([]) List<ApiRequest> requests,
  }) = _Collection;

  factory Collection.fromJson(Map<String, dynamic> json) =>
      _$CollectionFromJson(json);
}
