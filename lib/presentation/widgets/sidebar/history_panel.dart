import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/history_provider.dart';
import '../../providers/tabs_provider.dart';
import '../../../core/theme/mapia_colors.dart';
import '../../../core/widgets/method_badge.dart';
import '../../../core/constants/http_constants.dart';
import '../../../domain/entities/history_entry.dart';

class HistoryPanel extends ConsumerStatefulWidget {
  const HistoryPanel({super.key});

  @override
  ConsumerState<HistoryPanel> createState() => _HistoryPanelState();
}

class _HistoryPanelState extends ConsumerState<HistoryPanel> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  HttpMethod? _methodFilter; // null = ALL
  int? _statusFilter; // null = ALL, 2/3/4/5 = 2xx/3xx/4xx/5xx

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<HistoryEntry> _applyFilters(List<HistoryEntry> entries) {
    return entries.where((e) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final url = e.request.url.toLowerCase();
        final name = e.request.name.toLowerCase();
        if (!url.contains(_searchQuery) && !name.contains(_searchQuery)) {
          return false;
        }
      }
      // Method filter
      if (_methodFilter != null && e.request.method != _methodFilter) {
        return false;
      }
      // Status filter
      if (_statusFilter != null) {
        final code = e.response.statusCode;
        final bin = code ~/ 100;
        if (bin != _statusFilter) return false;
      }
      return true;
    }).toList();
  }

  Color _getMethodColor(HttpMethod method) {
    final colors = context.colors;
    switch (method) {
      case HttpMethod.get: return colors.methodGet;
      case HttpMethod.post: return colors.methodPost;
      case HttpMethod.put: return colors.methodPut;
      case HttpMethod.patch: return colors.methodPatch;
      case HttpMethod.delete: return colors.methodDelete;
      case HttpMethod.head: return colors.methodHead;
      case HttpMethod.options: return colors.methodOptions;
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyProvider);
    return historyAsync.when(
      loading: () => Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: context.colors.accent)),
      error: (e, _) => Center(
          child: Text('Error: $e',
              style: TextStyle(color: context.colors.error, fontSize: 12))),
      data: (entries) {
        final filtered = _applyFilters(entries);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Search + Clear ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 30,
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) =>
                            setState(() => _searchQuery = v.toLowerCase()),
                        style: TextStyle(fontSize: 12, color: context.colors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search history…',
                          hintStyle: TextStyle(
                              fontSize: 12, color: context.colors.textMuted),
                          prefixIcon: Icon(Icons.search,
                              size: 14, color: context.colors.textMuted),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? InkWell(
                                  onTap: () {
                                    _searchCtrl.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                  child: Icon(Icons.close,
                                      size: 12, color: context.colors.textMuted),
                                )
                              : null,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide:
                                BorderSide(color: context.colors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide:
                                BorderSide(color: context.colors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide:
                                BorderSide(color: context.colors.accent),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Clear all history
                  Tooltip(
                    message: 'Clear all history',
                    child: InkWell(
                      onTap: entries.isEmpty
                          ? null
                          : () => _confirmClear(context),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_sweep_outlined,
                          size: 16,
                          color: entries.isEmpty
                              ? context.colors.textMuted.withValues(alpha: 0.4)
                              : context.colors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Method filter chips ─────────────────────────────────────
            _FilterRow(
              children: [
                _MethodChip(
                  label: 'ALL',
                  selected: _methodFilter == null,
                  onTap: () => setState(() => _methodFilter = null),
                ),
                ...HttpMethod.values.map((m) => _MethodChip(
                      label: m.label,
                      color: _getMethodColor(m),
                      selected: _methodFilter == m,
                      onTap: () => setState(() =>
                          _methodFilter = _methodFilter == m ? null : m),
                    )),
              ],
            ),

            // ── Status filter chips ─────────────────────────────────────
            _FilterRow(
              children: [
                _StatusChip(
                  label: 'ALL',
                  selected: _statusFilter == null,
                  onTap: () => setState(() => _statusFilter = null),
                ),
                _StatusChip(
                  label: '2xx',
                  color: context.colors.success,
                  selected: _statusFilter == 2,
                  onTap: () => setState(
                      () => _statusFilter = _statusFilter == 2 ? null : 2),
                ),
                _StatusChip(
                  label: '3xx',
                  color: context.colors.warning,
                  selected: _statusFilter == 3,
                  onTap: () => setState(
                      () => _statusFilter = _statusFilter == 3 ? null : 3),
                ),
                _StatusChip(
                  label: '4xx',
                  color: context.colors.error,
                  selected: _statusFilter == 4,
                  onTap: () => setState(
                      () => _statusFilter = _statusFilter == 4 ? null : 4),
                ),
                _StatusChip(
                  label: '5xx',
                  color: Colors.deepOrange,
                  selected: _statusFilter == 5,
                  onTap: () => setState(
                      () => _statusFilter = _statusFilter == 5 ? null : 5),
                ),
              ],
            ),

            const Divider(height: 1),

            // ── Results ─────────────────────────────────────────────────
            if (filtered.isEmpty)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      entries.isEmpty
                          ? 'No history yet.\nSend a request to see it here.'
                          : 'No results match your filters.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: context.colors.textMuted,
                          fontSize: 12,
                          height: 1.5),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) => _HistoryRow(entry: filtered[i]),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgElevated,
        title: Text('Clear History', style: TextStyle(fontSize: 15, color: context.colors.textPrimary)),
        content: Text('Remove all history entries?',
            style: TextStyle(fontSize: 13, color: context.colors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: context.colors.error),
              child: const Text('Clear All')),
        ],
      ),
    );
    if (confirm == true) {
      ref.read(historyProvider.notifier).clear();
    }
  }
}

// ─── History Row ──────────────────────────────────────────────────────────────

class _HistoryRow extends ConsumerWidget {
  final HistoryEntry entry;
  const _HistoryRow({required this.entry});

  Color _getStatusColor(BuildContext context, int statusCode) {
    final colors = context.colors;
    if (statusCode >= 200 && statusCode < 300) return colors.success;
    if (statusCode >= 300 && statusCode < 400) return colors.accent;
    if (statusCode >= 400 && statusCode < 500) return colors.warning;
    return colors.error;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _getStatusColor(context, entry.response.statusCode);
    return InkWell(
      onTap: () =>
          ref.read(tabsProvider.notifier).openNewTab(request: entry.request),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: context.colors.border, width: 0.5)),
        ),
        child: Row(
          children: [
            MethodBadge(method: entry.request.method, fontSize: 9),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.request.url.isEmpty
                        ? entry.request.name
                        : entry.request.url,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11, color: context.colors.textSecondary),
                  ),
                  Text(
                    _timeAgo(entry.timestamp),
                    style: TextStyle(
                        fontSize: 10, color: context.colors.textMuted),
                  ),
                ],
              ),
            ),
            Text(
              '${entry.response.statusCode}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ─── Filter Row ───────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final List<Widget> children;
  const _FilterRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Row(
        children: children
            .expand((w) => [w, const SizedBox(width: 4)])
            .toList()
          ..removeLast(),
      ),
    );
  }
}

// ─── Method Chip ──────────────────────────────────────────────────────────────

class _MethodChip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  const _MethodChip({
    required this.label,
    this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = color ?? context.colors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: selected ? fg.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(
            color: selected ? fg : context.colors.border,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? fg : context.colors.textMuted,
          ),
        ),
      ),
    );
  }
}

// ─── Status Chip ──────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = color ?? context.colors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: selected ? fg.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(
            color: selected ? fg : context.colors.border,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? fg : context.colors.textMuted,
          ),
        ),
      ),
    );
  }
}
