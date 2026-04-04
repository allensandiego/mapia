import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/collection_provider.dart';
import '../../providers/tabs_provider.dart';
import '../../providers/environment_provider.dart';
import '../../../core/theme/mapia_colors.dart';
import '../../../core/widgets/method_badge.dart';
import '../../../core/widgets/key_value_editor.dart';
import '../../../domain/entities/collection.dart';
import '../../../domain/entities/folder.dart';
import '../../../domain/entities/api_request.dart';
import '../../../domain/entities/variable.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/file_utils.dart';

class _DragData {
  final String type; // 'request' or 'folder'
  final String id;
  final String fromCollectionId;
  final String? fromFolderId;

  _DragData({
    required this.type,
    required this.id,
    required this.fromCollectionId,
    this.fromFolderId,
  });
}

class CollectionTree extends ConsumerWidget {
  const CollectionTree({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider);
    return collectionsAsync.when(
      loading: () => Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: context.colors.accent)),
      error: (e, _) => Center(
          child: Text('Error: $e',
              style: TextStyle(color: context.colors.error, fontSize: 12))),
      data: (collections) {
        if (collections.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No collections yet.\nCreate one to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: context.colors.textMuted, fontSize: 12, height: 1.5),
              ),
            ),
          );
        }
        return ReorderableListView.builder(
          itemCount: collections.length,
          itemBuilder: (ctx, i) =>
              _CollectionItem(key: ValueKey(collections[i].id), collection: collections[i]),
          onReorder: (oldIndex, newIndex) {
            ref
                .read(collectionsProvider.notifier)
                .reorderCollections(oldIndex, newIndex);
          },
        );
      },
    );
  }
}

class _CollectionItem extends ConsumerStatefulWidget {
  final Collection collection;
  const _CollectionItem({super.key, required this.collection});

  @override
  ConsumerState<_CollectionItem> createState() => _CollectionItemState();
}

class _CollectionItemState extends ConsumerState<_CollectionItem> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final col = widget.collection;
    return Column(
      key: widget.key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Collection header
        DragTarget<_DragData>(
          onWillAcceptWithDetails: (details) {
            if (details.data.type == 'request') {
              return details.data.fromFolderId != null ||
                  details.data.fromCollectionId != col.id;
            }
            if (details.data.type == 'folder') {
              return details.data.fromCollectionId != col.id;
            }
            return false;
          },
          onAcceptWithDetails: (details) {
            final data = details.data;
            if (data.type == 'request') {
              ref.read(collectionsProvider.notifier).moveRequest(
                    data.id,
                    fromCollectionId: data.fromCollectionId,
                    fromFolderId: data.fromFolderId,
                    toCollectionId: col.id,
                    toFolderId: null,
                  );
            } else if (data.type == 'folder') {
              ref.read(collectionsProvider.notifier).moveFolder(
                    data.id,
                    fromCollectionId: data.fromCollectionId,
                    toCollectionId: col.id,
                  );
            }
          },
          builder: (context, candidateData, rejectedData) {
            final isHighlighted = candidateData.isNotEmpty;
            return InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              onSecondaryTap: () => _showContextMenu(context, col),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? context.colors.accent.withValues(alpha: 0.1)
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      size: 14,
                      color: context.colors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.folder_outlined,
                        size: 14, color: context.colors.warning),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        col.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: context.colors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => _addRequest(context, col),
                      borderRadius: BorderRadius.circular(3),
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: Icon(Icons.add,
                            size: 13, color: context.colors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // Children
        if (_expanded) ...[
          // Root requests
          Column(
            children: col.requests
                .map((r) => _RequestItem(
                      key: ValueKey(r.id),
                      request: r,
                      collectionId: col.id,
                      indent: 24,
                    ))
                .toList(),
          ),
          // Folders
          Column(
            children: col.folders
                .map((f) => _FolderItem(
                      key: ValueKey(f.id),
                      folder: f,
                      collectionId: col.id,
                    ))
                .toList(),
          ),
        ],
        const Divider(height: 1, indent: 8),
      ],
    );
  }

  Future<void> _addFolder(BuildContext context, Collection col) async {
    final name = await _showRenameDialog(context, 'New Folder', '');
    if (name == null || name.trim().isEmpty) return;
    final folder = Folder(id: const Uuid().v4(), name: name.trim());
    final updated = col.copyWith(folders: [...col.folders, folder]);
    ref.read(collectionsProvider.notifier).updateCollection(updated);
  }

  void _duplicateCollection(Collection col) {
    final copy = col.copyWith(
      id: const Uuid().v4(),
      name: '${col.name} (Copy)',
      requests:
          col.requests.map((r) => r.copyWith(id: const Uuid().v4())).toList(),
      folders: col.folders
          .map((f) => f.copyWith(
                id: const Uuid().v4(),
                requests: f.requests
                    .map((r) => r.copyWith(id: const Uuid().v4()))
                    .toList(),
              ))
          .toList(),
    );
    ref.read(collectionsProvider.notifier).addCollection(copy);
  }

  Future<void> _addRequest(BuildContext context, Collection col) async {
    ref.read(tabsProvider.notifier).openNewTab();
  }

  void _showContextMenu(BuildContext context, Collection col) {
    showMenu<void>(
      context: context,
      position: _getTapPosition(context),
      items: [
        PopupMenuItem(
          child: const ListTile(
            dense: true,
            leading: Icon(Icons.add, size: 16),
            title: Text('Add Request'),
          ),
          onTap: () => _addRequest(context, col),
        ),
        PopupMenuItem(
          child: const ListTile(
            dense: true,
            leading: Icon(Icons.create_new_folder_outlined, size: 16),
            title: Text('Add Folder'),
          ),
          onTap: () => _addFolder(context, col),
        ),
        PopupMenuItem(
          child: const ListTile(
            dense: true,
            leading: Icon(Icons.settings_outlined, size: 16),
            title: Text('Settings'),
          ),
          onTap: () => _showSettings(context, col),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          child: const ListTile(
            dense: true,
            leading: Icon(Icons.drive_file_rename_outline, size: 16),
            title: Text('Rename'),
          ),
          onTap: () => _renameCollection(context, col),
        ),
        PopupMenuItem(
          child: const ListTile(
            dense: true,
            leading: Icon(Icons.copy_outlined, size: 16),
            title: Text('Duplicate'),
          ),
          onTap: () => _duplicateCollection(col),
        ),
        PopupMenuItem(
          child: const ListTile(
            dense: true,
            leading: Icon(Icons.file_download_outlined, size: 16),
            title: Text('Export'),
          ),
          onTap: () => _exportCollection(context, col),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          child: ListTile(
            dense: true,
            leading: Icon(Icons.delete_outline,
                size: 16, color: context.colors.error),
            title:
                Text('Delete', style: TextStyle(color: context.colors.error)),
          ),
          onTap: () =>
              ref.read(collectionsProvider.notifier).deleteCollection(col.id),
        ),
      ],
    );
  }

  RelativeRect _getTapPosition(BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final pos = box.localToGlobal(Offset.zero);
    return RelativeRect.fromLTRB(pos.dx, pos.dy, pos.dx + 200, pos.dy + 100);
  }

  Future<void> _renameCollection(BuildContext context, Collection col) async {
    final name =
        await _showRenameDialog(context, 'Rename Collection', col.name);
    if (name != null) {
      ref.read(collectionsProvider.notifier).renameCollection(col.id, name);
    }
  }

  void _showSettings(BuildContext context, Collection col) {
    showDialog(
      context: context,
      builder: (ctx) => _CollectionSettingsDialog(collection: col),
    );
  }

  Future<void> _exportCollection(BuildContext context, Collection col) async {
    try {
      final json =
          await ref.read(collectionsProvider.notifier).exportCollection(col.id);
      await FileUtils.downloadFile('${col.name}.json', json);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Collection exported successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export: $e')),
        );
      }
    }
  }

  Future<String?> _showRenameDialog(
      BuildContext context, String title, String current) {
    final ctrl = TextEditingController(text: current);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgElevated,
        title: Text(title,
            style: TextStyle(fontSize: 16, color: context.colors.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          onSubmitted: (v) => Navigator.pop(ctx, v),
          decoration: InputDecoration(
            hintText: 'Enter name',
            hintStyle: TextStyle(color: context.colors.textDisabled),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Save')),
        ],
      ),
    );
  }
}

class _FolderItem extends ConsumerStatefulWidget {
  final Folder folder;
  final String collectionId;

  const _FolderItem({super.key, required this.folder, required this.collectionId});

  @override
  ConsumerState<_FolderItem> createState() => _FolderItemState();
}

class _FolderItemState extends ConsumerState<_FolderItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: widget.key,
      children: [
        DragTarget<_DragData>(
          onWillAcceptWithDetails: (details) {
            if (details.data.id == widget.folder.id) return false;
            if (details.data.type == 'request') {
              return details.data.fromFolderId != widget.folder.id;
            }
            if (details.data.type == 'folder') {
              return details.data.fromCollectionId == widget.collectionId;
            }
            return false;
          },
          onAcceptWithDetails: (details) {
            final data = details.data;
            if (data.type == 'request') {
              ref.read(collectionsProvider.notifier).moveRequest(
                    data.id,
                    fromCollectionId: data.fromCollectionId,
                    fromFolderId: data.fromFolderId,
                    toCollectionId: widget.collectionId,
                    toFolderId: widget.folder.id,
                  );
            } else if (data.type == 'folder') {
              // Reorder folders
              final cols = ref.read(collectionsProvider).value ?? [];
              final col =
                  cols.where((c) => c.id == widget.collectionId).firstOrNull;
              if (col == null) return;
              final oldIndex =
                  col.folders.indexWhere((f) => f.id == data.id);
              final newIndex =
                  col.folders.indexWhere((f) => f.id == widget.folder.id);
              if (oldIndex >= 0 && newIndex >= 0) {
                ref
                    .read(collectionsProvider.notifier)
                    .reorderFolders(widget.collectionId, oldIndex, newIndex);
              }
            }
          },
          builder: (context, candidateData, rejectedData) {
            final isHighlighted = candidateData.isNotEmpty;
            final itemContent = InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              onSecondaryTap: () => _showContextMenu(context),
              child: Container(
                padding:
                    const EdgeInsets.only(left: 24, right: 8, top: 5, bottom: 5),
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? context.colors.accent.withValues(alpha: 0.1)
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      size: 12,
                      color: context.colors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.folder_outlined,
                        size: 13, color: context.colors.accent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.folder.name,
                        style: TextStyle(
                            fontSize: 12, color: context.colors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );

            return Draggable<_DragData>(
              data: _DragData(
                type: 'folder',
                id: widget.folder.id,
                fromCollectionId: widget.collectionId,
              ),
              feedback: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colors.bgElevated,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_outlined,
                          size: 13, color: context.colors.accent),
                      const SizedBox(width: 6),
                      Text(
                        widget.folder.name,
                        style: TextStyle(
                            fontSize: 12, color: context.colors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.4,
                child: itemContent,
              ),
              child: itemContent,
            );
          },
        ),
        if (_expanded)
          Column(
            children: widget.folder.requests
                .map((r) => _RequestItem(
                      key: ValueKey(r.id),
                      request: r,
                      collectionId: widget.collectionId,
                      folderId: widget.folder.id,
                      indent: 40,
                    ))
                .toList(),
          ),
      ],
    );
  }

  void _showContextMenu(BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final pos = box.localToGlobal(Offset.zero);
    final rect =
        RelativeRect.fromLTRB(pos.dx, pos.dy, pos.dx + 200, pos.dy + 100);
    showMenu(
      context: context,
      position: rect,
      items: [
        PopupMenuItem(
          child: const ListTile(
              dense: true,
              leading: Icon(Icons.drive_file_rename_outline, size: 16),
              title: Text('Rename')),
          onTap: () => _rename(context),
        ),
        PopupMenuItem(
          child: ListTile(
              dense: true,
              leading: Icon(Icons.delete_outline,
                  size: 16, color: context.colors.error),
              title: Text('Delete',
                  style: TextStyle(color: context.colors.error))),
          onTap: () => _delete(),
        ),
      ],
    );
  }

  Future<void> _rename(BuildContext context) async {
    final ctrl = TextEditingController(text: widget.folder.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgElevated,
        title: Text('Rename Folder',
            style: TextStyle(fontSize: 16, color: context.colors.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          onSubmitted: (v) => Navigator.pop(ctx, v),
          decoration: const InputDecoration(hintText: 'Enter name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Save')),
        ],
      ),
    );
    if (newName != null && newName.trim().isNotEmpty) {
      final cols = ref.read(collectionsProvider).value ?? [];
      final col = cols.where((c) => c.id == widget.collectionId).firstOrNull;
      if (col == null) return;
      final updated = col.copyWith(
        folders: col.folders
            .map((f) =>
                f.id == widget.folder.id ? f.copyWith(name: newName.trim()) : f)
            .toList(),
      );
      ref.read(collectionsProvider.notifier).updateCollection(updated);
    }
  }

  void _delete() {
    final cols = ref.read(collectionsProvider).value ?? [];
    final col = cols.where((c) => c.id == widget.collectionId).firstOrNull;
    if (col == null) return;
    final updated = col.copyWith(
      folders: col.folders.where((f) => f.id != widget.folder.id).toList(),
    );
    ref.read(collectionsProvider.notifier).updateCollection(updated);
  }
}

class _RequestItem extends ConsumerWidget {
  final ApiRequest request;
  final String collectionId;
  final String? folderId;
  final double indent;

  const _RequestItem({
    super.key,
    required this.request,
    required this.collectionId,
    this.folderId,
    required this.indent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(activeTabProvider);
    final isActive = activeTab?.request.id == request.id;

    final itemContent = Container(
      padding: EdgeInsets.only(left: indent, right: 8, top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: isActive
            ? context.colors.accent.withValues(alpha: 0.1)
            : Colors.transparent,
        border: isActive
            ? Border(left: BorderSide(color: context.colors.accent, width: 2))
            : null,
      ),
      child: Row(
        children: [
          MethodBadge(method: request.method, fontSize: 9),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              request.name,
              style: TextStyle(
                fontSize: 12,
                color: isActive
                    ? context.colors.textPrimary
                    : context.colors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    return DragTarget<_DragData>(
      onWillAcceptWithDetails: (details) =>
          details.data.type == 'request' && details.data.id != request.id,
      onAcceptWithDetails: (details) {
        final data = details.data;
        if (data.type == 'request') {
          // Find current index of this item
          final cols = ref.read(collectionsProvider).value ?? [];
          final col = cols.where((c) => c.id == collectionId).firstOrNull;
          if (col == null) return;
          
          int? index;
          if (folderId != null) {
            final f = col.folders.where((f) => f.id == folderId).firstOrNull;
            index = f?.requests.indexWhere((r) => r.id == request.id);
          } else {
            index = col.requests.indexWhere((r) => r.id == request.id);
          }

          ref.read(collectionsProvider.notifier).moveRequest(
                data.id,
                fromCollectionId: data.fromCollectionId,
                fromFolderId: data.fromFolderId,
                toCollectionId: collectionId,
                toFolderId: folderId,
                toIndex: index,
              );
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        return Draggable<_DragData>(
          data: _DragData(
            type: 'request',
            id: request.id,
            fromCollectionId: collectionId,
            fromFolderId: folderId,
          ),
          feedback: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.bgElevated,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MethodBadge(method: request.method, fontSize: 9),
                  const SizedBox(width: 6),
                  Text(
                    request.name,
                    style: TextStyle(
                        fontSize: 12, color: context.colors.textPrimary),
                  ),
                ],
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.4,
            child: itemContent,
          ),
          child: InkWell(
            onTap: () {
              final tabsNotifier = ref.read(tabsProvider.notifier);
              // Check if already open
              final tabs = ref.read(tabsProvider);
              final existing =
                  tabs.where((t) => t.request.id == request.id).firstOrNull;
              if (existing != null) {
                tabsNotifier.activateTab(existing.id);
              } else {
                tabsNotifier.openNewTab(
                  request: request,
                  collectionId: collectionId,
                  folderId: folderId,
                );
              }
            },
            onSecondaryTap: () => _showContextMenu(context, ref),
            child: Container(
              decoration: BoxDecoration(
                border: isHighlighted
                    ? Border(
                        bottom: BorderSide(
                            color: context.colors.accent, width: 2))
                    : null,
              ),
              child: itemContent,
            ),
          ),
        );
      },
    );
  }

  void _showContextMenu(BuildContext context, WidgetRef ref) {
    final box = context.findRenderObject() as RenderBox;
    final pos = box.localToGlobal(Offset.zero);
    final rect =
        RelativeRect.fromLTRB(pos.dx, pos.dy, pos.dx + 200, pos.dy + 100);

    showMenu<void>(
      context: context,
      position: rect,
      items: [
        PopupMenuItem<void>(
          child: const ListTile(
              dense: true,
              leading: Icon(Icons.drive_file_rename_outline, size: 16),
              title: Text('Rename')),
          onTap: () => _rename(context, ref),
        ),
        PopupMenuItem<void>(
          child: const ListTile(
              dense: true,
              leading: Icon(Icons.copy_outlined, size: 16),
              title: Text('Duplicate')),
          onTap: () => _duplicate(ref),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<void>(
          child: ListTile(
              dense: true,
              leading: Icon(Icons.delete_outline,
                  size: 16, color: context.colors.error),
              title: Text('Delete',
                  style: TextStyle(color: context.colors.error))),
          onTap: () => ref
              .read(collectionsProvider.notifier)
              .deleteRequest(collectionId, folderId, request.id),
        ),
      ],
    );
  }

  void _duplicate(WidgetRef ref) {
    final copy =
        request.copyWith(id: const Uuid().v4(), name: '${request.name} (Copy)');
    ref
        .read(collectionsProvider.notifier)
        .saveRequest(collectionId, folderId, copy);
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController(text: request.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgSurface,
        title: Text('Rename Request',
            style: TextStyle(fontSize: 16, color: context.colors.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Save')),
        ],
      ),
    );

    if (newName != null && newName.trim().isNotEmpty) {
      ref
          .read(collectionsProvider.notifier)
          .renameRequest(collectionId, folderId, request.id, newName.trim());
      // Also update open tabs
      final tabsNotifier = ref.read(tabsProvider.notifier);
      final tabs = ref.read(tabsProvider);
      final openTab = tabs.where((t) => t.request.id == request.id).firstOrNull;
      if (openTab != null) {
        tabsNotifier.updateRequest(
            openTab.id, openTab.request.copyWith(name: newName.trim()));
      }
    }
  }
}

class _CollectionSettingsDialog extends ConsumerStatefulWidget {
  final Collection collection;
  const _CollectionSettingsDialog({required this.collection});

  @override
  ConsumerState<_CollectionSettingsDialog> createState() =>
      _CollectionSettingsDialogState();
}

class _CollectionSettingsDialogState
    extends ConsumerState<_CollectionSettingsDialog>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late List<Variable> _vars;
  late TabController _tabCtrl;
  String? _envId;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.collection.name);
    _descCtrl = TextEditingController(text: widget.collection.description);
    _vars = List.from(widget.collection.variables);
    _tabCtrl = TabController(length: 2, vsync: this);
    _envId = widget.collection.environmentId;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colors.bgElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: context.colors.border),
      ),
      child: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.settings_outlined,
                      size: 18, color: context.colors.textSecondary),
                  const SizedBox(width: 12),
                  Text('Collection Settings',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 18),
                    color: context.colors.textMuted,
                  ),
                ],
              ),
            ),
            // Tabs
            TabBar(
              controller: _tabCtrl,
              labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textPrimary),
              labelColor: context.colors.accent,
              unselectedLabelColor: context.colors.textSecondary,
              tabs: const [
                Tab(text: 'General'),
                Tab(text: 'Variables'),
              ],
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  // General
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: context.colors.textSecondary)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _nameCtrl,
                            decoration: InputDecoration(
                              hintText: 'Collection Name',
                              hintStyle:
                                  TextStyle(color: context.colors.textDisabled),
                              border: const OutlineInputBorder(),
                            ),
                            style: TextStyle(color: context.colors.textPrimary),
                          ),
                          const SizedBox(height: 24),
                          Text('Description',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: context.colors.textSecondary)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _descCtrl,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Optional description...',
                              hintStyle:
                                  TextStyle(color: context.colors.textDisabled),
                              border: const OutlineInputBorder(),
                            ),
                            style: TextStyle(color: context.colors.textPrimary),
                          ),
                          const SizedBox(height: 24),
                          Text('Linked Environment',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: context.colors.textSecondary)),
                          const SizedBox(height: 8),
                          Consumer(
                            builder: (context, ref, child) {
                              final envsAsync = ref.watch(environmentsProvider);
                              return envsAsync.when(
                                data: (envs) {
                                  final items = [
                                    DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text('No Environment (Use Active)',
                                          style: TextStyle(
                                              color: context.colors.textMuted)),
                                    ),
                                    ...envs
                                        .map((e) => DropdownMenuItem<String?>(
                                              value: e.id,
                                              child: Text(e.name),
                                            )),
                                  ];
                                  return DropdownButtonFormField<String?>(
                                    initialValue: _envId,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 0),
                                    ),
                                    style: TextStyle(
                                        color: context.colors.textPrimary),
                                    dropdownColor: context.colors.bgElevated,
                                    items: items,
                                    onChanged: (v) =>
                                        setState(() => _envId = v),
                                  );
                                },
                                loading: () =>
                                    const CircularProgressIndicator(),
                                error: (_, __) =>
                                    const Text('Error loading environments'),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Variables
                  SingleChildScrollView(
                    child: KeyValueEditor(
                      items: _vars,
                      keyHint: 'Variable',
                      valueHint: 'Value',
                      showSecretToggle: true,
                      onChanged: (v) => setState(() => _vars = v),
                    ),
                  ),
                ],
              ),
            ),
            // Footer
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final updated = widget.collection.copyWith(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      environmentId: _envId,
      variables: _vars,
    );
    ref.read(collectionsProvider.notifier).updateCollection(updated);
    Navigator.pop(context);
  }
}
