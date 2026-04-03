import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';

/// A syntax-highlighted, selectable code viewer for JSON, XML, and HTML.
/// Falls back to plain monospace for unknown formats.
class CodeViewer extends StatelessWidget {
  final String code;
  final String language; // 'json' | 'xml' | 'html' | 'plaintext'
  final bool selectable;

  const CodeViewer({
    super.key,
    required this.code,
    required this.language,
    this.selectable = true,
  });

  @override
  Widget build(BuildContext context) {
    if (code.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseTheme = isDark ? atomOneDarkTheme : atomOneLightTheme;

    // We override the background to be transparent so the parent Container
    // controls the background colour.
    final theme = Map<String, TextStyle>.from(baseTheme);
    theme['root'] = (theme['root'] ?? const TextStyle()).copyWith(
      backgroundColor: Colors.transparent,
    );

    // SizedBox.expand + HighlightView ensures the block always fills the full
    // horizontal width of the ScrollView, so code starts at the left edge.
    return SizedBox(
      width: double.infinity,
      child: HighlightView(
        code,
        language: _normaliseLanguage(language),
        theme: theme,
        padding: const EdgeInsets.all(12),
        textStyle: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12.5,
          height: 1.6,
        ),
      ),
    );
  }

  String _normaliseLanguage(String lang) {
    switch (lang.toLowerCase()) {
      case 'json':
        return 'json';
      case 'xml':
        return 'xml';
      case 'html':
        return 'xml'; // highlight.js treats HTML as XML variant
      default:
        return 'plaintext';
    }
  }
}
