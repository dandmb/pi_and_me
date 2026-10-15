import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/core/localization/locale_controller.dart';
import 'package:pi_et_moi/features/profile/data/profile_repository.dart';
import 'package:pi_et_moi/features/profile/domain/child_profile.dart';
import 'package:pi_et_moi/features/profile/domain/school_grade.dart';
import 'package:pi_et_moi/features/profile/presentation/profile_controller.dart';
import 'package:pi_et_moi/features/profile/presentation/widgets/profile_switcher_sheet.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'has_completed_care_showcase_v1': true,
    });
    prefs = await SharedPreferences.getInstance();
  });

  testWidgets('ProfileSwitcherSheet renders created profiles and marks active profile', (tester) async {
    final repo = ProfileRepository(prefs: prefs);
    final profile1 = ChildProfile(
      id: 'p1',
      name: 'Léa',
      avatar: 'avatar_dog',
      grade: SchoolGrade.cm1,
      createdAt: DateTime.now(),
    );
    final profile2 = ChildProfile(
      id: 'p2',
      name: 'Thomas',
      avatar: 'avatar_cat',
      grade: SchoolGrade.ce2,
      createdAt: DateTime.now(),
    );

    await repo.saveProfile(profile1);
    await repo.saveProfile(profile2);
    await repo.setActiveProfile('p1');

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
          home: Scaffold(
            body: ProfileSwitcherSheet(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify both profile names are listed
    expect(find.text('Profils des enfants'), findsOneWidget);
    expect(find.text('Léa'), findsOneWidget);
    expect(find.text('Thomas'), findsOneWidget);

    // Verify active badge on Léa
    expect(find.text('Actif'), findsOneWidget);

    // Switch to Thomas
    await tester.tap(find.text('Thomas'));
    await tester.pumpAndSettle();

    // Verify active profile in container changed to Thomas
    final active = container.read(activeProfileProvider).value;
    expect(active?.id, 'p2');
    expect(active?.name, 'Thomas');
  });
}
