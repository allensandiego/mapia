import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants/http_constants.dart';
import '../../core/utils/variable_parser.dart';
import '../../domain/entities/api_request.dart';
import '../../domain/entities/api_response.dart';
import '../../domain/entities/variable.dart';
import '../../core/utils/logger.dart';

class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal();

  Dio _buildDio({bool verifySsl = true, int timeoutMs = 30000}) {
    final options = BaseOptions(
      connectTimeout: Duration(milliseconds: timeoutMs),
      receiveTimeout: Duration(milliseconds: timeoutMs),
      sendTimeout: Duration(milliseconds: timeoutMs),
      validateStatus: (_) => true, // don't throw on 4xx/5xx
      followRedirects: true,
      maxRedirects: 5,
    );
    return Dio(options);
  }

  String _resolveVars(
    String input,
    List<Variable> envVars,
    List<Variable> collectionVars,
    List<Variable> requestVars,
  ) {
    final map = <String, String>{};
    // Lowest priority: Environment
    for (final v in envVars.where((v) => v.enabled)) {
      map[v.key] = v.value;
    }
    // Middle priority: Collection (overrides Environment)
    for (final v in collectionVars.where((v) => v.enabled)) {
      map[v.key] = v.value;
    }
    // Highest priority: Request (overrides both)
    for (final v in requestVars.where((v) => v.enabled)) {
      map[v.key] = v.value;
    }
    return VariableParser.resolve(input, map);
  }

  Map<String, String> _resolveHeaders(
    List<Variable> headers,
    List<Variable> envVars,
    List<Variable> collectionVars,
    List<Variable> requestVars,
  ) {
    final map = <String, String>{};
    for (final h in headers.where((h) => h.enabled)) {
      map[_resolveVars(h.key, envVars, collectionVars, requestVars)] =
          _resolveVars(h.value, envVars, collectionVars, requestVars);
    }
    return map;
  }

  String _buildUrl(
    String url,
    List<Variable> queryParams,
    List<Variable> envVars,
    List<Variable> collectionVars,
    List<Variable> requestVars,
  ) {
    final resolvedUrl = _resolveVars(url, envVars, collectionVars, requestVars);
    final activeParams =
        queryParams.where((p) => p.enabled && p.key.isNotEmpty);
    if (activeParams.isEmpty) return resolvedUrl;

    final uri = Uri.tryParse(resolvedUrl) ?? Uri.parse(resolvedUrl);
    final existingParams = Map<String, dynamic>.from(uri.queryParameters);
    for (final p in activeParams) {
      existingParams[
              _resolveVars(p.key, envVars, collectionVars, requestVars)] =
          _resolveVars(p.value, envVars, collectionVars, requestVars);
    }
    return uri.replace(queryParameters: existingParams).toString();
  }

  Future<Map<String, dynamic>?> fetchOAuth2Token(
    String tokenUrl,
    Map<String, dynamic> body, {
    bool verifySsl = true,
    int timeoutMs = 30000,
  }) async {
    final dio = _buildDio(verifySsl: verifySsl, timeoutMs: timeoutMs);
    try {
      final response = await dio.post<Map<String, dynamic>>(
        tokenUrl,
        data: body,
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          responseType: ResponseType.json,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  bool _isTokenExpired(OAuth2Config oauth2) {
    if (oauth2.tokenExpiry == null) return false;
    // Consider token expired if less than 30 seconds remain
    return DateTime.now()
        .add(const Duration(seconds: 30))
        .isAfter(oauth2.tokenExpiry!);
  }

  Future<OAuth2Config> refreshOAuth2IfNeeded(
    OAuth2Config oauth2, {
    bool verifySsl = true,
    int timeoutMs = 30000,
  }) async {
    if (!_isTokenExpired(oauth2) || oauth2.refreshToken.isEmpty) {
      return oauth2;
    }

    try {
      final body = {
        'grant_type': 'refresh_token',
        'refresh_token': oauth2.refreshToken,
        'client_id': oauth2.clientId,
      };

      if (oauth2.clientSecret.isNotEmpty) {
        body['client_secret'] = oauth2.clientSecret;
      }

      final tokenResponse = await fetchOAuth2Token(
        oauth2.tokenUrl,
        body,
        verifySsl: verifySsl,
        timeoutMs: timeoutMs,
      );

      if (tokenResponse != null) {
        final accessToken = tokenResponse['access_token'] ?? '';
        final expiresIn = tokenResponse['expires_in'] ?? 0;
        final newRefreshToken =
            tokenResponse['refresh_token'] ?? oauth2.refreshToken;

        final tokenExpiry = expiresIn > 0
            ? DateTime.now().add(Duration(seconds: expiresIn as int))
            : null;

        return oauth2.copyWith(
          accessToken: accessToken,
          expiresIn: expiresIn,
          refreshToken: newRefreshToken,
          tokenExpiry: tokenExpiry,
        );
      }
    } catch (_) {
      // If refresh fails, continue with existing token
    }

    return oauth2;
  }

  Future<ApiResponse> send(
    ApiRequest request, {
    List<Variable> envVars = const [],
    List<Variable> collectionVars = const [],
    bool verifySsl = true,
    int timeoutMs = 30000,
  }) async {
    final dio = _buildDio(verifySsl: verifySsl, timeoutMs: timeoutMs);
    final url = _buildUrl(request.url, request.queryParams, envVars,
        collectionVars, request.variables);
    final headers = _resolveHeaders(
        request.headers, envVars, collectionVars, request.variables);

    // Standard auto-generated headers
    headers['User-Agent'] = 'Mapia/1.0.0';
    headers['Accept'] = '*/*';
    headers['Accept-Encoding'] = 'identity';
    headers['Connection'] = 'keep-alive';

    // Extract and set Host from URL
    try {
      final uri = Uri.tryParse(url) ?? Uri.parse(url);
      if (uri.host.isNotEmpty) {
        headers['Host'] = uri.host;
      }
    } catch (_) {
      // If URL parsing fails, skip Host header
    }

    // Auth injection
    if (request.auth.type == AuthType.bearer && request.auth.token.isNotEmpty) {
      headers['Authorization'] =
          'Bearer ${_resolveVars(request.auth.token, envVars, collectionVars, request.variables)}';
    } else if (request.auth.type == AuthType.basic) {
      final username = _resolveVars(
          request.auth.username, envVars, collectionVars, request.variables);
      final password = _resolveVars(
          request.auth.password, envVars, collectionVars, request.variables);
      final creds = '$username:$password';
      final encoded = base64Encode(utf8.encode(creds));
      headers['Authorization'] = 'Basic $encoded';
    } else if (request.auth.type == AuthType.apiKey &&
        request.auth.apiKeyHeader.isNotEmpty) {
      headers[request.auth.apiKeyHeader] = _resolveVars(
          request.auth.apiKeyValue, envVars, collectionVars, request.variables);
    } else if (request.auth.type == AuthType.oauth2 &&
        request.auth.oauth2Config.accessToken.isNotEmpty) {
      headers['Authorization'] =
          'Bearer ${request.auth.oauth2Config.accessToken}';
    }

    dynamic data;
    switch (request.bodyType) {
      case BodyType.json:
        headers['Content-Type'] = 'application/json';
        data = _resolveVars(
            request.body, envVars, collectionVars, request.variables);
        break;
      case BodyType.raw:
        data = _resolveVars(
            request.body, envVars, collectionVars, request.variables);
        break;
      case BodyType.urlEncoded:
        headers['Content-Type'] = 'application/x-www-form-urlencoded';
        final formMap = <String, String>{};
        for (final f in request.formDataFields.where((f) => f.enabled)) {
          formMap[_resolveVars(
                  f.key, envVars, collectionVars, request.variables)] =
              _resolveVars(f.value, envVars, collectionVars, request.variables);
        }
        data = formMap;
        break;
      case BodyType.formData:
        final formData = FormData();
        for (final f in request.formDataFields.where((f) => f.enabled)) {
          formData.fields.add(MapEntry(
            _resolveVars(f.key, envVars, collectionVars, request.variables),
            _resolveVars(f.value, envVars, collectionVars, request.variables),
          ));
        }
        data = formData;
        break;
      case BodyType.none:
      case BodyType.binary:
        break;
    }

    final stopwatch = Stopwatch()..start();
    try {
      final response = await dio.request<List<int>>(
        url,
        options: Options(
          method: request.method.name,
          headers: headers,
          responseType: ResponseType.bytes,
        ),
        data: data,
      );
      stopwatch.stop();

      final responseHeaders = <String, String>{};
      response.headers.forEach((name, values) {
        responseHeaders[name] = values.join(', ');
      });

      final contentType =
          responseHeaders['content-type'] ?? responseHeaders['Content-Type'];

      // Robust decoding logic
      String body;
      try {
        final bytes = response.data ?? [];
        if (bytes.isEmpty) {
          body = '';
        } else {
          // Default to UTF-8, but try to respect Content-Type charset if present
          Encoding encoding = utf8;
          if (contentType != null) {
            if (contentType.toLowerCase().contains('iso-8859-1')) {
              encoding = latin1;
            }
            // Add other common encodings here if needed
          }
          body = encoding.decode(bytes);
        }
      } catch (e) {
        // Fallback to latin1 if UTF-8 fails (common for legacy or misconfigured servers)
        body = latin1.decode(response.data ?? []);
      }

      final sizeBytes = response.data?.length ?? 0;

      final apiResponse = ApiResponse(
        statusCode: response.statusCode ?? 0,
        statusMessage: response.statusMessage ?? '',
        body: body,
        headers: responseHeaders,
        durationMs: stopwatch.elapsedMilliseconds,
        sizeBytes: sizeBytes,
        contentType: contentType,
      );

      // Log the response to a file
      await ResponseLogger.logResponse(apiResponse);

      return apiResponse;
    } on DioException catch (e) {
      stopwatch.stop();
      final msg = e.message ?? e.type.name;

      String errorBody = '';
      if (e.response?.data != null) {
        if (e.response?.data is List<int>) {
          errorBody = utf8.decode(e.response!.data as List<int>, allowMalformed: true);
        } else {
          errorBody = e.response?.data.toString() ?? '';
        }
      }

      return ApiResponse(
        statusCode: e.response?.statusCode ?? 0,
        statusMessage: msg,
        body: errorBody,
        headers: const {},
        durationMs: stopwatch.elapsedMilliseconds,
        sizeBytes: 0,
      );
    }
  }
}
