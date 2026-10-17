import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/core/localization/locale_controller.dart';
import 'package:pi_et_moi/features/parent/presentation/parent_dashboard_controller.dart';
import 'package:pi_et_moi/features/parent/presentation/parent_dashboard_screen.dart';
import 'package:pi_et_moi/features/profile/data/profile_repository.dart';
import 'package:pi_et_moi/features/profile/domain/child_profile.dart';
import 'package:pi_et_moi/features/profile/domain/school_grade.dart';
import 'package:pi_et_moi/features/profile/presentation/profile_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'pi_profiles_list': jsonEncode([
        {
          'id': 'profile_lea',
          'name': 'Léa',
          'avatar': 'avatar_dog',
          'grade': 'cm1',
          'createdAt': DateTime.now().toIso8601String(),
        },
      ]),
      'pi_active_profile_id': 'profile_lea',
      'pi_daily_limit_state_v1_profile_lea': jsonEncode({
        'profileId': 'profile_lea',
        'usedSessionsToday': 6,
        'maxDailySessions': 6,
        'lastSessionDate': DateTime.now().toIso8601String(),
        'isUnlockedByParent': false,
      }),
    });
    prefs = await SharedPreferences.getInstance();
  });

  group('ParentDashboardController Tests', () {
    test('Initial state and timer-free mode toggle', () async {
      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(ProfileRepository(prefs: prefs)),
        ],
      );

      final controller = container.read(parentDashboardControllerProvider.notifier);
      expect(controller.state.totalQuizzesCompleted, 18);
      expect(controller.state.averageAccuracyRate, 0.88);
      expect(controller.state.isTimerFree('profile_lea'), isFalse);

      await controller.toggleTimerFreeMode('profile_lea', true);
      expect(controller.state.isTimerFree('profile_lea'), isTrue);
    });

    test('Data export generates compliant JSON string (Art. 20 RGPD)', () async {
      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(ProfileRepository(prefs: prefs)),
        ],
      );

      final controller = container.read(parentDashboardControllerProvider.notifier);
      final jsonOutput = await controller.exportHouseholdDataJson();

      final decoded = jsonDecode(jsonOutput) as Map<String, dynamic>;
      expect(decoded['appName'], 'MathPup');
      expect(decoded['compliance']['article'], contains('Article 20'));
      expect(decoded['compliance']['zeroAds'], isTrue);
      expect(decoded['profiles'], isNotEmpty);
    });
  });

  group('ParentDashboardScreen Widget Tests', () {
    Widget createWidget() {
      return ProviderScope(
        overrides: [
          languageProvider.overrideWith((ref) => LanguageNotifier(systemLocaleCodeOverride: 'fr')),
          profileRepositoryProvider.overrideWithValue(ProfileRepository(prefs: prefs)),
          allProfilesProvider.overrideWith((ref) async => [
                ChildProfile(
                  id: 'profile_lea',
                  name: 'Léa',
                  avatar: 'avatar_dog',
                  grade: SchoolGrade.cm1,
                  createdAt: DateTime.now(),
                ),
              ]),
        ],
        child: const MaterialApp(
          home: ParentDashboardScreen(),
        ),
      );
    }

    testWidgets('Renders all 3 tabs and displays child quotas and profile card in Tab 1',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Check header and tabs
      expect(find.text('Espace Parents'), findsOneWidget);
      expect(find.text('Supervision Bienveillante'), findsOneWidget);
      expect(find.text('Enfants & Quotas'), findsOneWidget);
      expect(find.text('Statistiques'), findsOneWidget);
      expect(find.text('Données & RGPD'), findsOneWidget);

      // Check child profile in Tab 1
      expect(find.text('Léa'), findsOneWidget);
      expect(find.textContaining('CM1'), findsWidgets);
      expect(find.text('Limite quotidienne de quiz'), findsOneWidget);
      expect(find.byKey(const Key('daily_limit_decrease_profile_lea')), findsOneWidget);
      expect(find.byKey(const Key('daily_limit_increase_profile_lea')), findsOneWidget);
      expect(find.text('+1 session bonus'), findsOneWidget);
      expect(find.text('Mode sans chrono'), findsOneWidget);

      // Tap decrease daily limit stepper
      await tester.tap(find.byKey(const Key('daily_limit_decrease_profile_lea')));
      await tester.pumpAndSettle();
      expect(find.text('5 / jour'), findsOneWidget);

      // Tap increase daily limit stepper
      await tester.tap(find.byKey(const Key('daily_limit_increase_profile_lea')));
      await tester.pumpAndSettle();
      expect(find.text('6 / jour'), findsOneWidget);
    });

    testWidgets('Renders properly on narrow mobile screen (360x800) without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Verify no overflow assertion was thrown and key elements are visible
      expect(find.text('+1 session bonus'), findsOneWidget);
      expect(find.text('Remettre à zéro'), findsOneWidget);
      expect(find.text('Ajouter un profil enfant'), findsOneWidget);
    });

    testWidgets('Switching to Tab 2 displays math domains and accuracy statistics',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Tap on Tab 2: Statistiques
      await tester.tap(find.text('Statistiques'));
      await tester.pumpAndSettle();

      expect(find.text('Quiz complétés au total'), findsOneWidget);
      expect(find.text('Taux moyen de réussite'), findsOneWidget);
      expect(find.text('Nombres & Calculs'), findsOneWidget);
      expect(find.text('Géométrie & Espace'), findsOneWidget);
      expect(find.text('Grandeurs & Mesures'), findsOneWidget);
      expect(find.text('Résolution de Problèmes'), findsOneWidget);
    });

    testWidgets('Switching to Tab 3 displays privacy pledge, export JSON and danger zone',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Tap on Tab 3: Données & RGPD
      await tester.tap(find.text('Données & RGPD'));
      await tester.pumpAndSettle();

      expect(find.textContaining('100% Hors-ligne'), findsOneWidget);
      expect(find.byKey(const Key('parent_export_json_button')), findsOneWidget);
      expect(find.byKey(const Key('parent_delete_household_button')), findsOneWidget);

      // Tap delete button to open confirmation dialog
      await tester.ensureVisible(find.byKey(const Key('parent_delete_household_button')));
      await tester.tap(find.byKey(const Key('parent_delete_household_button')));
      await tester.pumpAndSettle();

      expect(find.text('Confirmer la suppression définitive ?'), findsOneWidget);
      expect(find.text('Oui, tout supprimer'), findsOneWidget);
    });
  });
}
