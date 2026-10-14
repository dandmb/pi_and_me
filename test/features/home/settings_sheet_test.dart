import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/core/localization/app_language.dart';
import 'package:pi_et_moi/core/localization/locale_controller.dart';
import 'package:pi_et_moi/features/home/presentation/settings_sheet.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SettingsSheet allows switching language from Settings', (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        languageProvider.overrideWith((ref) => LanguageNotifier(systemLocaleCodeOverride: 'en')),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: SettingsSheet(),
          ),
        ),
      ),
    );

    // Verify Settings UI in English
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('App Language'), findsOneWidget);
    expect(find.text('English active'), findsOneWidget);

    // Tap FR inside the settings sheet
    await tester.tap(find.text('FR'));
    await tester.pumpAndSettle();

    // Verify it switched to French
    expect(container.read(languageProvider), AppLanguage.fr);
    expect(find.text('Paramètres'), findsOneWidget);
    expect(find.text('Langue de l\'application'), findsOneWidget);
    expect(find.text('Français activé'), findsOneWidget);
  });
}
