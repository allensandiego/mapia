class VariableParser {
  static final _pattern = RegExp(r'\{\{([^}]+)\}\}');

  /// Resolves all {{variable}} placeholders in [input] using [variables] map.
  static String resolve(String input, Map<String, String> variables) {
    return input.replaceAllMapped(_pattern, (match) {
      final key = match.group(1)?.trim() ?? '';
      return variables[key] ?? match.group(0)!;
    });
  }

  /// Returns a list of all variable names found in [input].
  static List<String> extract(String input) {
    return _pattern
        .allMatches(input)
        .map((m) => m.group(1)?.trim() ?? '')
        .where((k) => k.isNotEmpty)
        .toList();
  }
}
