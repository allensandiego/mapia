import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/tabs_provider.dart';
import '../../providers/ui_provider.dart';
import '../../providers/environment_provider.dart';
import '../../../core/theme/mapia_colors.dart';
import 'url_bar.dart';
import 'request_editor.dart';
import 'response_panel.dart';
import 'snippet_panel.dart';

class RequestTabView extends ConsumerWidget {
  final String tabId;
  const RequestTabView({super.key, required this.tabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = ref.watch(tabsProvider);
    final tab = tabs.where((t) => t.id == tabId).firstOrNull;
    if (tab == null) {
      return Center(
          child: Text('Tab not found',
              style: TextStyle(color: context.colors.textMuted)));
    }

    final showCode = ref.watch(showCodePanelProvider);
    final codeWidth = ref.watch(codePanelWidthProvider);

    return Row(
      children: [
        // Left side: URL Bar + Editor/Response split
        Expanded(
          child: Column(
            children: [
              // URL bar
              UrlBar(
                tab: tab,
                onSend: () =>
                    ref.read(tabsProvider.notifier).sendRequest(tab.id),
              ),
              const Divider(height: 1),
              // Request Editor + Response Panel (vertical split)
              Expanded(
                child: _VerticalSplit(tab: tab),
              ),
            ],
          ),
        ),
        // Right side: Code Snippet Sidebar (Full Height)
        if (showCode) ...[
          // Drag handle for code panel
          MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                final current = ref.read(codePanelWidthProvider);
                ref.read(codePanelWidthProvider.notifier).state =
                    (current - details.delta.dx).clamp(200.0, 800.0);
              },
              child: Container(
                width: 1,
                color: context.colors.border,
              ),
            ),
          ),
          // Code Panel
          SizedBox(
            width: codeWidth,
            child: Container(
              color: context.colors.bgBase,
              child: Column(
                children: [
                  _EnvironmentDropdown(),
                  const Divider(height: 1),
                  Expanded(
                    child: SnippetPanel(request: tab.request),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _EnvironmentDropdown extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final envsAsync = ref.watch(environmentsProvider);
    final activeId = ref.watch(activeEnvironmentProvider);
    final colors = context.colors;

    return Container(
      color: colors.bgSurface,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.tune_outlined, size: 12, color: colors.textMuted),
          const SizedBox(width: 4),
          Text('Env:', style: TextStyle(fontSize: 11, color: colors.textMuted)),
          const SizedBox(width: 4),
          Expanded(
            child: envsAsync.when(
              loading: () => Text('Loading...',
                  style: TextStyle(fontSize: 11, color: colors.textMuted)),
              error: (_, __) => Text('Error',
                  style: TextStyle(fontSize: 11, color: colors.error)),
              data: (envs) {
                final items = [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text('None',
                        style:
                            TextStyle(fontSize: 11, color: colors.textMuted)),
                  ),
                  ...envs.map((e) => DropdownMenuItem<String?>(
                        value: e.id,
                        child: Text(e.name,
                            style: TextStyle(
                                fontSize: 11, color: colors.textPrimary)),
                      )),
                ];
                return DropdownButton<String?>(
                  value: activeId,
                  isExpanded: true,
                  isDense: true,
                  underline: const SizedBox(),
                  dropdownColor: colors.bgElevated,
                  iconSize: 14,
                  iconEnabledColor: colors.textMuted,
                  items: items,
                  onChanged: (v) {
                    ref.read(activeEnvironmentProvider.notifier).state = v;
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalSplit extends ConsumerStatefulWidget {
  final RequestTab tab;
  const _VerticalSplit({required this.tab});

  @override
  ConsumerState<_VerticalSplit> createState() => _VerticalSplitState();
}

class _VerticalSplitState extends ConsumerState<_VerticalSplit> {
  double _splitRatio = 0.48;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalH = constraints.maxHeight;
        const dragHandleHeight = 5.0;
        final availableH =
            (totalH - dragHandleHeight).clamp(0.0, double.infinity);

        final topH = availableH * _splitRatio;

        return Column(
          children: [
            // Top section: Request Editor
            SizedBox(
              height: topH,
              child: RequestEditor(tab: widget.tab),
            ),
            // Drag handle (vertical)
            GestureDetector(
              onVerticalDragUpdate: (details) {
                setState(() {
                  _splitRatio = (_splitRatio + details.delta.dy / availableH)
                      .clamp(0.2, 0.8);
                });
              },
              child: Container(
                height: dragHandleHeight,
                color: context.colors.border,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 3,
                    decoration: BoxDecoration(
                      color: context.colors.textMuted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
            // Bottom section: Response Panel (full width)
            Expanded(
              child: ResponsePanel(tab: widget.tab),
            ),
          ],
        );
      },
    );
  }
}
