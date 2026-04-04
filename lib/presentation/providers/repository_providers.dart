import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/collection_repository_impl.dart';
import '../../data/repositories/environment_repository_impl.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../domain/repositories/collection_repository.dart';
import '../../domain/repositories/environment_repository.dart';
import '../../domain/repositories/history_repository.dart';

import '../../core/services/storage_service.dart';

// Repository providers
final collectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return CollectionRepositoryImpl(storage);
});

final environmentRepositoryProvider = Provider<EnvironmentRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return EnvironmentRepositoryImpl(storage);
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return HistoryRepositoryImpl(storage);
});
