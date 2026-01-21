import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

/// Theme mode options
enum AppThemeMode {
  light('Light', Icons.light_mode),
  dark('Dark', Icons.dark_mode),
  system('System', Icons.smartphone);

  final String label;
  final IconData icon;

  const AppThemeMode(this.label, this.icon);

  /// Convert to Flutter ThemeMode
  ThemeMode toThemeMode() {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

/// Theme provider with persistence
@Riverpod(keepAlive: true)
class AppTheme extends _$AppTheme {
  static const _storageKey = 'theme_mode';

  @override
  AppThemeMode build() {
    // Load saved preference (async, will update state when ready)
    _loadSavedTheme();

    // Default to system
    return AppThemeMode.system;
  }

  Future<void> _loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_storageKey);
      if (saved != null) {
        final theme = AppThemeMode.values.firstWhere(
          (e) => e.name == saved,
          orElse: () => AppThemeMode.system,
        );
        state = theme;
      }
    } catch (_) {
      // Ignore errors, use default
    }
  }

  /// Set theme mode
  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;

    // Persist preference
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, mode.name);
    } catch (_) {
      // Ignore errors
    }
  }
}

/// Convenience provider for Flutter ThemeMode
@Riverpod(keepAlive: true)
ThemeMode themeMode(Ref ref) {
  return ref.watch(appThemeProvider).toThemeMode();
}
