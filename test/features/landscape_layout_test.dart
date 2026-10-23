import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/core/localization/locale_controller.dart';
import 'package:pi_et_moi/features/navigation/presentation/main_shell_screen.dart';
import 'package:pi_et_moi/features/profile/data/profile_repository.dart';
import 'package:pi_et_moi/features/profile/domain/child_profile.dart';
import 'package:pi_et_moi/features/profile/domain/school_grade.dart';
import 'package:pi_et_moi/features/profile/presentation/profile_controller.dart';
import 'package:pi_et_moi/features/quiz/presentation/quiz_controller.dart';
import 'package:pi_et_moi/features/quiz/presentation/quiz_screen.dart';
import 'package:pi_et_moi/features/quiz/presentation/quiz_results_screen.dart';
import 'package:pi_et_moi/features/onboarding/presentation/onboarding_screen.dart';
import 'package:pi_et_moi/features/onboarding/presentation/onboarding_carousel_screen.dart';
import 'package:pi_et_moi/features/parent/presentation/daily_limit_screen.dart';
import 'package:pi_et_moi/features/parent/presentation/parent_dashboard_screen.dart';
import 'package:pi_et_moi/features/parent/presentation/widgets/parental_gate_dialog.dart';
import 'package:pi_et_moi/features/about/presentation/about_screen.dart';
import 'package:pi_et_moi/features/splash/presentation/splash_screen.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'has_completed_care_showcase_v1': true,
      'has_seen_onboarding_intro_v1': true,
    });
    prefs = await SharedPreferences.getInstance();
  });

  void setLandscape(WidgetTester tester) {
    tester.view.physicalSize = const Size(840 * 2.5, 380 * 2.5);
    tester.view.devicePixelRatio = 2.5;
  }

  void resetOrientation(WidgetTester tester) {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }

  testWidgets('MainShellScreen renders adaptive Navigation Rail in landscape without overflow', (tester) async {
    setLandscape(tester);
    addTearDown(() => resetOrientation(tester));

    final repo = ProfileRepository(prefs: prefs);
    final profile = ChildProfile(
      id: 'p1',
      name: 'Léa',
      avatar: 'avatar_dog',
      grade: SchoolGrade.cm1,
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

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: MainShellScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Navigation Rail items exist
    expect(find.byKey(const Key('nav_item_0')), findsOneWidget);
    expect(find.byKey(const Key('nav_item_1')), findsOneWidget);
    expect(find.byKey(const Key('nav_item_2')), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Switch to Soigner tab
    await tester.tap(find.byKey(const Key('nav_item_1')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Switch to Boutique tab
    await tester.tap(find.byKey(const Key('nav_item_2')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('QuizScreen renders 2-column landscape layout without overflow', (tester) async {
    setLandscape(tester);
    addTearDown(() => resetOrientation(tester));

    final container = ProviderContainer(
      overrides: [
        languageProvider.overrideWith(
          (ref) => LanguageNotifier(systemLocaleCodeOverride: 'fr'),
        ),
      ],
    );

    // Pre-populate quiz questions
    container.read(quizControllerProvider.notifier).startQuiz(SchoolGrade.ce1);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: QuizScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Verify options are rendered
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
    expect(find.text('D'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('QuizResultsScreen renders 2-column landscape layout without overflow', (tester) async {
    setLandscape(tester);
    addTearDown(() => resetOrientation(tester));

    final repo = ProfileRepository(prefs: prefs);
    final profile = ChildProfile(
      id: 'p1',
      name: 'Léa',
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

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: QuizResultsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nourrir & Soigner Pi'), findsOneWidget);
    expect(find.text('Retour au salon'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('OnboardingCarouselScreen renders side-by-side landscape layout without overflow', (tester) async {
    setLandscape(tester);
    addTearDown(() => resetOrientation(tester));

    final container = ProviderContainer(
      overrides: [
        languageProvider.overrideWith(
          (ref) => LanguageNotifier(systemLocaleCodeOverride: 'fr'),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: OnboardingCarouselScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Suivant'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('DailyLimitScreen renders 2-column landscape layout without overflow', (tester) async {
    setLandscape(tester);
    addTearDown(() => resetOrientation(tester));

    final container = ProviderContainer(
      overrides: [
        languageProvider.overrideWith(
          (ref) => LanguageNotifier(systemLocaleCodeOverride: 'fr'),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: DailyLimitScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Retour au salon'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('SplashScreen renders landscape layout without overflow', (tester) async {
    setLandscape(tester);
    addTearDown(() => resetOrientation(tester));

    final container = ProviderContainer(
      overrides: [
        languageProvider.overrideWith(
          (ref) => LanguageNotifier(systemLocaleCodeOverride: 'fr'),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SplashScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
  });

  testWidgets('OnboardingScreen renders landscape layout without overflow', (tester) async {
    setLandscape(tester);
    addTearDown(() => resetOrientation(tester));

    final container = ProviderContainer(
      overrides: [
        languageProvider.overrideWith(
          (ref) => LanguageNotifier(systemLocaleCodeOverride: 'fr'),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("C'est parti !"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AboutScreen renders landscape layout without overflow', (tester) async {
    setLandscape(tester);
    addTearDown(() => resetOrientation(tester));

    final container = ProviderContainer(
      overrides: [
        languageProvider.overrideWith(
          (ref) => LanguageNotifier(systemLocaleCodeOverride: 'fr'),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AboutScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fermer'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ParentDashboardScreen renders landscape layout without overflow', (tester) async {
    setLandscape(tester);
    addTearDown(() => resetOrientation(tester));

    final repo = ProfileRepository(prefs: prefs);
    final profile = ChildProfile(
      id: 'p1',
      name: 'Léa',
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

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ParentDashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('ParentalGateDialog renders landscape layout without overflow', (tester) async {
    setLandscape(tester);
    addTearDown(() => resetOrientation(tester));

    final container = ProviderContainer(
      overrides: [
        languageProvider.overrideWith(
          (ref) => LanguageNotifier(systemLocaleCodeOverride: 'fr'),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: ParentalGateDialog(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('parental_gate_submit_button')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
