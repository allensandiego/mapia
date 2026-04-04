import '../../domain/entities/environment.dart';

abstract class EnvironmentRepository {
  Future<List<Environment>> getAll();
  Future<void> save(Environment environment);
  Future<void> delete(String environmentId);
  Future<String> exportEnvironment(String environmentId);
  Future<Environment> importEnvironment(String jsonString);
}
