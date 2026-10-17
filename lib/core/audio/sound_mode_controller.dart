import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notifier Riverpod gérant l'activation globale des effets sonores dans MathPup.
/// Persiste le choix dans les SharedPreferences de l'appareil.
class SoundModeNotifier extends StateNotifier<bool> {
  static const String _storageKey = 'mathpup_sound_enabled_v1';
  final SharedPreferences? _prefs;

  SoundModeNotifier({SharedPreferences? prefsInstance, bool initialValue = true})
      : _prefs = prefsInstance,
        super(initialValue) {
    if (prefsInstance == null) {
      _loadFromPrefs();
    }
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool(_storageKey);
      if (saved != null) {
        state = saved;
      }
    } catch (_) {}
  }

  /// Active ou coupe les effets sonores
  Future<void> setSoundEnabled(bool enabled) async {
    state = enabled;
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setBool(_storageKey, enabled);
    } catch (_) {}
  }

  /// Bascule l'état du son (ON -> OFF -> ON)
  Future<void> toggle() => setSoundEnabled(!state);
}

final soundEnabledProvider =
    StateNotifierProvider<SoundModeNotifier, bool>((ref) {
  return SoundModeNotifier();
});
