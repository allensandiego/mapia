import '../../domain/entities/environment.dart';

abstract class EnvironmentRepository {
  Future<List<Environment>> getAll();
  Future<void> save(Environment environment);
  Future<void> delete(String environmentId);
}
