import '../../features/profile/domain/school_grade.dart';
import 'app_language.dart';

/// Système de chaînes de caractères bilingue (Anglais par défaut / Français).
/// Typé, auto-complété, sans over-ingénierie ni compilation lourde.
class AppStrings {
  final AppLanguage language;

  const AppStrings(this.language);

  bool get isFrench => language == AppLanguage.fr;

  // --- Titre & Splash ---
  String get appTitle => 'Pi & Moi';
  String get splashBadge => isFrench
      ? 'Programmes officiels du CP à la 3e'
      : 'Official curriculum from Grade 1 to 9';
  String get loading => isFrench ? 'Chargement...' : 'Loading...';

  // --- Onboarding ---
  String get onboardingWelcome => isFrench
      ? 'Wouf ! Crée ton profil pour jouer avec moi !'
      : 'Woof! Create your profile to play with me!';
  String get whoWillPlay => isFrench
      ? 'Qui va jouer avec Pi ?'
      : 'Who will play with Pi?';
  String get chooseAvatar => isFrench ? 'Choisis ton avatar' : 'Choose your avatar';
  String get yourName => isFrench ? 'Ton prénom' : 'Your first name';
  String get nameHint => isFrench ? 'Ex: Léa' : 'E.g. Alex';
  String get nameEmptyError => isFrench
      ? 'Wouf ! Quel est ton prénom ?'
      : 'Woof! What is your name?';
  String get yourGrade => isFrench ? 'Ta classe' : 'Your grade';
  String get letsGo => isFrench ? 'C\'est parti !' : 'Let\'s go!';

  // --- Avatars ---
  String avatarLabel(String id) {
    switch (id) {
      case 'avatar_dog':
        return isFrench ? 'Pi' : 'Pi';
      case 'avatar_cat':
        return isFrench ? 'Minou' : 'Kitty';
      case 'avatar_fox':
        return isFrench ? 'Renard' : 'Fox';
      case 'avatar_bear':
        return isFrench ? 'Ourson' : 'Bear';
      default:
        return 'Ami';
    }
  }

  // --- Niveaux scolaires & Cycles ---
  String getGradeLabel(SchoolGrade grade) {
    if (isFrench) {
      return grade.label; // CP, CE1, CE2, CM1, CM2, 6e, 5e, 4e, 3e
    }
    // Adaptation internationale pour l'anglais (Grades 1 to 9)
    switch (grade) {
      case SchoolGrade.cp:
        return 'Grade 1';
      case SchoolGrade.ce1:
        return 'Grade 2';
      case SchoolGrade.ce2:
        return 'Grade 3';
      case SchoolGrade.cm1:
        return 'Grade 4';
      case SchoolGrade.cm2:
        return 'Grade 5';
      case SchoolGrade.sixieme:
        return 'Grade 6';
      case SchoolGrade.cinquieme:
        return 'Grade 7';
      case SchoolGrade.quatrieme:
        return 'Grade 8';
      case SchoolGrade.troisieme:
        return 'Grade 9';
    }
  }

  String getCycleLabel(SchoolGrade grade) {
    if (isFrench) {
      return grade.cycleLabel;
    }
    switch (grade.cycle) {
      case 2:
        return 'Cycle 2 (Elementary 1-3)';
      case 3:
        return 'Cycle 3 (Middle 4-6)';
      case 4:
        return 'Cycle 4 (Junior High 7-9)';
      default:
        return 'Curriculum';
    }
  }

  // --- Salon de Pi (Home) ---
  String readyForQuiz(String childName) => isFrench
      ? 'Wouf ! Prête pour le quiz, $childName ?'
      : 'Woof! Ready for the quiz, $childName?';
  String get hunger => isFrench ? 'Faim' : 'Hunger';
  String get joy => isFrench ? 'Joie' : 'Joy';
  String get energy => isFrench ? 'Énergie' : 'Energy';
  String get playQuiz => isFrench ? 'Jouer au Quiz' : 'Play Quiz';
  String get changeProfile => isFrench ? 'Changer de profil' : 'Change profile';
  String get phase2Notice => isFrench
      ? 'Le moteur mathématique arrive en Phase 2 !'
      : 'Math engine coming in Phase 2!';

  // --- Paramètres / Settings ---
  String get settings => isFrench ? 'Paramètres' : 'Settings';
  String get languageTitle => isFrench ? 'Langue de l\'application' : 'App Language';
  String get close => isFrench ? 'Fermer' : 'Close';
}
