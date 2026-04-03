import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'mapia_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.dark,
        ),
        textTheme: AppTypography.textTheme,
        extensions: const [MapiaColors.dark],
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.light,
        ),
        textTheme: AppTypography.textTheme,
        extensions: const [MapiaColors.light],
      );
}
