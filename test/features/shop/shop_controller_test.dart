import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/features/care/domain/pi_companion.dart';
import 'package:pi_et_moi/features/care/presentation/care_controller.dart';
import 'package:pi_et_moi/features/shop/domain/accessory_category.dart';
import 'package:pi_et_moi/features/shop/domain/accessory_item.dart';
import 'package:pi_et_moi/features/shop/domain/shop_state.dart';
import 'package:pi_et_moi/features/shop/presentation/shop_controller.dart';

void main() {
  group('ShopState Model Tests', () {
    test('serialization toMap and fromMap works properly', () {
      const state = ShopState(
        ownedAccessoryIds: {'blue_cap', 'nerd_glasses'},
        equippedAccessoryId: 'blue_cap',
      );

      final map = state.toMap();
      final restored = ShopState.fromMap(map);

      expect(
        restored.ownedAccessoryIds,
        containsAll(['blue_cap', 'nerd_glasses']),
      );
      expect(restored.equippedAccessoryId, equals('blue_cap'));
      expect(restored.selectedAccessoryId, equals('blue_cap'));
    });

    test('toJson and fromJson preserves data', () {
      const state = ShopState(
        ownedAccessoryIds: {'hero_cape'},
        equippedAccessoryId: 'hero_cape',
      );

      final json = state.toJson();
      final restored = ShopState.fromJson(json);

      expect(restored.ownedAccessoryIds, contains('hero_cape'));
      expect(restored.equippedAccessoryId, equals('hero_cape'));
    });

    test('copyWith clears fields correctly when specified', () {
      const state = ShopState(
        equippedAccessoryId: 'blue_cap',
        selectedAccessoryId: 'blue_cap',
        feedbackMessage: 'Message',
      );

      final updated = state.copyWith(
        clearEquipped: true,
        clearSelected: true,
        clearFeedback: true,
      );

      expect(updated.equippedAccessoryId, isNull);
      expect(updated.selectedAccessoryId, isNull);
      expect(updated.feedbackMessage, isNull);
    });
  });

  group('ShopController Unit Tests', () {
    late ShopController shopController;
    late CareController careController;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      shopController = ShopController(initialState: const ShopState());
      careController = CareController(
        initialCompanion: const PiCompanion(bones: 100),
      );
    });

    tearDown(() {
      shopController.dispose();
      careController.dispose();
    });

    test('initial state has empty owned items and no equipped accessory', () {
      expect(shopController.state.ownedAccessoryIds, isEmpty);
      expect(shopController.state.equippedAccessoryId, isNull);
      expect(
        shopController.state.selectedCategory,
        equals(AccessoryCategory.hats),
      );
    });

    test('selectCategory updates selectedCategory', () {
      shopController.selectCategory(AccessoryCategory.glasses);
      expect(
        shopController.state.selectedCategory,
        equals(AccessoryCategory.glasses),
      );
    });

    test('selectAccessory updates selectedAccessoryId', () {
      shopController.selectAccessory('nerd_glasses');
      expect(shopController.state.selectedAccessoryId, equals('nerd_glasses'));
    });

    test('buyAccessory with sufficient bones deducts bones, equips item, and gives feedback', () {
      final item = ShopCatalog.findById('blue_cap')!; // price = 50
      final success = shopController.buyAccessory(
        item: item,
        careNotifier: careController,
        isFrench: true,
      );

      expect(success, isTrue);
      expect(careController.state.bones, equals(50)); // 100 - 50
      expect(shopController.state.isOwned('blue_cap'), isTrue);
      expect(shopController.state.isEquipped('blue_cap'), isTrue);
      expect(shopController.state.feedbackMessage, contains('Casquette Bleue'));
    });

    test(
      'buyAccessory with insufficient bones fails and sets error feedback',
      () {
        careController.state = careController.state.copyWith(bones: 10);
        final item = ShopCatalog.findById('blue_cap')!; // price = 50
        final success = shopController.buyAccessory(
          item: item,
          careNotifier: careController,
          isFrench: true,
        );

        expect(success, isFalse);
        expect(careController.state.bones, equals(10)); // uncharged
        expect(shopController.state.isOwned('blue_cap'), isFalse);
        expect(
          shopController.state.feedbackMessage,
          contains('Il te manque 40 os dorés'),
        );
      },
    );

    test('equipAccessory equips owned item', () {
      final item = ShopCatalog.findById('blue_cap')!;
      shopController.buyAccessory(
        item: item,
        careNotifier: careController,
        isFrench: true,
      );

      // Unequip first
      shopController.unequipAccessory(isFrench: true);
      expect(shopController.state.equippedAccessoryId, isNull);

      // Re-equip
      shopController.equipAccessory('blue_cap', isFrench: true);
      expect(shopController.state.equippedAccessoryId, equals('blue_cap'));
      expect(shopController.state.feedbackMessage, contains('équipé'));
    });

    test('equipAccessory does nothing if item is not owned', () {
      shopController.equipAccessory('royal_crown', isFrench: true);
      expect(shopController.state.equippedAccessoryId, isNull);
    });

    test('unequipAccessory clears equipped item and sets feedback', () {
      final item = ShopCatalog.findById('blue_cap')!;
      shopController.buyAccessory(
        item: item,
        careNotifier: careController,
        isFrench: true,
      );

      shopController.unequipAccessory(isFrench: false);
      expect(shopController.state.equippedAccessoryId, isNull);
      expect(shopController.state.feedbackMessage, equals('Accessory removed'));
    });

    test('combines accessories across categories when trying on and wearing (hat + glasses + collar + cape)', () {
      careController.state = careController.state.copyWith(bones: 500);

      // 1. Try on hat + glasses + collar simultaneously in fitting room
      shopController.selectAccessory('top_hat');
      shopController.selectAccessory('nerd_glasses');
      shopController.selectAccessory('pirate_bandana');

      expect(
        shopController.state.activeFittingRoomIds,
        equals(['pirate_bandana', 'nerd_glasses', 'top_hat']),
      );

      // 2. Buy and equip hat, glasses, collar, and cape -> all 4 remain equipped together
      shopController.buyAccessory(
        item: ShopCatalog.findById('top_hat')!,
        careNotifier: careController,
        isFrench: true,
      );
      shopController.buyAccessory(
        item: ShopCatalog.findById('nerd_glasses')!,
        careNotifier: careController,
        isFrench: true,
      );
      shopController.buyAccessory(
        item: ShopCatalog.findById('pirate_bandana')!,
        careNotifier: careController,
        isFrench: true,
      );
      shopController.buyAccessory(
        item: ShopCatalog.findById('hero_cape')!,
        careNotifier: careController,
        isFrench: true,
      );

      expect(
        shopController.state.equippedAccessoryIds,
        equals(['hero_cape', 'pirate_bandana', 'nerd_glasses', 'top_hat']),
      );
      expect(shopController.state.isEquipped('top_hat'), isTrue);
      expect(shopController.state.isEquipped('nerd_glasses'), isTrue);
      expect(shopController.state.isEquipped('pirate_bandana'), isTrue);
      expect(shopController.state.isEquipped('hero_cape'), isTrue);

      // 3. Unequipping only glasses leaves hat, collar, and cape equipped
      shopController.unequipAccessory(id: 'nerd_glasses', isFrench: true);
      expect(
        shopController.state.equippedAccessoryIds,
        equals(['hero_cape', 'pirate_bandana', 'top_hat']),
      );
    });
  });
}
