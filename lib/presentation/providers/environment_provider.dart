import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/environment.dart';
import 'repository_providers.dart';

class EnvironmentNotifier extends AsyncNotifier<List<Environment>> {
  @override
  Future<List<Environment>> build() async {
    return ref.read(environmentRepositoryProvider).getAll();
  }

  Future<void> save(Environment env) async {
    await ref.read(environmentRepositoryProvider).save(env);
    final current = state.value ?? [];
    final idx = current.indexWhere((e) => e.id == env.id);
    if (idx >= 0) {
      final updated = [...current];
      updated[idx] = env;
      state = AsyncValue.data(updated);
    } else {
      state = AsyncValue.data([...current, env]);
    }
  }

  Future<void> delete(String id) async {
    await ref.read(environmentRepositoryProvider).delete(id);
    state = AsyncValue.data(
      (state.value ?? []).where((e) => e.id != id).toList(),
    );
    // Clear active if deleted
    if (ref.read(activeEnvironmentProvider) == id) {
      ref.read(activeEnvironmentProvider.notifier).state = null;
    }
  }

  Future<String> exportEnvironment(String id) async {
    return ref.read(environmentRepositoryProvider).exportEnvironment(id);
  }

  Future<Environment> importEnvironment(String json) async {
    final env = await ref.read(environmentRepositoryProvider).importEnvironment(json);
    state = AsyncValue.data([...state.value ?? [], env]);
    return env;
  }
}

final environmentsProvider =
    AsyncNotifierProvider<EnvironmentNotifier, List<Environment>>(
  EnvironmentNotifier.new,
);

/// The currently selected environment id (null = no env)
final activeEnvironmentProvider = StateProvider<String?>((ref) => null);

/// Resolved variables map for the active environment
final activeEnvVariablesProvider = Provider<Map<String, String>>((ref) {
  final envId = ref.watch(activeEnvironmentProvider);
  if (envId == null) return {};
  final envs = ref.watch(environmentsProvider).value ?? [];
  final env = envs.where((e) => e.id == envId).firstOrNull;
  if (env == null) return {};
  return {
    for (final v in env.variables.where((v) => v.enabled)) v.key: v.value,
  };
});
