import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import '../../../domain/entities/api_request.dart';
import '../../../core/theme/mapia_colors.dart';
import '../../../core/utils/snippet_generator.dart';

enum SnippetType {
  curl('curl', 'bash'),
  python('Python', 'python'),
  fetch('Fetch', 'javascript'),
  axios('Axios', 'javascript'),
  dart('Dart', 'dart');

  final String label;
  final String highlightLanguage;

  const SnippetType(this.label, this.highlightLanguage);
}

class SnippetPanel extends StatefulWidget {
  final ApiRequest request;

  const SnippetPanel({super.key, required this.request});

  @override
  State<SnippetPanel> createState() => _SnippetPanelState();
}

class _SnippetPanelState extends State<SnippetPanel> {
  late SnippetType _selectedType = SnippetType.curl;

  String _generateSnippet(SnippetType type, ApiRequest request) {
    switch (type) {
      case SnippetType.curl:
        return SnippetGenerator.generateCurl(request);
      case SnippetType.python:
        return SnippetGenerator.generatePython(request);
      case SnippetType.fetch:
        return SnippetGenerator.generateFetch(request);
      case SnippetType.axios:
        return SnippetGenerator.generateAxios(request);
      case SnippetType.dart:
        return SnippetGenerator.generateDart(request);
    }
  }

  void _copySnippet(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Snippet copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final snippet = _generateSnippet(_selectedType, widget.request);

    return Column(
      children: [
        Container(
          color: colors.bgSurface,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              DropdownButton<SnippetType>(
                value: _selectedType,
                onChanged: (type) {
                  if (type != null) {
                    setState(() => _selectedType = type);
                  }
                },
                items: SnippetType.values
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.label,
                              style: TextStyle(
                                  fontSize: 12, color: colors.textPrimary)),
                        ))
                    .toList(),
                underline: Container(),
                dropdownColor: colors.bgElevated,
                style: TextStyle(fontSize: 12, color: colors.textPrimary),
              ),
              const Spacer(),
              Tooltip(
                message: 'Copy snippet',
                child: IconButton(
                  icon: const Icon(Icons.copy_outlined, size: 14),
                  onPressed: () => _copySnippet(snippet),
                  color: colors.textMuted,
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            child: SelectionArea(
              child: HighlightView(
                snippet,
                language: _selectedType.highlightLanguage,
                theme: atomOneDarkTheme,
                textStyle:
                    const TextStyle(fontFamily: 'monospace', fontSize: 12),
                padding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
