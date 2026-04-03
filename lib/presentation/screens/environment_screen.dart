import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/environment_provider.dart';
import '../../../core/theme/mapia_colors.dart';
import '../../../core/widgets/key_value_editor.dart';
import '../../../domain/entities/environment.dart';
import '../../../domain/entities/variable.dart';
import 'package:uuid/uuid.dart';

class EnvironmentScreen extends ConsumerStatefulWidget {
  const EnvironmentScreen({super.key});

  @override
  ConsumerState<EnvironmentScreen> createState() => _EnvironmentScreenState();
}

class _EnvironmentScreenState extends ConsumerState<EnvironmentScreen> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final envsAsync = ref.watch(environmentsProvider);
    return Dialog(
      backgroundColor: context.colors.bgElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: context.colors.border),
      ),
      child: SizedBox(
        width: 720,
        height: 520,
        child: Column(
          children: [
            // Title bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: context.colors.border)),
              ),
              child: Row(
                children: [
                  Text('Environments',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 16),
                    color: context.colors.textMuted,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  ),
                ],
              ),
            ),
            Expanded(
              child: envsAsync.when(
                loading: () => Center(
                    child: CircularProgressIndicator(
                        color: context.colors.accent, strokeWidth: 2)),
                error: (e, _) => Center(child: Text('$e')),
                data: (envs) => Row(
                  children: [
                    // Left: env list
                    SizedBox(
                      width: 200,
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: envs.length,
                              itemBuilder: (ctx, i) {
                                final env = envs[i];
                                final isSelected = env.id == _selectedId;
                                return ListTile(
                                  selected: isSelected,
                                  title: Text(env.name,
                                      style: const TextStyle(fontSize: 13)),
                                  onTap: () =>
                                      setState(() => _selectedId = env.id),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        size: 14),
                                    onPressed: () {
                                      ref
                                          .read(environmentsProvider.notifier)
                                          .delete(env.id);
                                      if (_selectedId == env.id) {
                                        setState(() => _selectedId = null);
                                      }
                                    },
                                    color: context.colors.textMuted,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                        minWidth: 24, minHeight: 24),
                                  ),
                                );
                              },
                            ),
                          ),
                          const Divider(height: 1),
                          InkWell(
                            onTap: () => _addEnv(context),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Icon(Icons.add,
                                      size: 14, color: context.colors.accent),
                                  const SizedBox(width: 6),
                                  Text('Add Environment',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: context.colors.accent)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Vertical divider
                    Container(width: 1, color: context.colors.border),
                    // Right: variable editor
                    Expanded(
                      child: _selectedId == null
                          ? Center(
                              child: Text('Select an environment to edit',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: context.colors.textMuted)))
                          : _EnvironmentEditor(
                              key: ValueKey(_selectedId),
                              environment: envs
                                  .firstWhere((e) => e.id == _selectedId),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addEnv(BuildContext context) async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgElevated,
        title: Text('New Environment',
            style: TextStyle(color: context.colors.textPrimary, fontSize: 15)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          onSubmitted: (v) => Navigator.pop(ctx, v),
          decoration: const InputDecoration(hintText: 'Environment name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Create')),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    final env = Environment(id: const Uuid().v4(), name: name.trim());
    await ref.read(environmentsProvider.notifier).save(env);
    setState(() => _selectedId = env.id);
  }
}

class _EnvironmentEditor extends ConsumerStatefulWidget {
  final Environment environment;
  const _EnvironmentEditor({super.key, required this.environment});

  @override
  ConsumerState<_EnvironmentEditor> createState() => _EnvironmentEditorState();
}

class _EnvironmentEditorState extends ConsumerState<_EnvironmentEditor> {
  late List<Variable> _vars;

  @override
  void initState() {
    super.initState();
    _vars = List.from(widget.environment.variables);
  }

  Future<void> _rename(BuildContext context) async {
    final ctrl = TextEditingController(text: widget.environment.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgElevated,
        title: Text('Rename Environment',
            style: TextStyle(color: context.colors.textPrimary, fontSize: 15)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          onSubmitted: (v) => Navigator.pop(ctx, v),
          decoration: const InputDecoration(hintText: 'Environment name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Save')),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    ref.read(environmentsProvider.notifier).save(
          widget.environment.copyWith(name: name.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Text(widget.environment.name,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary)),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 14),
                onPressed: () => _rename(context),
                color: context.colors.textMuted,
                tooltip: 'Rename Environment',
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            child: KeyValueEditor(
              items: _vars,
              keyHint: 'Variable',
              valueHint: 'Value',
              showSecretToggle: true,
              onChanged: (vars) {
                setState(() => _vars = vars);
                ref.read(environmentsProvider.notifier).save(
                      widget.environment.copyWith(variables: vars),
                    );
              },
            ),
          ),
        ),
      ],
    );
  }
}
