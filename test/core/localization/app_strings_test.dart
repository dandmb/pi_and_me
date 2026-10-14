import 'package:flutter_test/flutter_test.dart';
import 'package:pi_et_moi/core/localization/app_language.dart';
import 'package:pi_et_moi/core/localization/app_strings.dart';
import 'package:pi_et_moi/features/profile/domain/school_grade.dart';

void main() {
  group('AppLanguage Enum Tests', () {
    test('English is the default language fallback', () {
      expect(AppLanguage.fromCode(null), AppLanguage.en);
      expect(AppLanguage.fromCode('unknown'), AppLanguage.en);
      expect(AppLanguage.fromCode('en'), AppLanguage.en);
      expect(AppLanguage.fromCode('fr'), AppLanguage.fr);
    });

    test('Supported languages have correct flags and codes', () {
      expect(AppLanguage.en.code, 'en');
      expect(AppLanguage.en.flag, '🇬🇧');
      expect(AppLanguage.fr.code, 'fr');
      expect(AppLanguage.fr.flag, '🇫🇷');
    });
  });

  group('AppStrings Translation Tests', () {
    const en = AppStrings(AppLanguage.en);
    const fr = AppStrings(AppLanguage.fr);

    test('English translations are accurate', () {
      expect(en.isFrench, isFalse);
      expect(en.splashBadge, 'Official curriculum from Grade 1 to 9');
      expect(en.loading, 'Loading...');
      expect(en.whoWillPlay, 'Who will play with Pi?');
      expect(en.yourName, 'Your first name');
      expect(en.yourGrade, 'Your grade');
      expect(en.letsGo, 'Let\'s go!');
      expect(en.playQuiz, 'Play Quiz');
      expect(en.hunger, 'Hunger');
      expect(en.joy, 'Joy');
      expect(en.energy, 'Energy');

      // Grades in English
      expect(en.getGradeLabel(SchoolGrade.cp), 'Grade 1');
      expect(en.getGradeLabel(SchoolGrade.cm1), 'Grade 4');
      expect(en.getGradeLabel(SchoolGrade.troisieme), 'Grade 9');
    });

    test('French translations are accurate', () {
      expect(fr.isFrench, isTrue);
      expect(fr.splashBadge, 'Programmes officiels du CP à la 3e');
      expect(fr.loading, 'Chargement...');
      expect(fr.whoWillPlay, 'Qui va jouer avec Pi ?');
      expect(fr.yourName, 'Ton prénom');
      expect(fr.yourGrade, 'Ta classe');
      expect(fr.letsGo, 'C\'est parti !');
      expect(fr.playQuiz, 'Jouer au Quiz');
      expect(fr.hunger, 'Faim');
      expect(fr.joy, 'Joie');
      expect(fr.energy, 'Énergie');

      // Grades in French
      expect(fr.getGradeLabel(SchoolGrade.cp), 'CP');
      expect(fr.getGradeLabel(SchoolGrade.cm1), 'CM1');
      expect(fr.getGradeLabel(SchoolGrade.troisieme), '3e');
    });
  });
}
