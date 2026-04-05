import 'dart:convert';
import '../../core/services/storage_service.dart';
import '../../domain/entities/collection.dart';
import '../../domain/entities/api_request.dart';
import '../../domain/entities/folder.dart';
import '../../domain/repositories/collection_repository.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  static const _storageKey = 'collections';
  final StorageService _storage;

  CollectionRepositoryImpl(this._storage);

  @override
  Future<List<Collection>> getAll() async {
    try {
      final jsonStr = await _storage.load(_storageKey);
      if (jsonStr == null) return [];
      final List<dynamic> jsonList = jsonDecode(jsonStr) as List;
      return jsonList
          .map((e) => Collection.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll(List<Collection> collections) async {
    await _storage.save(
      _storageKey,
      jsonEncode(collections.map((c) => c.toJson()).toList()),
    );
  }

  @override
  Future<void> save(Collection collection) async {
    final all = await getAll();
    final idx = all.indexWhere((c) => c.id == collection.id);
    if (idx >= 0) {
      all[idx] = collection;
    } else {
      all.add(collection);
    }
    await _saveAll(all);
  }

  @override
  Future<void> delete(String collectionId) async {
    final all = await getAll();
    all.removeWhere((c) => c.id == collectionId);
    await _saveAll(all);
  }

  @override
  Future<void> addRequest(
    String collectionId,
    ApiRequest request, {
    String? folderId,
  }) async {
    final all = await getAll();
    final idx = all.indexWhere((c) => c.id == collectionId);
    if (idx < 0) return;
    final col = all[idx];
    if (folderId != null) {
      final folders = col.folders.map((f) {
        if (f.id != folderId) return f;
        return f.copyWith(requests: [...f.requests, request]);
      }).toList();
      all[idx] = col.copyWith(folders: folders);
    } else {
      all[idx] = col.copyWith(requests: [...col.requests, request]);
    }
    await _saveAll(all);
  }

  @override
  Future<void> updateRequest(
    String collectionId,
    ApiRequest request, {
    String? folderId,
  }) async {
    final all = await getAll();
    final idx = all.indexWhere((c) => c.id == collectionId);
    if (idx < 0) return;
    final col = all[idx];
    if (folderId != null) {
      final folders = col.folders.map((f) {
        if (f.id != folderId) return f;
        final reqs =
            f.requests.map((r) => r.id == request.id ? request : r).toList();
        return f.copyWith(requests: reqs);
      }).toList();
      all[idx] = col.copyWith(folders: folders);
    } else {
      final reqs =
          col.requests.map((r) => r.id == request.id ? request : r).toList();
      all[idx] = col.copyWith(requests: reqs);
    }
    await _saveAll(all);
  }

  @override
  Future<void> deleteRequest(
    String collectionId,
    String requestId, {
    String? folderId,
  }) async {
    final all = await getAll();
    final idx = all.indexWhere((c) => c.id == collectionId);
    if (idx < 0) return;
    final col = all[idx];
    if (folderId != null) {
      final folders = col.folders.map((f) {
        if (f.id != folderId) return f;
        return f.copyWith(
          requests: f.requests.where((r) => r.id != requestId).toList(),
        );
      }).toList();
      all[idx] = col.copyWith(folders: folders);
    } else {
      all[idx] = col.copyWith(
        requests: col.requests.where((r) => r.id != requestId).toList(),
      );
    }
    await _saveAll(all);
  }

  @override
  Future<void> addFolder(String collectionId, Folder folder) async {
    final all = await getAll();
    final idx = all.indexWhere((c) => c.id == collectionId);
    if (idx < 0) return;
    final col = all[idx];
    all[idx] = col.copyWith(folders: [...col.folders, folder]);
    await _saveAll(all);
  }

  @override
  Future<void> deleteFolder(String collectionId, String folderId) async {
    final all = await getAll();
    final idx = all.indexWhere((c) => c.id == collectionId);
    if (idx < 0) return;
    final col = all[idx];
    all[idx] = col.copyWith(
      folders: col.folders.where((f) => f.id != folderId).toList(),
    );
    await _saveAll(all);
  }

  @override
  Future<void> reorderFolders(
    String collectionId,
    List<String> orderedIds,
  ) async {
    final all = await getAll();
    final idx = all.indexWhere((c) => c.id == collectionId);
    if (idx < 0) return;
    final col = all[idx];
    final ordered = orderedIds
        .map((id) => col.folders.firstWhere((f) => f.id == id))
        .toList();
    all[idx] = col.copyWith(folders: ordered);
    await _saveAll(all);
  }

  @override
  Future<void> reorderCollections(List<String> orderedIds) async {
    final all = await getAll();
    final ordered =
        orderedIds.map((id) => all.firstWhere((c) => c.id == id)).toList();
    await _saveAll(ordered);
  }

  @override
  Future<void> moveRequest(
    String requestId, {
    required String fromCollectionId,
    String? fromFolderId,
    required String toCollectionId,
    String? toFolderId,
    int? toIndex,
  }) async {
    final all = await getAll();
    final fromIdx = all.indexWhere((c) => c.id == fromCollectionId);
    final toIdx = all.indexWhere((c) => c.id == toCollectionId);
    if (fromIdx < 0 || toIdx < 0) return;

    final fromCol = all[fromIdx];
    ApiRequest? request;

    // Remove from source
    if (fromFolderId != null) {
      final folders = fromCol.folders.map((f) {
        if (f.id != fromFolderId) return f;
        request = f.requests.where((r) => r.id == requestId).firstOrNull;
        return f.copyWith(
          requests: f.requests.where((r) => r.id != requestId).toList(),
        );
      }).toList();
      all[fromIdx] = fromCol.copyWith(folders: folders);
    } else {
      request = fromCol.requests.where((r) => r.id == requestId).firstOrNull;
      all[fromIdx] = fromCol.copyWith(
        requests: fromCol.requests.where((r) => r.id != requestId).toList(),
      );
    }

    if (request == null) return;

    // Add to destination
    final targetCol = all[toIdx];

    if (toFolderId != null) {
      final folders = targetCol.folders.map((f) {
        if (f.id != toFolderId) return f;
        final reqs = f.requests.toList();
        if (toIndex != null && toIndex <= reqs.length) {
          reqs.insert(toIndex, request!);
        } else {
          reqs.add(request!);
        }
        return f.copyWith(requests: reqs);
      }).toList();
      all[toIdx] = targetCol.copyWith(folders: folders);
    } else {
      final reqs = targetCol.requests.toList();
      if (toIndex != null && toIndex <= reqs.length) {
        reqs.insert(toIndex, request!);
      } else {
        reqs.add(request!);
      }
      all[toIdx] = targetCol.copyWith(requests: reqs);
    }

    await _saveAll(all);
  }

  @override
  Future<void> reorderRequests(
    String collectionId,
    String? folderId,
    List<String> orderedIds,
  ) async {
    final all = await getAll();
    final idx = all.indexWhere((c) => c.id == collectionId);
    if (idx < 0) return;
    final col = all[idx];
    if (folderId != null) {
      final folders = col.folders.map((f) {
        if (f.id != folderId) return f;
        final ordered = orderedIds
            .map((id) => f.requests.firstWhere((r) => r.id == id))
            .toList();
        return f.copyWith(requests: ordered);
      }).toList();
      all[idx] = col.copyWith(folders: folders);
    } else {
      final ordered = orderedIds
          .map((id) => col.requests.firstWhere((r) => r.id == id))
          .toList();
      all[idx] = col.copyWith(requests: ordered);
    }
    await _saveAll(all);
  }

  @override
  Future<void> moveFolder(
    String folderId, {
    required String fromCollectionId,
    required String toCollectionId,
    int? toIndex,
  }) async {
    final all = await getAll();
    final fromIdx = all.indexWhere((c) => c.id == fromCollectionId);
    final toIdx = all.indexWhere((c) => c.id == toCollectionId);
    if (fromIdx < 0 || toIdx < 0) return;

    final fromCol = all[fromIdx];
    Folder? folder = fromCol.folders.where((f) => f.id == folderId).firstOrNull;
    if (folder == null) return;

    // Remove from source
    all[fromIdx] = fromCol.copyWith(
      folders: fromCol.folders.where((f) => f.id != folderId).toList(),
    );

    // Add to destination
    final targetCol = all[toIdx];
    final folders = targetCol.folders.toList();
    if (toIndex != null && toIndex <= folders.length) {
      folders.insert(toIndex, folder);
    } else {
      folders.add(folder);
    }
    all[toIdx] = targetCol.copyWith(folders: folders);

    await _saveAll(all);
  }

  @override
  Future<String> exportCollection(String collectionId) async {
    final all = await getAll();
    final col = all.firstWhere((c) => c.id == collectionId);
    return jsonEncode(col.toJson());
  }

  @override
  Future<Collection> importCollection(String jsonString) async {
    final Map<String, dynamic> json =
        jsonDecode(jsonString) as Map<String, dynamic>;
    final col = Collection.fromJson(json);
    await save(col);
    return col;
  }
}
