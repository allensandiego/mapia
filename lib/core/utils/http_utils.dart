import 'dart:convert';
import 'package:xml/xml.dart';
import '../constants/http_constants.dart';
import '../../domain/entities/api_request.dart';

class HttpUtils {
  HttpUtils._();

  static String statusLabel(int statusCode) {
    switch (statusCode) {
      case 200:
        return '200 OK';
      case 201:
        return '201 Created';
      case 204:
        return '204 No Content';
      case 301:
        return '301 Moved Permanently';
      case 302:
        return '302 Found';
      case 304:
        return '304 Not Modified';
      case 400:
        return '400 Bad Request';
      case 401:
        return '401 Unauthorized';
      case 403:
        return '403 Forbidden';
      case 404:
        return '404 Not Found';
      case 405:
        return '405 Method Not Allowed';
      case 422:
        return '422 Unprocessable Entity';
      case 429:
        return '429 Too Many Requests';
      case 500:
        return '500 Internal Server Error';
      case 502:
        return '502 Bad Gateway';
      case 503:
        return '503 Service Unavailable';
      default:
        return '$statusCode';
    }
  }

  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String formatDuration(int ms) {
    if (ms < 1000) return '$ms ms';
    return '${(ms / 1000).toStringAsFixed(2)} s';
  }

  static bool isJson(String? contentType) =>
      contentType?.toLowerCase().contains('application/json') ?? false;

  static bool isXml(String? contentType) =>
      contentType?.toLowerCase().contains('/xml') ??
      contentType?.toLowerCase().contains('+xml') ??
      false;

  static bool isHtml(String? contentType) =>
      contentType?.toLowerCase().contains('text/html') ?? false;

  static String prettyJson(String raw) {
    if (raw.trim().isEmpty) return raw;
    try {
      final decoded = jsonDecode(raw);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      // Fallback to raw text if it's invalid JSON
      return raw;
    }
  }

  static String prettyXml(String raw) {
    if (raw.trim().isEmpty) return raw;
    try {
      final document = XmlDocument.parse(raw);
      return document.toXmlString(pretty: true, indent: '  ');
    } catch (_) {
      // If parsing fails for any reason (e.g. malformed HTML that is technically not valid XML),
      // fallback to a basic string-manipulation formatter so we don't return a giant 1-line string.
      return prettyHtml(raw);
    }
  }

  static String prettyHtml(String raw) {
    if (raw.trim().isEmpty) return raw;
    try {
      // Very basic formatting for raw HTML/XML to make it readable without strict parsing.
      // Breaks tags onto new lines and adds naive indentation.
      String formatted = raw.replaceAllMapped(RegExp(r'>\s*<'), (m) => '>\n<');

      final buffer = StringBuffer();
      int indent = 0;

      for (final line in formatted.split('\n')) {
        final trimLine = line.trim();
        if (trimLine.isEmpty) continue;

        if (trimLine.startsWith('</')) {
          indent = (indent - 1).clamp(0, 999);
          buffer.write('  ' * indent);
          buffer.writeln(trimLine);
        } else if (trimLine.startsWith('<') &&
            !trimLine.startsWith('<?') &&
            !trimLine.startsWith('<!') &&
            !trimLine.contains('</') &&
            !trimLine.endsWith('/>')) {
          // Heuristic: Is it a common self-closing HTML tag?
          bool isSelfClosingHtml = RegExp(
                  r'^<(meta|link|br|hr|img|input|base)[ >]',
                  caseSensitive: false)
              .hasMatch(trimLine);

          buffer.write('  ' * indent);
          buffer.writeln(trimLine);

          if (!isSelfClosingHtml) {
            indent++;
          }
        } else {
          buffer.write('  ' * indent);
          buffer.writeln(trimLine);
        }
      }
      return buffer.toString().trim();
    } catch (_) {
      return raw;
    }
  }

  /// Compute headers that HttpService would auto-inject for the given request.
  /// Returns a list of MapEntry<String, String> representing auto-generated headers.
  /// Sensitive data (tokens, credentials, API keys) are masked.
  static List<MapEntry<String, String>> computeAutoHeaders(ApiRequest request) {
    final headers = <MapEntry<String, String>>[];

    // Standard request headers
    headers.add(const MapEntry('User-Agent', 'Mapia/1.0.0'));
    headers.add(const MapEntry('Accept', '*/*'));
    headers.add(const MapEntry('Accept-Encoding', 'gzip, deflate, br'));
    headers.add(const MapEntry('Connection', 'keep-alive'));

    // Extract Host from URL
    try {
      final uri = Uri.tryParse(request.url) ?? Uri.parse(request.url);
      if (uri.host.isNotEmpty) {
        headers.add(MapEntry('Host', uri.host));
      }
    } catch (_) {
      // If URL parsing fails, skip Host header
    }

    // Body-type Content-Type headers
    switch (request.bodyType) {
      case BodyType.json:
        headers.add(const MapEntry('Content-Type', 'application/json'));
        break;
      case BodyType.urlEncoded:
        headers.add(const MapEntry(
            'Content-Type', 'application/x-www-form-urlencoded'));
        break;
      case BodyType.formData:
        headers.add(const MapEntry(
            'Content-Type', 'multipart/form-data; boundary=...'));
        break;
      default:
        break;
    }

    // Auth headers
    final auth = request.auth;
    switch (auth.type) {
      case AuthType.bearer:
        if (auth.token.isNotEmpty) {
          headers.add(const MapEntry('Authorization', 'Bearer ••••••'));
        }
        break;
      case AuthType.basic:
        if (auth.username.isNotEmpty) {
          headers.add(const MapEntry('Authorization', 'Basic ••••••'));
        }
        break;
      case AuthType.apiKey:
        if (auth.apiKeyHeader.isNotEmpty && auth.apiKeyValue.isNotEmpty) {
          headers.add(MapEntry(auth.apiKeyHeader, '••••••'));
        }
        break;
      case AuthType.oauth2:
        if (auth.oauth2Config.accessToken.isNotEmpty) {
          headers.add(const MapEntry('Authorization', 'Bearer ••••••'));
        }
        break;
      case AuthType.none:
        break;
    }

    return headers;
  }
}
