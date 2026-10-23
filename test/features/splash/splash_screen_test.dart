import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/core/localization/locale_controller.dart';
import 'package:pi_et_moi/features/splash/presentation/splash_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'SplashScreen renders English title and badge when language is English',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            languageProvider.overrideWith(
              (ref) => LanguageNotifier(systemLocaleCodeOverride: 'en'),
            ),
          ],
          child: const MaterialApp(home: SplashScreen()),
        ),
      );

      expect(find.text('MathPup'), findsOneWidget);
      expect(
        find.text('Official curriculum from Grade 1 to 9'),
        findsOneWidget,
      );
      expect(find.text('Loading...'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 2));
    },
  );

  testWidgets('SplashScreen renders French when language is French', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          languageProvider.overrideWith(
            (ref) => LanguageNotifier(systemLocaleCodeOverride: 'fr'),
          ),
        ],
        child: const MaterialApp(home: SplashScreen()),
      ),
    );

    expect(find.text('MathPup'), findsOneWidget);
    expect(find.text('Programmes officiels du CP à la 3e'), findsOneWidget);
    expect(find.text('Chargement...'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
}
