import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/features/parent/domain/daily_limit_state.dart';
import 'package:pi_et_moi/features/parent/presentation/daily_limit_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DailyLimitState Tests', () {
    test('Default values and getters', () {
      final now = DateTime.now();
      final state = DailyLimitState(
        profileId: 'test_child',
        usedSessionsToday: 2,
        maxDailySessions: 6,
        lastSessionDate: now,
      );

      expect(state.profileId, 'test_child');
      expect(state.usedSessionsToday, 2);
      expect(state.maxDailySessions, 6);
      expect(state.remainingSessions, 4);
      expect(state.progress, closeTo(2 / 6, 0.001));
      expect(state.isLimitReached, isFalse);
    });

    test('Limit reached when used sessions >= maxDailySessions and not unlocked', () {
      final now = DateTime.now();
      final state = DailyLimitState(
        usedSessionsToday: 6,
        maxDailySessions: 6,
        lastSessionDate: now,
      );

      expect(state.isLimitReached, isTrue);
      expect(state.remainingSessions, 0);
      expect(state.progress, 1.0);
    });

    test('Parent override bypasses limit reached', () {
      final now = DateTime.now();
      final state = DailyLimitState(
        usedSessionsToday: 6,
        maxDailySessions: 6,
        lastSessionDate: now,
        isUnlockedByParent: true,
      );

      expect(state.isLimitReached, isFalse);
    });

    test('Serialization toMap / fromMap / JSON preserves data', () {
      final date = DateTime(2026, 10, 16, 14, 30);
      final original = DailyLimitState(
        profileId: 'lea_1',
        usedSessionsToday: 5,
        maxDailySessions: 6,
        lastSessionDate: date,
        isUnlockedByParent: true,
      );

      final jsonStr = original.toJson();
      final parsed = DailyLimitState.fromJson(jsonStr);

      expect(parsed.profileId, original.profileId);
      expect(parsed.usedSessionsToday, original.usedSessionsToday);
      expect(parsed.maxDailySessions, original.maxDailySessions);
      expect(parsed.lastSessionDate.year, original.lastSessionDate.year);
      expect(parsed.lastSessionDate.day, original.lastSessionDate.day);
      expect(parsed.isUnlockedByParent, original.isUnlockedByParent);
    });
  });

  group('DailyLimitController Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initializes with default 0/6 quota and persists', () async {
      final prefs = await SharedPreferences.getInstance();
      final controller = DailyLimitController(
        prefs: prefs,
        initialProfileId: 'profile_test',
      );

      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.state.usedSessionsToday, 0);
      expect(controller.state.maxDailySessions, 6);
      expect(controller.state.isLimitReached, isFalse);
    });

    test('recordCompletedQuiz increments quota and marks limit reached at 6', () async {
      final prefs = await SharedPreferences.getInstance();
      final controller = DailyLimitController(
        prefs: prefs,
        initialProfileId: 'profile_test',
      );

      await Future.delayed(const Duration(milliseconds: 20));
      await controller.recordCompletedQuiz(3);
      expect(controller.state.usedSessionsToday, 3);
      expect(controller.state.isLimitReached, isFalse);

      await controller.recordCompletedQuiz(3);
      expect(controller.state.usedSessionsToday, 6);
      expect(controller.state.isLimitReached, isTrue);
    });

    test('grantParentOverride unlocks limit', () async {
      final prefs = await SharedPreferences.getInstance();
      final controller = DailyLimitController(
        prefs: prefs,
        initialProfileId: 'profile_test',
      );

      await controller.simulateLimitReached();
      expect(controller.state.isLimitReached, isTrue);

      await controller.grantParentOverride();
      expect(controller.state.isLimitReached, isFalse);
      expect(controller.state.isUnlockedByParent, isTrue);
    });

    test('resetTodayQuota resets sessions to 0', () async {
      final prefs = await SharedPreferences.getInstance();
      final controller = DailyLimitController(
        prefs: prefs,
        initialProfileId: 'profile_test',
      );

      await controller.simulateLimitReached();
      expect(controller.state.usedSessionsToday, 6);

      await controller.resetTodayQuota();
      expect(controller.state.usedSessionsToday, 0);
      expect(controller.state.isLimitReached, isFalse);
    });

    test('Auto-midnight rollover resets quota when previous session was yesterday', () async {
      final prefs = await SharedPreferences.getInstance();
      // Enregistre un état d'hier avec quota 6/6
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayState = DailyLimitState(
        profileId: 'rollover_profile',
        usedSessionsToday: 6,
        maxDailySessions: 6,
        lastSessionDate: yesterday,
      );
      await prefs.setString(
        'pi_daily_limit_state_v1_rollover_profile',
        yesterdayState.toJson(),
      );

      final controller = DailyLimitController(
        prefs: prefs,
        initialProfileId: 'rollover_profile',
      );

      await Future.delayed(const Duration(milliseconds: 50));
      // Après le chargement, le contrôleur a automatiquement remis à 0
      expect(controller.state.usedSessionsToday, 0);
      expect(controller.state.isLimitReached, isFalse);
    });
  });
}
