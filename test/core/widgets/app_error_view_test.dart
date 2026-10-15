import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_et_moi/core/widgets/app_error_view.dart';

void main() {
  testWidgets('AppErrorView renders kid-friendly message and handles retry & home', (tester) async {
    bool retried = false;
    bool homed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppErrorView(
            isFrench: true,
            customMessage: 'Message personnalisé d\'erreur',
            onRetry: () => retried = true,
            onHome: () => homed = true,
          ),
        ),
      ),
    );

    expect(find.text('Oups ! Une petite bêtise...'), findsOneWidget);
    expect(find.text('Message personnalisé d\'erreur'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
    expect(find.text('Retour au salon'), findsOneWidget);

    await tester.tap(find.text('Réessayer'));
    await tester.pump();
    expect(retried, isTrue);

    await tester.tap(find.text('Retour au salon'));
    await tester.pump();
    expect(homed, isTrue);
  });
}
