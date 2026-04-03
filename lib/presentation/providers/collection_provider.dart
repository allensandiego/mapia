import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/collection.dart';
import '../../domain/entities/api_request.dart';
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
}

final collectionsProvider =
    AsyncNotifierProvider<CollectionNotifier, List<Collection>>(
  CollectionNotifier.new,
);
