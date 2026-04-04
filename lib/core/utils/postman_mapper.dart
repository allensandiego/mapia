import 'package:uuid/uuid.dart';
import '../../domain/entities/collection.dart';
import '../../domain/entities/folder.dart';
import '../../domain/entities/api_request.dart';
import '../../domain/entities/variable.dart';
import '../constants/http_constants.dart';

class PostmanMapper {
  static Collection mapPostman(Map<String, dynamic> json) {
    const uuid = Uuid();
    final info = json['info'] as Map<String, dynamic>?;
    final items = json['item'] as List<dynamic>? ?? [];

    final name = info?['name'] ?? 'Imported Postman Collection';
    final description = info?['description'] ?? '';

    final List<Folder> folders = [];
    final List<ApiRequest> requests = [];

    for (final item in items) {
      _parseItem(item as Map<String, dynamic>, folders, requests, null, uuid);
    }

    return Collection(
      id: uuid.v4(),
      name: name,
      description: description,
      folders: folders,
      requests: requests,
    );
  }

  static void _parseItem(
    Map<String, dynamic> item,
    List<Folder> parentFolders,
    List<ApiRequest> parentRequests,
    String? currentFolderId,
    Uuid uuid,
  ) {
    final name = item['name'] ?? 'Unnamed';
    final subItems = item['item'] as List<dynamic>?;

    if (subItems != null) {
      // It's a folder
      final folderId = uuid.v4();
      final List<ApiRequest> folderRequests = [];
      
      // Postman folders can be nested, but Mapia only supports 1 level for now?
      // Actually Collection has List<Folder> and Folder has List<ApiRequest>.
      // If we find nested folders, we'll flatten them or just take the requests.
      
      for (final sub in subItems) {
        _parseSubItem(sub as Map<String, dynamic>, folderRequests, uuid);
      }
      
      parentFolders.add(Folder(
        id: folderId,
        name: name,
        requests: folderRequests,
      ));
    } else if (item['request'] != null) {
      // It's a request at root
      parentRequests.add(_mapRequest(item, uuid));
    }
  }

  static void _parseSubItem(
    Map<String, dynamic> item,
    List<ApiRequest> folderRequests,
    Uuid uuid,
  ) {
    if (item['request'] != null) {
      folderRequests.add(_mapRequest(item, uuid));
    } else if (item['item'] != null) {
      // Nested folder - flatten for now
      final subs = item['item'] as List<dynamic>;
      for (final sub in subs) {
        _parseSubItem(sub as Map<String, dynamic>, folderRequests, uuid);
      }
    }
  }

  static ApiRequest _mapRequest(Map<String, dynamic> item, Uuid uuid) {
    final name = item['name'] ?? 'Unnamed Request';
    final req = item['request'] as Map<String, dynamic>;
    final methodStr = (req['method'] as String? ?? 'GET').toLowerCase();
    final method = HttpMethod.values.firstWhere(
      (m) => m.name == methodStr,
      orElse: () => HttpMethod.get,
    );

    String urlString = '';
    final urlData = req['url'];
    if (urlData is String) {
      urlString = urlData;
    } else if (urlData is Map) {
      urlString = urlData['raw'] ?? '';
    }

    final headers = req['header'] as List<dynamic>? ?? [];
    final List<Variable> headersList = headers.map((h) {
      final hm = h as Map<String, dynamic>;
      return Variable(
        key: hm['key'] ?? '',
        value: hm['value'] ?? '',
        enabled: !(hm['disabled'] ?? false),
      );
    }).toList();

    // Body
    final bodyData = req['body'] as Map<String, dynamic>?;
    String? rawBody;
    
    if (bodyData != null) {
      final mode = bodyData['mode'] as String?;
      if (mode == 'raw') {
        rawBody = bodyData['raw'];
      }
      // TODO: form-data, urlencoded etc.
    }

    return ApiRequest(
      id: uuid.v4(),
      name: name,
      method: method,
      url: urlString,
      headers: headersList,
      body: rawBody ?? '',
      // Mapia currently uses a simple body string, 
      // but should probably support more complex ones soon.
    );
  }
}
