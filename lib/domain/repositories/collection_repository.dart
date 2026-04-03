import '../../domain/entities/collection.dart';
import '../../domain/entities/api_request.dart';
import '../../domain/entities/folder.dart';

abstract class CollectionRepository {
  Future<List<Collection>> getAll();
  Future<void> save(Collection collection);
  Future<void> delete(String collectionId);
  Future<void> addRequest(String collectionId, ApiRequest request, {String? folderId});
  Future<void> updateRequest(String collectionId, ApiRequest request, {String? folderId});
  Future<void> deleteRequest(String collectionId, String requestId, {String? folderId});
  Future<void> addFolder(String collectionId, Folder folder);
  Future<void> deleteFolder(String collectionId, String folderId);
  Future<void> reorderRequests(String collectionId, String? folderId, List<String> orderedIds);
}
