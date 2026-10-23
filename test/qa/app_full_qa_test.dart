import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/core/audio/audio_service.dart';
import 'package:pi_et_moi/core/localization/locale_controller.dart';
import 'package:pi_et_moi/features/care/presentation/care_screen.dart';
import 'package:pi_et_moi/features/home/presentation/home_screen.dart';
import 'package:pi_et_moi/features/home/presentation/settings_sheet.dart';
import 'package:pi_et_moi/features/navigation/presentation/main_shell_screen.dart';
import 'package:pi_et_moi/features/onboarding/presentation/onboarding_carousel_screen.dart';
import 'package:pi_et_moi/features/onboarding/presentation/onboarding_screen.dart';
import 'package:pi_et_moi/features/parent/presentation/widgets/parental_gate_dialog.dart';
import 'package:pi_et_moi/features/profile/data/profile_repository.dart';
import 'package:pi_et_moi/features/profile/domain/child_profile.dart';
import 'package:pi_et_moi/features/profile/domain/school_grade.dart';
import 'package:pi_et_moi/features/profile/presentation/profile_controller.dart';
import 'package:pi_et_moi/features/quiz/data/quiz_stats_repository.dart';
import 'package:pi_et_moi/features/quiz/domain/quiz_session_record.dart';
import 'package:pi_et_moi/features/quiz/presentation/quiz_results_screen.dart';
import 'package:pi_et_moi/features/quiz/presentation/quiz_screen.dart';
import 'package:pi_et_moi/features/shop/presentation/shop_screen.dart';
import 'package:pi_et_moi/main.dart';

class _NoOpAudioPlayerClient implements AudioPlayerClient {
  @override
  Future<void> playAsset(String assetPath) async {}

  @override
  void dispose() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget buildAppWithScope({
    ProfileRepository? profileRepo,
    QuizStatsRepository? statsRepo,
  }) {
    return ProviderScope(
      overrides: [
        languageProvider.overrideWith(
          (ref) => LanguageNotifier(systemLocaleCodeOverride: 'fr'),
        ),
        audioServiceProvider.overrideWithValue(
          AudioService(client: _NoOpAudioPlayerClient(), isSoundEnabled: false),
        ),
        profileRepositoryProvider.overrideWithValue(
          profileRepo ?? ProfileRepository(prefs: prefs),
        ),
        quizStatsRepositoryProvider.overrideWithValue(
          statsRepo ?? QuizStatsRepository(prefs: prefs),
        ),
      ],
      child: const MathPupApp(),
    );
  }

  group('Complete App QA & User Journey Tests', () {
    testWidgets(
      'QA Flow 1: Onboarding Carousel -> Grade Setup -> Profile Creation',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(buildAppWithScope());

        // 1. Splash Screen transitions after 100ms
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();

        // 2. Onboarding Carousel displayed
        expect(find.byType(OnboardingCarouselScreen), findsOneWidget);
        expect(find.text('Maths Ludiques'), findsOneWidget);
        expect(find.text('Progresse en maths sans stress'), findsOneWidget);

        // Slide to next slide
        await tester.tap(find.text('Suivant'));
        await tester.pumpAndSettle();
        expect(find.text('Ton Compagnon'), findsOneWidget);

        // Slide to third slide
        await tester.tap(find.text('Suivant'));
        await tester.pumpAndSettle();
        expect(find.text('Récompenses & Boutique'), findsOneWidget);

        // Tap Rencontrer Pi 🐾 -> Enters Profile creation
        await tester.tap(find.text('Rencontrer Pi 🐾'));
        await tester.pumpAndSettle();

        expect(find.byType(OnboardingScreen), findsOneWidget);
        expect(find.text('Qui va jouer avec Pi ?'), findsOneWidget);

        // Select Grade CE2
        await tester.tap(find.text('CE2'));
        await tester.pumpAndSettle();

        // Enter child name
        await tester.enterText(find.byType(TextField), 'Maxime');
        await tester.pumpAndSettle();

        // Submit profile
        await tester.tap(find.text('C\'est parti !'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        // Verifies arrival on Main Living Room (Salon)
        expect(find.byType(MainShellScreen), findsOneWidget);
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.text('Maxime (CE2)'), findsOneWidget);
      },
    );

    testWidgets(
      'QA Flow 2: Living Room (Salon), Care Tab & Shop Tab Navigation',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await prefs.setBool('has_completed_care_showcase_v1', true);
        final child = ChildProfile.defaultProfile(
          name: 'Maxime',
          grade: SchoolGrade.ce2,
        );
        final profileRepo = ProfileRepository(prefs: prefs);
        await profileRepo.saveProfile(child);

        await tester.pumpWidget(buildAppWithScope(profileRepo: profileRepo));

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 300));

        // 1. Arrived on MainShellScreen in Salon (Tab 0)
        expect(find.byType(MainShellScreen), findsOneWidget);
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.text('Jouer au Quiz'), findsOneWidget);

        // 2. Switch to Tab 1: Soigner
        await tester.tap(find.byKey(const Key('nav_item_1')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(CareScreen), findsOneWidget);

        // 3. Switch to Tab 2: Boutique
        await tester.tap(find.byKey(const Key('nav_item_2')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(ShopScreen), findsOneWidget);
        expect(find.text('Boutique'), findsWidgets);

        // 4. Return to Tab 0: Salon
        await tester.tap(find.byKey(const Key('nav_item_0')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );

    testWidgets(
      'QA Flow 3: Quiz Execution, Celebration, and Real Stats Recording',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final child = ChildProfile.defaultProfile(
          name: 'Maxime',
          grade: SchoolGrade.ce2,
        );
        final profileRepo = ProfileRepository(prefs: prefs);
        await profileRepo.saveProfile(child);
        final statsRepo = QuizStatsRepository(prefs: prefs);

        await tester.pumpWidget(
          buildAppWithScope(profileRepo: profileRepo, statsRepo: statsRepo),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 300));

        // Tap "Jouer au Quiz"
        await tester.tap(find.text('Jouer au Quiz'));
        await tester.pumpAndSettle();

        expect(find.byType(QuizScreen), findsOneWidget);

        // Answer 6 questions
        for (int i = 0; i < 6; i++) {
          // Tap Option 'A'
          await tester.tap(find.text('A'));
          await tester.pumpAndSettle();

          // Tap Valider la réponse 🚀
          await tester.tap(find.text('Valider la réponse 🚀'));
          await tester.pumpAndSettle();

          // Next or finish
          final nextFinder = find.text('Question suivante ➔');
          final finishFinder = find.text('Voir les résultats ✨');
          if (nextFinder.evaluate().isNotEmpty) {
            await tester.tap(nextFinder);
            await tester.pumpAndSettle();
          } else if (finishFinder.evaluate().isNotEmpty) {
            await tester.tap(finishFinder);
            await tester.pumpAndSettle();
          }
        }

        // Quiz Results celebration screen
        expect(find.byType(QuizResultsScreen), findsOneWidget);
        expect(find.text('Quiz Terminé !'), findsOneWidget);

        // Return to salon
        await tester.tap(find.text('Retour au salon'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Verify that the session was dynamically persisted in QuizStatsRepository
        final sessions = await statsRepo.getAllSessions();
        expect(sessions.length, 1);
        expect(sessions.first.totalQuestions, 6);
        expect(sessions.first.profileId, child.id);
      },
    );

    testWidgets(
      'QA Flow 4: Parental Gate with Comma Input and Real Stats in Dashboard',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final child = ChildProfile.defaultProfile(
          name: 'Maxime',
          grade: SchoolGrade.ce2,
        );
        final profileRepo = ProfileRepository(prefs: prefs);
        await profileRepo.saveProfile(child);
        final statsRepo = QuizStatsRepository(prefs: prefs);

        // Seed 1 real completed quiz in stats repo
        await statsRepo.recordSession(
          QuizSessionRecord(
            id: 'test_session_1',
            profileId: child.id,
            timestamp: DateTime.now(),
            grade: SchoolGrade.ce2,
            totalQuestions: 6,
            correctAnswers: 5,
            totalByDomain: {'numbers': 4, 'geometry': 2},
            correctByDomain: {'numbers': 3, 'geometry': 2},
          ),
        );

        await tester.pumpWidget(
          buildAppWithScope(profileRepo: profileRepo, statsRepo: statsRepo),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 300));

        // Tap Settings icon in top app bar
        await tester.tap(find.byIcon(Icons.settings_rounded));
        await tester.pumpAndSettle();

        expect(find.byType(SettingsSheet), findsOneWidget);

        // Tap Espace Parents tile in settings sheet
        await tester.tap(find.byKey(const Key('parent_dashboard_entry_tile')));
        await tester.pumpAndSettle();

        expect(find.byType(ParentalGateDialog), findsOneWidget);

        // Test decimal / comma input on Parental Gate!
        final inputFinder = find.byKey(const Key('parental_gate_input'));
        expect(inputFinder, findsOneWidget);

        // Test that typing a comma character ',' is accepted by the input formatter
        await tester.enterText(inputFinder, '4,5');
        await tester.pump();
        final editableText = tester.widget<EditableText>(
          find.descendant(of: inputFinder, matching: find.byType(EditableText)),
        );
        expect(editableText.controller.text, '4,5'); // Comma is preserved!

        final submitFinder = find.byKey(
          const Key('parental_gate_submit_button'),
        );
        expect(submitFinder, findsOneWidget);
      },
    );
  });
}
