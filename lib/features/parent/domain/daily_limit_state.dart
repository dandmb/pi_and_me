import 'dart:convert';

/// État immuable de la limite quotidienne de temps d'écran / sessions de quiz.
/// Conforme aux exigences Google Play Familles & COPPA (respect des temps de repos).
class DailyLimitState {
  final String profileId;
  final int usedSessionsToday;
  final int maxDailySessions;
  final DateTime lastSessionDate;
  final bool isUnlockedByParent;

  const DailyLimitState({
    this.profileId = 'default',
    this.usedSessionsToday = 0,
    this.maxDailySessions = 6,
    required this.lastSessionDate,
    this.isUnlockedByParent = false,
  });

  /// Indique si la limite quotidienne bienveillante est atteinte pour l'enfant.
  bool get isLimitReached =>
      !isUnlockedByParent && usedSessionsToday >= maxDailySessions;

  /// Nombre de sessions restantes autorisées aujourd'hui.
  int get remainingSessions => isLimitReached
      ? 0
      : (maxDailySessions - usedSessionsToday).clamp(0, maxDailySessions);

  /// Progression normalisée (0.0 à 1.0) du quota du jour.
  double get progress => maxDailySessions > 0
      ? (usedSessionsToday / maxDailySessions).clamp(0.0, 1.0)
      : 1.0;

  /// Alias de lisibilité pour le nombre de questions/parties effectuées.
  int get questionsAnsweredToday => usedSessionsToday;
  int get maxDailyQuestions => maxDailySessions;

  DailyLimitState copyWith({
    String? profileId,
    int? usedSessionsToday,
    int? maxDailySessions,
    DateTime? lastSessionDate,
    bool? isUnlockedByParent,
  }) {
    return DailyLimitState(
      profileId: profileId ?? this.profileId,
      usedSessionsToday: usedSessionsToday ?? this.usedSessionsToday,
      maxDailySessions: maxDailySessions ?? this.maxDailySessions,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      isUnlockedByParent: isUnlockedByParent ?? this.isUnlockedByParent,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profileId': profileId,
      'usedSessionsToday': usedSessionsToday,
      'maxDailySessions': maxDailySessions,
      'lastSessionDate': lastSessionDate.toIso8601String(),
      'isUnlockedByParent': isUnlockedByParent,
    };
  }

  factory DailyLimitState.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    try {
      parsedDate = map['lastSessionDate'] != null
          ? DateTime.parse(map['lastSessionDate'] as String)
          : DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    final used =
        map['usedSessionsToday'] as int? ??
        map['questionsAnsweredToday'] as int? ??
        0;

    return DailyLimitState(
      profileId: map['profileId'] as String? ?? 'default',
      usedSessionsToday: used,
      maxDailySessions:
          map['maxDailySessions'] as int? ??
          map['maxDailyQuestions'] as int? ??
          6,
      lastSessionDate: parsedDate,
      isUnlockedByParent: map['isUnlockedByParent'] as bool? ?? false,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory DailyLimitState.fromJson(String source) =>
      DailyLimitState.fromMap(jsonDecode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DailyLimitState(profileId: $profileId, used: $usedSessionsToday/$maxDailySessions, '
        'limitReached: $isLimitReached, lastSession: $lastSessionDate, parentUnlocked: $isUnlockedByParent)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyLimitState &&
        other.profileId == profileId &&
        other.usedSessionsToday == usedSessionsToday &&
        other.maxDailySessions == maxDailySessions &&
        other.lastSessionDate.year == lastSessionDate.year &&
        other.lastSessionDate.month == lastSessionDate.month &&
        other.lastSessionDate.day == lastSessionDate.day &&
        other.isUnlockedByParent == isUnlockedByParent;
  }

  @override
  int get hashCode {
    return Object.hash(
      profileId,
      usedSessionsToday,
      maxDailySessions,
      lastSessionDate.year,
      lastSessionDate.month,
      lastSessionDate.day,
      isUnlockedByParent,
    );
  }
}
