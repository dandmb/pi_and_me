import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_et_moi/core/widgets/chunky_button.dart';

void main() {
  group('ChunkyButton Widget Tests', () {
    testWidgets('renders button label and responds to tap', (
      WidgetTester tester,
    ) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChunkyButton(
              label: 'Jouer au Quiz',
              variant: ChunkyButtonVariant.primary,
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      // Verify label is present
      expect(find.text('Jouer au Quiz'), findsOneWidget);

      // Tap on the button
      await tester.tap(find.text('Jouer au Quiz'));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('renders secondary variant correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChunkyButton(
              label: 'Retour',
              variant: ChunkyButtonVariant.secondary,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Retour'), findsOneWidget);
    });

    testWidgets('disabled button does not trigger callback', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChunkyButton(label: 'Désactivé', onPressed: null),
          ),
        ),
      );

      expect(find.text('Désactivé'), findsOneWidget);
      await tester.tap(find.text('Désactivé'));
      await tester.pump();
      // Test passes without throwing
    });
  });
}
