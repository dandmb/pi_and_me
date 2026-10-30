/// Politique et règles de limitation pour la sollicitation d'avis (In-App Review).
/// Conforme aux directives Apple StoreKit et Google Play Famille :
/// 1. Ne solliciter que lors d'un « Moment de Victoire » (Milestone).
/// 2. Pas de sollicitation prématurée (minimum de quiz et d'ancienneté).
/// 3. Espacement strict (cooldown de 30 jours minimum).
/// 4. Plafond absolu (3 présentations maximum à vie).
/// 5. Arrêt définitif dès que l'utilisateur a noté.
class RatingPromptPolicy {
  /// Nombre minimum de quiz terminés avant la 1ère sollicitation.
  final int minQuizzesCompleted;

  /// Score minimum obtenu sur le quiz en cours pour être qualifié de « Moment de Victoire ».
  final int minScoreForVictory;

  /// Nombre de jours d'attente requis entre deux sollicitations si reporté (« Plus tard »).
  final int cooldownDays;

  /// Nombre maximal de sollicitations autorisées.
  final int maxPromptCount;

  /// Ancienneté minimale requise depuis le premier lancement (en heures).
  final int minHoursSinceFirstLaunch;

  const RatingPromptPolicy({
    this.minQuizzesCompleted = 3,
    this.minScoreForVictory = 4,
    this.cooldownDays = 30,
    this.maxPromptCount = 3,
    this.minHoursSinceFirstLaunch = 24,
  });

  /// Évalue si toutes les conditions sont réunies pour présenter la demande d'avis.
  bool shouldPrompt({
    required bool hasRated,
    required int promptCount,
    required int quizzesCompletedCount,
    required int currentQuizScore,
    required DateTime? firstLaunchTime,
    required DateTime? lastPromptTime,
    required DateTime now,
  }) {
    // 1. Règle absolue : Si l'utilisateur a déjà noté, ne plus jamais afficher.
    if (hasRated) return false;

    // 2. Plafond strict : Ne jamais dépasser le quota maximal de sollicitations.
    if (promptCount >= maxPromptCount) return false;

    // 3. Condition de Victoire : Le score actuel doit être élevé (au moins 4/5 ou 4/6).
    if (currentQuizScore < minScoreForVictory) return false;

    // 4. Milestone d'usage : Doit avoir terminé au moins le nombre seuil de quiz.
    if (quizzesCompletedCount < minQuizzesCompleted) return false;

    // 5. Ancienneté minimale depuis la première ouverture.
    if (firstLaunchTime != null) {
      final hoursSinceFirstLaunch = now.difference(firstLaunchTime).inHours;
      if (hoursSinceFirstLaunch < minHoursSinceFirstLaunch) {
        return false;
      }
    }

    // 6. Règle de temporisation (Cooldown) après un refus ou report.
    if (lastPromptTime != null) {
      final daysSinceLastPrompt = now.difference(lastPromptTime).inDays;
      if (daysSinceLastPrompt < cooldownDays) {
        return false;
      }
    }

    return true;
  }
}
