import 'dart:io';
import 'package:file_picker/file_picker.dart';

Future<void> downloadFileImpl(String name, String content) async {
  final result = await FilePicker.platform.saveFile(
    dialogTitle: 'Export',
    fileName: name,
    type: FileType.custom,
    allowedExtensions: ['json'],
  );

  if (result != null) {
    final file = File(result);
    await file.writeAsString(content);
  }
}
