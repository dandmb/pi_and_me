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

  // --- Garde-robe (Wardrobe) ---
  String get wardrobeTab => isFrench ? 'Garde-robe' : 'Wardrobe';
  String get shopTab => isFrench ? 'Boutique' : 'Shop';
  String get wardrobeEmptyTitle => isFrench ? 'Garde-robe vide' : 'Empty Wardrobe';
  String get wardrobeEmptySubtitle => isFrench
      ? 'Tu n\'as pas encore d\'accessoires. Visite la boutique pour en acheter avec tes os dorés !'
      : 'You don\'t have any accessories yet. Visit the shop to buy some with your golden bones!';
  String get goToShop => isFrench ? 'Aller à la boutique' : 'Go to Shop';
  String get unequipAll => isFrench ? 'Tout enlever' : 'Unequip all';
  String get wearAction => isFrench ? 'Porter' : 'Wear';
  String get ownedBadge => isFrench ? 'Possédé' : 'Owned';
  String get cancelPreview => isFrench ? 'Annuler l\'essai' : 'Cancel preview';
  String get lockedBadge => isFrench ? 'Verrouillé' : 'Locked';
  String get inWardrobe => isFrench ? 'Dans la garde-robe' : 'In wardrobe';

  // --- Alertes & Textes Soins/Dodo ---
  String get piSleepingTitle => isFrench ? 'Pi dort paisiblement' : 'Pi is sleeping peacefully';
  String get piSleepingDesc => isFrench
      ? 'Il se repose bien au chaud dans sa chambre étoilée. Réveille-le d\'abord dans l\'onglet Dodo pour pouvoir jouer ou prendre soin de lui !'
      : 'He is resting warmly in his starry bedroom. Wake him up first in the Sleep tab to play or care for him!';
  String get piSleepingBanner => isFrench ? 'Pi dort paisiblement... Chut !' : 'Pi is sleeping peacefully... Shh!';
  String get piNeedsSleep => isFrench ? 'Pi a besoin d\'un bon dodo' : 'Pi needs a good nap';
  String get wakeUpAction => isFrench ? 'Réveiller' : 'Wake up';
  String get goToSleepAction => isFrench ? 'Faire dodo' : 'Put to sleep';
  String get piNeedsBath => isFrench ? 'Pi a besoin d\'un bon bain !' : 'Pi needs a good bath!';
  String get piAllClean => isFrench ? 'Pi est tout propre et brillant !' : 'Pi is all clean and fresh!';
  String get eatingInProgress => isFrench ? 'Repas en cours...' : 'Eating...';
  String get fullStomach => isFrench ? 'Rassasié' : 'Full';
  String get sleepAlertPlay => isFrench
      ? 'Pi dort paisiblement ! Réveille-le d\'abord dans Dodo pour jouer.'
      : 'Pi is sleeping peacefully! Wake him up first in Sleep mode to play.';
  String get sleepAlertFeed => isFrench
      ? 'Pi dort ! Réveille-le d\'abord dans Dodo pour le nourrir.'
      : 'Pi is sleeping! Wake him up first in Sleep mode to feed him.';
  String get sleepAlertWash => isFrench
      ? 'Pi dort ! Réveille-le d\'abord dans Dodo pour le laver.'
      : 'Pi is sleeping! Wake him up first in Sleep mode to wash him.';

  String get catchingBall => isFrench ? 'J\'attrape la balle !' : 'Catching the ball!';
  String get ballFound => isFrench ? 'Balle trouvée !' : 'Ball found!';
  String get guideHelp => isFrench ? 'Aide' : 'Help';
  String get guideEnvironmentsTitle => isFrench ? 'Décors immersifs' : 'Play Environments';
  String get guideEnvironmentsDesc => isFrench
      ? 'Choisis l\'endroit où Pi va s\'amuser : Salon, Jardin, Plage ou Forêt.'
      : 'Choose where Pi plays: Living Room, Garden, Beach or Forest.';
  String get guideVitalsTitle => isFrench ? 'Besoins vitaux de Pi' : 'Pi\'s Vital Gauges';
  String get guideVitalsDesc => isFrench
      ? 'Surveille la faim, la joie, l\'énergie et la propreté de Pi !'
      : 'Monitor Pi\'s hunger, joy, energy, and cleanliness!';
  String get guideInteractionTitle => isFrench ? 'Barre d\'interaction' : 'Interaction Bar';
  String get guideInteractionDesc => isFrench
      ? 'Lance la balle, sers les croquettes, lave Pi ou prépare sa sieste !'
      : 'Throw the ball, serve kibbles, wash Pi, or prepare for bedtime!';
  String get guideActionsTitle => isFrench ? 'Actions de soin' : 'Care & Play Tray';
  String get guideActionsDesc => isFrench
      ? 'Prends soin de Pi : Jouer à la balle, Nourrir, Laver dans la douche, Guider ou Dodo !'
      : 'Take care of Pi: Play fetch, Feed, Wash in dog shower, Guide, or Sleep!';
  String get piAsleep => isFrench ? 'Pi dort...' : 'Pi asleep...';
  String get sleepingStatus => isFrench ? 'Dort' : 'Sleeping';
  String get fullStatus => isFrench ? 'Rassasié' : 'Full';
  String get dirtyStatus => isFrench ? 'Sale' : 'Dirty';
  String get cleanStatus => isFrench ? 'Propre' : 'Clean';
  String get defaultFriendName => isFrench ? 'Ami' : 'Friend';
  String get languageActiveDescription => isFrench ? 'Français activé' : 'English active';
  String get noItemsInCategory => isFrench
      ? 'Aucun accessoire possédé dans cette catégorie.'
      : 'No owned accessories in this category.';
  String get dressingTitle => isFrench ? 'Dressing de Pi' : 'Pi\'s Dressing Room';

  // --- Limite quotidienne 6/6 & Écran de repos bienveillant ---
  String get dailyQuotaTitle => isFrench ? 'Parties du jour' : 'Daily Quizzes';
  String get dailyLimitReachedTitle =>
      isFrench ? 'Limite quotidienne atteinte !' : 'Daily limit reached!';
  String get quotaCompletedBadge =>
      isFrench ? '6/6 complété' : '6/6 completed';
  String piRestingTitle(String childName) => isFrench
      ? 'Bravo $childName ! Tu as bien travaillé !'
      : 'Bravo $childName! You worked great today!';
  String get piRestingSubtitle => isFrench
      ? 'Pi fait la sieste après toutes ces aventures.\nReviens demain pour 6 nouvelles parties !'
      : 'Pi is taking a nap after all those adventures.\nCome back tomorrow for 6 new quizzes!';
  String get nextResetIn =>
      isFrench ? 'Prochaine réinitialisation dans :' : 'Next reset in:';
  String resetCountdownFormatted(int hours, int minutes) =>
      '${hours.toString().padLeft(2, '0')}h : ${minutes.toString().padLeft(2, '0')}m';
  String get offlineActivityHeader =>
      isFrench ? 'L\'activité hors-écran du jour :' : 'Today\'s off-screen activity:';
  String get seePiRestAction =>
      isFrench ? 'Voir Pi se reposer (6/6)' : 'See Pi resting (6/6)';
  String get takeCareOfPiAction =>
      isFrench ? 'Prendre soin de Pi' : 'Take care of Pi';
  String get dailyLimitHomeNotice => isFrench
      ? 'Zzz... Pi fait sa sieste ! Tu as complété tes 6 parties du jour. Reviens demain !'
      : 'Zzz... Pi is napping! You completed your 6 quizzes for today. Come back tomorrow!';
  String get offlineActivityWindowCount => isFrench
      ? 'Compte combien de fenêtres et de portes il y a dans ta maison !'
      : 'Count how many windows and doors there are in your home!';
  String get offlineActivityPlayOutside => isFrench
      ? 'Va jouer dehors, respirer le grand air ou faire un tour de vélo !'
      : 'Go play outside, get some fresh air or ride a bicycle!';
  String get offlineActivityDrawPi => isFrench
      ? 'Prends des feutres et dessine Pi avec son plus bel accessoire !'
      : 'Grab markers and draw a portrait of Pi with their favorite accessory!';
  String get offlineActivityReadBook => isFrench
      ? 'Installe-toi confortablement pour lire un chapitre d\'une belle histoire !'
      : 'Get comfy and read a chapter from a great storybook or comic!';
  String get offlineActivityFindShapes => isFrench
      ? 'Chasse aux trésors : trouve 5 cercles ou rectangles cachés dans ta chambre !'
      : 'Treasure hunt: find 5 circles or rectangles hidden in your room!';
  String get careDisabledWhenLimitReached => isFrench
      ? 'Pi dort · Soins désactivés'
      : 'Pi is sleeping · Care disabled';
  String get shopClosedWhenLimitReached => isFrench
      ? 'Pi dort · Boutique fermée'
      : 'Pi is sleeping · Shop closed';
  String get allActivitiesSleeping => isFrench
      ? 'Pi fait un gros dodo ! Les soins et la boutique rouvriront demain.'
      : 'Pi is having a good sleep! Care and shop will reopen tomorrow.';
}


