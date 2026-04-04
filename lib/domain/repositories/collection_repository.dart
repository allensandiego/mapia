import '../../domain/entities/collection.dart';
import '../../domain/entities/api_request.dart';
import '../../domain/entities/folder.dart';

abstract class CollectionRepository {
  Future<List<Collection>> getAll();
  Future<void> save(Collection collection);
  Future<void> delete(String collectionId);
  Future<void> addRequest(String collectionId, ApiRequest request,
      {String? folderId});
  Future<void> updateRequest(String collectionId, ApiRequest request,
      {String? folderId});
  Future<void> deleteRequest(String collectionId, String requestId,
      {String? folderId});
  Future<void> addFolder(String collectionId, Folder folder);
  Future<void> deleteFolder(String collectionId, String folderId);
  Future<void> reorderFolders(String collectionId, List<String> orderedIds);
  Future<void> reorderRequests(
      String collectionId, String? folderId, List<String> orderedIds);
  Future<void> reorderCollections(List<String> orderedIds);
  Future<void> moveRequest(
    String requestId, {
    required String fromCollectionId,
    String? fromFolderId,
    required String toCollectionId,
    String? toFolderId,
    int? toIndex,
  });
  Future<void> moveFolder(
    String folderId, {
    required String fromCollectionId,
    required String toCollectionId,
    int? toIndex,
  });
  Future<String> exportCollection(String collectionId);
  Future<Collection> importCollection(String jsonString);
}
