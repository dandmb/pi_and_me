import 'package:flutter_test/flutter_test.dart';
import 'package:pi_et_moi/features/rating/domain/rating_prompt_policy.dart';

void main() {
  group('RatingPromptPolicy Unit Tests', () {
    const policy = RatingPromptPolicy(
      minQuizzesCompleted: 3,
      minScoreForVictory: 4,
      cooldownDays: 30,
      maxPromptCount: 3,
      minHoursSinceFirstLaunch: 24,
    );

    final baseTime = DateTime(2026, 10, 30, 10, 0);

    test('returns false if user already rated the app', () {
      final should = policy.shouldPrompt(
        hasRated: true,
        promptCount: 0,
        quizzesCompletedCount: 5,
        currentQuizScore: 5,
        firstLaunchTime: baseTime.subtract(const Duration(days: 5)),
        lastPromptTime: null,
        now: baseTime,
      );

      expect(should, isFalse);
    });

    test('returns false if maximum prompts count reached (>= 3)', () {
      final should = policy.shouldPrompt(
        hasRated: false,
        promptCount: 3,
        quizzesCompletedCount: 10,
        currentQuizScore: 6,
        firstLaunchTime: baseTime.subtract(const Duration(days: 40)),
        lastPromptTime: baseTime.subtract(const Duration(days: 35)),
        now: baseTime,
      );

      expect(should, isFalse);
    });

    test('returns false if current quiz score is not a victory moment (< 4)', () {
      final should = policy.shouldPrompt(
        hasRated: false,
        promptCount: 0,
        quizzesCompletedCount: 5,
        currentQuizScore: 3, // Score insuffisant pour célébration
        firstLaunchTime: baseTime.subtract(const Duration(days: 3)),
        lastPromptTime: null,
        now: baseTime,
      );

      expect(should, isFalse);
    });

    test('returns false if quizzes count is below minimum milestone (< 3)', () {
      final should = policy.shouldPrompt(
        hasRated: false,
        promptCount: 0,
        quizzesCompletedCount: 2, // Moins de 3 quiz
        currentQuizScore: 5,
        firstLaunchTime: baseTime.subtract(const Duration(days: 2)),
        lastPromptTime: null,
        now: baseTime,
      );

      expect(should, isFalse);
    });

    test('returns false if first launch was less than 24h ago', () {
      final should = policy.shouldPrompt(
        hasRated: false,
        promptCount: 0,
        quizzesCompletedCount: 4,
        currentQuizScore: 5,
        firstLaunchTime: baseTime.subtract(const Duration(hours: 12)), // Moins de 24h
        lastPromptTime: null,
        now: baseTime,
      );

      expect(should, isFalse);
    });

    test('returns false if within 30 days cooldown period after a dismissal', () {
      final should = policy.shouldPrompt(
        hasRated: false,
        promptCount: 1,
        quizzesCompletedCount: 8,
        currentQuizScore: 5,
        firstLaunchTime: baseTime.subtract(const Duration(days: 45)),
        lastPromptTime: baseTime.subtract(const Duration(days: 15)), // Seulement 15 jours
        now: baseTime,
      );

      expect(should, isFalse);
    });

    test('returns true when all milestone & rating criteria are satisfied', () {
      final should = policy.shouldPrompt(
        hasRated: false,
        promptCount: 0,
        quizzesCompletedCount: 3,
        currentQuizScore: 4,
        firstLaunchTime: baseTime.subtract(const Duration(days: 2)),
        lastPromptTime: null,
        now: baseTime,
      );

      expect(should, isTrue);
    });

    test('returns true after 30 days cooldown on second prompt attempt', () {
      final should = policy.shouldPrompt(
        hasRated: false,
        promptCount: 1,
        quizzesCompletedCount: 12,
        currentQuizScore: 6,
        firstLaunchTime: baseTime.subtract(const Duration(days: 60)),
        lastPromptTime: baseTime.subtract(const Duration(days: 31)), // > 30 jours
        now: baseTime,
      );

      expect(should, isTrue);
    });
  });
}
