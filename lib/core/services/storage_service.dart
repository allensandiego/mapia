import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_service_stub.dart'
    if (dart.library.io) 'storage_service_io.dart'
    if (dart.library.js_interop) 'storage_service_web.dart';

abstract class StorageService {
  Future<void> save(String key, String data);
  Future<String?> load(String key);
  Future<void> delete(String key);
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return getStorageService();
});
