// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OAuth2ConfigImpl _$$OAuth2ConfigImplFromJson(Map<String, dynamic> json) =>
    _$OAuth2ConfigImpl(
      flow: $enumDecodeNullable(_$OAuth2FlowEnumMap, json['flow']) ??
          OAuth2Flow.clientCredentials,
      tokenUrl: json['tokenUrl'] as String? ?? '',
      authorizationUrl: json['authorizationUrl'] as String? ?? '',
      clientId: json['clientId'] as String? ?? '',
      clientSecret: json['clientSecret'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      redirectUrl: json['redirectUrl'] as String? ?? '',
      scope: json['scope'] as String? ?? '',
      accessToken: json['accessToken'] as String? ?? '',
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 0,
      refreshToken: json['refreshToken'] as String? ?? '',
      tokenExpiry: json['tokenExpiry'] == null
          ? null
          : DateTime.parse(json['tokenExpiry'] as String),
    );

Map<String, dynamic> _$$OAuth2ConfigImplToJson(_$OAuth2ConfigImpl instance) =>
    <String, dynamic>{
      'flow': _$OAuth2FlowEnumMap[instance.flow]!,
      'tokenUrl': instance.tokenUrl,
      'authorizationUrl': instance.authorizationUrl,
      'clientId': instance.clientId,
      'clientSecret': instance.clientSecret,
      'username': instance.username,
      'password': instance.password,
      'redirectUrl': instance.redirectUrl,
      'scope': instance.scope,
      'accessToken': instance.accessToken,
      'expiresIn': instance.expiresIn,
      'refreshToken': instance.refreshToken,
      'tokenExpiry': instance.tokenExpiry?.toIso8601String(),
    };

const _$OAuth2FlowEnumMap = {
  OAuth2Flow.clientCredentials: 'clientCredentials',
  OAuth2Flow.authorizationCode: 'authorizationCode',
  OAuth2Flow.password: 'password',
  OAuth2Flow.implicit: 'implicit',
};

_$AuthConfigImpl _$$AuthConfigImplFromJson(Map<String, dynamic> json) =>
    _$AuthConfigImpl(
      type:
          $enumDecodeNullable(_$AuthTypeEnumMap, json['type']) ?? AuthType.none,
      token: json['token'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      apiKeyHeader: json['apiKeyHeader'] as String? ?? '',
      apiKeyValue: json['apiKeyValue'] as String? ?? '',
      oauth2Config: json['oauth2Config'] == null
          ? const OAuth2Config()
          : OAuth2Config.fromJson(json['oauth2Config'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AuthConfigImplToJson(_$AuthConfigImpl instance) =>
    <String, dynamic>{
      'type': _$AuthTypeEnumMap[instance.type]!,
      'token': instance.token,
      'username': instance.username,
      'password': instance.password,
      'apiKeyHeader': instance.apiKeyHeader,
      'apiKeyValue': instance.apiKeyValue,
      'oauth2Config': instance.oauth2Config,
    };

const _$AuthTypeEnumMap = {
  AuthType.none: 'none',
  AuthType.bearer: 'bearer',
  AuthType.basic: 'basic',
  AuthType.apiKey: 'apiKey',
  AuthType.oauth2: 'oauth2',
};

_$ApiRequestImpl _$$ApiRequestImplFromJson(Map<String, dynamic> json) =>
    _$ApiRequestImpl(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'New Request',
      method: $enumDecodeNullable(_$HttpMethodEnumMap, json['method']) ??
          HttpMethod.get,
      url: json['url'] as String? ?? '',
      queryParams: (json['queryParams'] as List<dynamic>?)
              ?.map((e) => Variable.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      headers: (json['headers'] as List<dynamic>?)
              ?.map((e) => Variable.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      body: json['body'] as String? ?? '',
      bodyType: $enumDecodeNullable(_$BodyTypeEnumMap, json['bodyType']) ??
          BodyType.none,
      formDataFields: (json['formDataFields'] as List<dynamic>?)
              ?.map((e) => Variable.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      variables: (json['variables'] as List<dynamic>?)
              ?.map((e) => Variable.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      auth: json['auth'] == null
          ? const AuthConfig()
          : AuthConfig.fromJson(json['auth'] as Map<String, dynamic>),
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$$ApiRequestImplToJson(_$ApiRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'method': _$HttpMethodEnumMap[instance.method]!,
      'url': instance.url,
      'queryParams': instance.queryParams,
      'headers': instance.headers,
      'body': instance.body,
      'bodyType': _$BodyTypeEnumMap[instance.bodyType]!,
      'formDataFields': instance.formDataFields,
      'variables': instance.variables,
      'auth': instance.auth,
      'description': instance.description,
    };

const _$HttpMethodEnumMap = {
  HttpMethod.get: 'get',
  HttpMethod.post: 'post',
  HttpMethod.put: 'put',
  HttpMethod.patch: 'patch',
  HttpMethod.delete: 'delete',
  HttpMethod.head: 'head',
  HttpMethod.options: 'options',
};

const _$BodyTypeEnumMap = {
  BodyType.none: 'none',
  BodyType.json: 'json',
  BodyType.formData: 'formData',
  BodyType.urlEncoded: 'urlEncoded',
  BodyType.raw: 'raw',
  BodyType.binary: 'binary',
};
