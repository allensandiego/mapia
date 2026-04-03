import '../../domain/entities/history_entry.dart';

abstract class HistoryRepository {
  Future<List<HistoryEntry>> getAll();
  Future<void> add(HistoryEntry entry);
  Future<void> clear();
  Future<void> delete(String id);
}
