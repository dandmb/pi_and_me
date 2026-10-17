import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/core/localization/locale_controller.dart';
import 'package:pi_et_moi/features/care/presentation/widgets/animated_pi_mascot.dart';
import 'package:pi_et_moi/features/home/presentation/home_screen.dart';
import 'package:pi_et_moi/features/parent/domain/daily_limit_state.dart';
import 'package:pi_et_moi/features/parent/presentation/daily_limit_controller.dart';
import 'package:pi_et_moi/features/parent/presentation/daily_limit_screen.dart';
import 'package:pi_et_moi/features/profile/domain/child_profile.dart';
import 'package:pi_et_moi/features/profile/domain/school_grade.dart';
import 'package:pi_et_moi/features/profile/presentation/profile_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestApp({required DailyLimitState limitState}) {
    final profile = ChildProfile(
      id: 'test_child',
      name: 'Léa',
      avatar: 'avatar_dog',
      grade: SchoolGrade.cm1,
      createdAt: DateTime.now(),
    );

    return ProviderScope(
      overrides: [
        languageProvider.overrideWith(
          (ref) => LanguageNotifier(systemLocaleCodeOverride: 'fr'),
        ),
        activeProfileProvider.overrideWith(() => _MockActiveProfileNotifier(profile)),
        dailyLimitControllerProvider.overrideWith((ref) {
          return DailyLimitController(
            initialProfileId: 'test_child',
            initialState: limitState,
          );
        }),
      ],
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    );
  }

  group('HomeScreen Daily Limit integration', () {
    testWidgets('When quota available (< 6): shows Play Quiz button and active dialogue',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestApp(
        limitState: DailyLimitState(
          profileId: 'test_child',
          usedSessionsToday: 2,
          maxDailySessions: 6,
          lastSessionDate: DateTime.now(),
        ),
      ));
      await tester.pumpAndSettle();

      // Quota indicator shows 2/6
      expect(find.text('2/6'), findsOneWidget);

      // Play button available
      expect(find.text('Jouer au Quiz'), findsOneWidget);

      // Normal dialogue
      expect(find.textContaining('Prête pour le quiz'), findsOneWidget);

      // Tapping on DailyQuotaIndicator when quota is available opens info dialog, NOT DailyLimitScreen
      await tester.tap(find.text('2/6'));
      await tester.pumpAndSettle();

      // Info dialog appears with title 'Parties du jour'
      expect(find.text('Parties du jour'), findsOneWidget);
      expect(find.byType(DailyLimitScreen), findsNothing);

      // Dismiss dialog
      await tester.tap(find.text('C\'est parti !'));
      await tester.pumpAndSettle();
      expect(find.text('Parties du jour'), findsNothing);
    });

    testWidgets(
        'When quota reached (6/6): shows resting action, sleep notice, and opens DailyLimitScreen on tap',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestApp(
        limitState: DailyLimitState(
          profileId: 'test_child',
          usedSessionsToday: 6,
          maxDailySessions: 6,
          lastSessionDate: DateTime.now(),
        ),
      ));
      await tester.pumpAndSettle();

      // Quota indicator shows 6/6
      expect(find.text('6/6'), findsOneWidget);

      // Resting notice in dialogue bubble
      expect(find.textContaining('Zzz... Pi fait sa sieste !'), findsOneWidget);

      // Rest action button replaces Quiz button
      final restBtn = find.text('Voir Pi se reposer (6/6)');
      expect(restBtn, findsOneWidget);

      // Tapping rest button opens DailyLimitScreen
      await tester.tap(restBtn);
      await tester.pumpAndSettle();

      expect(find.byType(DailyLimitScreen), findsOneWidget);
    });

    testWidgets('When quota reached: tapping 6/6 DailyQuotaIndicator opens DailyLimitScreen',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestApp(
        limitState: DailyLimitState(
          profileId: 'test_child',
          usedSessionsToday: 6,
          maxDailySessions: 6,
          lastSessionDate: DateTime.now(),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('6/6'));
      await tester.pumpAndSettle();

      expect(find.byType(DailyLimitScreen), findsOneWidget);
    });

    testWidgets('When quota reached: tapping Pi mascot opens DailyLimitScreen',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestApp(
        limitState: DailyLimitState(
          profileId: 'test_child',
          usedSessionsToday: 6,
          maxDailySessions: 6,
          lastSessionDate: DateTime.now(),
        ),
      ));
      await tester.pumpAndSettle();

      // Tap on AnimatedPiMascot
      await tester.tap(find.byType(AnimatedPiMascot));
      await tester.pumpAndSettle();

      expect(find.byType(DailyLimitScreen), findsOneWidget);
    });

    testWidgets('When quota reached: tapping bottom dock Soigner or Boutique opens DailyLimitScreen',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestApp(
        limitState: DailyLimitState(
          profileId: 'test_child',
          usedSessionsToday: 6,
          maxDailySessions: 6,
          lastSessionDate: DateTime.now(),
        ),
      ));
      await tester.pumpAndSettle();

      // Tap on Soigner in bottom dock
      final soignerDock = find.text('Soigner');
      expect(soignerDock, findsOneWidget);
      await tester.tap(soignerDock);
      await tester.pumpAndSettle();

      expect(find.byType(DailyLimitScreen), findsOneWidget);
    });
  });
}

class _MockActiveProfileNotifier extends ActiveProfileNotifier {
  final ChildProfile _profile;
  _MockActiveProfileNotifier(this._profile);

  @override
  Future<ChildProfile?> build() async => _profile;
}
