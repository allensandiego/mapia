import 'package:flutter/material.dart';
import '../../domain/entities/variable.dart';
import '../theme/mapia_colors.dart';
import 'package:uuid/uuid.dart';

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
  final List<String>? envVars;
  final Map<String, String>? resolvedEnvVars;

  const KeyValueEditor({
    super.key,
    required this.items,
    required this.onChanged,
    this.keyHint = 'Key',
    this.valueHint = 'Value',
    this.showSecretToggle = false,
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
    required this.onChanged,
    required this.onRemove,
    this.envVars,
    this.resolvedEnvVars,
  });

  @override
  State<_KVRow> createState() => _KVRowState();
}

class _KVRowState extends State<_KVRow> {
  late TextEditingController _keyCtrl;
  late TextEditingController _valCtrl;
  OverlayEntry? _overlay;
  final FocusNode _valFocus = FocusNode();
  final LayerLink _valLayerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _keyCtrl = TextEditingController(text: widget.item.key);
    _valCtrl = TextEditingController(text: widget.item.value);
    _valCtrl.addListener(_onValueChanged);
    _valFocus.addListener(() {
      if (!_valFocus.hasFocus) _hideOverlay();
    });
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    _valCtrl.removeListener(_onValueChanged);
    _valCtrl.dispose();
    _valFocus.dispose();
    _hideOverlay();
    super.dispose();
  }

  void _notify() {
    widget.onChanged(widget.item.copyWith(
      key: _keyCtrl.text,
      value: _valCtrl.text,
    ));
  }

  void _onValueChanged() {
    if (widget.envVars == null || widget.envVars!.isEmpty) {
      _hideOverlay();
      return;
    }

    final text = _valCtrl.text;
    final pos = _valCtrl.selection.baseOffset;
    if (pos < 0) return;

    // Find the last {{ before the cursor
    final before = text.substring(0, pos);
    final openIdx = before.lastIndexOf('{{');
    if (openIdx == -1) {
      _hideOverlay();
      return;
    }

    // If there's a closing }} between {{ and cursor, don't show
    if (before.substring(openIdx).contains('}}')) {
      _hideOverlay();
      return;
    }

    final query = before.substring(openIdx + 2).toLowerCase();
    final matches = widget.envVars!
        .where((k) => k.toLowerCase().startsWith(query))
        .toList();

    if (matches.isEmpty) {
      _hideOverlay();
      return;
    }
    _showOverlay(matches, openIdx, pos, query.length);
  }

  void _showOverlay(List<String> matches, int openIdx, int cursorPos, int queryLen) {
    _hideOverlay();
    _overlay = OverlayEntry(
      builder: (_) => Positioned(
        width: 240,
        child: CompositedTransformFollower(
          link: _valLayerLink,
          offset: const Offset(0, 50),
          showWhenUnlinked: false,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(6),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: matches
                  .map((varKey) => InkWell(
                onTap: () {
                  final text = _valCtrl.text;
                  final prefix = text.substring(0, openIdx);
                  final suffix = text.substring(cursorPos);
                  final inserted = '$prefix{{$varKey}}$suffix';
                  _valCtrl.value = TextEditingValue(
                    text: inserted,
                    selection: TextSelection.collapsed(
                        offset: openIdx + varKey.length + 4),
                  );
                  _notify();
                  _hideOverlay();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: '{{',
                            style: TextStyle(
                                color: context.colors.warning,
                                fontFamily: 'monospace',
                                fontSize: 12)),
                        TextSpan(
                            text: varKey,
                            style: TextStyle(
                                color: context.colors.textPrimary,
                                fontFamily: 'monospace',
                                fontSize: 12)),
                        TextSpan(
                            text: '}}',
                            style: TextStyle(
                                color: context.colors.warning,
                                fontFamily: 'monospace',
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlay!);
  }

  void _hideOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedValue = _resolveVars(_valCtrl.text, widget.resolvedEnvVars);
    final resolvedKey   = _resolveVars(_keyCtrl.text, widget.resolvedEnvVars);
    
    final hasValueVars = _valCtrl.text.contains('{{');
    final hasKeyVars = _keyCtrl.text.contains('{{');

    // Value field widget — optionally wrapped in a Tooltip showing the resolved value
    Widget valueField = CompositedTransformTarget(
      link: _valLayerLink,
      child: TextField(
        controller: _valCtrl,
        focusNode: _valFocus,
        onChanged: (_) => _notify(),
        obscureText: widget.item.isSecret && !_valCtrl.text.startsWith('{{'),
        style: TextStyle(fontSize: 13, color: context.colors.textPrimary),
        decoration: InputDecoration(
          hintText: widget.valueHint,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          filled: false,
        ),
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
          border: Border.all(color: context.colors.warning.withValues(alpha: 0.5)),
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
    Widget keyField = TextField(
      controller: _keyCtrl,
      onChanged: (_) => _notify(),
      style: TextStyle(fontSize: 13, color: context.colors.textPrimary),
      decoration: InputDecoration(
        hintText: widget.keyHint,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
          border: Border.all(color: context.colors.warning.withValues(alpha: 0.5)),
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
                  onChanged: (v) =>
                      widget.onChanged(widget.item.copyWith(enabled: v ?? true)),
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
              // Secret toggle
              if (widget.showSecretToggle)
                IconButton(
                  icon: Icon(
                    widget.item.isSecret ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 14,
                  ),
                  onPressed: () => widget.onChanged(widget.item.copyWith(isSecret: !widget.item.isSecret)),
                  color: context.colors.textMuted,
                  tooltip: 'Toggle Secret',
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
                const Expanded(child: SizedBox()),  // aligns under Value column
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
