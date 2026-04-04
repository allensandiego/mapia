import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'storage_service.dart';

class FileStorageService implements StorageService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _getLocalFile(String key) async {
    final path = await _localPath;
    return File('$path/mapia_$key.json');
  }

  @override
  Future<void> save(String key, String data) async {
    final file = await _getLocalFile(key);
    await file.writeAsString(data);
  }

  @override
  Future<String?> load(String key) async {
    try {
      final file = await _getLocalFile(key);
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> delete(String key) async {
    final file = await _getLocalFile(key);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

StorageService getStorageService() => FileStorageService();
