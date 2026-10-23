import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../profile/presentation/profile_controller.dart';
import '../domain/daily_limit_state.dart';

/// Contrôleur Riverpod pour gérer la limite quotidienne bienveillante de temps d'écran (6/6).
class DailyLimitController extends StateNotifier<DailyLimitState> {
  static const String _storagePrefix = 'pi_daily_limit_state_v1_';
  SharedPreferences? _prefs;

  DailyLimitController({
    SharedPreferences? prefs,
    String initialProfileId = 'default',
    DailyLimitState? initialState,
  }) : super(
         initialState ??
             DailyLimitState(
               profileId: initialProfileId,
               lastSessionDate: DateTime.now(),
             ),
       ) {
    _prefs = prefs;
    if (initialState == null) {
      _init();
    }
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Calcule la durée restante avant minuit (prochaine réinitialisation).
  static Duration timeUntilMidnight([DateTime? from]) {
    final now = from ?? DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return tomorrow.difference(now);
  }

  Future<void> _init() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      if (!mounted) return;
      await loadProfileQuota(state.profileId);
    } catch (e) {
      if (mounted) {
        debugPrint('[DailyLimitController] Error during init: $e');
      }
    }
  }

  /// Charge le quota stocké pour un profil enfant spécifique.
  Future<void> loadProfileQuota(String profileId) async {
    _prefs ??= await SharedPreferences.getInstance();
    if (!mounted) return;
    final key = '$_storagePrefix$profileId';
    final raw = _prefs?.getString(key);

    final now = DateTime.now();
    if (raw != null) {
      try {
        final loaded = DailyLimitState.fromJson(raw);
        if (!mounted) return;
        // Vérifie si la nuit est passée (changement de jour -> réinitialisation à 0)
        if (!isSameDay(now, loaded.lastSessionDate)) {
          state = DailyLimitState(
            profileId: profileId,
            usedSessionsToday: 0,
            maxDailySessions: loaded.maxDailySessions,
            lastSessionDate: now,
            isUnlockedByParent: false,
          );
          await _save();
        } else {
          state = loaded.copyWith(profileId: profileId);
        }
        return;
      } catch (e) {
        debugPrint('[DailyLimitController] Parsing error, reset state: $e');
      }
    }

    if (!mounted) return;
    // Aucun état enregistré pour ce profil : valeur par défaut (0/6)
    state = DailyLimitState(
      profileId: profileId,
      usedSessionsToday: 0,
      maxDailySessions: 6,
      lastSessionDate: now,
      isUnlockedByParent: false,
    );
    await _save();
  }

  /// Enregistre une partie de quiz terminée pour la journée.
  Future<void> recordCompletedQuiz([int count = 1]) async {
    _checkMidnightRollover();
    final newUsed = state.usedSessionsToday + count;
    state = state.copyWith(
      usedSessionsToday: newUsed,
      lastSessionDate: DateTime.now(),
    );
    await _save();
  }

  /// Débloque temporairement l'application par le parent (passe-droit adulte).
  Future<void> grantParentOverride() async {
    state = state.copyWith(
      isUnlockedByParent: true,
      lastSessionDate: DateTime.now(),
    );
    await _save();
  }

  /// Accorde une ou plusieurs sessions bonus supplémentaires pour aujourd'hui.
  Future<void> grantBonusSession([int bonus = 1]) async {
    final currentMax = state.maxDailySessions;
    final newMax = (state.usedSessionsToday >= currentMax)
        ? state.usedSessionsToday + bonus
        : currentMax + bonus;
    state = state.copyWith(
      maxDailySessions: newMax,
      isUnlockedByParent: false,
      lastSessionDate: DateTime.now(),
    );
    await _save();
  }

  /// Remet à zéro le quota de la journée (depuis l'espace parent ou après minuit).
  Future<void> resetTodayQuota() async {
    state = state.copyWith(
      usedSessionsToday: 0,
      isUnlockedByParent: false,
      lastSessionDate: DateTime.now(),
    );
    await _save();
  }

  /// Modifie la limite maximale autorisée par jour (par exemple 3, 6 ou 10 sessions).
  Future<void> setMaxDailySessions(int max) async {
    state = state.copyWith(
      maxDailySessions: max,
      lastSessionDate: DateTime.now(),
    );
    await _save();
  }

  /// Outil de test / démo pour déclencher instantanément l'écran Limite 6/6.
  Future<void> simulateLimitReached() async {
    state = state.copyWith(
      usedSessionsToday: state.maxDailySessions,
      isUnlockedByParent: false,
      lastSessionDate: DateTime.now(),
    );
    await _save();
  }

  void _checkMidnightRollover() {
    final now = DateTime.now();
    if (!isSameDay(now, state.lastSessionDate)) {
      state = state.copyWith(
        usedSessionsToday: 0,
        isUnlockedByParent: false,
        lastSessionDate: now,
      );
    }
  }

  Future<void> _save() async {
    if (_prefs == null || !mounted) return;
    final key = '$_storagePrefix${state.profileId}';
    await _prefs!.setString(key, state.toJson());
  }

  /// Identifiant du profil enfant associé.
  String get currentProfileId => state.profileId;
}

/// Provider Riverpod global pour la limite quotidienne et le temps d'écran.
final dailyLimitControllerProvider =
    StateNotifierProvider<DailyLimitController, DailyLimitState>((ref) {
      final activeProfile = ref.watch(activeProfileProvider).value;
      final profileId = activeProfile?.id ?? 'default';

      return DailyLimitController(initialProfileId: profileId);
    });
