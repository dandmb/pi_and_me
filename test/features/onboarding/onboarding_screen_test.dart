import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/core/localization/locale_controller.dart';
import 'package:pi_et_moi/features/onboarding/presentation/onboarding_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'has_completed_care_showcase_v1': true,
    });
  });

  testWidgets('OnboardingScreen renders English strings when language is English', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          languageProvider.overrideWith((ref) => LanguageNotifier(systemLocaleCodeOverride: 'en')),
        ],
        child: const MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );

    // English strings
    expect(find.text('Who will play with Pi?'), findsOneWidget);
    expect(find.text('Your first name'), findsOneWidget);
    expect(find.text('Your grade'), findsOneWidget);

    // Grades are displayed in English format (Grade 1 to 9)
    expect(find.text('Grade 1'), findsOneWidget);
    expect(find.text('Grade 4'), findsOneWidget);
    expect(find.text('Grade 9'), findsOneWidget);

    // Tap CTA to validate profile
    final ctaFinder = find.text('Let\'s go!');
    expect(ctaFinder, findsOneWidget);
    await tester.ensureVisible(ctaFinder);
    await tester.tap(ctaFinder);
    await tester.pumpAndSettle();
  });

  testWidgets('OnboardingScreen renders French when language is French', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          languageProvider.overrideWith((ref) => LanguageNotifier(systemLocaleCodeOverride: 'fr')),
        ],
        child: const MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );

    expect(find.text('Qui va jouer avec Pi ?'), findsOneWidget);
    expect(find.text('Ton prénom'), findsOneWidget);
    expect(find.text('Ta classe'), findsOneWidget);

    expect(find.text('CP'), findsOneWidget);
    expect(find.text('CM1'), findsOneWidget);
    expect(find.text('3e'), findsOneWidget);

    final ctaFinder = find.text('C\'est parti !');
    expect(ctaFinder, findsOneWidget);
    await tester.ensureVisible(ctaFinder);
    await tester.tap(ctaFinder);
    await tester.pumpAndSettle();
  });
}
