import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';

class PrefsStorageService implements StorageService {
  @override
  Future<void> save(String key, String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mapia_$key', data);
  }

  @override
  Future<String?> load(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('mapia_$key');
  }

  @override
  Future<void> delete(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('mapia_$key');
  }
}

StorageService getStorageService() => PrefsStorageService();
