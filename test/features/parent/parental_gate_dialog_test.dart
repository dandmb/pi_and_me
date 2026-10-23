import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_et_moi/core/localization/locale_controller.dart';
import 'package:pi_et_moi/features/parent/domain/parental_gate_challenge.dart';
import 'package:pi_et_moi/features/parent/presentation/widgets/parental_gate_dialog.dart';

void main() {
  Widget createDialogWidget({
    required VoidCallback onSuccess,
    ParentalGateChallenge? challenge,
    ParentalGateLockoutManager? lockoutManager,
  }) {
    return ProviderScope(
      overrides: [
        languageProvider.overrideWith(
          (ref) => LanguageNotifier(systemLocaleCodeOverride: 'fr'),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                ParentalGateDialog.show(
                  context,
                  onSuccess: onSuccess,
                  testChallenge: challenge,
                  testLockoutManager: lockoutManager,
                );
              },
              child: const Text('Open Gate'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'ParentalGateDialog displays challenge and triggers onSuccess upon correct input',
    (tester) async {
      bool successCalled = false;
      const testChallenge = ParentalGateChallenge(
        questionFr: 'Quarante-huit divisé par six',
        questionEn: 'Forty-eight divided by six',
        expectedAnswer: 8,
      );

      await tester.pumpWidget(
        createDialogWidget(
          onSuccess: () => successCalled = true,
          challenge: testChallenge,
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open Gate'));
      await tester.pumpAndSettle();

      // Check challenge rendered
      expect(find.text('Quarante-huit divisé par six'), findsOneWidget);
      expect(find.byKey(const Key('parental_gate_input')), findsOneWidget);

      // Enter correct answer '8'
      await tester.enterText(find.byKey(const Key('parental_gate_input')), '8');
      await tester.pump();

      // Submit
      await tester.tap(find.byKey(const Key('parental_gate_submit_button')));
      await tester.pumpAndSettle();

      expect(successCalled, isTrue);
      expect(find.byType(ParentalGateDialog), findsNothing);
    },
  );

  testWidgets(
    'ParentalGateDialog accepts answers with comma notation (e.g. 8,0)',
    (tester) async {
      bool successCalled = false;
      const testChallenge = ParentalGateChallenge(
        questionFr: 'Quarante-huit divisé par six',
        questionEn: 'Forty-eight divided by six',
        expectedAnswer: 8,
      );

      await tester.pumpWidget(
        createDialogWidget(
          onSuccess: () => successCalled = true,
          challenge: testChallenge,
        ),
      );

      await tester.tap(find.text('Open Gate'));
      await tester.pumpAndSettle();

      // Enter answer with a comma '8,0'
      await tester.enterText(
        find.byKey(const Key('parental_gate_input')),
        '8,0',
      );
      await tester.pump();

      // Submit
      await tester.tap(find.byKey(const Key('parental_gate_submit_button')));
      await tester.pumpAndSettle();

      expect(successCalled, isTrue);
      expect(find.byType(ParentalGateDialog), findsNothing);
    },
  );

  testWidgets(
    'ParentalGateDialog shows error and remaining attempts on incorrect answer',
    (tester) async {
      bool successCalled = false;
      const testChallenge = ParentalGateChallenge(
        questionFr: 'Sept multiplié par huit',
        questionEn: 'Seven multiplied by eight',
        expectedAnswer: 56,
      );

      await tester.pumpWidget(
        createDialogWidget(
          onSuccess: () => successCalled = true,
          challenge: testChallenge,
        ),
      );

      await tester.tap(find.text('Open Gate'));
      await tester.pumpAndSettle();

      // Enter wrong answer '12'
      await tester.enterText(
        find.byKey(const Key('parental_gate_input')),
        '12',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('parental_gate_submit_button')));
      await tester.pumpAndSettle();

      expect(successCalled, isFalse);
      expect(find.textContaining('2 essais restants'), findsOneWidget);
    },
  );

  testWidgets('ParentalGateDialog locks out after 3 failed attempts', (
    tester,
  ) async {
    const testChallenge = ParentalGateChallenge(
      questionFr: 'Sept multiplié par huit',
      questionEn: 'Seven multiplied by eight',
      expectedAnswer: 56,
    );

    await tester.pumpWidget(
      createDialogWidget(onSuccess: () {}, challenge: testChallenge),
    );

    await tester.tap(find.text('Open Gate'));
    await tester.pumpAndSettle();

    final inputFinder = find.byKey(const Key('parental_gate_input'));
    final submitFinder = find.byKey(const Key('parental_gate_submit_button'));

    // Attempt 1
    await tester.enterText(inputFinder, '1');
    await tester.tap(submitFinder);
    await tester.pumpAndSettle();

    // Attempt 2
    await tester.enterText(inputFinder, '2');
    await tester.tap(submitFinder);
    await tester.pumpAndSettle();

    // Attempt 3 -> triggers lockout
    await tester.enterText(inputFinder, '3');
    await tester.tap(submitFinder);
    await tester.pumpAndSettle();

    expect(find.textContaining('Trop d\'essais'), findsOneWidget);
  });
}
