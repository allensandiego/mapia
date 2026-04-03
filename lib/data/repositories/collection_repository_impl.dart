import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/collection.dart';
import '../../domain/entities/api_request.dart';
import '../../domain/entities/folder.dart';
import '../../domain/repositories/collection_repository.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  static const _fileName = 'collections.json';

  Future<File> _getFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_fileName');
  }

  @override
  Future<List<Collection>> getAll() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];
      final jsonStr = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonStr) as List;
      return jsonList
          .map((e) => Collection.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll(List<Collection> collections) async {
    final file = await _getFile();
    await file.writeAsString(
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
        final reqs = f.requests
            .map((r) => r.id == request.id ? request : r)
            .toList();
        return f.copyWith(requests: reqs);
      }).toList();
      all[idx] = col.copyWith(folders: folders);
    } else {
      final reqs = col.requests
          .map((r) => r.id == request.id ? request : r)
          .toList();
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
}
