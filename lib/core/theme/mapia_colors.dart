import 'package:flutter/material.dart';
import 'app_colors.dart';

class MapiaColors extends ThemeExtension<MapiaColors> {
  final Color bgBase;
  final Color bgSurface;
  final Color bgElevated;
  final Color bgCard;
  final Color bgHover;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDisabled;
  final Color sidebarBg;
  final Color sidebarRail;
  final Color accent;
  final Color accentSubtle;
  final Color success;
  final Color warning;
  final Color error;

  // HTTP Method colors
  final Color methodGet;
  final Color methodPost;
  final Color methodPut;
  final Color methodPatch;
  final Color methodDelete;
  final Color methodHead;
  final Color methodOptions;

  const MapiaColors({
    required this.bgBase,
    required this.bgSurface,
    required this.bgElevated,
    required this.bgCard,
    required this.bgHover,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDisabled,
    required this.sidebarBg,
    required this.sidebarRail,
    required this.accent,
    required this.accentSubtle,
    required this.success,
    required this.warning,
    required this.error,
    required this.methodGet,
    required this.methodPost,
    required this.methodPut,
    required this.methodPatch,
    required this.methodDelete,
    required this.methodHead,
    required this.methodOptions,
  });

  @override
  MapiaColors copyWith({
    Color? bgBase,
    Color? bgSurface,
    Color? bgElevated,
    Color? bgCard,
    Color? bgHover,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textDisabled,
    Color? sidebarBg,
    Color? sidebarRail,
    Color? accent,
    Color? accentSubtle,
    Color? success,
    Color? warning,
    Color? error,
    Color? methodGet,
    Color? methodPost,
    Color? methodPut,
    Color? methodPatch,
    Color? methodDelete,
    Color? methodHead,
    Color? methodOptions,
  }) {
    return MapiaColors(
      bgBase: bgBase ?? this.bgBase,
      bgSurface: bgSurface ?? this.bgSurface,
      bgElevated: bgElevated ?? this.bgElevated,
      bgCard: bgCard ?? this.bgCard,
      bgHover: bgHover ?? this.bgHover,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textDisabled: textDisabled ?? this.textDisabled,
      sidebarBg: sidebarBg ?? this.sidebarBg,
      sidebarRail: sidebarRail ?? this.sidebarRail,
      accent: accent ?? this.accent,
      accentSubtle: accentSubtle ?? this.accentSubtle,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      methodGet: methodGet ?? this.methodGet,
      methodPost: methodPost ?? this.methodPost,
      methodPut: methodPut ?? this.methodPut,
      methodPatch: methodPatch ?? this.methodPatch,
      methodDelete: methodDelete ?? this.methodDelete,
      methodHead: methodHead ?? this.methodHead,
      methodOptions: methodOptions ?? this.methodOptions,
    );
  }

  @override
  MapiaColors lerp(ThemeExtension<MapiaColors>? other, double t) {
    if (other is! MapiaColors) return this;
    return MapiaColors(
      bgBase: Color.lerp(bgBase, other.bgBase, t)!,
      bgSurface: Color.lerp(bgSurface, other.bgSurface, t)!,
      bgElevated: Color.lerp(bgElevated, other.bgElevated, t)!,
      bgCard: Color.lerp(bgCard, other.bgCard, t)!,
      bgHover: Color.lerp(bgHover, other.bgHover, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      sidebarBg: Color.lerp(sidebarBg, other.sidebarBg, t)!,
      sidebarRail: Color.lerp(sidebarRail, other.sidebarRail, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSubtle: Color.lerp(accentSubtle, other.accentSubtle, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      methodGet: Color.lerp(methodGet, other.methodGet, t)!,
      methodPost: Color.lerp(methodPost, other.methodPost, t)!,
      methodPut: Color.lerp(methodPut, other.methodPut, t)!,
      methodPatch: Color.lerp(methodPatch, other.methodPatch, t)!,
      methodDelete: Color.lerp(methodDelete, other.methodDelete, t)!,
      methodHead: Color.lerp(methodHead, other.methodHead, t)!,
      methodOptions: Color.lerp(methodOptions, other.methodOptions, t)!,
    );
  }

  static const dark = MapiaColors(
    bgBase: Color(0xFF0B0E14),
    bgSurface: Color(0xFF12171F),
    bgElevated: Color(0xFF181F29),
    bgCard: Color(0xFF1D2533),
    bgHover: Color(0xFF242C3D),
    border: Color(0xFF232D3F),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    textDisabled: Color(0xFF475569),
    sidebarBg: Color(0xFF07090D),
    sidebarRail: Color(0xFF030508),
    accent: AppColors.accent,
    accentSubtle: Color(0xFF15263F),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    methodGet: Color(0xFF10B981),
    methodPost: Color(0xFFF59E0B),
    methodPut: Color(0xFF3B82F6),
    methodPatch: Color(0xFFA855F7),
    methodDelete: Color(0xFFEF4444),
    methodHead: Color(0xFF06B6D4),
    methodOptions: Color(0xFF64748B),
  );

  static const light = MapiaColors(
    bgBase: Color(0xFFF8FAFC),
    bgSurface: Color(0xFFFFFFFF),
    bgElevated: Color(0xFFF1F5F9),
    bgCard: Color(0xFFE2E8F0),
    bgHover: Color(0xFFCBD5E1),
    border: Color(0xFFCBD5E1),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF64748B),
    textDisabled: Color(0xFF94A3B8),
    sidebarBg: Color(0xFFF1F5F9),
    sidebarRail: Color(0xFFE2E8F0),
    accent: AppColors.accent,
    accentSubtle: Color(0xFFE0F2FE),
    success: Color(0xFF059669),
    warning: Color(0xFFD97706),
    error: Color(0xFFDC2626),
    methodGet: Color(0xFF059669),
    methodPost: Color(0xFFD97706),
    methodPut: Color(0xFF2563EB),
    methodPatch: Color(0xFF9333EA),
    methodDelete: Color(0xFFDC2626),
    methodHead: Color(0xFF0891B2),
    methodOptions: Color(0xFF475569),
  );
}

extension MapiaColorsExtension on BuildContext {
  MapiaColors get colors => Theme.of(this).extension<MapiaColors>()!;
}
