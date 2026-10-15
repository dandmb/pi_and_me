import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/core/localization/locale_controller.dart';
import 'package:pi_et_moi/features/care/domain/pi_companion.dart';
import 'package:pi_et_moi/features/care/domain/play_environment.dart';
import 'package:pi_et_moi/features/care/presentation/care_controller.dart';
import 'package:pi_et_moi/features/care/presentation/care_screen.dart';
import 'package:pi_et_moi/core/widgets/chunky_button.dart';
import 'package:pi_et_moi/features/care/presentation/widgets/feed_walkthrough_dialog.dart';
import 'package:pi_et_moi/features/care/presentation/widgets/kibble_widget.dart';
import 'package:pi_et_moi/features/care/presentation/widgets/play_onboarding_dialog.dart';
import 'package:pi_et_moi/features/care/presentation/widgets/tennis_ball_widget.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'has_completed_care_showcase_v1': true,
      PlayOnboardingDialog.prefKey: true,
      FeedWalkthroughDialog.prefKey: true,
    });
  });

  Widget buildTestableCareScreen({
    String systemLocale = 'fr',
    PiCompanion? initialCompanion,
  }) {
    return ProviderScope(
      overrides: [
        languageProvider.overrideWith(
          (ref) => LanguageNotifier(systemLocaleCodeOverride: systemLocale),
        ),
        careControllerProvider.overrideWith(
          (ref) => CareController(
            initialCompanion: initialCompanion ??
                const PiCompanion(
                  hunger: 0.80,
                  joy: 0.70,
                  energy: 0.90,
                  croquettes: 3,
                  balls: 4,
                  bones: 100,
                  environment: PlayEnvironment.livingRoom,
                ),
          ),
        ),
      ],
      child: const MaterialApp(
        home: CareScreen(),
      ),
    );
  }

  group('CareScreen Widget Tests', () {
    testWidgets('renders header, environment selector, gauges, tennis ball row and action tray in French', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableCareScreen(systemLocale: 'fr'));
      await tester.pumpAndSettle();

      expect(find.text('Prendre soin de Pi'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);

      expect(find.text('Salon'), findsWidgets);
      expect(find.text('Jardin'), findsOneWidget);
      expect(find.text('Plage'), findsOneWidget);
      expect(find.text('Forêt'), findsOneWidget);

      expect(find.text('Faim'), findsOneWidget);
      expect(find.text('Joie'), findsOneWidget);
      expect(find.text('Énergie'), findsOneWidget);
      expect(find.text('Propreté'), findsOneWidget);

      expect(find.text('Balles'), findsOneWidget);
      expect(find.text('Lancer la balle'), findsOneWidget);
      expect(find.byType(TennisBallWidget), findsWidgets);

      expect(find.text('Jouer'), findsOneWidget);
      expect(find.text('Nourrir'), findsOneWidget);
      expect(find.text('Laver'), findsOneWidget);
      expect(find.text('Guider'), findsOneWidget);
      expect(find.text('Dodo'), findsOneWidget);
    });

    testWidgets('switching mode clears previous status message', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableCareScreen(
        systemLocale: 'fr',
        initialCompanion: const PiCompanion(
          statusMessage: 'Wouf ! Balle rapportée ! (+25% Joie)',
          croquettes: 3,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Wouf ! Balle rapportée ! (+25% Joie)'), findsOneWidget);

      // Clic sur Nourrir : le message doit être effacé immédiatement
      await tester.tap(find.text('Nourrir'));
      await tester.pumpAndSettle();

      expect(find.text('Wouf ! Balle rapportée ! (+25% Joie)'), findsNothing);
    });

    testWidgets('serving food and come eat 5-second sequence', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableCareScreen(
        systemLocale: 'fr',
        initialCompanion: const PiCompanion(croquettes: 3, hunger: 0.50),
      ));
      await tester.pumpAndSettle();

      // Passer en mode Nourrir
      await tester.tap(find.text('Nourrir'));
      await tester.pumpAndSettle();

      expect(find.text('Croquettes'), findsOneWidget);
      expect(find.text('Servir'), findsOneWidget);
      expect(find.byType(KibbleWidget), findsWidgets);

      // Clic sur Servir
      await tester.tap(find.text('Servir'));
      await tester.pumpAndSettle();

      // Maintenant le bouton "Viens manger !" doit apparaître car la gamelle contient 1 croquette
      expect(find.text('Viens manger !'), findsOneWidget);

      // Clic sur "Viens manger !"
      await tester.tap(find.text('Viens manger !'));
      await tester.pump();

      expect(find.text('Miam miam miam...'), findsOneWidget);
      expect(find.text('Repas en cours...'), findsOneWidget);

      // Avance le temps de 5 secondes : Pi finit de manger et retourne au centre
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      expect(find.text('Miam ! Délicieux repas, merci ! (+Faim)'), findsOneWidget);
    });

    testWidgets('sleep mode activates bedtime scene and toggles nap/wake', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableCareScreen(systemLocale: 'fr'));
      await tester.pumpAndSettle();

      // Clic sur Dodo
      await tester.tap(find.text('Dodo'));
      await tester.pumpAndSettle();

      expect(find.text('Pi dort paisiblement... Chut !'), findsOneWidget);
      expect(find.widgetWithText(ChunkyButton, 'Réveiller'), findsOneWidget);

      // Clic sur Réveiller
      await tester.tap(find.widgetWithText(ChunkyButton, 'Réveiller'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ChunkyButton, 'Faire dodo'), findsOneWidget);
    });

    testWidgets('status reward message auto-dismisses after 4 seconds', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableCareScreen(
        systemLocale: 'fr',
        initialCompanion: const PiCompanion(
          statusMessage: 'Bravo Pi ! (+10% Joie)',
        ),
      ));
      await tester.pump();

      expect(find.text('Bravo Pi ! (+10% Joie)'), findsOneWidget);

      // Avance le temps de 4 secondes pour déclencher le timer d'auto-dismiss
      await tester.pump(const Duration(seconds: 4));
      await tester.pump();

      expect(find.text('Bravo Pi ! (+10% Joie)'), findsNothing);
    });

    testWidgets('clean mode washes dirty Pi and restores cleanliness', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableCareScreen(
        systemLocale: 'fr',
        initialCompanion: const PiCompanion(
          dirtCount: 3,
          cleanliness: 0.25,
        ),
      ));
      await tester.pumpAndSettle();

      // Clic sur Laver
      await tester.tap(find.text('Laver'));
      await tester.pumpAndSettle();

      expect(find.text('Pi a besoin d\'un bon bain !'), findsOneWidget);

      // Clic sur le bouton Laver
      await tester.tap(find.widgetWithText(ChunkyButton, 'Laver'));
      await tester.pumpAndSettle();

      expect(find.text('Tout propre et tout frais ! (+15% Joie)'), findsOneWidget);
      expect(find.text('Pi est tout propre et brillant !'), findsOneWidget);
    });

    testWidgets('renders in English when language is English', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableCareScreen(systemLocale: 'en'));
      await tester.pumpAndSettle();

      expect(find.text('Care for Pi'), findsOneWidget);
      expect(find.text('Play'), findsOneWidget);
      expect(find.text('Feed'), findsOneWidget);
      expect(find.text('Wash'), findsOneWidget);
    });
  });
}
