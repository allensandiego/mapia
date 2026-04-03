import 'dart:convert';
import '../../domain/entities/api_request.dart';
import '../../core/constants/http_constants.dart';

class SnippetGenerator {
  SnippetGenerator._();

  /// Generate a curl command snippet
  static String generateCurl(ApiRequest r) {
    final lines = <String>[];
    lines.add('curl -X ${r.method.name}');

    // Add query params to URL
    String url = r.url;
    if (r.queryParams.isNotEmpty) {
      final enabledParams = r.queryParams
          .where((p) => p.enabled)
          .map((p) => '${p.key}=${Uri.encodeQueryComponent(p.value)}')
          .toList();
      if (enabledParams.isNotEmpty) {
        url += '?${enabledParams.join('&')}';
      }
    }
    lines.add('  \'$url\'');

    // Add headers
    final enabledHeaders = r.headers.where((h) => h.enabled).toList();
    for (final header in enabledHeaders) {
      lines.add('  -H \'${header.key}: ${header.value}\'');
    }

    // Add auth header
    if (r.auth.type != AuthType.none) {
      final authHeader = _buildAuthHeader(r.auth);
      lines.add('  -H \'Authorization: $authHeader\'');
    }

    // Add body if present
    if (r.body.isNotEmpty &&
        r.method != HttpMethod.get &&
        r.method != HttpMethod.head) {
      final bodyStr = r.body.replaceAll("'", "'\\''");
      lines.add('  --data-raw \'$bodyStr\'');
    }

    // Join with backslash continuation
    return lines.join(' \\\n');
  }

  /// Generate a Python requests snippet
  static String generatePython(ApiRequest r) {
    final lines = <String>[];
    lines.add('import requests');
    lines.add('');

    // Headers dict
    lines.add('headers = {');
    final enabledHeaders = r.headers.where((h) => h.enabled).toList();
    for (final header in enabledHeaders) {
      lines.add('    \'${header.key}\': \'${header.value}\',');
    }
    lines.add('}');
    lines.add('');

    // Auth handling
    String authStr = 'None';
    if (r.auth.type == AuthType.bearer) {
      lines.add('headers[\'Authorization\'] = \'Bearer ${r.auth.token}\'');
    } else if (r.auth.type == AuthType.basic) {
      lines.add('auth = (\'${r.auth.username}\', \'${r.auth.password}\')');
      authStr = 'auth';
    } else if (r.auth.type == AuthType.apiKey) {
      lines.add(
          'headers[\'${r.auth.apiKeyHeader}\'] = \'${r.auth.apiKeyValue}\'');
    }
    lines.add('');

    // Params dict
    final enabledParams = r.queryParams.where((p) => p.enabled).toList();
    if (enabledParams.isNotEmpty) {
      lines.add('params = {');
      for (final param in enabledParams) {
        lines.add('    \'${param.key}\': \'${param.value}\',');
      }
      lines.add('}');
    } else {
      lines.add('params = {}');
    }
    lines.add('');

    // Body
    String dataArg = '';
    if (r.body.isNotEmpty &&
        r.method != HttpMethod.get &&
        r.method != HttpMethod.head) {
      if (r.bodyType == BodyType.json) {
        dataArg = ', json=${_escapeJsonBody(r.body)}';
      } else {
        final bodyStr = r.body.replaceAll("'", "\\'");
        dataArg = ', data=\'$bodyStr\'';
      }
    }

    // Request
    final authArg = authStr == 'None' ? '' : ', auth=$authStr';
    lines.add(
        'response = requests.${r.method.name.toLowerCase()}(\'${r.url}\'${r.queryParams.isNotEmpty ? ', params=params' : ''}$dataArg, headers=headers$authArg)');
    lines.add('bdebugPrint(response.status_code)');
    lines.add('bdebugPrint(response.text)');

    return lines.join('\n');
  }

  /// Generate a modern JavaScript fetch snippet
  static String generateFetch(ApiRequest r) {
    final lines = <String>[];

    // Build headers object
    lines.add('const headers = {');
    final enabledHeaders = r.headers.where((h) => h.enabled).toList();
    for (final header in enabledHeaders) {
      lines.add('  \'${header.key}\': \'${header.value}\',');
    }

    // Add auth header
    if (r.auth.type == AuthType.bearer) {
      lines.add('  \'Authorization\': \'Bearer ${r.auth.token}\',');
    } else if (r.auth.type == AuthType.basic) {
      final auth =
          base64Encode(utf8.encode('${r.auth.username}:${r.auth.password}'));
      lines.add('  \'Authorization\': \'Basic $auth\',');
    } else if (r.auth.type == AuthType.apiKey) {
      lines.add('  \'${r.auth.apiKeyHeader}\': \'${r.auth.apiKeyValue}\',');
    }

    lines.add('};');
    lines.add('');

    // Build URL with query params
    String url = r.url;
    if (r.queryParams.isNotEmpty) {
      final enabledParams = r.queryParams
          .where((p) => p.enabled)
          .map((p) => '${p.key}=${Uri.encodeQueryComponent(p.value)}')
          .toList();
      if (enabledParams.isNotEmpty) {
        url += '?${enabledParams.join('&')}';
      }
    }

    // Build fetch options
    lines.add('const options = {');
    lines.add('  method: \'${r.method.name}\',');
    lines.add('  headers,');

    // Add body if present
    if (r.body.isNotEmpty &&
        r.method != HttpMethod.get &&
        r.method != HttpMethod.head) {
      final bodyStr = r.body.replaceAll("'", "\\'").replaceAll('\n', '\\n');
      lines.add('  body: \'$bodyStr\',');
    }

    lines.add('};');
    lines.add('');

    lines.add('fetch(\'$url\', options)');
    lines.add('  .then(response => response.text())');
    lines.add('  .then(data => console.log(data))');
    lines.add('  .catch(error => console.error(\'Error:\', error));');

    return lines.join('\n');
  }

  /// Generate an axios snippet
  static String generateAxios(ApiRequest r) {
    final lines = <String>[];
    lines.add('const axios = require(\'axios\');');
    lines.add('');

    // Build URL with query params
    String url = r.url;
    if (r.queryParams.isNotEmpty) {
      final enabledParams = r.queryParams
          .where((p) => p.enabled)
          .map((p) => '${p.key}=${Uri.encodeQueryComponent(p.value)}')
          .toList();
      if (enabledParams.isNotEmpty) {
        url += '?${enabledParams.join('&')}';
      }
    }

    // Build config object
    lines.add('const config = {');
    lines.add('  method: \'${r.method.name.toLowerCase()}\',');
    lines.add('  url: \'$url\',');

    // Headers
    lines.add('  headers: {');
    final enabledHeaders = r.headers.where((h) => h.enabled).toList();
    for (final header in enabledHeaders) {
      lines.add('    \'${header.key}\': \'${header.value}\',');
    }

    // Auth
    if (r.auth.type == AuthType.bearer) {
      lines.add('    \'Authorization\': \'Bearer ${r.auth.token}\',');
    } else if (r.auth.type == AuthType.basic) {
      lines.add(
          '    \'Authorization\': \'Basic ${base64Encode(utf8.encode('${r.auth.username}:${r.auth.password}'))}\',');
    } else if (r.auth.type == AuthType.apiKey) {
      lines.add('    \'${r.auth.apiKeyHeader}\': \'${r.auth.apiKeyValue}\',');
    }

    lines.add('  },');

    // Body/Data
    if (r.body.isNotEmpty &&
        r.method != HttpMethod.get &&
        r.method != HttpMethod.head) {
      if (r.bodyType == BodyType.json) {
        lines.add('  data: ${r.body},');
      } else {
        final bodyStr = r.body.replaceAll("'", "\\'");
        lines.add('  data: \'$bodyStr\',');
      }
    }

    lines.add('};');
    lines.add('');

    lines.add('axios(config)');
    lines.add('  .then(response => console.log(response.data))');
    lines.add('  .catch(error => console.error(error));');

    return lines.join('\n');
  }

  /// Generate a Dart dio snippet
  static String generateDart(ApiRequest r) {
    final lines = <String>[];
    lines.add('import \'package:dio/dio.dart\';');
    lines.add('');

    lines.add('Future<void> makeRequest() async {');
    lines.add('  final dio = Dio();');
    lines.add('');

    // Build URL with query params
    String url = r.url;
    if (r.queryParams.isNotEmpty) {
      final enabledParams = r.queryParams
          .where((p) => p.enabled)
          .map((p) => '${p.key}=${Uri.encodeQueryComponent(p.value)}')
          .toList();
      if (enabledParams.isNotEmpty) {
        url += '?${enabledParams.join('&')}';
      }
    }

    // Headers
    lines.add('  final headers = <String, dynamic>{');
    final enabledHeaders = r.headers.where((h) => h.enabled).toList();
    for (final header in enabledHeaders) {
      lines.add('    \'${header.key}\': \'${header.value}\',');
    }

    // Auth
    if (r.auth.type == AuthType.bearer) {
      lines.add('    \'Authorization\': \'Bearer ${r.auth.token}\',');
    } else if (r.auth.type == AuthType.basic) {
      lines.add(
          '    \'Authorization\': \'Basic ${base64Encode(utf8.encode('${r.auth.username}:${r.auth.password}'))}\',');
    } else if (r.auth.type == AuthType.apiKey) {
      lines.add('    \'${r.auth.apiKeyHeader}\': \'${r.auth.apiKeyValue}\',');
    }

    lines.add('  };');
    lines.add('');

    // Body
    String dataArg = '';
    if (r.body.isNotEmpty &&
        r.method != HttpMethod.get &&
        r.method != HttpMethod.head) {
      if (r.bodyType == BodyType.json) {
        dataArg = ', data: ${r.body}';
      } else {
        dataArg = ', data: \'${r.body.replaceAll("'", "\\'")}\',';
      }
    }

    // Make request
    lines.add('  try {');
    lines.add(
        '    final response = await dio.${r.method.name.toLowerCase()}(\'$url\'$dataArg, options: Options(headers: headers));');
    lines.add('    bdebugPrint(response.statusCode);');
    lines.add('    bdebugPrint(response.data);');
    lines.add('  } catch (e) {');
    lines.add('    bdebugPrint(\'Error: \$e\');');
    lines.add('  }');
    lines.add('}');

    return lines.join('\n');
  }

  // Helper functions
  static String _buildAuthHeader(AuthConfig auth) {
    switch (auth.type) {
      case AuthType.bearer:
        return 'Bearer ${auth.token}';
      case AuthType.basic:
        final credentials =
            base64Encode(utf8.encode('${auth.username}:${auth.password}'));
        return 'Basic $credentials';
      case AuthType.apiKey:
        return auth.apiKeyValue;
      case AuthType.oauth2:
        return 'Bearer ${auth.oauth2Config.accessToken}';
      case AuthType.none:
        return '';
    }
  }

  static String _escapeJsonBody(String body) {
    try {
      final decoded = jsonDecode(body);
      return jsonEncode(decoded);
    } catch (e) {
      return 'None';
    }
  }
}
