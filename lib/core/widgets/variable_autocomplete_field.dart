import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/mapia_colors.dart';
import 'variable_text_editing_controller.dart';

/// A wrapper around [TextField] that adds an autocomplete overlay for environment variables ({{variable}}).
class VariableAutocompleteField extends StatefulWidget {
  final VariableTextEditingController controller;
  final List<String> envVars;
  final Map<String, String>? resolvedEnvVars;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final InputDecoration decoration;
  final bool obscureText;
  final TextStyle? style;
  final FocusNode? focusNode;
  final int? maxLines;
  final bool expands;
  final TextAlign textAlign;
  final EdgeInsets scrollPadding;

  const VariableAutocompleteField({
    super.key,
    required this.controller,
    required this.envVars,
    this.resolvedEnvVars,
    this.onChanged,
    this.onSubmitted,
    this.decoration = const InputDecoration(),
    this.obscureText = false,
    this.style,
    this.focusNode,
    this.maxLines = 1,
    this.expands = false,
    this.textAlign = TextAlign.start,
    this.scrollPadding = const EdgeInsets.all(20.0),
  });

  @override
  State<VariableAutocompleteField> createState() =>
      _VariableAutocompleteFieldState();
}

class _VariableAutocompleteFieldState extends State<VariableAutocompleteField> {
  final LayerLink _layerLink = LayerLink();
  final ValueNotifier<_AutocompleteMatchData?> _matchData = ValueNotifier(null);
  final ValueNotifier<int> _selectedIndex = ValueNotifier(0);
  OverlayEntry? _overlay;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    widget.controller.addListener(_handleTextChange);
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(VariableAutocompleteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_handleTextChange);
      widget.controller.addListener(_handleTextChange);
    }
    if (widget.focusNode != oldWidget.focusNode) {
      if (widget.focusNode == null) {
        _focusNode = FocusNode();
      } else {
        _focusNode = widget.focusNode!;
      }
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _hideOverlay();
    _matchData.dispose();
    _selectedIndex.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _hideOverlay();
    }
  }

  void _handleTextChange() {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    final pos = selection.baseOffset;

    // Only show if we have a single cursor (no selection)
    if (pos < 0 || !selection.isCollapsed || !_focusNode.hasFocus) {
      _hideOverlay();
      return;
    }

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
    final matches =
        widget.envVars.where((k) => k.toLowerCase().startsWith(query)).toList();

    _selectedIndex.value = 0;
    _showOverlay(matches, openIdx, pos);
  }

  void _showOverlay(List<String> matches, int openIdx, int cursorPos) {
    if (_overlay == null) {
      _overlay = _createOverlayEntry();
      Overlay.of(context).insert(_overlay!);
    }

    _matchData.value = _AutocompleteMatchData(
      matches: matches,
      openIdx: openIdx,
      cursorPos: cursorPos,
    );
  }

  void _hideOverlay() {
    _overlay?.remove();
    _overlay = null;
    _matchData.value = null;
  }

  KeyEventResult _handleKeyDown(FocusNode node, KeyEvent event) {
    final data = _matchData.value;
    if (data == null || data.matches.isEmpty) return KeyEventResult.ignored;

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _selectedIndex.value = (_selectedIndex.value + 1) % data.matches.length;
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _selectedIndex.value =
            (_selectedIndex.value - 1 + data.matches.length) %
                data.matches.length;
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        final selected = data.matches[_selectedIndex.value];
        _selectVariable(selected, data);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        _hideOverlay();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        final colors = context.colors;
        return Positioned(
          width: 320,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            followerAnchor: Alignment.topLeft,
            offset: const Offset(0, 4),
            child: Material(
              key: const Key('variable_autocomplete_overlay'),
              elevation: 12,
              color: colors.bgElevated,
              shadowColor: Colors.black,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(color: colors.border),
              ),
              child: ValueListenableBuilder<_AutocompleteMatchData?>(
                valueListenable: _matchData,
                builder: (context, data, child) {
                  if (data == null) return const SizedBox.shrink();

                  if (data.matches.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.envVars.isEmpty
                                ? 'No environment active'
                                : 'No matches found',
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.envVars.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Activate an environment to see variables',
                                style: TextStyle(
                                    color: colors.textSecondary, fontSize: 11),
                              ),
                            ),
                        ],
                      ),
                    );
                  }

                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ValueListenableBuilder<int>(
                      valueListenable: _selectedIndex,
                      builder: (context, selectedIdx, child) {
                        return ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: data.matches.length,
                          itemBuilder: (context, index) {
                            final varKey = data.matches[index];
                            final isSelected = index == selectedIdx;
                            return InkWell(
                              onTap: () => _selectVariable(varKey, data),
                              child: Container(
                                color: isSelected
                                    ? colors.accent.withValues(alpha: 0.15)
                                    : null,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 9),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '{{',
                                        style: TextStyle(
                                          color: isSelected
                                              ? colors.accent
                                              : colors.warning,
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                        ),
                                      ),
                                      TextSpan(
                                        text: varKey,
                                        style: TextStyle(
                                          color: isSelected
                                              ? colors.accent
                                              : colors.textPrimary,
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '}}',
                                        style: TextStyle(
                                          color: isSelected
                                              ? colors.accent
                                              : colors.warning,
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _selectVariable(String varKey, _AutocompleteMatchData data) {
    final text = widget.controller.text;
    final prefix = text.substring(0, data.openIdx);
    final suffix = text.substring(data.cursorPos);
    final inserted = '$prefix{{$varKey}}$suffix';

    widget.controller.value = TextEditingValue(
      text: inserted,
      selection: TextSelection.collapsed(
        offset: data.openIdx + varKey.length + 4,
      ),
    );

    widget.onChanged?.call(inserted);
    _hideOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: _handleKeyDown,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          decoration: widget.decoration,
          obscureText:
              widget.obscureText && !widget.controller.text.startsWith('{{'),
          style: widget.style,
          maxLines: widget.maxLines,
          expands: widget.expands,
          textAlign: widget.textAlign,
          scrollPadding: widget.scrollPadding,
        ),
      ),
    );
  }
}

class _AutocompleteMatchData {
  final List<String> matches;
  final int openIdx;
  final int cursorPos;

  _AutocompleteMatchData({
    required this.matches,
    required this.openIdx,
    required this.cursorPos,
  });
}
