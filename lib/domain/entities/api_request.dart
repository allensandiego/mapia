import 'package:freezed_annotation/freezed_annotation.dart';
import 'variable.dart';
import '../../core/constants/http_constants.dart';

part 'api_request.freezed.dart';
part 'api_request.g.dart';

@freezed
class OAuth2Config with _$OAuth2Config {
  const factory OAuth2Config({
    @Default(OAuth2Flow.clientCredentials) OAuth2Flow flow,
    @Default('') String tokenUrl,
    @Default('') String authorizationUrl,
    @Default('') String clientId,
    @Default('') String clientSecret,
    @Default('') String username,
    @Default('') String password,
    @Default('') String redirectUrl,
    @Default('') String scope,
    @Default('') String accessToken,
    @Default(0) int expiresIn,
    @Default('') String refreshToken,
    DateTime? tokenExpiry,
  }) = _OAuth2Config;

  factory OAuth2Config.fromJson(Map<String, dynamic> json) =>
      _$OAuth2ConfigFromJson(json);
}

@freezed
class AuthConfig with _$AuthConfig {
  const factory AuthConfig({
    @Default(AuthType.none) AuthType type,
    @Default('') String token,
    @Default('') String username,
    @Default('') String password,
    @Default('') String apiKeyHeader,
    @Default('') String apiKeyValue,
    @Default(OAuth2Config()) OAuth2Config oauth2Config,
  }) = _AuthConfig;

  factory AuthConfig.fromJson(Map<String, dynamic> json) =>
      _$AuthConfigFromJson(json);
}

@freezed
class ApiRequest with _$ApiRequest {
  const factory ApiRequest({
    required String id,
    @Default('New Request') String name,
    @Default(HttpMethod.get) HttpMethod method,
    @Default('') String url,
    @Default([]) List<Variable> queryParams,
    @Default([]) List<Variable> headers,
    @Default('') String body,
    @Default(BodyType.none) BodyType bodyType,
    @Default([]) List<Variable> formDataFields,
    @Default([]) List<Variable> variables,
    @Default(AuthConfig()) AuthConfig auth,
    @Default('') String description,
  }) = _ApiRequest;

  factory ApiRequest.fromJson(Map<String, dynamic> json) =>
      _$ApiRequestFromJson(json);
}
