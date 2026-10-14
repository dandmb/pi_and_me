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
import 'package:pi_et_moi/features/quiz/presentation/quiz_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestableQuizScreen({
    String systemLocale = 'fr',
    SchoolGrade grade = SchoolGrade.cm1,
  }) {
    return ProviderScope(
      overrides: [
        languageProvider.overrideWith(
          (ref) => LanguageNotifier(systemLocaleCodeOverride: systemLocale),
        ),
        activeProfileProvider.overrideWith(
          () => _FakeProfileNotifier(
            ChildProfile.defaultProfile(name: 'Léa', grade: grade),
          ),
        ),
        quizControllerProvider.overrideWith((ref) {
          final controller = QuizController(
            generator: MathQuestionGenerator(Random(42)),
          );
          controller.startQuiz(grade);
          return controller;
        }),
      ],
      child: const MaterialApp(
        home: QuizScreen(),
      ),
    );
  }

  group('QuizScreen Widget Tests', () {
    testWidgets('renders question card, options grid and progress bar in French', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableQuizScreen(systemLocale: 'fr'));
      await tester.pumpAndSettle();

      // Vérifie la présence de la jauge et du badge sans stress
      expect(find.text('Question 1 / 6'), findsOneWidget);
      expect(find.text('🌱 Sans stress'), findsOneWidget);

      // Vérifie que les 4 options (A, B, C, D) sont affichées
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);

      // Le bouton valider est affiché
      expect(find.text('Valider la réponse 🚀'), findsOneWidget);
    });

    testWidgets('selecting an option enables validation and displays feedback', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableQuizScreen(systemLocale: 'fr'));
      await tester.pumpAndSettle();

      // Tap sur l'option A
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      // Tap sur valider
      await tester.tap(find.text('Valider la réponse 🚀'));
      await tester.pumpAndSettle();

      // Le bouton d'action devient "Question suivante ➔"
      expect(find.text('Question suivante ➔'), findsOneWidget);
    });

    testWidgets('exit cross shows confirmation modal', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableQuizScreen(systemLocale: 'fr'));
      await tester.pumpAndSettle();

      // Tap sur l'icône de fermeture
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // La modale de confirmation est affichée
      expect(find.text('Quitter le quiz ?'), findsOneWidget);
      expect(find.text('Continuer'), findsOneWidget);
      expect(find.text('Quitter'), findsOneWidget);
    });

    testWidgets('renders in English when language is English', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableQuizScreen(systemLocale: 'en'));
      await tester.pumpAndSettle();

      expect(find.text('🌱 Stress-free'), findsOneWidget);
      expect(find.text('Submit answer 🚀'), findsOneWidget);
    });
  });
}

class _FakeProfileNotifier extends ActiveProfileNotifier {
  final ChildProfile _profile;
  _FakeProfileNotifier(this._profile);

  @override
  Future<ChildProfile?> build() async => _profile;
}
