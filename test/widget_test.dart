import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/core/localization/locale_controller.dart';
import 'package:pi_et_moi/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('PiEtMoiApp boots on SplashScreen and transitions', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          languageProvider.overrideWith((ref) => LanguageNotifier(systemLocaleCodeOverride: 'en')),
        ],
        child: const PiEtMoiApp(),
      ),
    );
    await tester.pump();

    // Verify splash screen in English
    expect(find.text('MathPup'), findsOneWidget);
    expect(find.text('Official curriculum from Grade 1 to 9'), findsOneWidget);

    // Let the animation and navigation settle
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Navigated to Onboarding Carousel Intro
    expect(find.text('Playful Math'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    // Tap Skip to transition to Profile Setup
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    // Navigated to Profile Setup Onboarding
    expect(find.text('Who will play with Pi?'), findsOneWidget);
    expect(find.text('Let\'s go!'), findsOneWidget);
  });
}
