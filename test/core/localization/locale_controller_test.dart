import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/core/localization/app_language.dart';
import 'package:pi_et_moi/core/localization/locale_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LanguageNotifier System Language Detection', () {
    test('Detects French when system language is French (fr)', () {
      final notifier = LanguageNotifier(systemLocaleCodeOverride: 'fr');
      expect(notifier.state, AppLanguage.fr);
    });

    test('Detects French with regional code like fr_FR or fr_CA', () {
      final notifier = LanguageNotifier(systemLocaleCodeOverride: 'fr_CA');
      expect(notifier.state, AppLanguage.fr);
    });

    test('Falls back to English when system language is English (en)', () {
      final notifier = LanguageNotifier(systemLocaleCodeOverride: 'en');
      expect(notifier.state, AppLanguage.en);
    });

    test('Falls back to English for any other language (e.g. Spanish, German, Japanese)', () {
      final notifierEs = LanguageNotifier(systemLocaleCodeOverride: 'es');
      expect(notifierEs.state, AppLanguage.en);

      final notifierDe = LanguageNotifier(systemLocaleCodeOverride: 'de');
      expect(notifierDe.state, AppLanguage.en);

      final notifierJa = LanguageNotifier(systemLocaleCodeOverride: 'ja');
      expect(notifierJa.state, AppLanguage.en);
    });

    test('User manual setting in settings overrides system language', () async {
      SharedPreferences.setMockInitialValues({'pi_app_language': 'en'});

      // System is French, but user manually chose English in settings
      final notifier = LanguageNotifier(systemLocaleCodeOverride: 'fr');
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state, AppLanguage.en);
    });

    test('Switching language persists in SharedPreferences', () async {
      final notifier = LanguageNotifier(systemLocaleCodeOverride: 'en');
      expect(notifier.state, AppLanguage.en);

      await notifier.setLanguage(AppLanguage.fr);
      expect(notifier.state, AppLanguage.fr);

      final sp = await SharedPreferences.getInstance();
      expect(sp.getString('pi_app_language'), 'fr');
    });
  });
}
