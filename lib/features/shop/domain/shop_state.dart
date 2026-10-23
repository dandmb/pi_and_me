import 'dart:convert';

import 'accessory_category.dart';
import 'accessory_item.dart';

/// État immuable de la boutique, des articles achetés et des accessoires combinés
/// (équipés sur Pi ou essayés simultanément dans la cabine d'essayage).
class ShopState {
  /// Ordre anatomique de superposition des calques (du plus en arrière au plus en avant)
  static const List<AccessoryCategory> layerOrder = [
    AccessoryCategory.capes,
    AccessoryCategory.collars,
    AccessoryCategory.glasses,
    AccessoryCategory.hats,
  ];

  final Set<String> ownedAccessoryIds;
  final Map<AccessoryCategory, String> _equippedMap;
  final Map<AccessoryCategory, String> _previewMap;
  final String? _legacyEquippedId;
  final String? _legacySelectedId;
  final AccessoryCategory selectedCategory;
  final String? feedbackMessage;

  const ShopState({
    this.ownedAccessoryIds = const {},
    Map<AccessoryCategory, String> equippedByCategory = const {},
    Map<AccessoryCategory, String> previewByCategory = const {},
    String? equippedAccessoryId,
    String? selectedAccessoryId,
    this.selectedCategory = AccessoryCategory.hats,
    this.feedbackMessage,
  }) : _equippedMap = equippedByCategory,
       _previewMap = previewByCategory,
       _legacyEquippedId = equippedAccessoryId,
       _legacySelectedId = selectedAccessoryId;

  /// Accessoires actuellement portés par Pi (jusqu'à 1 par catégorie : chapeau, lunettes, collier/écharpe, cape).
  Map<AccessoryCategory, String> get equippedByCategory {
    if (_equippedMap.isNotEmpty) return _equippedMap;
    if (_legacyEquippedId != null && _legacyEquippedId.isNotEmpty) {
      final item = ShopCatalog.findById(_legacyEquippedId);
      final category = item?.category ?? AccessoryCategory.hats;
      return {category: _legacyEquippedId};
    }
    return const {};
  }

  /// Accessoires actuellement essayés dans la cabine par catégorie.
  Map<AccessoryCategory, String> get previewByCategory {
    if (_previewMap.isNotEmpty) return _previewMap;
    final fallbackId = _legacySelectedId ?? _legacyEquippedId;
    if (fallbackId != null && fallbackId.isNotEmpty) {
      final item = ShopCatalog.findById(fallbackId);
      final category = item?.category ?? AccessoryCategory.hats;
      return {category: fallbackId};
    }
    return const {};
  }

  /// Liste ordonnée des identifiants d'accessoires équipés sur Pi (Capes -> Colliers -> Lunettes -> Chapeaux).
  List<String> get equippedAccessoryIds {
    final map = equippedByCategory;
    final result = <String>[];
    for (final cat in layerOrder) {
      final id = map[cat];
      if (id != null && id.isNotEmpty) {
        result.add(id);
      }
    }
    return result;
  }

  /// Liste ordonnée des accessoires affichés sur Pi dans la cabine d'essayage :
  /// combine la tenue portée (`equippedByCategory`) avec les essais en cours (`previewByCategory`).
  List<String> get activeFittingRoomIds {
    final merged = <AccessoryCategory, String>{
      ...equippedByCategory,
      ...previewByCategory,
    };
    final result = <String>[];
    for (final cat in layerOrder) {
      final id = merged[cat];
      if (id != null && id.isNotEmpty) {
        result.add(id);
      }
    }
    return result;
  }

  /// Identifiants d'accessoires en cours d'essai mais pas encore portés/équipés.
  List<String> get unequippedPreviewIds {
    final equipped = equippedByCategory;
    final preview = previewByCategory;
    final result = <String>[];
    for (final cat in layerOrder) {
      final pId = preview[cat];
      if (pId != null && pId.isNotEmpty && equipped[cat] != pId) {
        result.add(pId);
      }
    }
    return result;
  }

  /// Compatibilité unitaire : retourne l'accessoire équipé de la catégorie active (ou le dernier équipé).
  String? get equippedAccessoryId {
    final map = equippedByCategory;
    if (map.isEmpty) return null;
    return map[selectedCategory] ?? map.values.last;
  }

  /// Compatibilité unitaire : retourne l'accessoire sélectionné/essayé de la catégorie active (ou le dernier essayé).
  String? get selectedAccessoryId {
    final pMap = previewByCategory;
    if (pMap.containsKey(selectedCategory)) {
      return pMap[selectedCategory];
    }
    final eMap = equippedByCategory;
    if (eMap.containsKey(selectedCategory)) {
      return eMap[selectedCategory];
    }
    if (pMap.isNotEmpty) return pMap.values.last;
    if (eMap.isNotEmpty) return eMap.values.last;
    return null;
  }

  bool isOwned(String id) => ownedAccessoryIds.contains(id);
  bool isEquipped(String id) => equippedByCategory.containsValue(id);
  bool isSelected(String id) =>
      previewByCategory.containsValue(id) ||
      (!previewByCategory.containsKey(ShopCatalog.findById(id)?.category) &&
          equippedByCategory.containsValue(id));

  ShopState copyWith({
    Set<String>? ownedAccessoryIds,
    Map<AccessoryCategory, String>? equippedByCategory,
    Map<AccessoryCategory, String>? previewByCategory,
    String? equippedAccessoryId,
    bool clearEquipped = false,
    String? selectedAccessoryId,
    bool clearSelected = false,
    AccessoryCategory? selectedCategory,
    String? feedbackMessage,
    bool clearFeedback = false,
  }) {
    Map<AccessoryCategory, String> nextEquipped;
    if (clearEquipped) {
      nextEquipped = const {};
    } else if (equippedByCategory != null) {
      nextEquipped = Map<AccessoryCategory, String>.unmodifiable(
        equippedByCategory,
      );
    } else if (equippedAccessoryId != null) {
      final item = ShopCatalog.findById(equippedAccessoryId);
      final cat = item?.category ?? (selectedCategory ?? this.selectedCategory);
      nextEquipped = Map<AccessoryCategory, String>.unmodifiable({
        ...this.equippedByCategory,
        cat: equippedAccessoryId,
      });
    } else {
      nextEquipped = this.equippedByCategory;
    }

    Map<AccessoryCategory, String> nextPreview;
    if (clearSelected) {
      nextPreview = const {};
    } else if (previewByCategory != null) {
      nextPreview = Map<AccessoryCategory, String>.unmodifiable(
        previewByCategory,
      );
    } else if (selectedAccessoryId != null) {
      if (selectedAccessoryId.isEmpty) {
        nextPreview = const {};
      } else {
        final item = ShopCatalog.findById(selectedAccessoryId);
        final cat =
            item?.category ?? (selectedCategory ?? this.selectedCategory);
        nextPreview = Map<AccessoryCategory, String>.unmodifiable({
          ...this.previewByCategory,
          cat: selectedAccessoryId,
        });
      }
    } else {
      nextPreview = this.previewByCategory;
    }

    return ShopState(
      ownedAccessoryIds: ownedAccessoryIds ?? this.ownedAccessoryIds,
      equippedByCategory: nextEquipped,
      previewByCategory: nextPreview,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      feedbackMessage: clearFeedback
          ? null
          : (feedbackMessage ?? this.feedbackMessage),
    );
  }

  Map<String, dynamic> toMap() {
    final eqMap = <String, String>{};
    for (final entry in equippedByCategory.entries) {
      eqMap[entry.key.name] = entry.value;
    }
    return {
      'ownedAccessoryIds': ownedAccessoryIds.toList(),
      'equippedAccessoryId': equippedAccessoryId,
      'equippedByCategory': eqMap,
    };
  }

  factory ShopState.fromMap(Map<String, dynamic> map) {
    final rawOwned = map['ownedAccessoryIds'] as List<dynamic>? ?? [];
    final equippedSingle = map['equippedAccessoryId'] as String?;
    final rawEquippedMap = map['equippedByCategory'] as Map<String, dynamic>?;

    final parsedEquipped = <AccessoryCategory, String>{};
    if (rawEquippedMap != null && rawEquippedMap.isNotEmpty) {
      for (final entry in rawEquippedMap.entries) {
        final val = entry.value?.toString() ?? '';
        if (val.isEmpty) continue;
        for (final cat in AccessoryCategory.values) {
          if (cat.name == entry.key) {
            parsedEquipped[cat] = val;
            break;
          }
        }
      }
    } else if (equippedSingle != null && equippedSingle.isNotEmpty) {
      final item = ShopCatalog.findById(equippedSingle);
      parsedEquipped[item?.category ?? AccessoryCategory.hats] = equippedSingle;
    }

    return ShopState(
      ownedAccessoryIds: rawOwned.map((e) => e.toString()).toSet(),
      equippedByCategory: parsedEquipped,
      previewByCategory: Map<AccessoryCategory, String>.from(parsedEquipped),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ShopState.fromJson(String source) =>
      ShopState.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
