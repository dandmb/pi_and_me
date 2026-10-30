import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/features/rating/data/rating_repository.dart';
import 'package:pi_et_moi/features/rating/domain/rating_prompt_policy.dart';
import 'package:pi_et_moi/features/rating/presentation/rating_controller.dart';
import 'package:pi_et_moi/features/rating/presentation/widgets/rating_milestone_dialog.dart';

class MockInAppReviewService implements InAppReviewService {
  bool isAvailableResult = true;
  int requestReviewCalls = 0;
  int openStoreListingCalls = 0;

  @override
  Future<bool> isAvailable() async => isAvailableResult;

  @override
  Future<void> requestReview() async {
    requestReviewCalls++;
  }

  @override
  Future<void> openStoreListing() async {
    openStoreListingCalls++;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('RatingRepository & Controller Tests', () {
    test('increments quiz count and initializes first launch date', () async {
      final repo = RatingRepository();
      final mockReview = MockInAppReviewService();
      final controller = RatingController(
        repository: repo,
        inAppReviewService: mockReview,
      );

      final now = DateTime(2026, 10, 30, 12, 0);

      // Quiz 1 (score 5, premier quiz)
      final shouldPrompt1 = await controller.onQuizCompleted(
        currentScore: 5,
        mockNow: now,
      );
      expect(shouldPrompt1, isFalse); // Seuil de 3 quiz non atteint
      expect(controller.state.quizzesCompletedCount, 1);

      // Quiz 2
      final shouldPrompt2 = await controller.onQuizCompleted(
        currentScore: 4,
        mockNow: now,
      );
      expect(shouldPrompt2, isFalse);
      expect(controller.state.quizzesCompletedCount, 2);

      // Quiz 3 avec 2 jours d'ancienneté
      final futureTime = now.add(const Duration(days: 2));
      final shouldPrompt3 = await controller.onQuizCompleted(
        currentScore: 5,
        mockNow: futureTime,
      );
      expect(shouldPrompt3, isTrue); // 3 quiz + score >= 4 + > 24h
      expect(controller.state.quizzesCompletedCount, 3);
    });

    test('rateApp sets hasRated to true and calls in_app_review', () async {
      final repo = RatingRepository();
      final mockReview = MockInAppReviewService();
      final controller = RatingController(
        repository: repo,
        inAppReviewService: mockReview,
      );

      await controller.rateApp();

      expect(controller.state.hasRated, isTrue);
      expect(await repo.getHasRated(), isTrue);
      expect(mockReview.requestReviewCalls, 1);
    });

    test('dismissLater increments promptCount and sets lastPromptTime', () async {
      final repo = RatingRepository();
      final mockReview = MockInAppReviewService();
      final controller = RatingController(
        repository: repo,
        inAppReviewService: mockReview,
      );

      final now = DateTime(2026, 10, 30, 14, 0);
      await controller.dismissLater(mockNow: now);

      expect(controller.state.promptCount, 1);
      expect(controller.state.lastPromptTime, now);
      expect(await repo.getPromptCount(), 1);
    });
  });

  group('RatingMilestoneDialog Widget Tests', () {
    testWidgets('renders celebratory dialog with Pi and buttons', (tester) async {
      final repo = RatingRepository();
      final mockReview = MockInAppReviewService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ratingRepositoryProvider.overrideWithValue(repo),
            inAppReviewServiceProvider.overrideWithValue(mockReview),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: RatingMilestoneDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('SUPER CHAMPION'), findsOneWidget);
      expect(find.byKey(const Key('rating_dialog_confirm_button')), findsOneWidget);
      expect(find.byKey(const Key('rating_dialog_later_button')), findsOneWidget);
    });

    testWidgets('tapping confirm button triggers rateApp and closes dialog', (tester) async {
      final repo = RatingRepository();
      final mockReview = MockInAppReviewService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ratingRepositoryProvider.overrideWithValue(repo),
            inAppReviewServiceProvider.overrideWithValue(mockReview),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => RatingMilestoneDialog.show(context),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      // Ouvre le dialogue
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Confirme la note
      await tester.tap(find.byKey(const Key('rating_dialog_confirm_button')));
      await tester.pumpAndSettle();

      expect(mockReview.requestReviewCalls, 1);
      expect(find.byType(RatingMilestoneDialog), findsNothing);
    });

    testWidgets('tapping later button dismisses dialog without rating', (tester) async {
      final repo = RatingRepository();
      final mockReview = MockInAppReviewService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ratingRepositoryProvider.overrideWithValue(repo),
            inAppReviewServiceProvider.overrideWithValue(mockReview),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => RatingMilestoneDialog.show(context),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('rating_dialog_later_button')));
      await tester.pumpAndSettle();

      expect(mockReview.requestReviewCalls, 0);
      expect(find.byType(RatingMilestoneDialog), findsNothing);
    });
  });
}
