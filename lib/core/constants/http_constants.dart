enum HttpMethod {
  get,
  post,
  put,
  patch,
  delete,
  head,
  options;

  String get label => name.toUpperCase();
}

enum BodyType { none, json, formData, urlEncoded, raw, binary }

enum AuthType { none, bearer, basic, apiKey, oauth2 }

enum OAuth2Flow { clientCredentials, authorizationCode, password, implicit }
