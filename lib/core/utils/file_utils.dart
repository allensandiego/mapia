import 'file_utils_stub.dart'
    if (dart.library.io) 'file_utils_io.dart'
    if (dart.library.js_interop) 'file_utils_web.dart';

abstract class FileUtils {
  static Future<void> downloadFile(String name, String content) =>
      downloadFileImpl(name, content);
}
