import 'package:flutter/material.dart';

/// Custom TextEditingController that applies color highlighting to {{variable}} patterns.
/// Variables are highlighted in orange, while non-variable text remains in the default color.
class VariableTextEditingController extends TextEditingController {
  static final _variablePattern = RegExp(r'\{\{([^}]+)\}\}');

  Color variableColor;
  Color defaultColor;
  final TextStyle? baseTextStyle;

  VariableTextEditingController({
    super.text,
    this.variableColor = const Color(0xFFFFA500), // Orange
    this.defaultColor = const Color(0xFFF1F5F9), // Primary text color
    this.baseTextStyle,
  });

  /// Builds a TextSpan with colored variables.
  /// Variables ({{...}}) are colored with [variableColor],
  /// while other text uses [defaultColor].
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    style ??= baseTextStyle ??
        const TextStyle(fontSize: 13, color: Color(0xFFF1F5F9));

    final text = this.text;
    if (text.isEmpty) {
      return TextSpan(style: style, text: '');
    }

    final List<TextSpan> spans = [];
    int lastEnd = 0;

    for (final match in _variablePattern.allMatches(text)) {
      // Add non-variable text before this match
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: style.copyWith(color: defaultColor),
        ));
      }

      // Add the variable (highlighted)
      spans.add(TextSpan(
        text: match.group(0),
        style: style.copyWith(
          color: variableColor,
          fontWeight: FontWeight.w500,
        ),
      ));

      lastEnd = match.end;
    }

    // Add remaining text after the last match
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: style.copyWith(color: defaultColor),
      ));
    }

    return TextSpan(style: style, children: spans.isNotEmpty ? spans : null);
  }
}
