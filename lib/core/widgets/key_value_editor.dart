import 'package:flutter/material.dart';
import '../../domain/entities/variable.dart';
import '../theme/mapia_colors.dart';
import 'package:uuid/uuid.dart';
import 'variable_text_editing_controller.dart';
import 'variable_autocomplete_field.dart';

/// Resolves all {{key}} patterns in [text] using [vars], returns null if no
/// variables present or map is empty.
String? _resolveVars(String text, Map<String, String>? vars) {
  if (vars == null || vars.isEmpty) return null;
  if (!text.contains('{{')) return null;
  final resolved = text.replaceAllMapped(
    RegExp(r'\{\{([^}]+)\}\}'),
    (m) => vars[m.group(1)] ?? m.group(0)!,
  );
  return resolved == text ? null : resolved;
}

/// A reusable key-value pair editor used for headers, query params, form data, etc.
class KeyValueEditor extends StatefulWidget {
  final List<Variable> items;
  final ValueChanged<List<Variable>> onChanged;
  final String keyHint;
  final String valueHint;
  final bool showSecretToggle;
  final bool showDescription;
  final List<String>? envVars;
  final Map<String, String>? resolvedEnvVars;

  const KeyValueEditor({
    super.key,
    required this.items,
    required this.onChanged,
    this.keyHint = 'Key',
    this.valueHint = 'Value',
    this.showSecretToggle = false,
    this.showDescription = true,
    this.envVars,
    this.resolvedEnvVars,
  });

  @override
  State<KeyValueEditor> createState() => _KeyValueEditorState();
}

class _KeyValueEditorState extends State<KeyValueEditor> {
  late List<Variable> _items;
  late List<String> _rowIds;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
    _rowIds = List.generate(_items.length, (_) => const Uuid().v4());
  }

  @override
  void didUpdateWidget(KeyValueEditor old) {
    super.didUpdateWidget(old);
    if (old.items != widget.items) {
      _items = List.from(widget.items);
      if (_rowIds.length != _items.length) {
        _rowIds = List.generate(_items.length, (_) => const Uuid().v4());
      }
    }
  }

  void _update(int i, Variable v) {
    setState(() => _items[i] = v);
    widget.onChanged(_items);
  }

  void _addRow() {
    setState(() {
      _items.add(const Variable(key: ''));
      _rowIds.add(const Uuid().v4());
    });
    widget.onChanged(_items);
  }

  void _removeRow(int i) {
    setState(() {
      _items.removeAt(i);
      _rowIds.removeAt(i);
    });
    widget.onChanged(_items);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              const SizedBox(width: 32),
              Expanded(
                child: Text(widget.keyHint,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textMuted,
                        letterSpacing: 0.5)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(widget.valueHint,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textMuted,
                        letterSpacing: 0.5)),
              ),
              if (widget.showDescription) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Description',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textMuted,
                          letterSpacing: 0.5)),
                ),
              ],
              const SizedBox(width: 32),
            ],
          ),
        ),
        const Divider(height: 1),
        // Rows
        ...List.generate(_items.length, (i) {
          final item = _items[i];
          return _KVRow(
            key: ValueKey(_rowIds[i]),
            item: item,
            keyHint: widget.keyHint,
            valueHint: widget.valueHint,
            showSecretToggle: widget.showSecretToggle,
            showDescription: widget.showDescription,
            envVars: widget.envVars,
            resolvedEnvVars: widget.resolvedEnvVars,
            onChanged: (v) => _update(i, v),
            onRemove: () => _removeRow(i),
          );
        }),
        // Add row button
        InkWell(
          onTap: _addRow,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.add, size: 14, color: context.colors.accent),
                const SizedBox(width: 6),
                Text(
                  'Add ${widget.keyHint.toLowerCase()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _KVRow extends StatefulWidget {
  final Variable item;
  final String keyHint;
  final String valueHint;
  final bool showSecretToggle;
  final bool showDescription;
  final List<String>? envVars;
  final Map<String, String>? resolvedEnvVars;
  final ValueChanged<Variable> onChanged;
  final VoidCallback onRemove;

  const _KVRow({
    super.key,
    required this.item,
    required this.keyHint,
    required this.valueHint,
    required this.showSecretToggle,
    required this.showDescription,
    required this.onChanged,
    required this.onRemove,
    this.envVars,
    this.resolvedEnvVars,
  });

  @override
  State<_KVRow> createState() => _KVRowState();
}

class _KVRowState extends State<_KVRow> {
  late VariableTextEditingController _keyCtrl;
  late VariableTextEditingController _valCtrl;
  late TextEditingController _descCtrl;
  final FocusNode _valFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _keyCtrl = VariableTextEditingController(text: widget.item.key);
    _valCtrl = VariableTextEditingController(text: widget.item.value);
    _descCtrl = TextEditingController(text: widget.item.description);
    _valCtrl.addListener(() => _notify());
    _descCtrl.addListener(() => _notify());
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    _valCtrl.dispose();
    _descCtrl.dispose();
    _valFocus.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged(widget.item.copyWith(
      key: _keyCtrl.text,
      value: _valCtrl.text,
      description: _descCtrl.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    _keyCtrl.variableColor = context.colors.warning;
    _keyCtrl.defaultColor = context.colors.textPrimary;
    _valCtrl.variableColor = context.colors.warning;
    _valCtrl.defaultColor = context.colors.textPrimary;

    final resolvedValue = _resolveVars(_valCtrl.text, widget.resolvedEnvVars);
    final resolvedKey = _resolveVars(_keyCtrl.text, widget.resolvedEnvVars);

    final hasValueVars = _valCtrl.text.contains('{{');
    final hasKeyVars = _keyCtrl.text.contains('{{');

    // Value field widget — optionally wrapped in a Tooltip showing the resolved value
    Widget valueField = VariableAutocompleteField(
      controller: _valCtrl,
      focusNode: _valFocus,
      onChanged: (_) => _notify(),
      obscureText: widget.item.isSecret,
      envVars: widget.envVars ?? [],
      resolvedEnvVars: widget.resolvedEnvVars,
      style: TextStyle(fontSize: 13, color: context.colors.textPrimary),
      decoration: InputDecoration(
        hintText: widget.valueHint,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        filled: false,
      ),
    );

    if (resolvedValue != null) {
      valueField = Tooltip(
        message: resolvedValue,
        preferBelow: true,
        verticalOffset: 12,
        waitDuration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: context.colors.bgElevated,
          borderRadius: BorderRadius.circular(6),
          border:
              Border.all(color: context.colors.warning.withValues(alpha: 0.5)),
        ),
        textStyle: TextStyle(
          fontSize: 12,
          color: context.colors.warning,
          fontFamily: 'monospace',
        ),
        child: valueField,
      );
    }

    // Key field — optionally wrapped in a Tooltip
    Widget keyField = VariableAutocompleteField(
      controller: _keyCtrl,
      envVars: widget.envVars ?? [],
      resolvedEnvVars: widget.resolvedEnvVars,
      onChanged: (_) => _notify(),
      style: TextStyle(fontSize: 13, color: context.colors.textPrimary),
      decoration: InputDecoration(
        hintText: widget.keyHint,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        filled: false,
      ),
    );

    if (resolvedKey != null) {
      keyField = Tooltip(
        message: resolvedKey,
        preferBelow: true,
        verticalOffset: 12,
        waitDuration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: context.colors.bgElevated,
          borderRadius: BorderRadius.circular(6),
          border:
              Border.all(color: context.colors.warning.withValues(alpha: 0.5)),
        ),
        textStyle: TextStyle(
          fontSize: 12,
          color: context.colors.warning,
          fontFamily: 'monospace',
        ),
        child: keyField,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: (hasKeyVars || hasValueVars)
                    ? context.colors.warning.withValues(alpha: 0.4)
                    : context.colors.border,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Enabled checkbox
              SizedBox(
                width: 32,
                child: Checkbox(
                  value: widget.item.enabled,
                  onChanged: (v) => widget
                      .onChanged(widget.item.copyWith(enabled: v ?? true)),
                  side: BorderSide(color: context.colors.border),
                  activeColor: context.colors.accent,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              // Key field
              Expanded(child: keyField),
              Container(width: 1, height: 36, color: context.colors.border),
              // Value field
              Expanded(child: valueField),
              // Description field
              if (widget.showDescription) ...[
                Container(width: 1, height: 36, color: context.colors.border),
                Expanded(
                  child: TextField(
                    controller: _descCtrl,
                    onChanged: (_) => _notify(),
                    style: TextStyle(
                        fontSize: 13, color: context.colors.textSecondary),
                    decoration: const InputDecoration(
                      hintText: 'Description',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      filled: false,
                    ),
                  ),
                ),
              ],
              // Secret toggle
              if (widget.showSecretToggle)
                IconButton(
                  icon: Icon(
                    widget.item.isSecret
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 14,
                  ),
                  onPressed: () => widget.onChanged(
                      widget.item.copyWith(isSecret: !widget.item.isSecret)),
                  color: context.colors.textMuted,
                  tooltip: 'Toggle Secret',
                  padding: const EdgeInsets.all(8),
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              // Remove button
              IconButton(
                icon: const Icon(Icons.close, size: 14),
                onPressed: widget.onRemove,
                color: context.colors.textMuted,
                hoverColor: context.colors.error.withValues(alpha: 0.1),
                tooltip: 'Remove',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
        // Resolved value hint row — shown when the value contains {{var}} references
        if (resolvedValue != null)
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 48, bottom: 4),
            child: Row(
              children: [
                const Expanded(child: SizedBox()), // aligns under Value column
                Expanded(
                  child: Text(
                    '→ $resolvedValue',
                    style: TextStyle(
                      fontSize: 10,
                      color: context.colors.warning,
                      fontFamily: 'monospace',
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
