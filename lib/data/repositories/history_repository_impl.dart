import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  static const _fileName = 'history.json';
  static const _maxEntries = 200;

  Future<File> _getFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_fileName');
  }

  @override
  Future<List<HistoryEntry>> getAll() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];
      final jsonStr = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonStr) as List;
      return jsonList
          .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList()
          .reversed
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll(List<HistoryEntry> entries) async {
    final file = await _getFile();
    await file.writeAsString(
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<void> add(HistoryEntry entry) async {
    final all = await getAll();
    all.insert(0, entry);
    final trimmed = all.take(_maxEntries).toList();
    await _saveAll(trimmed);
  }

  @override
  Future<void> clear() async {
    await _saveAll([]);
  }

  @override
  Future<void> delete(String id) async {
    final all = await getAll();
    all.removeWhere((e) => e.id == id);
    await _saveAll(all);
  }
}
