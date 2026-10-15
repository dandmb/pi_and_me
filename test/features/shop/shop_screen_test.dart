import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/core/localization/locale_controller.dart';
import 'package:pi_et_moi/core/widgets/chunky_button.dart';
import 'package:pi_et_moi/features/care/domain/pi_companion.dart';
import 'package:pi_et_moi/features/care/presentation/care_controller.dart';
import 'package:pi_et_moi/features/profile/domain/child_profile.dart';
import 'package:pi_et_moi/features/profile/domain/school_grade.dart';
import 'package:pi_et_moi/features/profile/presentation/profile_controller.dart';
import 'package:pi_et_moi/features/shop/domain/shop_state.dart';
import 'package:pi_et_moi/features/shop/presentation/shop_controller.dart';
import 'package:pi_et_moi/features/shop/presentation/shop_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestableShopScreen({
    String systemLocale = 'fr',
    PiCompanion? initialCompanion,
    ShopState? initialShopState,
    SchoolGrade initialGrade = SchoolGrade.ce2,
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
                  bones: 150,
                ),
          ),
        ),
        shopControllerProvider.overrideWith(
          (ref) => ShopController(
            initialState: initialShopState ?? const ShopState(),
          ),
        ),
        activeProfileProvider.overrideWith(
          () => _TestActiveProfileNotifier(
            ChildProfile(
              id: 'test_child',
              name: 'Léo',
              grade: initialGrade,
              avatar: 'avatar_dog',
              createdAt: DateTime.now(),
            ),
          ),
        ),
      ],
      child: const MaterialApp(
        home: ShopScreen(),
      ),
    );
  }

  group('ShopScreen Widget Tests', () {
    testWidgets('renders shop header, bones balance, category selector, fitting room and catalog grid', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableShopScreen());
      await tester.pumpAndSettle();

      // Vérification Header
      expect(find.text('Boutique de Pi'), findsOneWidget);
      expect(find.text('150'), findsOneWidget); // Solde d'os dorés

      // Vérification Catégories
      expect(find.text('Chapeaux'), findsOneWidget);
      expect(find.text('Lunettes'), findsOneWidget);
      expect(find.text('Colliers'), findsOneWidget);
      expect(find.text('Capes'), findsOneWidget);

      // Vérification Cabine d'essayage
      expect(find.text('CABINE D\'ESSAYAGE'), findsOneWidget);
      expect(find.text('Pi au naturel ! Choisis un accessoire.'), findsOneWidget);

      // Vérification Catalogue Chapeaux
      expect(find.text('Casquette Bleue'), findsOneWidget);
      expect(find.text('Haut-de-forme'), findsOneWidget);
      expect(find.text('Bonnet d\'hiver'), findsOneWidget);
      expect(find.text('Couronne Royale'), findsOneWidget);

      // Onglets haut et Bottom dock
      expect(find.text('Garde-robe'), findsOneWidget);
      expect(find.text('Boutique'), findsNWidgets(2)); // Onglet haut + Dock
      expect(find.text('Soigner'), findsOneWidget);
      expect(find.text('Salon'), findsOneWidget);
    });

    testWidgets('switching categories displays accessories of that category', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableShopScreen());
      await tester.pumpAndSettle();

      // Switch to Lunettes
      await tester.tap(find.text('Lunettes'));
      await tester.pumpAndSettle();

      expect(find.text('Lunettes Rondes'), findsOneWidget);
      expect(find.text('Lunettes de Soleil'), findsOneWidget);
      expect(find.text('Casquette Bleue'), findsNothing);

      // Switch to Capes
      await tester.tap(find.text('Capes'));
      await tester.pumpAndSettle();

      expect(find.text('Cape de Super-Héros'), findsOneWidget);
      expect(find.text('Cape Étoilée'), findsOneWidget);
    });

    testWidgets('selecting an item updates fitting room preview label', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableShopScreen());
      await tester.pumpAndSettle();

      // Tap on Casquette Bleue card
      await tester.tap(find.text('Casquette Bleue'));
      await tester.pumpAndSettle();

      expect(find.text('Pi essaie : Casquette Bleue'), findsOneWidget);
      expect(find.text('Annuler l\'essai'), findsOneWidget);
    });

    testWidgets('buying an accessory purchases and equips it', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableShopScreen(
        initialCompanion: const PiCompanion(bones: 100),
      ));
      await tester.pumpAndSettle();

      // Find buy button for Casquette Bleue (Acheter (50))
      final buyButtonFinder = find.widgetWithText(ChunkyButton, 'Acheter (50)');
      expect(buyButtonFinder, findsWidgets);

      await tester.tap(buyButtonFinder.first);
      await tester.pumpAndSettle();

      // Bones deducted: 100 - 50 = 50
      expect(find.text('50'), findsOneWidget);

      // Now equipped
      expect(find.text('Équipé'), findsWidgets);
      expect(find.text('Pi porte : Casquette Bleue'), findsOneWidget);
      expect(find.text('Retirer'), findsOneWidget);
    });

    testWidgets('renders English strings when language is English', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableShopScreen(
        systemLocale: 'en',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Pi\'s Shop'), findsOneWidget);
      expect(find.text('FITTING ROOM'), findsOneWidget);
      expect(find.text('Natural Pi! Choose an accessory.'), findsOneWidget);
      expect(find.text('Hats'), findsOneWidget);
      expect(find.text('Glasses'), findsOneWidget);
      expect(find.text('Collars'), findsOneWidget);
      expect(find.text('Capes'), findsOneWidget);
      expect(find.text('Blue Cap'), findsOneWidget);
    });

    testWidgets('switching to wardrobe tab shows empty wardrobe state when no items owned', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableShopScreen());
      await tester.pumpAndSettle();

      // Clic sur l'onglet Garde-robe
      await tester.tap(find.text('Garde-robe'));
      await tester.pumpAndSettle();

      expect(find.text('Garde-robe vide'), findsOneWidget);
      expect(find.text('Aller à la boutique'), findsOneWidget);
    });
  });
}

class _TestActiveProfileNotifier extends ActiveProfileNotifier {
  final ChildProfile? _mockProfile;
  _TestActiveProfileNotifier(this._mockProfile);

  @override
  Future<ChildProfile?> build() async => _mockProfile;
}
