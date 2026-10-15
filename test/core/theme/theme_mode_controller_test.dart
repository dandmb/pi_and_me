import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/core/theme/theme_mode_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeModeNotifier Tests', () {
    test('initializes with default light theme', () {
      final notifier = ThemeModeNotifier();
      expect(notifier.state, equals(ThemeMode.light));
    });

    test('toggleTheme toggles between light and dark', () async {
      final notifier = ThemeModeNotifier();
      expect(notifier.state, equals(ThemeMode.light));

      await notifier.toggleTheme();
      expect(notifier.state, equals(ThemeMode.dark));

      await notifier.toggleTheme();
      expect(notifier.state, equals(ThemeMode.light));
    });

    test('setTheme persists to SharedPreferences', () async {
      final notifier = ThemeModeNotifier();
      await notifier.setTheme(ThemeMode.dark);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('pi_theme_mode_key'), equals('dark'));
    });
  });
}
