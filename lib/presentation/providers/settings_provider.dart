import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final ThemeMode themeMode;
  final bool sslVerification;
  final int requestTimeoutMs;
  final String proxyHost;
  final int proxyPort;

  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.sslVerification = true,
    this.requestTimeoutMs = 30000,
    this.proxyHost = '',
    this.proxyPort = 8080,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? sslVerification,
    int? requestTimeoutMs,
    String? proxyHost,
    int? proxyPort,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      sslVerification: sslVerification ?? this.sslVerification,
      requestTimeoutMs: requestTimeoutMs ?? this.requestTimeoutMs,
      proxyHost: proxyHost ?? this.proxyHost,
      proxyPort: proxyPort ?? this.proxyPort,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.index,
        'sslVerification': sslVerification,
        'requestTimeoutMs': requestTimeoutMs,
        'proxyHost': proxyHost,
        'proxyPort': proxyPort,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        themeMode: ThemeMode.values[json['themeMode'] as int? ?? 0],
        sslVerification: json['sslVerification'] as bool? ?? true,
        requestTimeoutMs: json['requestTimeoutMs'] as int? ?? 30000,
        proxyHost: json['proxyHost'] as String? ?? '',
        proxyPort: json['proxyPort'] as int? ?? 8080,
      );
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const _key = 'mapia_settings';

  @override
  AppSettings build() {
    _load();
    return const AppSettings();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        state = AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {}
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toJson()));
  }

  Future<void> update(AppSettings settings) async {
    state = settings;
    await _save();
  }

  Future<void> setThemeMode(ThemeMode mode) => update(state.copyWith(themeMode: mode));
  Future<void> setSslVerification(bool v) => update(state.copyWith(sslVerification: v));
  Future<void> setRequestTimeout(int ms) => update(state.copyWith(requestTimeoutMs: ms));
  Future<void> setProxy(String host, int port) => update(state.copyWith(proxyHost: host, proxyPort: port));
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
