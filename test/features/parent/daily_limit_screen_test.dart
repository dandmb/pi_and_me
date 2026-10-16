import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/core/localization/app_language.dart';
import 'package:pi_et_moi/core/localization/locale_controller.dart';
import 'package:pi_et_moi/features/parent/domain/daily_limit_state.dart';
import 'package:pi_et_moi/features/parent/presentation/daily_limit_controller.dart';
import 'package:pi_et_moi/features/parent/presentation/daily_limit_screen.dart';
import 'package:pi_et_moi/features/profile/domain/child_profile.dart';
import 'package:pi_et_moi/features/profile/domain/school_grade.dart';
import 'package:pi_et_moi/features/profile/presentation/profile_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestApp({
    AppLanguage language = AppLanguage.fr,
    ChildProfile? profile,
    DailyLimitState? limitState,
  }) {
    final effectiveProfile = profile ??
        ChildProfile(
          id: 'child_1',
          name: 'Léa',
          avatar: 'avatar_dog',
          grade: SchoolGrade.cm1,
          createdAt: DateTime.now(),
        );

    final effectiveState = limitState ??
        DailyLimitState(
          profileId: effectiveProfile.id,
          usedSessionsToday: 6,
          maxDailySessions: 6,
          lastSessionDate: DateTime.now(),
        );

    return ProviderScope(
      overrides: [
        languageProvider.overrideWith(
          (ref) => LanguageNotifier(systemLocaleCodeOverride: language.code),
        ),
        activeProfileProvider.overrideWith(
          () => _MockActiveProfileNotifier(effectiveProfile),
        ),
        dailyLimitControllerProvider.overrideWith((ref) {
          return DailyLimitController(
            initialProfileId: effectiveProfile.id,
            initialState: effectiveState,
          );
        }),
      ],
      child: const MaterialApp(
        home: DailyLimitScreen(),
      ),
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DailyLimitScreen Widget Tests', () {
    testWidgets('Renders all benevolent screen time components in French',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // 1. Quota indicator 6/6
      expect(find.text('6/6'), findsOneWidget);

      // 2. Benevolent Title with Child Name
      expect(find.textContaining('Bravo Léa !'), findsOneWidget);
      expect(find.textContaining('Pi fait la sieste'), findsOneWidget);

      // 3. Countdown reset card
      expect(find.text('Prochaine réinitialisation dans :'), findsOneWidget);

      // 4. Offline activity card
      expect(find.text('L\'activité hors-écran du jour :'), findsOneWidget);

      // 5. Action button (only Return to Home, Care is deactivated when limit reached)
      expect(find.text('Prendre soin de Pi'), findsNothing);
      expect(find.text('Retour au salon'), findsOneWidget);
    });

    testWidgets('Renders properly in English', (tester) async {
      await tester.pumpWidget(buildTestApp(
        language: AppLanguage.en,
        profile: ChildProfile(
          id: 'child_en',
          name: 'Alex',
          avatar: 'avatar_fox',
          grade: SchoolGrade.cm1,
          createdAt: DateTime.now(),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('6/6'), findsOneWidget);
      expect(find.textContaining('Bravo Alex!'), findsOneWidget);
      expect(find.text('Next reset in:'), findsOneWidget);
      expect(find.text('Today\'s off-screen activity:'), findsOneWidget);
      expect(find.text('Take care of Pi'), findsNothing);
      expect(find.text('Return to Home'), findsOneWidget);
    });

    testWidgets('Tapping Return to Home button pops or navigates safely',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final returnBtn = find.text('Retour au salon');
      expect(returnBtn, findsOneWidget);

      await tester.tap(returnBtn);
      await tester.pumpAndSettle();
    });
  });
}

class _MockActiveProfileNotifier extends ActiveProfileNotifier {
  final ChildProfile _profile;
  _MockActiveProfileNotifier(this._profile);

  @override
  Future<ChildProfile?> build() async => _profile;
}
