import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/features/profile/domain/school_grade.dart';
import 'package:pi_et_moi/features/quiz/data/quiz_stats_repository.dart';
import 'package:pi_et_moi/features/quiz/domain/quiz_session_record.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late QuizStatsRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = QuizStatsRepository(prefs: prefs);
  });

  group('EducationalStats Unit Tests', () {
    test('Calculates empty stats when no sessions exist', () {
      final stats = EducationalStats.calculate([]);
      expect(stats.totalQuizzesCompleted, 0);
      expect(stats.averageAccuracyRate, 0.0);
      expect(stats.domainMastery['numbers'], 0.0);
      expect(stats.domainMastery['geometry'], 0.0);
      expect(stats.domainMastery['measures'], 0.0);
      expect(stats.domainMastery['problems'], 0.0);
    });

    test('Calculates real aggregated stats across multiple sessions', () {
      final s1 = QuizSessionRecord(
        id: 's1',
        profileId: 'p1',
        timestamp: DateTime.now(),
        grade: SchoolGrade.ce2,
        totalQuestions: 6,
        correctAnswers: 5,
        totalByDomain: {'numbers': 4, 'geometry': 2},
        correctByDomain: {'numbers': 3, 'geometry': 2},
      );

      final s2 = QuizSessionRecord(
        id: 's2',
        profileId: 'p1',
        timestamp: DateTime.now(),
        grade: SchoolGrade.ce2,
        totalQuestions: 6,
        correctAnswers: 6,
        totalByDomain: {'numbers': 2, 'measures': 2, 'problems': 2},
        correctByDomain: {'numbers': 2, 'measures': 2, 'problems': 2},
      );

      final stats = EducationalStats.calculate([s1, s2]);
      expect(stats.totalQuizzesCompleted, 2);
      expect(stats.averageAccuracyRate, closeTo(11 / 12, 0.001));
      // Numbers: 3 + 2 / 4 + 2 = 5/6 = 0.833...
      expect(stats.domainMastery['numbers'], closeTo(5 / 6, 0.001));
      // Geometry: 2 / 2 = 1.0
      expect(stats.domainMastery['geometry'], 1.0);
      // Measures: 2 / 2 = 1.0
      expect(stats.domainMastery['measures'], 1.0);
      // Problems: 2 / 2 = 1.0
      expect(stats.domainMastery['problems'], 1.0);
    });
  });

  group('QuizStatsRepository Tests', () {
    test('Records, retrieves, and purges quiz sessions correctly', () async {
      expect(await repository.getAllSessions(), isEmpty);

      final session = QuizSessionRecord(
        id: 'session_1',
        profileId: 'child_1',
        timestamp: DateTime.now(),
        grade: SchoolGrade.cm1,
        totalQuestions: 6,
        correctAnswers: 4,
        totalByDomain: {'numbers': 6},
        correctByDomain: {'numbers': 4},
      );

      await repository.recordSession(session);

      final child1Sessions = await repository.getSessionsForProfile('child_1');
      expect(child1Sessions.length, 1);
      expect(child1Sessions.first.correctAnswers, 4);

      final allSessions = await repository.getAllSessions();
      expect(allSessions.length, 1);

      await repository.clearAll();
      expect(await repository.getAllSessions(), isEmpty);
    });
  });
}
