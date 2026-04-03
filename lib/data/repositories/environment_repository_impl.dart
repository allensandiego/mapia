import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/environment.dart';
import '../../domain/repositories/environment_repository.dart';

class EnvironmentRepositoryImpl implements EnvironmentRepository {
  static const _fileName = 'environments.json';

  Future<File> _getFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_fileName');
  }

  @override
  Future<List<Environment>> getAll() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];
      final jsonStr = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonStr) as List;
      return jsonList
          .map((e) => Environment.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll(List<Environment> envs) async {
    final file = await _getFile();
    await file.writeAsString(
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
}
