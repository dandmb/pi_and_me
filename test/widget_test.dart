import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pi_et_moi/main.dart';

void main() {
  testWidgets('PiEtMoiApp boots and displays title', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PiEtMoiApp()));
    await tester.pumpAndSettle();

    expect(find.text('Pi & Moi'), findsOneWidget);
    expect(find.text('C\'est parti !'), findsOneWidget);
  });
}
