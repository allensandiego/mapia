import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/entities/api_response.dart';

class ResponseLogger {
  ResponseLogger._();

  static Future<void> logResponse(ApiResponse response) async {
    // Only log to a physical file on Desktop platforms for easy viewing in the workspace
    if (kIsWeb) return;

    try {
      final Map<String, dynamic> logData = {
        'timestamp': DateTime.now().toIso8601String(),
        'status': response.statusCode,
        'message': response.statusMessage,
        'contentType': response.contentType,
        'headers': response.headers,
        'body': _tryParseBody(response.body),
      };

      final file = File('latest_response.json');
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(logData),
      );
    } catch (e) {
      debugPrint('Failed to log response: $e');
    }
  }

  static dynamic _tryParseBody(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }
}
