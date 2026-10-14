import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/core/localization/locale_controller.dart';
import 'package:pi_et_moi/features/profile/domain/child_profile.dart';
import 'package:pi_et_moi/features/profile/domain/school_grade.dart';
import 'package:pi_et_moi/features/profile/presentation/profile_controller.dart';
import 'package:pi_et_moi/features/quiz/domain/math_question_generator.dart';
import 'package:pi_et_moi/features/quiz/presentation/quiz_controller.dart';
import 'package:pi_et_moi/features/quiz/presentation/quiz_results_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestableResultsScreen({
    String systemLocale = 'fr',
    int score = 5,
  }) {
    return ProviderScope(
      overrides: [
        languageProvider.overrideWith(
          (ref) => LanguageNotifier(systemLocaleCodeOverride: systemLocale),
        ),
        activeProfileProvider.overrideWith(
          () => _FakeProfileNotifier(
            ChildProfile.defaultProfile(name: 'Léa', grade: SchoolGrade.cm1),
          ),
        ),
        quizControllerProvider.overrideWith((ref) {
          final controller = QuizController(
            generator: MathQuestionGenerator(Random(42)),
          );
          controller.startQuiz(SchoolGrade.cm1);
          // Simuler 5 bonnes réponses
          for (int i = 0; i < 6; i++) {
            final q = controller.state.currentQuestion!;
            if (i < score) {
              controller.selectOption(q.correctIndex);
            } else {
              controller.selectOption((q.correctIndex + 1) % 4);
            }
            controller.validateAnswer();
            controller.nextQuestion();
          }
          return controller;
        }),
      ],
      child: const MaterialApp(
        home: QuizResultsScreen(),
      ),
    );
  }

  group('QuizResultsScreen Widget Tests', () {
    testWidgets('renders celebration, score, rewards and action buttons in French', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableResultsScreen(systemLocale: 'fr', score: 5));
      await tester.pumpAndSettle();

      // Vérifie les textes d'en-tête
      expect(find.text('✨ Quiz Terminé !'), findsOneWidget);
      expect(find.text('Bravo Léa !'), findsOneWidget);
      expect(find.text('Score : 5 / 6'), findsOneWidget);

      // Vérifie les récompenses
      expect(find.text('Récompenses gagnées'), findsOneWidget);
      expect(find.text('Os dorés'), findsOneWidget);
      expect(find.text('Croquettes'), findsOneWidget);
      expect(find.text('Balles'), findsOneWidget);

      // Vérifie les boutons d'action
      expect(find.text('Nourrir & Soigner Pi 🍖'), findsOneWidget);
      expect(find.text('Retour au salon 🏠'), findsOneWidget);
    });

    testWidgets('renders in English when language is English', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableResultsScreen(systemLocale: 'en', score: 6));
      await tester.pumpAndSettle();

      expect(find.text('✨ Quiz Completed!'), findsOneWidget);
      expect(find.text('Well done Léa!'), findsOneWidget);
      expect(find.text('Score: 6 / 6'), findsOneWidget);
      expect(find.text('Golden bones'), findsOneWidget);
      expect(find.text('Kibbles'), findsOneWidget);
      expect(find.text('Balls'), findsOneWidget);
      expect(find.text('Feed & Care for Pi 🍖'), findsOneWidget);
      expect(find.text('Back to living room 🏠'), findsOneWidget);
    });
  });
}

class _FakeProfileNotifier extends ActiveProfileNotifier {
  final ChildProfile _profile;
  _FakeProfileNotifier(this._profile);

  @override
  Future<ChildProfile?> build() async => _profile;
}
