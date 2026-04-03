// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OAuth2Config _$OAuth2ConfigFromJson(Map<String, dynamic> json) {
  return _OAuth2Config.fromJson(json);
}

/// @nodoc
mixin _$OAuth2Config {
  OAuth2Flow get flow => throw _privateConstructorUsedError;
  String get tokenUrl => throw _privateConstructorUsedError;
  String get authorizationUrl => throw _privateConstructorUsedError;
  String get clientId => throw _privateConstructorUsedError;
  String get clientSecret => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  String get redirectUrl => throw _privateConstructorUsedError;
  String get scope => throw _privateConstructorUsedError;
  String get accessToken => throw _privateConstructorUsedError;
  int get expiresIn => throw _privateConstructorUsedError;
  String get refreshToken => throw _privateConstructorUsedError;
  DateTime? get tokenExpiry => throw _privateConstructorUsedError;

  /// Serializes this OAuth2Config to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OAuth2Config
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OAuth2ConfigCopyWith<OAuth2Config> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OAuth2ConfigCopyWith<$Res> {
  factory $OAuth2ConfigCopyWith(
          OAuth2Config value, $Res Function(OAuth2Config) then) =
      _$OAuth2ConfigCopyWithImpl<$Res, OAuth2Config>;
  @useResult
  $Res call(
      {OAuth2Flow flow,
      String tokenUrl,
      String authorizationUrl,
      String clientId,
      String clientSecret,
      String username,
      String password,
      String redirectUrl,
      String scope,
      String accessToken,
      int expiresIn,
      String refreshToken,
      DateTime? tokenExpiry});
}

/// @nodoc
class _$OAuth2ConfigCopyWithImpl<$Res, $Val extends OAuth2Config>
    implements $OAuth2ConfigCopyWith<$Res> {
  _$OAuth2ConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OAuth2Config
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? flow = null,
    Object? tokenUrl = null,
    Object? authorizationUrl = null,
    Object? clientId = null,
    Object? clientSecret = null,
    Object? username = null,
    Object? password = null,
    Object? redirectUrl = null,
    Object? scope = null,
    Object? accessToken = null,
    Object? expiresIn = null,
    Object? refreshToken = null,
    Object? tokenExpiry = freezed,
  }) {
    return _then(_value.copyWith(
      flow: null == flow
          ? _value.flow
          : flow // ignore: cast_nullable_to_non_nullable
              as OAuth2Flow,
      tokenUrl: null == tokenUrl
          ? _value.tokenUrl
          : tokenUrl // ignore: cast_nullable_to_non_nullable
              as String,
      authorizationUrl: null == authorizationUrl
          ? _value.authorizationUrl
          : authorizationUrl // ignore: cast_nullable_to_non_nullable
              as String,
      clientId: null == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as String,
      clientSecret: null == clientSecret
          ? _value.clientSecret
          : clientSecret // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      redirectUrl: null == redirectUrl
          ? _value.redirectUrl
          : redirectUrl // ignore: cast_nullable_to_non_nullable
              as String,
      scope: null == scope
          ? _value.scope
          : scope // ignore: cast_nullable_to_non_nullable
              as String,
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      expiresIn: null == expiresIn
          ? _value.expiresIn
          : expiresIn // ignore: cast_nullable_to_non_nullable
              as int,
      refreshToken: null == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
      tokenExpiry: freezed == tokenExpiry
          ? _value.tokenExpiry
          : tokenExpiry // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OAuth2ConfigImplCopyWith<$Res>
    implements $OAuth2ConfigCopyWith<$Res> {
  factory _$$OAuth2ConfigImplCopyWith(
          _$OAuth2ConfigImpl value, $Res Function(_$OAuth2ConfigImpl) then) =
      __$$OAuth2ConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {OAuth2Flow flow,
      String tokenUrl,
      String authorizationUrl,
      String clientId,
      String clientSecret,
      String username,
      String password,
      String redirectUrl,
      String scope,
      String accessToken,
      int expiresIn,
      String refreshToken,
      DateTime? tokenExpiry});
}

/// @nodoc
class __$$OAuth2ConfigImplCopyWithImpl<$Res>
    extends _$OAuth2ConfigCopyWithImpl<$Res, _$OAuth2ConfigImpl>
    implements _$$OAuth2ConfigImplCopyWith<$Res> {
  __$$OAuth2ConfigImplCopyWithImpl(
      _$OAuth2ConfigImpl _value, $Res Function(_$OAuth2ConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of OAuth2Config
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? flow = null,
    Object? tokenUrl = null,
    Object? authorizationUrl = null,
    Object? clientId = null,
    Object? clientSecret = null,
    Object? username = null,
    Object? password = null,
    Object? redirectUrl = null,
    Object? scope = null,
    Object? accessToken = null,
    Object? expiresIn = null,
    Object? refreshToken = null,
    Object? tokenExpiry = freezed,
  }) {
    return _then(_$OAuth2ConfigImpl(
      flow: null == flow
          ? _value.flow
          : flow // ignore: cast_nullable_to_non_nullable
              as OAuth2Flow,
      tokenUrl: null == tokenUrl
          ? _value.tokenUrl
          : tokenUrl // ignore: cast_nullable_to_non_nullable
              as String,
      authorizationUrl: null == authorizationUrl
          ? _value.authorizationUrl
          : authorizationUrl // ignore: cast_nullable_to_non_nullable
              as String,
      clientId: null == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as String,
      clientSecret: null == clientSecret
          ? _value.clientSecret
          : clientSecret // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      redirectUrl: null == redirectUrl
          ? _value.redirectUrl
          : redirectUrl // ignore: cast_nullable_to_non_nullable
              as String,
      scope: null == scope
          ? _value.scope
          : scope // ignore: cast_nullable_to_non_nullable
              as String,
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      expiresIn: null == expiresIn
          ? _value.expiresIn
          : expiresIn // ignore: cast_nullable_to_non_nullable
              as int,
      refreshToken: null == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
      tokenExpiry: freezed == tokenExpiry
          ? _value.tokenExpiry
          : tokenExpiry // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OAuth2ConfigImpl implements _OAuth2Config {
  const _$OAuth2ConfigImpl(
      {this.flow = OAuth2Flow.clientCredentials,
      this.tokenUrl = '',
      this.authorizationUrl = '',
      this.clientId = '',
      this.clientSecret = '',
      this.username = '',
      this.password = '',
      this.redirectUrl = '',
      this.scope = '',
      this.accessToken = '',
      this.expiresIn = 0,
      this.refreshToken = '',
      this.tokenExpiry});

  factory _$OAuth2ConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$OAuth2ConfigImplFromJson(json);

  @override
  @JsonKey()
  final OAuth2Flow flow;
  @override
  @JsonKey()
  final String tokenUrl;
  @override
  @JsonKey()
  final String authorizationUrl;
  @override
  @JsonKey()
  final String clientId;
  @override
  @JsonKey()
  final String clientSecret;
  @override
  @JsonKey()
  final String username;
  @override
  @JsonKey()
  final String password;
  @override
  @JsonKey()
  final String redirectUrl;
  @override
  @JsonKey()
  final String scope;
  @override
  @JsonKey()
  final String accessToken;
  @override
  @JsonKey()
  final int expiresIn;
  @override
  @JsonKey()
  final String refreshToken;
  @override
  final DateTime? tokenExpiry;

  @override
  String toString() {
    return 'OAuth2Config(flow: $flow, tokenUrl: $tokenUrl, authorizationUrl: $authorizationUrl, clientId: $clientId, clientSecret: $clientSecret, username: $username, password: $password, redirectUrl: $redirectUrl, scope: $scope, accessToken: $accessToken, expiresIn: $expiresIn, refreshToken: $refreshToken, tokenExpiry: $tokenExpiry)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OAuth2ConfigImpl &&
            (identical(other.flow, flow) || other.flow == flow) &&
            (identical(other.tokenUrl, tokenUrl) ||
                other.tokenUrl == tokenUrl) &&
            (identical(other.authorizationUrl, authorizationUrl) ||
                other.authorizationUrl == authorizationUrl) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.clientSecret, clientSecret) ||
                other.clientSecret == clientSecret) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.redirectUrl, redirectUrl) ||
                other.redirectUrl == redirectUrl) &&
            (identical(other.scope, scope) || other.scope == scope) &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.expiresIn, expiresIn) ||
                other.expiresIn == expiresIn) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.tokenExpiry, tokenExpiry) ||
                other.tokenExpiry == tokenExpiry));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      flow,
      tokenUrl,
      authorizationUrl,
      clientId,
      clientSecret,
      username,
      password,
      redirectUrl,
      scope,
      accessToken,
      expiresIn,
      refreshToken,
      tokenExpiry);

  /// Create a copy of OAuth2Config
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OAuth2ConfigImplCopyWith<_$OAuth2ConfigImpl> get copyWith =>
      __$$OAuth2ConfigImplCopyWithImpl<_$OAuth2ConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OAuth2ConfigImplToJson(
      this,
    );
  }
}

abstract class _OAuth2Config implements OAuth2Config {
  const factory _OAuth2Config(
      {final OAuth2Flow flow,
      final String tokenUrl,
      final String authorizationUrl,
      final String clientId,
      final String clientSecret,
      final String username,
      final String password,
      final String redirectUrl,
      final String scope,
      final String accessToken,
      final int expiresIn,
      final String refreshToken,
      final DateTime? tokenExpiry}) = _$OAuth2ConfigImpl;

  factory _OAuth2Config.fromJson(Map<String, dynamic> json) =
      _$OAuth2ConfigImpl.fromJson;

  @override
  OAuth2Flow get flow;
  @override
  String get tokenUrl;
  @override
  String get authorizationUrl;
  @override
  String get clientId;
  @override
  String get clientSecret;
  @override
  String get username;
  @override
  String get password;
  @override
  String get redirectUrl;
  @override
  String get scope;
  @override
  String get accessToken;
  @override
  int get expiresIn;
  @override
  String get refreshToken;
  @override
  DateTime? get tokenExpiry;

  /// Create a copy of OAuth2Config
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OAuth2ConfigImplCopyWith<_$OAuth2ConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AuthConfig _$AuthConfigFromJson(Map<String, dynamic> json) {
  return _AuthConfig.fromJson(json);
}

/// @nodoc
mixin _$AuthConfig {
  AuthType get type => throw _privateConstructorUsedError;
  String get token => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  String get apiKeyHeader => throw _privateConstructorUsedError;
  String get apiKeyValue => throw _privateConstructorUsedError;
  OAuth2Config get oauth2Config => throw _privateConstructorUsedError;

  /// Serializes this AuthConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthConfigCopyWith<AuthConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthConfigCopyWith<$Res> {
  factory $AuthConfigCopyWith(
          AuthConfig value, $Res Function(AuthConfig) then) =
      _$AuthConfigCopyWithImpl<$Res, AuthConfig>;
  @useResult
  $Res call(
      {AuthType type,
      String token,
      String username,
      String password,
      String apiKeyHeader,
      String apiKeyValue,
      OAuth2Config oauth2Config});

  $OAuth2ConfigCopyWith<$Res> get oauth2Config;
}

/// @nodoc
class _$AuthConfigCopyWithImpl<$Res, $Val extends AuthConfig>
    implements $AuthConfigCopyWith<$Res> {
  _$AuthConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? token = null,
    Object? username = null,
    Object? password = null,
    Object? apiKeyHeader = null,
    Object? apiKeyValue = null,
    Object? oauth2Config = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AuthType,
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      apiKeyHeader: null == apiKeyHeader
          ? _value.apiKeyHeader
          : apiKeyHeader // ignore: cast_nullable_to_non_nullable
              as String,
      apiKeyValue: null == apiKeyValue
          ? _value.apiKeyValue
          : apiKeyValue // ignore: cast_nullable_to_non_nullable
              as String,
      oauth2Config: null == oauth2Config
          ? _value.oauth2Config
          : oauth2Config // ignore: cast_nullable_to_non_nullable
              as OAuth2Config,
    ) as $Val);
  }

  /// Create a copy of AuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OAuth2ConfigCopyWith<$Res> get oauth2Config {
    return $OAuth2ConfigCopyWith<$Res>(_value.oauth2Config, (value) {
      return _then(_value.copyWith(oauth2Config: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthConfigImplCopyWith<$Res>
    implements $AuthConfigCopyWith<$Res> {
  factory _$$AuthConfigImplCopyWith(
          _$AuthConfigImpl value, $Res Function(_$AuthConfigImpl) then) =
      __$$AuthConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {AuthType type,
      String token,
      String username,
      String password,
      String apiKeyHeader,
      String apiKeyValue,
      OAuth2Config oauth2Config});

  @override
  $OAuth2ConfigCopyWith<$Res> get oauth2Config;
}

/// @nodoc
class __$$AuthConfigImplCopyWithImpl<$Res>
    extends _$AuthConfigCopyWithImpl<$Res, _$AuthConfigImpl>
    implements _$$AuthConfigImplCopyWith<$Res> {
  __$$AuthConfigImplCopyWithImpl(
      _$AuthConfigImpl _value, $Res Function(_$AuthConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? token = null,
    Object? username = null,
    Object? password = null,
    Object? apiKeyHeader = null,
    Object? apiKeyValue = null,
    Object? oauth2Config = null,
  }) {
    return _then(_$AuthConfigImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AuthType,
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      apiKeyHeader: null == apiKeyHeader
          ? _value.apiKeyHeader
          : apiKeyHeader // ignore: cast_nullable_to_non_nullable
              as String,
      apiKeyValue: null == apiKeyValue
          ? _value.apiKeyValue
          : apiKeyValue // ignore: cast_nullable_to_non_nullable
              as String,
      oauth2Config: null == oauth2Config
          ? _value.oauth2Config
          : oauth2Config // ignore: cast_nullable_to_non_nullable
              as OAuth2Config,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthConfigImpl implements _AuthConfig {
  const _$AuthConfigImpl(
      {this.type = AuthType.none,
      this.token = '',
      this.username = '',
      this.password = '',
      this.apiKeyHeader = '',
      this.apiKeyValue = '',
      this.oauth2Config = const OAuth2Config()});

  factory _$AuthConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthConfigImplFromJson(json);

  @override
  @JsonKey()
  final AuthType type;
  @override
  @JsonKey()
  final String token;
  @override
  @JsonKey()
  final String username;
  @override
  @JsonKey()
  final String password;
  @override
  @JsonKey()
  final String apiKeyHeader;
  @override
  @JsonKey()
  final String apiKeyValue;
  @override
  @JsonKey()
  final OAuth2Config oauth2Config;

  @override
  String toString() {
    return 'AuthConfig(type: $type, token: $token, username: $username, password: $password, apiKeyHeader: $apiKeyHeader, apiKeyValue: $apiKeyValue, oauth2Config: $oauth2Config)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthConfigImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.apiKeyHeader, apiKeyHeader) ||
                other.apiKeyHeader == apiKeyHeader) &&
            (identical(other.apiKeyValue, apiKeyValue) ||
                other.apiKeyValue == apiKeyValue) &&
            (identical(other.oauth2Config, oauth2Config) ||
                other.oauth2Config == oauth2Config));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, token, username, password,
      apiKeyHeader, apiKeyValue, oauth2Config);

  /// Create a copy of AuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthConfigImplCopyWith<_$AuthConfigImpl> get copyWith =>
      __$$AuthConfigImplCopyWithImpl<_$AuthConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthConfigImplToJson(
      this,
    );
  }
}

abstract class _AuthConfig implements AuthConfig {
  const factory _AuthConfig(
      {final AuthType type,
      final String token,
      final String username,
      final String password,
      final String apiKeyHeader,
      final String apiKeyValue,
      final OAuth2Config oauth2Config}) = _$AuthConfigImpl;

  factory _AuthConfig.fromJson(Map<String, dynamic> json) =
      _$AuthConfigImpl.fromJson;

  @override
  AuthType get type;
  @override
  String get token;
  @override
  String get username;
  @override
  String get password;
  @override
  String get apiKeyHeader;
  @override
  String get apiKeyValue;
  @override
  OAuth2Config get oauth2Config;

  /// Create a copy of AuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthConfigImplCopyWith<_$AuthConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ApiRequest _$ApiRequestFromJson(Map<String, dynamic> json) {
  return _ApiRequest.fromJson(json);
}

/// @nodoc
mixin _$ApiRequest {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  HttpMethod get method => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  List<Variable> get queryParams => throw _privateConstructorUsedError;
  List<Variable> get headers => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  BodyType get bodyType => throw _privateConstructorUsedError;
  List<Variable> get formDataFields => throw _privateConstructorUsedError;
  List<Variable> get variables => throw _privateConstructorUsedError;
  AuthConfig get auth => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  /// Serializes this ApiRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ApiRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApiRequestCopyWith<ApiRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiRequestCopyWith<$Res> {
  factory $ApiRequestCopyWith(
          ApiRequest value, $Res Function(ApiRequest) then) =
      _$ApiRequestCopyWithImpl<$Res, ApiRequest>;
  @useResult
  $Res call(
      {String id,
      String name,
      HttpMethod method,
      String url,
      List<Variable> queryParams,
      List<Variable> headers,
      String body,
      BodyType bodyType,
      List<Variable> formDataFields,
      List<Variable> variables,
      AuthConfig auth,
      String description});

  $AuthConfigCopyWith<$Res> get auth;
}

/// @nodoc
class _$ApiRequestCopyWithImpl<$Res, $Val extends ApiRequest>
    implements $ApiRequestCopyWith<$Res> {
  _$ApiRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApiRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? method = null,
    Object? url = null,
    Object? queryParams = null,
    Object? headers = null,
    Object? body = null,
    Object? bodyType = null,
    Object? formDataFields = null,
    Object? variables = null,
    Object? auth = null,
    Object? description = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as HttpMethod,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      queryParams: null == queryParams
          ? _value.queryParams
          : queryParams // ignore: cast_nullable_to_non_nullable
              as List<Variable>,
      headers: null == headers
          ? _value.headers
          : headers // ignore: cast_nullable_to_non_nullable
              as List<Variable>,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      bodyType: null == bodyType
          ? _value.bodyType
          : bodyType // ignore: cast_nullable_to_non_nullable
              as BodyType,
      formDataFields: null == formDataFields
          ? _value.formDataFields
          : formDataFields // ignore: cast_nullable_to_non_nullable
              as List<Variable>,
      variables: null == variables
          ? _value.variables
          : variables // ignore: cast_nullable_to_non_nullable
              as List<Variable>,
      auth: null == auth
          ? _value.auth
          : auth // ignore: cast_nullable_to_non_nullable
              as AuthConfig,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  /// Create a copy of ApiRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuthConfigCopyWith<$Res> get auth {
    return $AuthConfigCopyWith<$Res>(_value.auth, (value) {
      return _then(_value.copyWith(auth: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ApiRequestImplCopyWith<$Res>
    implements $ApiRequestCopyWith<$Res> {
  factory _$$ApiRequestImplCopyWith(
          _$ApiRequestImpl value, $Res Function(_$ApiRequestImpl) then) =
      __$$ApiRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      HttpMethod method,
      String url,
      List<Variable> queryParams,
      List<Variable> headers,
      String body,
      BodyType bodyType,
      List<Variable> formDataFields,
      List<Variable> variables,
      AuthConfig auth,
      String description});

  @override
  $AuthConfigCopyWith<$Res> get auth;
}

/// @nodoc
class __$$ApiRequestImplCopyWithImpl<$Res>
    extends _$ApiRequestCopyWithImpl<$Res, _$ApiRequestImpl>
    implements _$$ApiRequestImplCopyWith<$Res> {
  __$$ApiRequestImplCopyWithImpl(
      _$ApiRequestImpl _value, $Res Function(_$ApiRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of ApiRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? method = null,
    Object? url = null,
    Object? queryParams = null,
    Object? headers = null,
    Object? body = null,
    Object? bodyType = null,
    Object? formDataFields = null,
    Object? variables = null,
    Object? auth = null,
    Object? description = null,
  }) {
    return _then(_$ApiRequestImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as HttpMethod,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      queryParams: null == queryParams
          ? _value._queryParams
          : queryParams // ignore: cast_nullable_to_non_nullable
              as List<Variable>,
      headers: null == headers
          ? _value._headers
          : headers // ignore: cast_nullable_to_non_nullable
              as List<Variable>,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      bodyType: null == bodyType
          ? _value.bodyType
          : bodyType // ignore: cast_nullable_to_non_nullable
              as BodyType,
      formDataFields: null == formDataFields
          ? _value._formDataFields
          : formDataFields // ignore: cast_nullable_to_non_nullable
              as List<Variable>,
      variables: null == variables
          ? _value._variables
          : variables // ignore: cast_nullable_to_non_nullable
              as List<Variable>,
      auth: null == auth
          ? _value.auth
          : auth // ignore: cast_nullable_to_non_nullable
              as AuthConfig,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ApiRequestImpl implements _ApiRequest {
  const _$ApiRequestImpl(
      {required this.id,
      this.name = 'New Request',
      this.method = HttpMethod.get,
      this.url = '',
      final List<Variable> queryParams = const [],
      final List<Variable> headers = const [],
      this.body = '',
      this.bodyType = BodyType.none,
      final List<Variable> formDataFields = const [],
      final List<Variable> variables = const [],
      this.auth = const AuthConfig(),
      this.description = ''})
      : _queryParams = queryParams,
        _headers = headers,
        _formDataFields = formDataFields,
        _variables = variables;

  factory _$ApiRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApiRequestImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final HttpMethod method;
  @override
  @JsonKey()
  final String url;
  final List<Variable> _queryParams;
  @override
  @JsonKey()
  List<Variable> get queryParams {
    if (_queryParams is EqualUnmodifiableListView) return _queryParams;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_queryParams);
  }

  final List<Variable> _headers;
  @override
  @JsonKey()
  List<Variable> get headers {
    if (_headers is EqualUnmodifiableListView) return _headers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_headers);
  }

  @override
  @JsonKey()
  final String body;
  @override
  @JsonKey()
  final BodyType bodyType;
  final List<Variable> _formDataFields;
  @override
  @JsonKey()
  List<Variable> get formDataFields {
    if (_formDataFields is EqualUnmodifiableListView) return _formDataFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_formDataFields);
  }

  final List<Variable> _variables;
  @override
  @JsonKey()
  List<Variable> get variables {
    if (_variables is EqualUnmodifiableListView) return _variables;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_variables);
  }

  @override
  @JsonKey()
  final AuthConfig auth;
  @override
  @JsonKey()
  final String description;

  @override
  String toString() {
    return 'ApiRequest(id: $id, name: $name, method: $method, url: $url, queryParams: $queryParams, headers: $headers, body: $body, bodyType: $bodyType, formDataFields: $formDataFields, variables: $variables, auth: $auth, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.url, url) || other.url == url) &&
            const DeepCollectionEquality()
                .equals(other._queryParams, _queryParams) &&
            const DeepCollectionEquality().equals(other._headers, _headers) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.bodyType, bodyType) ||
                other.bodyType == bodyType) &&
            const DeepCollectionEquality()
                .equals(other._formDataFields, _formDataFields) &&
            const DeepCollectionEquality()
                .equals(other._variables, _variables) &&
            (identical(other.auth, auth) || other.auth == auth) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      method,
      url,
      const DeepCollectionEquality().hash(_queryParams),
      const DeepCollectionEquality().hash(_headers),
      body,
      bodyType,
      const DeepCollectionEquality().hash(_formDataFields),
      const DeepCollectionEquality().hash(_variables),
      auth,
      description);

  /// Create a copy of ApiRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiRequestImplCopyWith<_$ApiRequestImpl> get copyWith =>
      __$$ApiRequestImplCopyWithImpl<_$ApiRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ApiRequestImplToJson(
      this,
    );
  }
}

abstract class _ApiRequest implements ApiRequest {
  const factory _ApiRequest(
      {required final String id,
      final String name,
      final HttpMethod method,
      final String url,
      final List<Variable> queryParams,
      final List<Variable> headers,
      final String body,
      final BodyType bodyType,
      final List<Variable> formDataFields,
      final List<Variable> variables,
      final AuthConfig auth,
      final String description}) = _$ApiRequestImpl;

  factory _ApiRequest.fromJson(Map<String, dynamic> json) =
      _$ApiRequestImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  HttpMethod get method;
  @override
  String get url;
  @override
  List<Variable> get queryParams;
  @override
  List<Variable> get headers;
  @override
  String get body;
  @override
  BodyType get bodyType;
  @override
  List<Variable> get formDataFields;
  @override
  List<Variable> get variables;
  @override
  AuthConfig get auth;
  @override
  String get description;

  /// Create a copy of ApiRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApiRequestImplCopyWith<_$ApiRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
