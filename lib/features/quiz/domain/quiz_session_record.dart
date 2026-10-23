import '../../profile/domain/school_grade.dart';

/// Enregistrement immuable d'une session de quiz terminée par un enfant.
/// Permet de calculer les statistiques pédagogiques réelles (Espace Parents).
class QuizSessionRecord {
  final String id;
  final String profileId;
  final DateTime timestamp;
  final SchoolGrade grade;
  final int totalQuestions;
  final int correctAnswers;
  final Map<String, int> totalByDomain;
  final Map<String, int> correctByDomain;

  const QuizSessionRecord({
    required this.id,
    required this.profileId,
    required this.timestamp,
    required this.grade,
    required this.totalQuestions,
    required this.correctAnswers,
    this.totalByDomain = const {},
    this.correctByDomain = const {},
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'profileId': profileId,
    'timestamp': timestamp.toIso8601String(),
    'grade': grade.name,
    'totalQuestions': totalQuestions,
    'correctAnswers': correctAnswers,
    'totalByDomain': totalByDomain,
    'correctByDomain': correctByDomain,
  };

  factory QuizSessionRecord.fromMap(Map<String, dynamic> map) {
    return QuizSessionRecord(
      id: map['id'] as String,
      profileId: map['profileId'] as String? ?? 'default',
      timestamp: DateTime.parse(map['timestamp'] as String),
      grade: SchoolGrade.values.firstWhere(
        (g) => g.name == map['grade'],
        orElse: () => SchoolGrade.cp,
      ),
      totalQuestions: map['totalQuestions'] as int? ?? 0,
      correctAnswers: map['correctAnswers'] as int? ?? 0,
      totalByDomain: Map<String, int>.from(map['totalByDomain'] as Map? ?? {}),
      correctByDomain: Map<String, int>.from(
        map['correctByDomain'] as Map? ?? {},
      ),
    );
  }
}

/// Statistiques agrégées réelles calculées à partir des sessions enregistrées.
class EducationalStats {
  final int totalQuizzesCompleted;
  final double averageAccuracyRate;
  final Map<String, double> domainMastery;

  const EducationalStats({
    this.totalQuizzesCompleted = 0,
    this.averageAccuracyRate = 0.0,
    this.domainMastery = const {
      'numbers': 0.0,
      'geometry': 0.0,
      'measures': 0.0,
      'problems': 0.0,
    },
  });

  /// Calcule les statistiques à partir d'une liste de sessions réelles.
  static EducationalStats calculate(List<QuizSessionRecord> sessions) {
    if (sessions.isEmpty) {
      return const EducationalStats();
    }

    final totalQuizzes = sessions.length;
    int totalQuestions = 0;
    int totalCorrect = 0;

    final domainTotals = <String, int>{
      'numbers': 0,
      'geometry': 0,
      'measures': 0,
      'problems': 0,
    };
    final domainCorrects = <String, int>{
      'numbers': 0,
      'geometry': 0,
      'measures': 0,
      'problems': 0,
    };

    for (final s in sessions) {
      totalQuestions += s.totalQuestions;
      totalCorrect += s.correctAnswers;
      s.totalByDomain.forEach((dom, count) {
        domainTotals[dom] = (domainTotals[dom] ?? 0) + count;
      });
      s.correctByDomain.forEach((dom, count) {
        domainCorrects[dom] = (domainCorrects[dom] ?? 0) + count;
      });
    }

    final accuracy = totalQuestions > 0 ? (totalCorrect / totalQuestions) : 0.0;
    final mastery = <String, double>{};
    for (final dom in ['numbers', 'geometry', 'measures', 'problems']) {
      final t = domainTotals[dom] ?? 0;
      final c = domainCorrects[dom] ?? 0;
      mastery[dom] = t > 0 ? (c / t) : 0.0;
    }

    return EducationalStats(
      totalQuizzesCompleted: totalQuizzes,
      averageAccuracyRate: accuracy,
      domainMastery: mastery,
    );
  }
}
