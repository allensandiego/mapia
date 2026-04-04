import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tabs_provider.dart';
import '../providers/ui_provider.dart';
import '../widgets/sidebar/sidebar_panel.dart';
import '../widgets/request/request_tab_view.dart';
import '../../core/theme/mapia_colors.dart';
import '../../core/constants/http_constants.dart';
import 'environment_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _nextTab() {
    final tabs = ref.read(tabsProvider);
    final activeTabId = ref.read(activeTabIdProvider);
    if (activeTabId == null || tabs.length <= 1) return;
    final index = tabs.indexWhere((t) => t.id == activeTabId);
    final nextIndex = (index + 1) % tabs.length;
    ref.read(tabsProvider.notifier).activateTab(tabs[nextIndex].id);
  }

  void _previousTab() {
    final tabs = ref.read(tabsProvider);
    final activeTabId = ref.read(activeTabIdProvider);
    if (activeTabId == null || tabs.length <= 1) return;
    final index = tabs.indexWhere((t) => t.id == activeTabId);
    final prevIndex = (index - 1 + tabs.length) % tabs.length;
    ref.read(tabsProvider.notifier).activateTab(tabs[prevIndex].id);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ref.watch(tabsProvider);
    final activeTabId = ref.watch(activeTabIdProvider);

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        // Prevent tab from moving focus when Ctrl is pressed
        if (event.logicalKey == LogicalKeyboardKey.tab &&
            HardwareKeyboard.instance.isControlPressed) {
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.enter, control: true): () {
            if (activeTabId != null) {
              ref.read(tabsProvider.notifier).sendRequest(activeTabId);
            }
          },
          const SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
            if (activeTabId != null) {
              ref.read(tabsProvider.notifier).saveRequest(activeTabId, context);
            }
          },
          const SingleActivator(LogicalKeyboardKey.keyT, control: true): () {
            ref.read(tabsProvider.notifier).openNewTab();
          },
          const SingleActivator(LogicalKeyboardKey.keyW, control: true): () {
            if (activeTabId != null) {
              ref.read(tabsProvider.notifier).closeTab(activeTabId);
            }
          },
          const SingleActivator(LogicalKeyboardKey.tab, control: true):
              _nextTab,
          const SingleActivator(LogicalKeyboardKey.tab,
              control: true, shift: true): _previousTab,
          const SingleActivator(LogicalKeyboardKey.keyE, control: true): () {
            showDialog(
                context: context, builder: (_) => const EnvironmentScreen());
          },
          const SingleActivator(LogicalKeyboardKey.comma, control: true): () {
            showDialog(
                context: context, builder: (_) => const SettingsScreen());
          },
        },
        child: Scaffold(
          backgroundColor: context.colors.bgBase,
          body: Row(
            children: [
              // Sidebar
              const SidebarPanel(),
              // Vertical divider
              MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragUpdate: (details) {
                    final current = ref.read(sidebarWidthProvider);
                    ref.read(sidebarWidthProvider.notifier).state =
                        (current + details.delta.dx).clamp(160.0, 600.0);
                  },
                  child: Container(
                    width: 1,
                    color: context.colors.border,
                  ),
                ),
              ),
              // Main content column
              Expanded(
                child: Column(
                  children: [
                    // Top tab bar (now only for requests)
                    _TopBar(tabs: tabs, activeTabId: activeTabId),
                    // Request/response area
                    Expanded(
                      child: tabs.isEmpty
                          ? const _EmptyState()
                          : RequestTabView(
                              tabId: activeTabId ?? tabs.first.id,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  final List<RequestTab> tabs;
  final String? activeTabId;

  const _TopBar({required this.tabs, required this.activeTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 48,
      color: context.colors.bgSurface,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Request tabs
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: context.colors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: tabs.map((tab) {
                          final isActive = tab.id == activeTabId;
                          return _TabChip(tab: tab, isActive: isActive);
                        }).toList(),
                      ),
                    ),
                  ),
                  // New tab button
                  InkWell(
                    onTap: () => ref.read(tabsProvider.notifier).openNewTab(),
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      child: Icon(Icons.add,
                          size: 18, color: context.colors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends ConsumerWidget {
  final RequestTab tab;
  final bool isActive;

  const _TabChip({required this.tab, required this.isActive});

  Color _getMethodColor(BuildContext context, HttpMethod method) {
    final colors = context.colors;
    switch (method) {
      case HttpMethod.get:
        return colors.methodGet;
      case HttpMethod.post:
        return colors.methodPost;
      case HttpMethod.put:
        return colors.methodPut;
      case HttpMethod.patch:
        return colors.methodPatch;
      case HttpMethod.delete:
        return colors.methodDelete;
      case HttpMethod.head:
        return colors.methodHead;
      case HttpMethod.options:
        return colors.methodOptions;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final methodColor = _getMethodColor(context, tab.request.method);
    return GestureDetector(
      onTap: () => ref.read(tabsProvider.notifier).activateTab(tab.id),
      child: Container(
        height: 48,
        constraints: const BoxConstraints(maxWidth: 240, minWidth: 140),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? context.colors.bgBase : Colors.transparent,
          border: Border(
            right: BorderSide(color: context.colors.border, width: 0.5),
            bottom: BorderSide(
              color: isActive ? context.colors.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: methodColor,
              ),
            ),
            Flexible(
              child: Text(
                tab.request.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: isActive
                      ? context.colors.textPrimary
                      : context.colors.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (tab.isDirty)
              Container(
                margin: const EdgeInsets.only(left: 4),
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.accent,
                ),
              ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () => ref.read(tabsProvider.notifier).closeTab(tab.id),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.close,
                    size: 14, color: context.colors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends ConsumerWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/mapia.png',
            width: 72,
            height: 72,
          ),
          const SizedBox(height: 24),
          Text(
            'Mapia',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yes another REST API client',
            style: TextStyle(fontSize: 14, color: context.colors.textSecondary),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => ref.read(tabsProvider.notifier).openNewTab(),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('New Request'),
          ),
        ],
      ),
    );
  }
}
