import 'package:flutter_test/flutter_test.dart';
import 'package:mapia/data/services/http_service.dart';
import 'package:mapia/domain/entities/api_request.dart';
import 'package:mapia/core/constants/http_constants.dart';
import 'dart:io';

void main() {
  group('HttpService Decoding & Logging Tests', () {
    final httpService = HttpService();

    test('should correctly decode UTF-8 response and create log file',
        () async {
      const request = ApiRequest(
        id: 'test-id',
        name: 'Test Request',
        method: HttpMethod.get,
        url: 'https://postman-echo.com/get?foo=bar',
      );

      final response = await httpService.send(request);

      expect(response.statusCode, 200);
      expect(response.body, contains('"foo":"bar"'));

      // Check if log file exists
      final logFile = File('latest_response.json');
      expect(logFile.existsSync(), isTrue);

      final logContent = logFile.readAsStringSync();
      expect(logContent, contains('"status": 200'));
      expect(
          logContent,
          contains(
              '"foo": "bar"')); // Logged with indent so space might be back
    });

    test('should correctly decode JSON from jsonplaceholder', () async {
      const request = ApiRequest(
        id: 'test-jsonplaceholder',
        name: 'JsonPlaceholder Test',
        method: HttpMethod.get,
        url: 'https://jsonplaceholder.typicode.com/todos/1',
      );

      final response = await httpService.send(request);

      expect(response.statusCode, 200);
      expect(response.body, contains('"title": "delectus aut autem"'));

      final logFile = File('latest_response.json');
      final logContent = logFile.readAsStringSync();
      expect(logContent, contains('"userId": 1'));
    });

    test('should handle 404 error and still decode error body', () async {
      const request = ApiRequest(
        id: 'test-id-404',
        name: 'Test 404',
        method: HttpMethod.get,
        url: 'https://postman-echo.com/status/404',
      );

      final response = await httpService.send(request);

      expect(response.statusCode, 404);
      // Even on error, it should not be "corrupted" (it might be empty or have text)
      expect(response.body, isNotNull);
    });
  });
}
