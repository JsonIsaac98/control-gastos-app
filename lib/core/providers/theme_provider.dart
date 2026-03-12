import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

const _kThemeModeKey = 'theme_mode';

/// Proveedor del modo de tema actual.
/// Default: ThemeMode.system (sigue al dispositivo)
/// Se persiste con SharedPreferences.
@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    _loadSavedMode(); // carga asíncrona, no bloquea
    return ThemeMode.system; // valor inicial
  }

  Future<void> _loadSavedMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kThemeModeKey);
    if (saved != null) {
      state = _fromString(saved);
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, _toString(mode));
  }

  /// Cicla entre system → light → dark → system
  Future<void> cycleMode() async {
    final next = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light  => ThemeMode.dark,
      ThemeMode.dark   => ThemeMode.system,
    };
    await setMode(next);
  }

  static ThemeMode _fromString(String s) => switch (s) {
        'light'  => ThemeMode.light,
        'dark'   => ThemeMode.dark,
        _        => ThemeMode.system,
      };

  static String _toString(ThemeMode m) => switch (m) {
        ThemeMode.light  => 'light',
        ThemeMode.dark   => 'dark',
        ThemeMode.system => 'system',
      };
}
