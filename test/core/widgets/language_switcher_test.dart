import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/core/localization/app_language.dart';
import 'package:pi_et_moi/core/localization/locale_controller.dart';
import 'package:pi_et_moi/core/widgets/language_switcher.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('LanguageSwitcher toggles language between EN and FR', (WidgetTester tester) async {
    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: LanguageSwitcher(),
          ),
        ),
      ),
    );

    // Initial state is English by default
    expect(container.read(languageProvider), AppLanguage.en);
    expect(find.text('EN'), findsOneWidget);
    expect(find.text('FR'), findsOneWidget);

    // Tap on FR button
    await tester.tap(find.text('FR'));
    await tester.pumpAndSettle();

    // Now state is French
    expect(container.read(languageProvider), AppLanguage.fr);

    // Tap on EN button
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();

    // Now state is back to English
    expect(container.read(languageProvider), AppLanguage.en);
  });
}
