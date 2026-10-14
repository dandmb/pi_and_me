import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/features/splash/presentation/splash_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SplashScreen renders title and badge', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SplashScreen(),
        ),
      ),
    );

    expect(find.text('Pi & Moi'), findsOneWidget);
    expect(find.text('Programmes officiels du CP à la 3e'), findsOneWidget);
    expect(find.text('Chargement...'), findsOneWidget);

    // Let the timer and animations complete
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
}
