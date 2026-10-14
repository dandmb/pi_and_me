import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_language.dart';
import 'app_strings.dart';

const String _keyAppLanguage = 'pi_app_language';

/// Contrôleur de gestion de la langue active dans l'application.
/// Règle : Détecte la langue du système.
/// - Si le système est en Français ('fr') -> Français.
/// - Si c'est une autre langue -> Anglais par défaut.
/// - Si l'utilisateur a choisi manuellement dans les paramètres -> son choix prévaut.
class LanguageNotifier extends StateNotifier<AppLanguage> {
  final SharedPreferences? prefs;
  final String? systemLocaleCodeOverride; // Pour tester l'injection de langue système

  LanguageNotifier({
    this.prefs,
    this.systemLocaleCodeOverride,
  }) : super(resolveInitialLanguage(
          prefs: prefs,
          systemCode: systemLocaleCodeOverride,
        )) {
    _loadSavedLanguage();
  }

  /// Résout la langue initiale en fonction des préférences enregistrées ou de la langue système.
  static AppLanguage resolveInitialLanguage({
    SharedPreferences? prefs,
    String? systemCode,
  }) {
    // 1. Choix explicite enregistré par l'utilisateur dans les paramètres
    final savedCode = prefs?.getString(_keyAppLanguage);
    if (savedCode != null) {
      return AppLanguage.fromCode(savedCode);
    }

    // 2. Détection de la langue du système
    final rawSystemCode = systemCode ?? ui.PlatformDispatcher.instance.locale.languageCode;
    if (rawSystemCode.toLowerCase().startsWith('fr')) {
      return AppLanguage.fr;
    }

    // 3. Fallback : Anglais pour toute autre langue
    return AppLanguage.en;
  }

  Future<void> _loadSavedLanguage() async {
    final sp = prefs ?? await SharedPreferences.getInstance();
    final savedCode = sp.getString(_keyAppLanguage);
    if (savedCode != null) {
      state = AppLanguage.fromCode(savedCode);
    } else {
      final rawSystemCode = systemLocaleCodeOverride ?? ui.PlatformDispatcher.instance.locale.languageCode;
      state = rawSystemCode.toLowerCase().startsWith('fr')
          ? AppLanguage.fr
          : AppLanguage.en;
    }
  }

  /// Change la langue manuellement dans les paramètres et sauvegarde le choix.
  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    final sp = prefs ?? await SharedPreferences.getInstance();
    await sp.setString(_keyAppLanguage, language.code);
  }

  /// Réinitialise sur la détection automatique du système.
  Future<void> resetToSystemLanguage() async {
    final sp = prefs ?? await SharedPreferences.getInstance();
    await sp.remove(_keyAppLanguage);
    final rawSystemCode = systemLocaleCodeOverride ?? ui.PlatformDispatcher.instance.locale.languageCode;
    state = rawSystemCode.toLowerCase().startsWith('fr')
        ? AppLanguage.fr
        : AppLanguage.en;
  }
}

/// Provider global de la langue active.
final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  return LanguageNotifier();
});

/// Provider global des chaînes de caractères localisées.
final stringsProvider = Provider<AppStrings>((ref) {
  final language = ref.watch(languageProvider);
  return AppStrings(language);
});
