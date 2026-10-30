import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';

import '../data/rating_repository.dart';
import '../domain/rating_prompt_policy.dart';

/// Interface abstraite pour encapsuler InAppReview et faciliter les tests.
abstract class InAppReviewService {
  Future<bool> isAvailable();
  Future<void> requestReview();
  Future<void> openStoreListing();
}

/// Implémentation réelle utilisant le package officiel in_app_review.
class DefaultInAppReviewService implements InAppReviewService {
  final InAppReview _inAppReview = InAppReview.instance;

  @override
  Future<bool> isAvailable() => _inAppReview.isAvailable();

  @override
  Future<void> requestReview() => _inAppReview.requestReview();

  @override
  Future<void> openStoreListing() => _inAppReview.openStoreListing();
}

/// Fournisseur pour le service InAppReview.
final inAppReviewServiceProvider = Provider<InAppReviewService>((ref) {
  return DefaultInAppReviewService();
});

/// État du gestionnaire de notation.
class RatingState {
  final bool hasRated;
  final int promptCount;
  final int quizzesCompletedCount;
  final DateTime? lastPromptTime;
  final DateTime? firstLaunchTime;

  const RatingState({
    this.hasRated = false,
    this.promptCount = 0,
    this.quizzesCompletedCount = 0,
    this.lastPromptTime,
    this.firstLaunchTime,
  });

  RatingState copyWith({
    bool? hasRated,
    int? promptCount,
    int? quizzesCompletedCount,
    DateTime? lastPromptTime,
    DateTime? firstLaunchTime,
  }) {
    return RatingState(
      hasRated: hasRated ?? this.hasRated,
      promptCount: promptCount ?? this.promptCount,
      quizzesCompletedCount:
          quizzesCompletedCount ?? this.quizzesCompletedCount,
      lastPromptTime: lastPromptTime ?? this.lastPromptTime,
      firstLaunchTime: firstLaunchTime ?? this.firstLaunchTime,
    );
  }
}

/// Contrôleur gérant la stratégie de notation par milestones et les règles de limitation.
class RatingController extends StateNotifier<RatingState> {
  final RatingRepository repository;
  final RatingPromptPolicy policy;
  final InAppReviewService inAppReviewService;

  RatingController({
    required this.repository,
    this.policy = const RatingPromptPolicy(),
    required this.inAppReviewService,
  }) : super(const RatingState()) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final hasRated = await repository.getHasRated();
    final promptCount = await repository.getPromptCount();
    final quizzesCompletedCount = await repository.getQuizzesCompletedCount();
    final lastPromptTime = await repository.getLastPromptTime();
    final firstLaunchTime = await repository.getFirstLaunchTime();

    state = RatingState(
      hasRated: hasRated,
      promptCount: promptCount,
      quizzesCompletedCount: quizzesCompletedCount,
      lastPromptTime: lastPromptTime,
      firstLaunchTime: firstLaunchTime,
    );
  }

  /// Appelé à la fin d'un quiz pour enregistrer la progression et déterminer si
  /// la pop-up de célébration / notation doit être affichée.
  Future<bool> onQuizCompleted({
    required int currentScore,
    DateTime? mockNow,
  }) async {
    final now = mockNow ?? DateTime.now();

    // 1. Initialise la date de 1ère utilisation si non enregistrée
    await repository.ensureFirstLaunchInitialized(now);

    // 2. Incrémente le compteur total de quiz joués
    final updatedQuizzesCount =
        await repository.incrementQuizzesCompletedCount();

    // 3. Recharge les données fraîches
    final hasRated = await repository.getHasRated();
    final promptCount = await repository.getPromptCount();
    final lastPromptTime = await repository.getLastPromptTime();
    final firstLaunchTime = await repository.getFirstLaunchTime();

    state = state.copyWith(
      hasRated: hasRated,
      promptCount: promptCount,
      quizzesCompletedCount: updatedQuizzesCount,
      lastPromptTime: lastPromptTime,
      firstLaunchTime: firstLaunchTime,
    );

    // 4. Évalue la politique de limitation
    final shouldPrompt = policy.shouldPrompt(
      hasRated: hasRated,
      promptCount: promptCount,
      quizzesCompletedCount: updatedQuizzesCount,
      currentQuizScore: currentScore,
      firstLaunchTime: firstLaunchTime,
      lastPromptTime: lastPromptTime,
      now: now,
    );

    return shouldPrompt;
  }

  /// Déclenché quand l'utilisateur clique pour noter l'application.
  Future<void> rateApp() async {
    // Marque comme noté immédiatement pour ne plus jamais redemander
    await repository.setHasRated(true);
    state = state.copyWith(hasRated: true);

    try {
      final available = await inAppReviewService.isAvailable();
      if (available) {
        // Affiche la pop-up native du Store à l'intérieur de l'application
        await inAppReviewService.requestReview();
      } else {
        // En cas d'indisponibilité (ex: simulateur ou ancienne version de l'OS), ouvre la fiche Store
        await inAppReviewService.openStoreListing();
      }
    } catch (e) {
      debugPrint('[RatingController] Erreur in-app review: $e');
    }
  }

  /// Déclenché quand l'utilisateur reporte l'avis (« Plus tard »).
  Future<void> dismissLater({DateTime? mockNow}) async {
    final now = mockNow ?? DateTime.now();
    await repository.incrementPromptCount();
    await repository.setLastPromptTime(now);

    final updatedPromptCount = await repository.getPromptCount();

    state = state.copyWith(
      promptCount: updatedPromptCount,
      lastPromptTime: now,
    );
  }
}

/// Fournisseur Riverpod pour le contrôleur de notation.
final ratingControllerProvider =
    StateNotifierProvider<RatingController, RatingState>((ref) {
  final repository = ref.watch(ratingRepositoryProvider);
  final reviewService = ref.watch(inAppReviewServiceProvider);

  return RatingController(
    repository: repository,
    inAppReviewService: reviewService,
  );
});
