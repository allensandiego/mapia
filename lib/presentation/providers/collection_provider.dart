import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../domain/entities/collection.dart';
import '../../domain/entities/api_request.dart';
import '../../core/utils/postman_mapper.dart';
import 'repository_providers.dart';

class CollectionNotifier extends AsyncNotifier<List<Collection>> {
  @override
  Future<List<Collection>> build() async {
    final repo = ref.read(collectionRepositoryProvider);
    return repo.getAll();
  }

  Future<void> addCollection(Collection collection) async {
    final repo = ref.read(collectionRepositoryProvider);
    await repo.save(collection);
    state = AsyncValue.data([...state.value ?? [], collection]);
  }

  Future<void> updateCollection(Collection collection) async {
    final repo = ref.read(collectionRepositoryProvider);
    await repo.save(collection);
    state = AsyncValue.data(
      (state.value ?? [])
          .map((c) => c.id == collection.id ? collection : c)
          .toList(),
    );
  }

  Future<void> deleteCollection(String id) async {
    final repo = ref.read(collectionRepositoryProvider);
    await repo.delete(id);
    state = AsyncValue.data(
      (state.value ?? []).where((c) => c.id != id).toList(),
    );
  }

  Future<void> saveRequest(
      String collectionId, String? folderId, ApiRequest request) async {
    final cols = state.value ?? [];
    final col = cols.where((c) => c.id == collectionId).firstOrNull;
    if (col == null) return;

    Collection newCol;
    if (folderId != null) {
      final folders = col.folders.map((f) {
        if (f.id != folderId) return f;
        final reqs = f.requests.toList();
        final i = reqs.indexWhere((r) => r.id == request.id);
        if (i >= 0) {
          reqs[i] = request;
        } else {
          reqs.add(request);
        }
        return f.copyWith(requests: reqs);
      }).toList();
      newCol = col.copyWith(folders: folders);
    } else {
      final reqs = col.requests.toList();
      final i = reqs.indexWhere((r) => r.id == request.id);
      if (i >= 0) {
        reqs[i] = request;
      } else {
        reqs.add(request);
      }
      newCol = col.copyWith(requests: reqs);
    }

    await updateCollection(newCol);
  }

  Future<void> deleteRequest(
      String collectionId, String? folderId, String requestId) async {
    final cols = state.value ?? [];
    final col = cols.where((c) => c.id == collectionId).firstOrNull;
    if (col == null) return;

    Collection newCol;
    if (folderId != null) {
      final folders = col.folders.map((f) {
        if (f.id != folderId) return f;
        final reqs = f.requests.where((r) => r.id != requestId).toList();
        return f.copyWith(requests: reqs);
      }).toList();
      newCol = col.copyWith(folders: folders);
    } else {
      final reqs = col.requests.where((r) => r.id != requestId).toList();
      newCol = col.copyWith(requests: reqs);
    }

    await updateCollection(newCol);
  }

  Future<void> renameCollection(String id, String newName) async {
    final col = (state.value ?? []).where((c) => c.id == id).firstOrNull;
    if (col == null) return;
    await updateCollection(col.copyWith(name: newName));
  }

  Future<void> renameRequest(String collectionId, String? folderId,
      String requestId, String newName) async {
    final cols = state.value ?? [];
    final col = cols.where((c) => c.id == collectionId).firstOrNull;
    if (col == null) return;

    Collection newCol;
    if (folderId != null) {
      final folders = col.folders.map((f) {
        if (f.id != folderId) return f;
        final reqs = f.requests
            .map((r) => r.id == requestId ? r.copyWith(name: newName) : r)
            .toList();
        return f.copyWith(requests: reqs);
      }).toList();
      newCol = col.copyWith(folders: folders);
    } else {
      final reqs = col.requests
          .map((r) => r.id == requestId ? r.copyWith(name: newName) : r)
          .toList();
      newCol = col.copyWith(requests: reqs);
    }

    await updateCollection(newCol);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(
      await ref.read(collectionRepositoryProvider).getAll(),
    );
  }

  Future<String> exportCollection(String id) async {
    return ref.read(collectionRepositoryProvider).exportCollection(id);
  }

  Future<void> importCollection(String jsonStr) async {
    final Map<String, dynamic> json = jsonDecode(jsonStr) as Map<String, dynamic>;
    Collection col;
    if (json.containsKey('info')) {
      // Treat as postman
      col = PostmanMapper.mapPostman(json);
      await ref.read(collectionRepositoryProvider).save(col);
    } else {
      col =
          await ref.read(collectionRepositoryProvider).importCollection(jsonStr);
    }
    state = AsyncValue.data([...state.value ?? [], col]);
  }

  Future<void> reorderCollections(int oldIndex, int newIndex) async {
    final cols = (state.value ?? []).toList();
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = cols.removeAt(oldIndex);
    cols.insert(newIndex, item);
    state = AsyncValue.data(cols);
    await ref
        .read(collectionRepositoryProvider)
        .reorderCollections(cols.map((c) => c.id).toList());
  }

  Future<void> reorderFolders(
      String collectionId, int oldIndex, int newIndex) async {
    final cols = state.value ?? [];
    final col = cols.where((c) => c.id == collectionId).firstOrNull;
    if (col == null) return;

    final folders = col.folders.toList();
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = folders.removeAt(oldIndex);
    folders.insert(newIndex, item);

    final newCol = col.copyWith(folders: folders);
    state = AsyncValue.data(
      cols.map((c) => c.id == collectionId ? newCol : c).toList(),
    );
    await ref
        .read(collectionRepositoryProvider)
        .reorderFolders(collectionId, folders.map((f) => f.id).toList());
  }

  Future<void> reorderRequests(String collectionId, String? folderId,
      int oldIndex, int newIndex) async {
    final cols = state.value ?? [];
    final col = cols.where((c) => c.id == collectionId).firstOrNull;
    if (col == null) return;

    List<ApiRequest> reqs;
    if (folderId != null) {
      final folder = col.folders.where((f) => f.id == folderId).firstOrNull;
      if (folder == null) return;
      reqs = folder.requests.toList();
    } else {
      reqs = col.requests.toList();
    }

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = reqs.removeAt(oldIndex);
    reqs.insert(newIndex, item);

    Collection newCol;
    if (folderId != null) {
      newCol = col.copyWith(
        folders: col.folders
            .map((f) => f.id == folderId ? f.copyWith(requests: reqs) : f)
            .toList(),
      );
    } else {
      newCol = col.copyWith(requests: reqs);
    }

    state = AsyncValue.data(
      cols.map((c) => c.id == collectionId ? newCol : c).toList(),
    );
    await ref
        .read(collectionRepositoryProvider)
        .reorderRequests(collectionId, folderId, reqs.map((r) => r.id).toList());
  }

  Future<void> moveRequest(
    String requestId, {
    required String fromCollectionId,
    String? fromFolderId,
    required String toCollectionId,
    String? toFolderId,
    int? toIndex,
  }) async {
    await ref.read(collectionRepositoryProvider).moveRequest(
          requestId,
          fromCollectionId: fromCollectionId,
          fromFolderId: fromFolderId,
          toCollectionId: toCollectionId,
          toFolderId: toFolderId,
          toIndex: toIndex,
        );
    await refresh();
  }

  Future<void> moveFolder(
    String folderId, {
    required String fromCollectionId,
    required String toCollectionId,
    int? toIndex,
  }) async {
    await ref.read(collectionRepositoryProvider).moveFolder(
          folderId,
          fromCollectionId: fromCollectionId,
          toCollectionId: toCollectionId,
          toIndex: toIndex,
        );
    await refresh();
  }
}

final collectionsProvider =
    AsyncNotifierProvider<CollectionNotifier, List<Collection>>(
  CollectionNotifier.new,
);
