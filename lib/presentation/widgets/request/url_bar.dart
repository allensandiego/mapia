import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/tabs_provider.dart';
import '../../providers/collection_provider.dart';
import '../../providers/environment_provider.dart';
import '../../../core/constants/http_constants.dart';
import '../../../core/utils/variable_parser.dart';
import '../../providers/ui_provider.dart';
import '../../../core/theme/mapia_colors.dart';
import '../../../core/widgets/variable_text_editing_controller.dart';

const double _kRowHeight = 48.0;

class UrlBar extends ConsumerStatefulWidget {
  final RequestTab tab;
  final VoidCallback onSend;

  const UrlBar({super.key, required this.tab, required this.onSend});

  @override
  ConsumerState<UrlBar> createState() => _UrlBarState();
}

class _UrlBarState extends ConsumerState<UrlBar> {
  late VariableTextEditingController _urlCtrl;
  late TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _urlCtrl = VariableTextEditingController(text: widget.tab.request.url);
    _nameCtrl = TextEditingController(text: widget.tab.request.name);
  }

  @override
  void didUpdateWidget(UrlBar old) {
    super.didUpdateWidget(old);
    if (old.tab.id != widget.tab.id) {
      _urlCtrl.text = widget.tab.request.url;
      _nameCtrl.text = widget.tab.request.name;
    }
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.tab.request;
    final colors = context.colors;
    final borderColor = colors.border;
    final focusedBorderColor = colors.accent;

    _urlCtrl.variableColor = colors.warning;
    _urlCtrl.defaultColor = colors.textPrimary;

    final activeEnvVars = ref.watch(activeEnvVariablesProvider);
    final allVars = <String>{...activeEnvVars.keys};
    final resolvedVars = Map<String, String>.from(activeEnvVars);

    if (widget.tab.collectionId != null) {
      final collections = ref.watch(collectionsProvider).value ?? [];
      final col =
          collections.where((c) => c.id == widget.tab.collectionId).firstOrNull;
      if (col != null) {
        if (col.environmentId != null) {
          final envs = ref.watch(environmentsProvider).value ?? [];
          final linkedEnv =
              envs.where((e) => e.id == col.environmentId).firstOrNull;
          if (linkedEnv != null) {
            for (final v in linkedEnv.variables.where((v) => v.enabled)) {
              allVars.add(v.key);
              resolvedVars.putIfAbsent(v.key, () => v.value);
            }
          }
        }
        for (final v in col.variables.where((v) => v.enabled)) {
          allVars.add(v.key);
          resolvedVars.putIfAbsent(v.key, () => v.value);
        }
      }
    }
    for (final v in request.variables.where((v) => v.enabled)) {
      allVars.add(v.key);
      resolvedVars.putIfAbsent(v.key, () => v.value);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Request name
          TextField(
            controller: _nameCtrl,
            onChanged: (v) => ref
                .read(tabsProvider.notifier)
                .updateRequest(widget.tab.id, request.copyWith(name: v)),
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              hintText: 'Untitled Request',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 12),
          // Method + URL + buttons — all exactly _kRowHeight tall
          SizedBox(
            height: _kRowHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Method dropdown ──────────────────────────────────────
                _MethodDropdown(
                  value: request.method,
                  borderColor: borderColor,
                  onChanged: (m) => ref
                      .read(tabsProvider.notifier)
                      .updateRequest(
                          widget.tab.id, request.copyWith(method: m)),
                ),
                const SizedBox(width: 8),
                // ── URL field with {{var}} autocomplete ──────────────────
                Expanded(
                  child: _VarAutocompleteField(
                    controller: _urlCtrl,
                    borderColor: borderColor,
                    focusedBorderColor: focusedBorderColor,
                    onChanged: (v) => ref
                        .read(tabsProvider.notifier)
                        .updateRequest(widget.tab.id, request.copyWith(url: v)),
                    onSubmitted: (_) => widget.onSend(),
                    envVars: allVars.toList(),
                    resolvedEnvVars: resolvedVars,
                  ),
                ),
                const SizedBox(width: 8),
                // ── Save button ──────────────────────────────────────────
                SizedBox(
                  width: _kRowHeight,
                  child: OutlinedButton(
                    onPressed: () => ref
                        .read(tabsProvider.notifier)
                        .saveRequest(widget.tab.id, context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Icon(
                      Icons.save_outlined,
                      size: 20,
                      color:
                          widget.tab.isDirty ? colors.accent : colors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // ── Send button ──────────────────────────────────────────
                SizedBox(
                  width: 100,
                  child: widget.tab.isLoading
                      ? FilledButton(
                          onPressed: null,
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.textPrimary,
                            ),
                          ),
                        )
                      : FilledButton.icon(
                          onPressed: widget.onSend,
                          icon: const Icon(Icons.send, size: 16),
                          label: const Text('Send'),
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                // ── Code toggle ──────────────────────────────────────────
                Tooltip(
                  message: ref.watch(showCodePanelProvider)
                      ? 'Hide code snippet'
                      : 'Generate code snippet',
                  child: OutlinedButton(
                    onPressed: () => ref
                        .read(showCodePanelProvider.notifier)
                        .state = !ref.read(showCodePanelProvider),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      side: BorderSide(
                        color: ref.watch(showCodePanelProvider)
                            ? colors.accent
                            : borderColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      backgroundColor: ref.watch(showCodePanelProvider)
                          ? colors.accent.withValues(alpha: 0.1)
                          : null,
                    ),
                    child: Icon(
                      Icons.code_outlined,
                      size: 20,
                      color: ref.watch(showCodePanelProvider)
                          ? colors.accent
                          : colors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Method Dropdown ─────────────────────────────────────────────────────────
// Uses a plain DropdownButton inside a styled Container so we have
// full control over the height, padding, and border — identical to the TextField.

class _MethodDropdown extends StatelessWidget {
  final HttpMethod value;
  final Color borderColor;
  final ValueChanged<HttpMethod> onChanged;

  const _MethodDropdown({
    required this.value,
    required this.borderColor,
    required this.onChanged,
  });

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
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DropdownButton<HttpMethod>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(), // remove the default underline
        icon: const Icon(Icons.arrow_drop_down, size: 20),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: _getMethodColor(context, value),
        ),
        items: HttpMethod.values.map((m) {
          return DropdownMenuItem(
            value: m,
            child: Text(m.label,
                style: TextStyle(
                    color: _getMethodColor(context, m),
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          );
        }).toList(),
        onChanged: (m) => m != null ? onChanged(m) : null,
      ),
    );
  }
}

// ─── Variable Autocomplete Field ─────────────────────────────────────────────
// Shows a dropdown with matching {{variable}} suggestions when the user types {{.

class _VarAutocompleteField extends StatefulWidget {
  final VariableTextEditingController controller;
  final Color borderColor;
  final Color focusedBorderColor;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final List<String> envVars;
  final Map<String, String> resolvedEnvVars;

  const _VarAutocompleteField({
    required this.controller,
    required this.borderColor,
    required this.focusedBorderColor,
    required this.onChanged,
    required this.onSubmitted,
    required this.envVars,
    required this.resolvedEnvVars,
  });

  @override
  State<_VarAutocompleteField> createState() => _VarAutocompleteFieldState();
}

class _VarAutocompleteFieldState extends State<_VarAutocompleteField> {
  late final ValueNotifier<_AutocompleteMatchData?> _matchData =
      ValueNotifier(null);
  final FocusNode _focus = FocusNode();
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focus.addListener(() {
      if (!_focus.hasFocus) _hideOverlay();
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focus.dispose();
    _hideOverlay();
    _matchData.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    final pos = selection.baseOffset;

    // Only show if we have a single cursor (no selection)
    if (pos < 0 || !selection.isCollapsed) {
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

    // Even if matches are empty, show "No matches" if we're in a {{ block
    _showOverlay(matches, openIdx, pos, query.length);
  }

  void _showOverlay(
      List<String> matches, int openIdx, int cursorPos, int queryLen) {
    if (_overlay == null) {
      _overlay = _createOverlayEntry();
      Overlay.of(context).insert(_overlay!);
    }

    _matchData.value = _AutocompleteMatchData(
      matches: matches,
      openIdx: openIdx,
      cursorPos: cursorPos,
      queryLen: queryLen,
    );
  }

  OverlayEntry? _overlay;

  OverlayEntry _createOverlayEntry() {
    final colors = context.colors;
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          width: 320, // Slightly wider for better readability
            child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            followerAnchor: Alignment.topLeft,
            offset: const Offset(0, 4), // Small gap below URL bar
            child: Material(
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
                  if (data == null) {
                    return const SizedBox.shrink();
                  }

                  if (data.matches.isEmpty) {
                     return Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                       child: Column(
                         mainAxisSize: MainAxisSize.min,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(
                             widget.envVars.isEmpty ? 'No environment active' : 'No matches found',
                             style: TextStyle(color: colors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                           ),
                           if (widget.envVars.isEmpty)
                             Padding(
                               padding: const EdgeInsets.only(top: 4.0),
                               child: Text(
                                 'Activate an environment to see variables',
                                 style: TextStyle(color: colors.textSecondary, fontSize: 11),
                               ),
                             ),
                         ],
                       ),
                     );
                  }

                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: data.matches.length,
                      itemBuilder: (context, index) {
                        final varKey = data.matches[index];
                        return _AutocompleteTile(
                          varKey: varKey,
                          colors: colors,
                          onTap: () {
                            final text = widget.controller.text;
                            final prefix = text.substring(0, data.openIdx);
                            final suffix = text.substring(data.cursorPos);
                            final inserted = '$prefix{{$varKey}}$suffix';
                            widget.controller.value = TextEditingValue(
                              text: inserted,
                              selection: TextSelection.collapsed(
                                  offset: data.openIdx + varKey.length + 4),
                            );
                            widget.onChanged(inserted);
                            _hideOverlay();
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

  void _hideOverlay() {
    _overlay?.remove();
    _overlay = null;
    _matchData.value = null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = widget.controller.text;
    final hasVars = text.contains('{{');
    final resolvedText =
        hasVars ? VariableParser.resolve(text, widget.resolvedEnvVars) : null;

    Widget field = TextField(
      controller: widget.controller,
      focusNode: _focus,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      style: TextStyle(fontSize: 13, color: colors.textPrimary),
      decoration: InputDecoration(
        hintText: 'https://api.example.com/endpoint',
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: hasVars
                ? colors.warning.withValues(alpha: 0.4)
                : widget.borderColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: hasVars
                ? colors.warning.withValues(alpha: 0.4)
                : widget.borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.focusedBorderColor,
            width: 2,
          ),
        ),
      ),
    );

    if (resolvedText != null && resolvedText != text) {
      field = Tooltip(
        message: resolvedText,
        preferBelow: true,
        decoration: BoxDecoration(
          color: colors.bgElevated,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colors.warning.withValues(alpha: 0.4)),
        ),
        textStyle: TextStyle(
          fontSize: 12,
          color: colors.warning,
          fontFamily: 'monospace',
        ),
        child: field,
      );
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: field,
    );
  }
}

class _AutocompleteMatchData {
  final List<String> matches;
  final int openIdx;
  final int cursorPos;
  final int queryLen;

  _AutocompleteMatchData({
    required this.matches,
    required this.openIdx,
    required this.cursorPos,
    required this.queryLen,
  });
}

class _AutocompleteTile extends StatelessWidget {
  final String varKey;
  final MapiaColors colors;
  final VoidCallback onTap;

  const _AutocompleteTile({
    required this.varKey,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '{{',
                style: TextStyle(
                  color: colors.warning,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text: varKey,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text: '}}',
                style: TextStyle(
                  color: colors.warning,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
