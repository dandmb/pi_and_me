import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/features/onboarding/presentation/onboarding_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('OnboardingScreen renders header, name input, and grade chips', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );

    // Header and title
    expect(find.text('Qui va jouer avec Pi ?'), findsOneWidget);
    expect(find.text('Ton prénom'), findsOneWidget);
    expect(find.text('Ta classe'), findsOneWidget);

    // Grades are displayed
    expect(find.text('CP'), findsOneWidget);
    expect(find.text('CM1'), findsOneWidget);
    expect(find.text('3e'), findsOneWidget);

    // Can change grade to 6e
    await tester.tap(find.text('6e'));
    await tester.pumpAndSettle();

    // Scroll to CTA button and tap to validate profile
    final ctaFinder = find.text('C\'est parti !');
    expect(ctaFinder, findsOneWidget);
    await tester.ensureVisible(ctaFinder);
    await tester.tap(ctaFinder);
    await tester.pumpAndSettle();
  });
}
