import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../care/presentation/care_controller.dart';
import '../domain/accessory_category.dart';
import '../domain/accessory_item.dart';
import '../domain/shop_state.dart';

/// Contrôleur Riverpod pour gérer la boutique de Pi, les achats avec les Os dorés,
/// l'inventaire possédé et l'accessoire actuellement équipé sur Pi.
class ShopController extends StateNotifier<ShopState> {
  static const String _storageKey = 'pi_shop_state_v1';
  final SharedPreferences? _prefs;
  Timer? _feedbackTimer;

  ShopController({SharedPreferences? prefsInstance, ShopState? initialState})
      : _prefs = prefsInstance,
        super(initialState ?? const ShopState()) {
    if (initialState == null) {
      _loadFromStorage();
    }
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    super.dispose();
  }

  void _startFeedbackTimer() {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(seconds: 4), () {
      state = state.copyWith(clearFeedback: true);
    });
  }

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        state = ShopState.fromJson(raw);
      }
    } catch (_) {}
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(_storageKey, state.toJson());
    } catch (_) {}
  }

  void selectCategory(AccessoryCategory category) {
    state = state.copyWith(selectedCategory: category, clearFeedback: true);
  }

  void selectAccessory(String id) {
    if (id.isEmpty) {
      // Annule les essais non équipés et conserve uniquement les accessoires portés
      state = state.copyWith(
        previewByCategory: Map<AccessoryCategory, String>.from(state.equippedByCategory),
        clearFeedback: true,
      );
      return;
    }

    final item = ShopCatalog.findById(id);
    final category = item?.category ?? state.selectedCategory;
    final nextPreview = Map<AccessoryCategory, String>.from(state.previewByCategory);
    nextPreview[category] = id;

    state = state.copyWith(
      previewByCategory: nextPreview,
      clearFeedback: true,
    );
  }

  void cancelCategoryPreview(AccessoryCategory category) {
    final nextPreview = Map<AccessoryCategory, String>.from(state.previewByCategory);
    final equippedInCat = state.equippedByCategory[category];
    if (equippedInCat != null) {
      nextPreview[category] = equippedInCat;
    } else {
      nextPreview.remove(category);
    }
    state = state.copyWith(
      previewByCategory: nextPreview,
      clearFeedback: true,
    );
  }

  bool buyAccessory({
    required AccessoryItem item,
    required CareController careNotifier,
    required bool isFrench,
  }) {
    final currentBones = careNotifier.state.bones;
    if (currentBones < item.price) {
      state = state.copyWith(
        feedbackMessage: isFrench
            ? 'Il te manque ${item.price - currentBones} os dorés pour cet article !'
            : 'You need ${item.price - currentBones} more golden bones for this item!',
      );
      _startFeedbackTimer();
      return false;
    }

    // Débit des Os dorés
    careNotifier.deductBones(item.price);

    // Ajout à l'inventaire & équipement automatique dans sa catégorie (sans retirer les autres catégories)
    final newOwned = Set<String>.from(state.ownedAccessoryIds)..add(item.id);
    final nextEquipped = Map<AccessoryCategory, String>.from(state.equippedByCategory)
      ..[item.category] = item.id;
    final nextPreview = Map<AccessoryCategory, String>.from(state.previewByCategory)
      ..[item.category] = item.id;

    state = state.copyWith(
      ownedAccessoryIds: newOwned,
      equippedByCategory: nextEquipped,
      previewByCategory: nextPreview,
      feedbackMessage: isFrench
          ? '${item.nameFr} acheté et équipé !'
          : '${item.nameEn} purchased & equipped!',
    );
    _saveToStorage();
    _startFeedbackTimer();
    return true;
  }

  void equipAccessory(String id, {required bool isFrench}) {
    if (!state.isOwned(id)) return;
    final item = ShopCatalog.findById(id);
    final category = item?.category ?? state.selectedCategory;
    final nextEquipped = Map<AccessoryCategory, String>.from(state.equippedByCategory)
      ..[category] = id;
    final nextPreview = Map<AccessoryCategory, String>.from(state.previewByCategory)
      ..[category] = id;

    state = state.copyWith(
      equippedByCategory: nextEquipped,
      previewByCategory: nextPreview,
      feedbackMessage: isFrench
          ? '${item?.nameFr ?? 'Accessoire'} équipé !'
          : '${item?.nameEn ?? 'Accessory'} equipped!',
    );
    _saveToStorage();
    _startFeedbackTimer();
  }

  void unequipAccessory({String? id, required bool isFrench}) {
    if (id != null && id.isNotEmpty) {
      final item = ShopCatalog.findById(id);
      final category = item?.category ?? state.selectedCategory;
      final nextEquipped = Map<AccessoryCategory, String>.from(state.equippedByCategory);
      final nextPreview = Map<AccessoryCategory, String>.from(state.previewByCategory);
      if (nextEquipped[category] == id) {
        nextEquipped.remove(category);
      }
      if (nextPreview[category] == id) {
        nextPreview.remove(category);
      }
      state = state.copyWith(
        equippedByCategory: nextEquipped,
        previewByCategory: nextPreview,
        feedbackMessage: isFrench ? 'Accessoire retiré' : 'Accessory removed',
      );
    } else {
      state = state.copyWith(
        clearEquipped: true,
        clearSelected: true,
        feedbackMessage: isFrench ? 'Accessoire retiré' : 'Accessory removed',
      );
    }
    _saveToStorage();
    _startFeedbackTimer();
  }

  void clearFeedback() {
    _feedbackTimer?.cancel();
    state = state.copyWith(clearFeedback: true);
  }
}

/// Provider global de la boutique de Pi
final shopControllerProvider =
    StateNotifierProvider<ShopController, ShopState>((ref) {
  return ShopController();
});
