import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/core/audio/audio_service.dart';
import 'package:pi_et_moi/core/localization/locale_controller.dart';
import 'package:pi_et_moi/features/onboarding/presentation/onboarding_carousel_screen.dart';
import 'package:pi_et_moi/features/onboarding/presentation/onboarding_screen.dart';

class _FakeAudioPlayerClient implements AudioPlayerClient {
  @override
  Future<void> playAsset(String assetPath) async {}

  @override
  void dispose() {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestWidget({String locale = 'fr'}) {
    return ProviderScope(
      overrides: [
        languageProvider.overrideWith(
          (ref) => LanguageNotifier(systemLocaleCodeOverride: locale),
        ),
        audioServiceProvider.overrideWithValue(
          AudioService(client: _FakeAudioPlayerClient(), isSoundEnabled: false),
        ),
      ],
      child: const MaterialApp(home: OnboardingCarouselScreen()),
    );
  }

  testWidgets('renders first slide with tag, title, and buttons in French', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget(locale: 'fr'));
    await tester.pumpAndSettle();

    expect(find.text('Maths Ludiques'), findsOneWidget);
    expect(find.text('Progresse en maths sans stress'), findsOneWidget);
    expect(find.text('Passer'), findsOneWidget);
    expect(find.text('Suivant'), findsOneWidget);
  });

  testWidgets('renders first slide in English when locale is en', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget(locale: 'en'));
    await tester.pumpAndSettle();

    expect(find.text('Playful Math'), findsOneWidget);
    expect(find.text('Level up in math stress-free'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('swiping / clicking Next advances slides up to meet Pi CTA', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget(locale: 'fr'));
    await tester.pumpAndSettle();

    // Slide 1
    expect(find.text('Progresse en maths sans stress'), findsOneWidget);

    // Tap Suivant -> Slide 2
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();

    expect(find.text('Ton Compagnon'), findsOneWidget);
    expect(find.text('Prends soin de ton chiot Pi'), findsOneWidget);

    // Tap Suivant -> Slide 3
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();

    expect(find.text('Récompenses & Boutique'), findsOneWidget);
    expect(find.text('Gagne des os et habille Pi'), findsOneWidget);
    expect(find.text('Rencontrer Pi 🐾'), findsOneWidget);

    // Tap Rencontrer Pi -> transitions to OnboardingScreen
    await tester.tap(find.text('Rencontrer Pi 🐾'));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(kHasSeenOnboardingIntroKey), isTrue);
  });

  testWidgets('tapping Passer on slide 1 skips directly to OnboardingScreen', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget(locale: 'fr'));
    await tester.pumpAndSettle();

    final skipFinder = find.text('Passer');
    expect(skipFinder, findsOneWidget);

    await tester.tap(skipFinder);
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(kHasSeenOnboardingIntroKey), isTrue);
  });
}
