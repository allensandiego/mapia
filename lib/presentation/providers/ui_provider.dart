import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_provider.dart';

final sidebarWidthProvider = StateProvider<double>((ref) => 240.0);
final showCodePanelProvider = StateProvider<bool>((ref) => false);
final codePanelWidthProvider = StateProvider<double>((ref) => 320.0);

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsProvider).themeMode;
});
