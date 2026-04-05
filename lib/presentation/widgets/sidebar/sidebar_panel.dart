import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../../providers/collection_provider.dart';
import '../../providers/ui_provider.dart';
import 'collection_tree.dart';
import 'history_panel.dart';
import 'environment_selector.dart';
import '../../../core/theme/mapia_colors.dart';
import '../../../domain/entities/collection.dart';
import 'package:uuid/uuid.dart';
import '../../screens/settings_screen.dart';
import '../../screens/about_screen.dart';

enum _SidebarTab { collections, history }

class SidebarPanel extends ConsumerStatefulWidget {
  const SidebarPanel({super.key});

  @override
  ConsumerState<SidebarPanel> createState() => _SidebarPanelState();
}

class _SidebarPanelState extends ConsumerState<SidebarPanel> {
  _SidebarTab _tab = _SidebarTab.collections;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ref.watch(sidebarWidthProvider),
      decoration: BoxDecoration(
        color: context.colors.sidebarBg,
        border:
            Border(right: BorderSide(color: context.colors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          // Left Rail Navigation
          Container(
            width: 44, // Slightly slimmer rail
            decoration: BoxDecoration(
              color: context.colors.sidebarRail,
              border: Border(
                  right: BorderSide(color: context.colors.border, width: 0.5)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                _RailBtn(
                  icon: Icons.folder_copy_outlined,
                  activeIcon: Icons.folder_copy,
                  active: _tab == _SidebarTab.collections,
                  onTap: () => setState(() => _tab = _SidebarTab.collections),
                  tooltip: 'Collections',
                ),
                _RailBtn(
                  icon: Icons.history_outlined,
                  activeIcon: Icons.history,
                  active: _tab == _SidebarTab.history,
                  onTap: () => setState(() => _tab = _SidebarTab.history),
                  tooltip: 'History',
                ),
                const Spacer(),
                const EnvironmentSelector(isCompact: true),
                const SizedBox(height: 4),
                Tooltip(
                  message: 'Settings',
                  child: InkWell(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => const SettingsScreen(),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Icon(
                        Icons.settings_outlined,
                        size: 18,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ),
                ),
                Tooltip(
                  message: 'About',
                  child: InkWell(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => const AboutScreen(),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Icon(
                        Icons.info_outline,
                        size: 18,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          // Content Area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (48px to match request tabs)
                Container(
                  height: 48,
                  padding: const EdgeInsets.fromLTRB(14, 0, 12, 0),
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: context.colors.border, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          (_tab == _SidebarTab.collections
                              ? 'COLLECTIONS'
                              : 'HISTORY'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: context.colors.textSecondary,
                            letterSpacing: 0.8,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      if (_tab == _SidebarTab.collections)
                        _ActionButton(
                          icon: Icons.add,
                          onTap: () => _newCollection(ref),
                          tooltip: 'New Collection',
                        ),
                      if (_tab == _SidebarTab.collections) ...[
                        const SizedBox(width: 8),
                        _ActionButton(
                          icon: Icons.file_upload_outlined,
                          onTap: () => _importCollections(ref),
                          tooltip: 'Import Collection',
                        ),
                      ],
                    ],
                  ),
                ),
                // Search Placeholder / List
                Expanded(
                  child: _tab == _SidebarTab.collections
                      ? const CollectionTree()
                      : const HistoryPanel(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _newCollection(WidgetRef ref) async {
    final name = await _showNameDialog(context, 'New Collection', '');
    if (name == null || name.trim().isEmpty) return;
    final col = Collection(
      id: const Uuid().v4(),
      name: name.trim(),
    );
    await ref.read(collectionsProvider.notifier).addCollection(col);
  }

  Future<String?> _showNameDialog(
      BuildContext context, String title, String initial) {
    final ctrl = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgElevated,
        title: Text(title,
            style: TextStyle(color: context.colors.textPrimary, fontSize: 15)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          onSubmitted: (v) => Navigator.pop(ctx, v),
          decoration: const InputDecoration(hintText: 'Name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Create')),
        ],
      ),
    );
  }

  Future<void> _importCollections(WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true, // Required for web
      );

      if (result != null && result.files.single.bytes != null) {
        final json = utf8.decode(result.files.single.bytes!);
        await ref.read(collectionsProvider.notifier).importCollection(json);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Collection imported successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to import: $e')),
        );
      }
    }
  }
}

class _RailBtn extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool active;
  final VoidCallback onTap;
  final String tooltip;

  const _RailBtn({
    required this.icon,
    required this.activeIcon,
    required this.active,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: active
                ? context.colors.accent.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            active ? activeIcon : icon,
            size: 20,
            color:
                active ? context.colors.accent : context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _ActionButton(
      {required this.icon, required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: context.colors.border, width: 0.5),
            ),
            child: Icon(icon, size: 16, color: context.colors.textSecondary),
          ),
        ),
      ),
    );
  }
}
