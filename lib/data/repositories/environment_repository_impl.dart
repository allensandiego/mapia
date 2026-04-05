import 'dart:convert';
import '../../core/services/storage_service.dart';
import '../../domain/entities/environment.dart';
import '../../domain/repositories/environment_repository.dart';

class EnvironmentRepositoryImpl implements EnvironmentRepository {
  static const _storageKey = 'environments';
  final StorageService _storage;

  EnvironmentRepositoryImpl(this._storage);

  @override
  Future<List<Environment>> getAll() async {
    try {
      final jsonStr = await _storage.load(_storageKey);
      if (jsonStr == null) return [];
      final List<dynamic> jsonList = jsonDecode(jsonStr) as List;
      return jsonList
          .map((e) => Environment.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll(List<Environment> envs) async {
    await _storage.save(
      _storageKey,
      jsonEncode(envs.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<void> save(Environment environment) async {
    final all = await getAll();
    final idx = all.indexWhere((e) => e.id == environment.id);
    if (idx >= 0) {
      all[idx] = environment;
    } else {
      all.add(environment);
    }
    await _saveAll(all);
  }

  @override
  Future<void> delete(String environmentId) async {
    final all = await getAll();
    all.removeWhere((e) => e.id == environmentId);
    await _saveAll(all);
  }

  @override
  Future<String> exportEnvironment(String environmentId) async {
    final all = await getAll();
    final env = all.firstWhere((e) => e.id == environmentId);
    return jsonEncode(env.toJson());
  }

  @override
  Future<Environment> importEnvironment(String jsonString) async {
    final Map<String, dynamic> json =
        jsonDecode(jsonString) as Map<String, dynamic>;
    final env = Environment.fromJson(json);
    await save(env);
    return env;
  }
}
