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

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'has_completed_care_showcase_v1': true,
    });
    prefs = await SharedPreferences.getInstance();
  });

  testWidgets('MainShellScreen renders persistent AppBar and BottomBar with Salon first', (tester) async {
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
        child: const MaterialApp(
          home: MainShellScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify Top AppBar elements
    expect(find.text('Léa (CM1)'), findsOneWidget);
    expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
    expect(find.byIcon(Icons.stars_rounded), findsWidgets);

    // 2. Verify 3-tab BottomBar with Salon at index 0
    expect(find.text('Salon'), findsWidgets);
    expect(find.text('Soigner'), findsWidgets);
    expect(find.text('Boutique'), findsWidgets);

    // 3. Switch to Soigner tab
    await tester.tap(find.text('Soigner').first);
    await tester.pumpAndSettle();

    // Verify Soigner content is now visible
    expect(find.text('Faim'), findsWidgets);
    expect(find.text('Joie'), findsWidgets);

    // 4. Switch to Boutique tab
    await tester.tap(find.text('Boutique').first);
    await tester.pumpAndSettle();

    // Verify Shop content is visible
    expect(find.text('Chapeaux'), findsWidgets);

    // 5. Test Back navigation while on Boutique -> Returns to Salon
    // Trigger pop on Navigator
    final dynamic popScope = tester.widget(find.byWidgetPredicate((w) => w is PopScope).first);
    popScope.onPopInvokedWithResult(false, null);
    await tester.pumpAndSettle();

    // Now active index should be 0 (Salon)
    expect(find.text('Jouer au Quiz'), findsOneWidget);
  });

  testWidgets('MainShellScreen bottom bar respects Android system navigation bar insets', (tester) async {
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

    // Simulate an Android device with a 48dp system navigation bar at the bottom
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(400, 800),
              padding: EdgeInsets.only(bottom: 48.0),
              viewPadding: EdgeInsets.only(bottom: 48.0),
            ),
            child: MainShellScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify all 3 navigation items are rendered and tappable
    expect(find.text('Salon'), findsWidgets);
    expect(find.text('Soigner'), findsWidgets);
    expect(find.text('Boutique'), findsWidgets);

    // Tap on Soigner tab - must register cleanly above the 48dp system navigation bar
    final soignerTarget = find.text('Soigner').first;
    final center = tester.getCenter(soignerTarget);
    // Center of Soigner must be strictly above (800 - 48 = 752)
    expect(center.dy < 752.0, isTrue);

    await tester.tap(soignerTarget);
    await tester.pumpAndSettle();

    // Verify Tab 1 is now active
    expect(find.text('Faim'), findsWidgets);
  });
}
