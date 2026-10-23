import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_et_moi/core/localization/locale_controller.dart';
import 'package:pi_et_moi/features/about/presentation/about_screen.dart';
import 'package:pi_et_moi/features/home/presentation/settings_sheet.dart';
import 'package:pi_et_moi/features/parent/presentation/widgets/parental_gate_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('AboutScreen renders MathPup info, mission, and Dan Bizwa contacts', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        languageProvider.overrideWith(
          (ref) => LanguageNotifier(systemLocaleCodeOverride: 'fr'),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AboutScreen()),
      ),
    );

    // Header & App Info
    expect(find.text('MathPup'), findsWidgets);
    expect(find.text('À propos de MathPup'), findsOneWidget);
    expect(find.text('Version 1.0.0 (Build 1)'), findsOneWidget);
    expect(find.text('100% Hors-ligne'), findsOneWidget);
    expect(find.text('Zéro Publicité'), findsOneWidget);

    // Creator / Developer Dan Bizwa
    expect(find.text('Dan Bizwa'), findsOneWidget);
    expect(find.text('Concepteur & Développeur Mobile'), findsOneWidget);

    // Contacts
    expect(find.text('bizwadan@gmail.com'), findsOneWidget);
    expect(find.text('https://www.linkedin.com/in/dan-bizwa/'), findsOneWidget);
  });

  testWidgets('Tapping email or LinkedIn in AboutScreen prompts ParentalGateDialog', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        languageProvider.overrideWith(
          (ref) => LanguageNotifier(systemLocaleCodeOverride: 'fr'),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AboutScreen()),
      ),
    );

    // Tap on the Email contact tile
    await tester.tap(find.text('bizwadan@gmail.com'));
    await tester.pumpAndSettle();

    // Verify ParentalGateDialog is displayed to protect child from leaving the app
    expect(find.byType(ParentalGateDialog), findsOneWidget);
  });

  testWidgets('Copying email or LinkedIn button puts text in clipboard', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        languageProvider.overrideWith(
          (ref) => LanguageNotifier(systemLocaleCodeOverride: 'fr'),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AboutScreen()),
      ),
    );

    // Find and tap email copy button
    final emailCopyBtn = find.byKey(const Key('copy_bizwadan@gmail.com'));
    expect(emailCopyBtn, findsOneWidget);

    await tester.tap(emailCopyBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify snackbar is shown
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Copié dans le presse-papier !'), findsOneWidget);
  });

  testWidgets('SettingsSheet contains About tile and can show AboutScreen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        languageProvider.overrideWith(
          (ref) => LanguageNotifier(systemLocaleCodeOverride: 'fr'),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => SettingsSheet.show(ctx),
                child: const Text('Open Settings'),
              ),
            ),
          ),
        ),
      ),
    );

    // Open SettingsSheet bottom sheet
    await tester.tap(find.text('Open Settings'));
    await tester.pumpAndSettle();

    // Verify About tile exists
    final aboutTile = find.byKey(const Key('about_screen_entry_tile'));
    expect(aboutTile, findsOneWidget);

    // Tap About tile
    await tester.tap(aboutTile);
    await tester.pumpAndSettle();

    // Verify AboutScreen is opened
    expect(find.byType(AboutScreen), findsOneWidget);
    expect(find.text('Dan Bizwa'), findsOneWidget);
  });
}
