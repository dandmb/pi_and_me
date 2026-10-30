import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clés de stockage local SharedPreferences pour le suivi des avis.
abstract class RatingPrefKeys {
  static const String hasRated = 'rating_has_rated';
  static const String promptCount = 'rating_prompt_count';
  static const String lastPromptMs = 'rating_last_prompt_ms';
  static const String firstLaunchMs = 'rating_first_launch_ms';
  static const String quizzesCompletedCount = 'rating_quizzes_completed_count';
}

/// Dépôt assurant la persistance locale de l'état de notation.
class RatingRepository {
  SharedPreferences? _prefs;

  RatingRepository({SharedPreferences? prefsInstance})
      : _prefs = prefsInstance;

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<bool> getHasRated() async {
    final prefs = await _getPrefs();
    return prefs.getBool(RatingPrefKeys.hasRated) ?? false;
  }

  Future<void> setHasRated(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(RatingPrefKeys.hasRated, value);
  }

  Future<int> getPromptCount() async {
    final prefs = await _getPrefs();
    return prefs.getInt(RatingPrefKeys.promptCount) ?? 0;
  }

  Future<void> incrementPromptCount() async {
    final prefs = await _getPrefs();
    final current = prefs.getInt(RatingPrefKeys.promptCount) ?? 0;
    await prefs.setInt(RatingPrefKeys.promptCount, current + 1);
  }

  Future<DateTime?> getLastPromptTime() async {
    final prefs = await _getPrefs();
    final ms = prefs.getInt(RatingPrefKeys.lastPromptMs);
    if (ms == null || ms == 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> setLastPromptTime(DateTime time) async {
    final prefs = await _getPrefs();
    await prefs.setInt(
      RatingPrefKeys.lastPromptMs,
      time.millisecondsSinceEpoch,
    );
  }

  Future<DateTime?> getFirstLaunchTime() async {
    final prefs = await _getPrefs();
    final ms = prefs.getInt(RatingPrefKeys.firstLaunchMs);
    if (ms == null || ms == 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> ensureFirstLaunchInitialized(DateTime now) async {
    final prefs = await _getPrefs();
    if (!prefs.containsKey(RatingPrefKeys.firstLaunchMs)) {
      await prefs.setInt(
        RatingPrefKeys.firstLaunchMs,
        now.millisecondsSinceEpoch,
      );
    }
  }

  Future<int> getQuizzesCompletedCount() async {
    final prefs = await _getPrefs();
    return prefs.getInt(RatingPrefKeys.quizzesCompletedCount) ?? 0;
  }

  Future<int> incrementQuizzesCompletedCount() async {
    final prefs = await _getPrefs();
    final current = prefs.getInt(RatingPrefKeys.quizzesCompletedCount) ?? 0;
    final updated = current + 1;
    await prefs.setInt(RatingPrefKeys.quizzesCompletedCount, updated);
    return updated;
  }
}

/// Fournisseur Riverpod pour le dépôt de notation.
final ratingRepositoryProvider = Provider<RatingRepository>((ref) {
  return RatingRepository();
});
