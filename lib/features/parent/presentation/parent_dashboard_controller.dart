import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../care/presentation/care_controller.dart';
import '../../profile/presentation/profile_controller.dart';
import '../../quiz/data/quiz_stats_repository.dart';
import '../../quiz/domain/quiz_session_record.dart';
import '../../shop/presentation/shop_controller.dart';
import 'daily_limit_controller.dart';

/// État immuable du tableau de bord parental.
class ParentDashboardState {
  final Map<String, bool> timerFreeModeByProfile;
  final int totalQuizzesCompleted;
  final double averageAccuracyRate;
  final Map<String, double> domainMastery;
  final bool isExporting;
  final String? lastExportJson;

  const ParentDashboardState({
    this.timerFreeModeByProfile = const {},
    this.totalQuizzesCompleted = 0,
    this.averageAccuracyRate = 0.0,
    this.domainMastery = const {
      'numbers': 0.0,
      'geometry': 0.0,
      'measures': 0.0,
      'problems': 0.0,
    },
    this.isExporting = false,
    this.lastExportJson,
  });

  bool isTimerFree(String profileId) =>
      timerFreeModeByProfile[profileId] ?? false;

  ParentDashboardState copyWith({
    Map<String, bool>? timerFreeModeByProfile,
    int? totalQuizzesCompleted,
    double? averageAccuracyRate,
    Map<String, double>? domainMastery,
    bool? isExporting,
    String? lastExportJson,
  }) {
    return ParentDashboardState(
      timerFreeModeByProfile:
          timerFreeModeByProfile ?? this.timerFreeModeByProfile,
      totalQuizzesCompleted:
          totalQuizzesCompleted ?? this.totalQuizzesCompleted,
      averageAccuracyRate: averageAccuracyRate ?? this.averageAccuracyRate,
      domainMastery: domainMastery ?? this.domainMastery,
      isExporting: isExporting ?? this.isExporting,
      lastExportJson: lastExportJson ?? this.lastExportJson,
    );
  }
}

/// Contrôleur Riverpod pour l'Espace Parents (Supervision, RGPD & Statistiques).
class ParentDashboardController extends StateNotifier<ParentDashboardState> {
  static const String _timerFreePrefix = 'pi_timer_free_mode_';
  final Ref _ref;
  SharedPreferences? _prefs;

  ParentDashboardController(this._ref, {SharedPreferences? prefs})
    : super(const ParentDashboardState()) {
    _prefs = prefs;
    _init();
  }

  Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    if (_prefs == null) return;
    final keys = _prefs!.getKeys();
    final timerMap = <String, bool>{};

    for (final key in keys) {
      if (key.startsWith(_timerFreePrefix)) {
        final profileId = key.substring(_timerFreePrefix.length);
        timerMap[profileId] = _prefs!.getBool(key) ?? false;
      }
    }

    state = state.copyWith(timerFreeModeByProfile: timerMap);
    await loadStats();
  }

  /// Charge et agrège les statistiques réelles depuis le dépôt d'historique de quiz.
  Future<void> loadStats() async {
    final statsRepo = _ref.read(quizStatsRepositoryProvider);
    final sessions = await statsRepo.getAllSessions();
    final stats = EducationalStats.calculate(sessions);

    state = state.copyWith(
      totalQuizzesCompleted: stats.totalQuizzesCompleted,
      averageAccuracyRate: stats.averageAccuracyRate,
      domainMastery: stats.domainMastery,
    );
  }

  /// Active ou désactive le mode sans chrono pour un profil enfant spécifique.
  Future<void> toggleTimerFreeMode(String profileId, bool enabled) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setBool('$_timerFreePrefix$profileId', enabled);

    final updated = Map<String, bool>.from(state.timerFreeModeByProfile);
    updated[profileId] = enabled;
    state = state.copyWith(timerFreeModeByProfile: updated);
  }

  /// Modifie la limite quotidienne maximale de quiz (augmenter ou diminuer de 1 à 12).
  Future<void> setDailyLimit(int max) async {
    await _ref
        .read(dailyLimitControllerProvider.notifier)
        .setMaxDailySessions(max);
  }

  /// Débloque +1 session bonus aujourd'hui via le contrôleur de quotas.
  Future<void> grantBonusSession() async {
    await _ref.read(dailyLimitControllerProvider.notifier).grantBonusSession(1);
  }

  /// Remet à zéro le quota de quiz utilisé aujourd'hui.
  Future<void> resetTodayQuota() async {
    await _ref.read(dailyLimitControllerProvider.notifier).resetTodayQuota();
  }

  /// Génère l'ensemble des données du foyer au format standard JSON (Art. 20 RGPD).
  Future<String> exportHouseholdDataJson() async {
    state = state.copyWith(isExporting: true);
    _prefs ??= await SharedPreferences.getInstance();

    final profileRepo = _ref.read(profileRepositoryProvider);
    final profiles = await profileRepo.getAllProfiles();
    final activeProfile = await profileRepo.getActiveProfile();

    final careState = _ref.read(careControllerProvider);
    final shopState = _ref.read(shopControllerProvider);
    final dailyLimit = _ref.read(dailyLimitControllerProvider);

    final Map<String, dynamic> exportData = {
      'schemaVersion': '1.0.0',
      'appName': 'MathPup',
      'exportDate': DateTime.now().toIso8601String(),
      'compliance': {
        'regulation': 'RGPD (UE 2016/679) & COPPA',
        'article': 'Article 20 - Droit à la portabilité des données',
        'zeroAds': true,
        'zeroThirdPartyTrackers': true,
        'offlineStorageOnly': true,
      },
      'profiles': profiles.map((p) => p.toMap()).toList(),
      'activeProfileId': activeProfile?.id ?? 'none',
      'timerFreeModeByProfile': state.timerFreeModeByProfile,
      'dailyScreenTimeLimit': dailyLimit.toMap(),
      'companionState': careState.toMap(),
      'shopInventory': {
        'ownedAccessoryIds': shopState.ownedAccessoryIds.toList(),
        'equippedAccessoryIds': shopState.equippedAccessoryIds,
      },
      'educationalAnalytics': {
        'totalQuizzesCompleted': state.totalQuizzesCompleted,
        'averageAccuracyRate': state.averageAccuracyRate,
        'domains': state.domainMastery,
      },
      'quizHistory':
          (await _ref.read(quizStatsRepositoryProvider).getAllSessions())
              .map((s) => s.toMap())
              .toList(),
    };

    const encoder = JsonEncoder.withIndent('  ');
    final jsonString = encoder.convert(exportData);

    state = state.copyWith(isExporting: false, lastExportJson: jsonString);

    return jsonString;
  }

  /// Efface irrévocablement l'ensemble des données du foyer sur cet appareil (Art. 17 RGPD).
  Future<void> deleteEntireHouseholdData() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.clear();
    await _ref.read(quizStatsRepositoryProvider).clearAll();

    // Réinitialise les contrôleurs mémoires
    _ref.invalidate(allProfilesProvider);
    _ref.invalidate(activeProfileProvider);
    _ref.invalidate(dailyLimitControllerProvider);
    _ref.invalidate(careControllerProvider);
    _ref.invalidate(shopControllerProvider);

    state = const ParentDashboardState();
  }
}

/// Provider global de l'Espace Parents.
final parentDashboardControllerProvider =
    StateNotifierProvider<ParentDashboardController, ParentDashboardState>((
      ref,
    ) {
      return ParentDashboardController(ref);
    });
