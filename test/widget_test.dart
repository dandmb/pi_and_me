import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('PiEtMoiApp boots on SplashScreen and transitions', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PiEtMoiApp()));
    await tester.pump();

    // Verify splash screen content
    expect(find.text('Pi & Moi'), findsOneWidget);
    expect(find.text('Programmes officiels du CP à la 3e'), findsOneWidget);

    // Let the animation and navigation settle
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Navigated to Onboarding because no profile exists
    expect(find.text('Qui va jouer avec Pi ?'), findsOneWidget);
  });
}
