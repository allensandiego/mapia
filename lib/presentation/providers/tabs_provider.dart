import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/api_request.dart';
import '../../domain/entities/api_response.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/entities/variable.dart';
import '../../core/constants/http_constants.dart';
import '../../data/services/http_service.dart';
import '../widgets/request/save_request_dialog.dart';
import 'history_provider.dart';
import 'collection_provider.dart';
import 'environment_provider.dart';
import 'package:uuid/uuid.dart';

class RequestTab {
  final String id;
  final ApiRequest request;
  final ApiResponse? response;
  final bool isLoading;
  final String? collectionId;
  final String? folderId;
  final bool isDirty;

  const RequestTab({
    required this.id,
    required this.request,
    this.response,
    this.isLoading = false,
    this.collectionId,
    this.folderId,
    this.isDirty = false,
  });

  RequestTab copyWith({
    ApiRequest? request,
    ApiResponse? response,
    bool? isLoading,
    String? collectionId,
    String? folderId,
    bool? isDirty,
    bool clearResponse = false,
  }) {
    return RequestTab(
      id: id,
      request: request ?? this.request,
      response: clearResponse ? null : (response ?? this.response),
      isLoading: isLoading ?? this.isLoading,
      collectionId: collectionId ?? this.collectionId,
      folderId: folderId ?? this.folderId,
      isDirty: isDirty ?? this.isDirty,
    );
  }
}

class TabsNotifier extends Notifier<List<RequestTab>> {
  static const _uuid = Uuid();

  @override
  List<RequestTab> build() => [];

  String openNewTab({
    ApiRequest? request,
    String? collectionId,
    String? folderId,
  }) {
    final tabId = _uuid.v4();
    final req = request ??
        ApiRequest(
          id: _uuid.v4(),
          name: 'New Request',
          method: HttpMethod.get,
          url: '',
        );
    final tab = RequestTab(
      id: tabId,
      request: req,
      collectionId: collectionId,
      folderId: folderId,
    );
    state = [...state, tab];
    ref.read(activeTabIdProvider.notifier).state = tabId;
    return tabId;
  }

  void closeTab(String tabId) {
    final newTabs = state.where((t) => t.id != tabId).toList();
    state = newTabs;
    final activeId = ref.read(activeTabIdProvider);
    if (activeId == tabId) {
      ref.read(activeTabIdProvider.notifier).state =
          newTabs.isEmpty ? null : newTabs.last.id;
    }
  }

  void updateRequest(String tabId, ApiRequest request) {
    state = state
        .map((t) => t.id == tabId ? t.copyWith(request: request, isDirty: true) : t)
        .toList();
  }

  void markClean(String tabId, {String? collectionId, String? folderId}) {
    state = state.map((t) {
      if (t.id != tabId) return t;
      return t.copyWith(
        isDirty: false,
        collectionId: collectionId ?? t.collectionId,
        folderId: folderId ?? t.folderId,
      );
    }).toList();
  }

  void setLoading(String tabId, bool loading) {
    state = state
        .map((t) => t.id == tabId ? t.copyWith(isLoading: loading) : t)
        .toList();
  }

  void setResponse(String tabId, ApiResponse response) {
    state = state
        .map((t) =>
            t.id == tabId ? t.copyWith(response: response, isLoading: false) : t)
        .toList();
  }

  void activateTab(String tabId) {
    ref.read(activeTabIdProvider.notifier).state = tabId;
  }

  Future<void> sendRequest(String tabId) async {
    final tab = state.where((t) => t.id == tabId).firstOrNull;
    if (tab == null || tab.request.url.isEmpty || tab.isLoading) return;

    setLoading(tabId, true);

    final envVars = ref.read(activeEnvVariablesProvider);
    var envVarsList = envVars.entries
        .map((e) => Variable(key: e.key, value: e.value))
        .toList();

    List<Variable> collectionVars = [];
    if (tab.collectionId != null) {
      final collections = ref.read(collectionsProvider).value ?? [];
      final collection =
          collections.where((c) => c.id == tab.collectionId).firstOrNull;
      if (collection != null) {
        collectionVars = collection.variables;
        
        if (collection.environmentId != null) {
          final envs = ref.read(environmentsProvider).value ?? [];
          final linkedEnv = envs.where((e) => e.id == collection.environmentId).firstOrNull;
          if (linkedEnv != null) {
            envVarsList = linkedEnv.variables.where((v) => v.enabled).toList();
          }
        }
      }
    }

    try {
      final httpService = HttpService();
      var request = tab.request;

      // Auto-refresh OAuth2 token if expired
      if (request.auth.type == AuthType.oauth2) {
        final refreshedOAuth2 = await httpService.refreshOAuth2IfNeeded(
          request.auth.oauth2Config,
        );
        if (refreshedOAuth2 != request.auth.oauth2Config) {
          request = request.copyWith(
            auth: request.auth.copyWith(oauth2Config: refreshedOAuth2),
          );
          updateRequest(tabId, request);
        }
      }

      final response = await httpService.send(
        request,
        envVars: envVarsList,
        collectionVars: collectionVars,
      );
      setResponse(tabId, response);

      // Save to history
      final entry = HistoryEntry(
        id: _uuid.v4(),
        request: request,
        response: response,
        timestamp: DateTime.now(),
      );
      await ref.read(historyProvider.notifier).add(entry);
    } catch (e) {
      setLoading(tabId, false);
    }
  }

  void saveRequest(String tabId, BuildContext context) {
    final tab = state.where((t) => t.id == tabId).firstOrNull;
    if (tab == null) return;

    if (tab.collectionId != null) {
      ref.read(collectionsProvider.notifier).saveRequest(
        tab.collectionId!,
        tab.folderId,
        tab.request,
      );
      markClean(tabId);
    } else {
      showDialog(
        context: context,
        builder: (_) => SaveRequestDialog(tab: tab),
      );
    }
  }
}

final tabsProvider = NotifierProvider<TabsNotifier, List<RequestTab>>(
  TabsNotifier.new,
);

final activeTabIdProvider = StateProvider<String?>((ref) => null);

final activeTabProvider = Provider<RequestTab?>((ref) {
  final id = ref.watch(activeTabIdProvider);
  if (id == null) return null;
  final tabs = ref.watch(tabsProvider);
  return tabs.where((t) => t.id == id).firstOrNull;
});
