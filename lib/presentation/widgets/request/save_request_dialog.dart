import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/collection_provider.dart';
import '../../providers/tabs_provider.dart';
import '../../../core/theme/mapia_colors.dart';

class SaveRequestDialog extends ConsumerStatefulWidget {
  final RequestTab tab;
  const SaveRequestDialog({super.key, required this.tab});

  @override
  ConsumerState<SaveRequestDialog> createState() => _SaveRequestDialogState();
}

class _SaveRequestDialogState extends ConsumerState<SaveRequestDialog> {
  late TextEditingController _nameCtrl;
  String? _selectedCollectionId;
  String? _selectedFolderId;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.tab.request.name);
    _selectedCollectionId = widget.tab.collectionId;
    _selectedFolderId = widget.tab.folderId;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colsAsync = ref.watch(collectionsProvider);

    return Dialog(
      backgroundColor: context.colors.bgElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: context.colors.border),
      ),
      child: SizedBox(
        width: 400,
        child: colsAsync.when(
          loading: () => SizedBox(
            height: 100,
            child: Center(
                child: CircularProgressIndicator(
                    color: context.colors.accent, strokeWidth: 2)),
          ),
          error: (e, _) => SizedBox(
            height: 100,
            child: Center(
                child: Text('Error: $e',
                    style: TextStyle(color: context.colors.error))),
          ),
          data: (cols) {
            if (cols.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                    'Please create a collection first from the sidebar.',
                    style: TextStyle(color: context.colors.textPrimary)),
              );
            }

            if (_selectedCollectionId == null ||
                !cols.any((c) => c.id == _selectedCollectionId)) {
              _selectedCollectionId = cols.first.id;
            }

            final activeCol =
                cols.firstWhere((c) => c.id == _selectedCollectionId);
            final folders = activeCol.folders;
            if (_selectedFolderId != null &&
                !folders.any((f) => f.id == _selectedFolderId)) {
              _selectedFolderId = null;
            }

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Save Request',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary)),
                  const SizedBox(height: 24),
                  Text('Request Name',
                      style: TextStyle(
                          fontSize: 12, color: context.colors.textSecondary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameCtrl,
                    style: TextStyle(
                        fontSize: 14, color: context.colors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'My Awesome Request',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Collection',
                      style: TextStyle(
                          fontSize: 12, color: context.colors.textSecondary)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCollectionId,
                    dropdownColor: context.colors.bgElevated,
                    isExpanded: true,
                    style: TextStyle(
                        fontSize: 14, color: context.colors.textPrimary),
                    items: cols
                        .map((c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedCollectionId = v;
                        _selectedFolderId = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Folder (Optional)',
                      style: TextStyle(
                          fontSize: 12, color: context.colors.textSecondary)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    initialValue: _selectedFolderId,
                    dropdownColor: context.colors.bgElevated,
                    isExpanded: true,
                    style: TextStyle(
                        fontSize: 14, color: context.colors.textPrimary),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('/',
                            style: TextStyle(color: context.colors.textMuted)),
                      ),
                      ...folders.map((f) => DropdownMenuItem(
                            value: f.id,
                            child: Text(f.name),
                          )),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _selectedFolderId = v;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => _handleSave(context, ref),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleSave(BuildContext context, WidgetRef ref) {
    if (_nameCtrl.text.trim().isEmpty) return;
    if (_selectedCollectionId == null) return;

    final request = widget.tab.request.copyWith(name: _nameCtrl.text.trim());
    ref.read(tabsProvider.notifier).updateRequest(widget.tab.id, request);

    ref.read(collectionsProvider.notifier).saveRequest(
          _selectedCollectionId!,
          _selectedFolderId,
          request,
        );

    ref.read(tabsProvider.notifier).markClean(
          widget.tab.id,
          collectionId: _selectedCollectionId,
          folderId: _selectedFolderId,
        );

    Navigator.pop(context);
  }
}
