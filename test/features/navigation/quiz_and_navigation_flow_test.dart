import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/core/localization/locale_controller.dart';
import 'package:pi_et_moi/features/care/presentation/care_controller.dart';
import 'package:pi_et_moi/features/navigation/presentation/main_shell_screen.dart';
import 'package:pi_et_moi/features/profile/data/profile_repository.dart';
import 'package:pi_et_moi/features/profile/domain/child_profile.dart';
import 'package:pi_et_moi/features/profile/domain/school_grade.dart';
import 'package:pi_et_moi/features/profile/presentation/profile_controller.dart';
import 'package:pi_et_moi/features/quiz/presentation/quiz_controller.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'has_completed_onboarding': true,
      'care_showcase_completed': true,
    });
    prefs = await SharedPreferences.getInstance();
  });

  Widget buildApp(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: MainShellScreen(initialIndex: 0),
      ),
    );
  }

  testWidgets('Full flow: Solve quiz from Salon, see results, return to Care screen and navigate across all tabs', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final repo = ProfileRepository(prefs: prefs);
    final profile = ChildProfile(
      id: 'p1',
      name: 'Léa',
      avatar: 'avatar_dog',
      grade: SchoolGrade.cp,
      createdAt: DateTime.now(),
    );
    await repo.saveProfile(profile);

    final container = ProviderContainer(
      overrides: [
        languageProvider.overrideWith(
          (ref) => LanguageNotifier(systemLocaleCodeOverride: 'fr'),
        ),
        profileRepositoryProvider.overrideWithValue(repo),
      ],
    );

    // Initial bones count before quiz
    expect(container.read(careControllerProvider).bones, 50);

    // 1. Lance l'application sur le MainShellScreen (Salon initialement)
    await tester.pumpWidget(buildApp(container));
    await tester.pumpAndSettle();

    // Vérifie la présence de l'AppBar et de la BottomBar
    expect(find.text('Léa (CP)'), findsOneWidget);
    expect(find.text('50'), findsOneWidget);
    expect(find.text('Salon'), findsWidgets);
    expect(find.text('Soigner'), findsWidgets);
    expect(find.text('Boutique'), findsWidgets);

    // 2. Taper sur "Jouer au Quiz"
    final playQuizButton = find.text('Jouer au Quiz');
    expect(playQuizButton, findsOneWidget);
    await tester.tap(playQuizButton);
    await tester.pumpAndSettle();

    // 3. Résoudre les 6 questions du Quiz
    for (int q = 0; q < 6; q++) {
      final quizState = container.read(quizControllerProvider);
      expect(quizState.currentQuestion, isNotNull);

      // Sélectionner la bonne réponse pour chaque question
      const letters = ['A', 'B', 'C', 'D'];
      final correctOptIndex = quizState.currentQuestion!.correctIndex;
      final optionFinder = find.text(letters[correctOptIndex]);
      await tester.tap(optionFinder);
      await tester.pumpAndSettle();

      // Valider la réponse
      final validateBtn = find.text('Valider la réponse 🚀');
      expect(validateBtn, findsOneWidget);
      await tester.tap(validateBtn);
      await tester.pumpAndSettle();

      // Passer à la question suivante ou voir les résultats
      if (q < 5) {
        final nextBtn = find.text('Question suivante ➔');
        expect(nextBtn, findsOneWidget);
        await tester.tap(nextBtn);
        await tester.pumpAndSettle();
      } else {
        final resultsBtn = find.text('Voir les résultats ✨');
        expect(resultsBtn, findsOneWidget);
        await tester.tap(resultsBtn);
        await tester.pumpAndSettle();
      }
    }

    // 4. On est maintenant sur QuizResultsScreen
    expect(find.text('Quiz Terminé !'), findsOneWidget);
    expect(find.text('Bravo Léa !'), findsOneWidget);
    expect(find.text('Score : 6 / 6'), findsOneWidget);
    expect(find.text('Nourrir & Soigner Pi'), findsOneWidget);
    expect(find.text('Retour au salon'), findsOneWidget);

    // 5. Cliquer sur "Nourrir & Soigner Pi" -> Redirection vers MainShellScreen (index 1: Soigner)
    await tester.tap(find.text('Nourrir & Soigner Pi'));
    await tester.pumpAndSettle();

    // Vérifier qu'on est revenu sur MainShellScreen avec l'onglet Soigner actif
    expect(find.text('Léa (CP)'), findsOneWidget);
    // Solde de bones mis à jour (50 + 6*5 + 5 bonus = 85 os)
    expect(find.text('85'), findsOneWidget);
    // Vérifier les 3 onglets persistants de la BottomBar
    expect(find.text('Salon'), findsWidgets);
    expect(find.text('Soigner'), findsWidgets);
    expect(find.text('Boutique'), findsWidgets);
    // L'écran Soigner affiche ses jauges (ex: Faim, Énergie, etc.)
    expect(find.text('Faim'), findsWidgets);

    // 6. Navigation fluide vers la Boutique via la BottomBar
    await tester.tap(find.text('Boutique').first);
    await tester.pumpAndSettle();
    expect(find.text('Chapeaux'), findsOneWidget);

    // 7. Navigation fluide vers le Salon via la BottomBar
    await tester.tap(find.text('Salon').first);
    await tester.pumpAndSettle();
    expect(find.text('Jouer au Quiz'), findsOneWidget);
  });

  testWidgets('Full flow: Solve quiz and tap "Retour au salon" returns to Salon with shell and rewards intact', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final repo = ProfileRepository(prefs: prefs);
    final profile = ChildProfile(
      id: 'p2',
      name: 'Thomas',
      avatar: 'avatar_dog',
      grade: SchoolGrade.ce1,
      createdAt: DateTime.now(),
    );
    await repo.saveProfile(profile);

    final container = ProviderContainer(
      overrides: [
        languageProvider.overrideWith(
          (ref) => LanguageNotifier(systemLocaleCodeOverride: 'fr'),
        ),
        profileRepositoryProvider.overrideWithValue(repo),
      ],
    );

    await tester.pumpWidget(buildApp(container));
    await tester.pumpAndSettle();

    // Taper sur "Jouer au Quiz"
    await tester.tap(find.text('Jouer au Quiz'));
    await tester.pumpAndSettle();

    // Répondre aux 6 questions
    for (int q = 0; q < 6; q++) {
      final quizState = container.read(quizControllerProvider);
      const letters = ['A', 'B', 'C', 'D'];
      await tester.tap(find.text(letters[quizState.currentQuestion!.correctIndex]));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Valider la réponse 🚀'));
      await tester.pumpAndSettle();

      if (q < 5) {
        await tester.tap(find.text('Question suivante ➔'));
        await tester.pumpAndSettle();
      } else {
        await tester.tap(find.text('Voir les résultats ✨'));
        await tester.pumpAndSettle();
      }
    }

    // Taper sur "Retour au salon"
    await tester.tap(find.text('Retour au salon'));
    await tester.pumpAndSettle();

    // Vérifier retour au Salon avec barre supérieure et inférieure intactes
    expect(find.text('Thomas (CE1)'), findsOneWidget);
    expect(find.text('85'), findsOneWidget); // 50 + 35
    expect(find.text('Jouer au Quiz'), findsOneWidget);
    expect(find.text('Salon'), findsWidgets);
    expect(find.text('Soigner'), findsWidgets);
    expect(find.text('Boutique'), findsWidgets);
  });
}

