import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/history_entry.dart';
import 'repository_providers.dart';

class HistoryNotifier extends AsyncNotifier<List<HistoryEntry>> {
  @override
  Future<List<HistoryEntry>> build() async {
    return ref.read(historyRepositoryProvider).getAll();
  }

  Future<void> add(HistoryEntry entry) async {
    await ref.read(historyRepositoryProvider).add(entry);
    state = AsyncValue.data([entry, ...(state.value ?? [])]);
  }

  Future<void> delete(String id) async {
    await ref.read(historyRepositoryProvider).delete(id);
    state = AsyncValue.data(
      (state.value ?? []).where((e) => e.id != id).toList(),
    );
  }

  Future<void> clear() async {
    await ref.read(historyRepositoryProvider).clear();
    state = const AsyncValue.data([]);
  }
}

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, List<HistoryEntry>>(
  HistoryNotifier.new,
);
