import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/collection_repository_impl.dart';
import '../../data/repositories/environment_repository_impl.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../domain/repositories/collection_repository.dart';
import '../../domain/repositories/environment_repository.dart';
import '../../domain/repositories/history_repository.dart';

// Repository providers
final collectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  return CollectionRepositoryImpl();
});

final environmentRepositoryProvider = Provider<EnvironmentRepository>((ref) {
  return EnvironmentRepositoryImpl();
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepositoryImpl();
});
