import 'package:flutter/material.dart';
import '../../core/constants/http_constants.dart';
import '../../core/theme/mapia_colors.dart';

class MethodBadge extends StatelessWidget {
  final HttpMethod method;
  final double fontSize;

  const MethodBadge({
    super.key,
    required this.method,
    this.fontSize = 11,
  });

  Color _getColor(BuildContext context) {
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
    final color = _getColor(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(77), width: 1),
      ),
      child: Text(
        method.label,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final int statusCode;
  final String label;

  const StatusBadge({super.key, required this.statusCode, required this.label});

  Color _getColor(BuildContext context) {
    final colors = context.colors;
    if (statusCode >= 200 && statusCode < 300) return colors.success;
    if (statusCode >= 300 && statusCode < 400) return colors.accent;
    if (statusCode >= 400 && statusCode < 500) return colors.warning;
    return colors.error;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
