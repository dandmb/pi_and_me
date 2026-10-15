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
  String get piNotHungry =>
      isFrench ? 'Pi n\'a pas faim pour le moment ! 🐾' : 'Pi isn\'t hungry right now! 🐾';
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
  String get themeTitle => isFrench ? 'Mode Sombre / Apparence' : 'Dark Mode / Appearance';
  String get lightTheme => isFrench ? 'Clair' : 'Light';
  String get darkTheme => isFrench ? 'Sombre' : 'Dark';
  String get systemTheme => isFrench ? 'Système' : 'System';
  String get close => isFrench ? 'Fermer' : 'Close';

  // --- Profils & Sélecteur ---
  String get profilesTitle => isFrench ? 'Profils des enfants' : 'Child Profiles';
  String get activeProfileLabel => isFrench ? 'Actif' : 'Active';
  String get addProfile => isFrench ? 'Ajouter un profil' : 'Add profile';
  String get maxProfilesReached => isFrench ? 'Maximum 4 profils atteints' : 'Maximum 4 profiles reached';
  String get deleteProfileConfirm => isFrench ? 'Supprimer ce profil ?' : 'Delete this profile?';
  String deleteProfileWarning(String name) => isFrench
      ? 'La progression et les données de $name seront définitivement effacées.'
      : 'All progress and data for $name will be permanently deleted.';
  String get cancel => isFrench ? 'Annuler' : 'Cancel';
  String get delete => isFrench ? 'Supprimer' : 'Delete';
  String get profileActivated => isFrench ? 'Profil activé !' : 'Profile activated!';

  // --- Confirmation Quitter l'application ---
  String get confirmExitTitle => isFrench ? 'Quitter Pi & Moi ?' : 'Exit Pi & Moi?';
  String get confirmExitMessage => isFrench
      ? 'À très vite pour jouer et apprendre avec Pi !'
      : 'See you very soon to learn and play with Pi!';
  String get continuePlaying => isFrench ? 'Continuer à jouer' : 'Keep playing';

  // --- Gestion des erreurs ---
  String get errorTitle => isFrench ? 'Oups ! Une petite bêtise...' : 'Oops! A little hiccup...';
  String get errorMessage => isFrench
      ? 'Pi s\'occupe de tout réparer !'
      : 'Pi is taking care of everything!';
  String get retry => isFrench ? 'Réessayer' : 'Retry';
  String get returnToHome => isFrench ? 'Retour au salon' : 'Return to Home';

  // --- Quiz ---
  String get stressFree => isFrench ? '🌱 Sans stress' : '🌱 Stress-free';
  String questionProgress(int current, int total) =>
      isFrench ? 'Question $current / $total' : 'Question $current / $total';
  String get validateAnswer =>
      isFrench ? 'Valider la réponse 🚀' : 'Submit answer 🚀';
  String get nextQuestion =>
      isFrench ? 'Question suivante ➔' : 'Next question ➔';
  String get seeResults =>
      isFrench ? 'Voir les résultats ✨' : 'See results ✨';
  String get selectAnOptionNotice =>
      isFrench ? 'Choisis une réponse pour valider' : 'Select an answer to submit';
  String get correctFeedback =>
      isFrench ? 'Bravo ! C\'est la bonne réponse ! 🐾' : 'Great job! That\'s correct! 🐾';
  String wrongFeedback(String answer) => isFrench
      ? 'Presque ! La bonne réponse était $answer. 🐾'
      : 'Almost! The correct answer was $answer. 🐾';
  String get quitQuizTitle =>
      isFrench ? 'Quitter le quiz ?' : 'Leave quiz?';
  String get quitQuizMessage => isFrench
      ? 'Ta progression sur ce quiz ne sera pas enregistrée.'
      : 'Your progress in this quiz will not be saved.';
  String get stay => isFrench ? 'Continuer' : 'Continue';
  String get quit => isFrench ? 'Quitter' : 'Leave';

  // --- Résultats / Results ---
  String get quizCompleted =>
      isFrench ? 'Quiz Terminé !' : 'Quiz Completed!';
  String quizBravo(String name) =>
      isFrench ? 'Bravo $name !' : 'Well done $name!';
  String quizSummary(int score, int total) =>
      isFrench ? 'Score : $score / $total' : 'Score: $score / $total';
  String quizEncouragement(int score, int total) {
    if (score == total) {
      return isFrench
          ? 'Incroyable ! Un sans-faute parfait !'
          : 'Incredible! A perfect score!';
    } else if (score >= total / 2) {
      return isFrench
          ? 'Super travail ! Tu progresses à grands pas !'
          : 'Great work! You are making huge progress!';
    } else {
      return isFrench
          ? 'Bien joué ! Chaque entraînement te rend plus fort !'
          : 'Well done! Practice makes you stronger!';
    }
  }
  String get rewardsEarned =>
      isFrench ? 'Récompenses gagnées' : 'Earned rewards';
  String get goldenBones => isFrench ? 'Os dorés' : 'Golden bones';
  String get croquettes => isFrench ? 'Croquettes' : 'Kibbles';
  String get balls => isFrench ? 'Balles' : 'Balls';
  String streakDays(int days) => isFrench
      ? 'Série : $days jour${days > 1 ? "s" : ""}'
      : 'Streak: $days day${days > 1 ? "s" : ""}';
  String get feedAndCare =>
      isFrench ? 'Nourrir & Soigner Pi' : 'Feed & Care for Pi';
  String get backToHome =>
      isFrench ? 'Retour au salon' : 'Back to living room';

  // --- Soins & Aire de Jeu (Care & Play) ---
  String get careTitle =>
      isFrench ? 'Prendre soin de Pi' : 'Care for Pi';
  String get playArea =>
      isFrench ? 'Aire de jeu' : 'Playground';
  String get livingRoomEnv =>
      isFrench ? 'Salon' : 'Living Room';
  String get gardenEnv =>
      isFrench ? 'Jardin' : 'Garden';
  String get beachEnv =>
      isFrench ? 'Plage' : 'Beach';
  String get forestEnv =>
      isFrench ? 'Forêt' : 'Forest';
  String get feedAction =>
      isFrench ? 'Nourrir' : 'Feed';
  String get playAction =>
      isFrench ? 'Jouer' : 'Play';
  String get walkAction =>
      isFrench ? 'Guider' : 'Guide';
  String get sleepAction =>
      isFrench ? 'Dodo' : 'Sleep';
  String available(int count) =>
      isFrench ? '$count dispo' : '$count left';
  String get unlimited =>
      isFrench ? 'Illimité' : 'Unlimited';
  String get tapToPlay => isFrench
      ? 'Touche le terrain pour diriger Pi !'
      : 'Tap the ground to guide Pi!';
  String get throwBallAction =>
      isFrench ? 'Lancer la balle' : 'Throw the ball';
  String get piChasingBall =>
      isFrench ? 'Pi court après la balle !' : 'Pi is running after the ball!';
  String get piFetchedBall =>
      isFrench ? 'Wouf ! Balle rapportée ! (+25% Joie)' : 'Woof! Ball fetched! (+25% Joy)';
  String get ballInPlay => isFrench
      ? 'Une balle est déjà en jeu ! Touche le terrain pour guider Pi.'
      : 'A ball is already in play! Tap the screen to guide Pi.';
  String get noBallsLeft => isFrench
      ? 'Plus de balle ! Réussis un quiz pour en gagner.'
      : 'No balls left! Complete a quiz to get more.';
  String get serveAction =>
      isFrench ? 'Servir' : 'Serve';
  String get comeEatAction =>
      isFrench ? 'Viens manger !' : 'Come eat!';
  String get bowlFilled => isFrench
      ? 'Croquette servie dans la gamelle !'
      : 'Kibble served in the bowl!';
  String get bowlFull => isFrench
      ? 'La gamelle est pleine !'
      : 'The bowl is full!';
  String get piEating => isFrench
      ? 'Miam miam miam...'
      : 'Yum yum yum...';
  String get piFinishedEating => isFrench
      ? 'Miam ! Délicieux repas, merci ! (+Faim)'
      : 'Yum! Delicious meal, thank you! (+Hunger)';
  String get noFoodLeft => isFrench
      ? 'Plus de croquettes ! Réussis un quiz pour en gagner.'
      : 'No kibbles left! Complete a quiz to get more.';
  String get cleanAction =>
      isFrench ? 'Laver' : 'Wash';
  String get piCleaned => isFrench
      ? 'Tout propre et tout frais ! (+15% Joie)'
      : 'All clean and fresh! (+15% Joy)';
  String get cleanliness =>
      isFrench ? 'Propreté' : 'Cleanliness';
  String get piRested => isFrench
      ? 'Chut... Pi se repose bien (+30% Énergie)'
      : 'Shh... Pi is resting well (+30% Energy)';
  String get piFed => isFrench
      ? 'Miam ! Pi s\'est régalé ! (+25% Faim)'
      : 'Yum! Pi enjoyed the treat! (+25% Hunger)';
  String get needMoreQuiz => isFrench
      ? 'Fais un quiz pour gagner plus de récompenses !'
      : 'Take a quiz to win more rewards!';
  String get careDockLabel =>
      isFrench ? 'Soigner' : 'Care';
  String get salonDockLabel =>
      isFrench ? 'Salon' : 'Home';
  String get shopDockLabel =>
      isFrench ? 'Boutique' : 'Shop';

  // --- Boutique de Pi (Shop) ---
  String get shopTitle => isFrench ? 'Boutique de Pi' : 'Pi\'s Shop';
  String get shopSubtitle => isFrench
      ? 'Habille et personnalise ton compagnon !'
      : 'Dress and customize your puppy!';
  String get fittingRoom => isFrench ? 'Cabine d\'essayage' : 'Fitting Room';
  String piTries(String name) =>
      isFrench ? 'Pi essaie : $name' : 'Pi is trying on: $name';
  String piWears(String name) =>
      isFrench ? 'Pi porte : $name' : 'Pi is wearing: $name';
  String get piNatural => isFrench
      ? 'Pi au naturel ! Choisis un accessoire.'
      : 'Natural Pi! Choose an accessory.';
  String get equipAction => isFrench ? 'Équiper' : 'Equip';
  String get equippedBadge => isFrench ? 'Équipé' : 'Equipped';
  String get unequipAction => isFrench ? 'Retirer' : 'Unequip';
  String buyAction(int price) => isFrench ? 'Acheter ($price)' : 'Buy ($price)';
  String lockedGrade(String grade) =>
      isFrench ? 'Niveau $grade' : 'Grade $grade';
}
