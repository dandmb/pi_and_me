import 'dart:convert';
import 'accessory_category.dart';

/// État immuable de la boutique, des articles achetés et de l'accessoire équipé.
class ShopState {
  final Set<String> ownedAccessoryIds;
  final String? equippedAccessoryId;
  final String? selectedAccessoryId;
  final AccessoryCategory selectedCategory;
  final String? feedbackMessage;

  const ShopState({
    this.ownedAccessoryIds = const {},
    this.equippedAccessoryId,
    this.selectedAccessoryId,
    this.selectedCategory = AccessoryCategory.hats,
    this.feedbackMessage,
  });

  bool isOwned(String id) => ownedAccessoryIds.contains(id);
  bool isEquipped(String id) => equippedAccessoryId == id;
  bool isSelected(String id) => selectedAccessoryId == id;

  ShopState copyWith({
    Set<String>? ownedAccessoryIds,
    String? equippedAccessoryId,
    bool clearEquipped = false,
    String? selectedAccessoryId,
    bool clearSelected = false,
    AccessoryCategory? selectedCategory,
    String? feedbackMessage,
    bool clearFeedback = false,
  }) {
    return ShopState(
      ownedAccessoryIds: ownedAccessoryIds ?? this.ownedAccessoryIds,
      equippedAccessoryId:
          clearEquipped ? null : (equippedAccessoryId ?? this.equippedAccessoryId),
      selectedAccessoryId:
          clearSelected ? null : (selectedAccessoryId ?? this.selectedAccessoryId),
      selectedCategory: selectedCategory ?? this.selectedCategory,
      feedbackMessage:
          clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownedAccessoryIds': ownedAccessoryIds.toList(),
      'equippedAccessoryId': equippedAccessoryId,
    };
  }

  factory ShopState.fromMap(Map<String, dynamic> map) {
    final rawOwned = map['ownedAccessoryIds'] as List<dynamic>? ?? [];
    final equipped = map['equippedAccessoryId'] as String?;
    return ShopState(
      ownedAccessoryIds: rawOwned.map((e) => e.toString()).toSet(),
      equippedAccessoryId: equipped,
      selectedAccessoryId: equipped,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ShopState.fromJson(String source) =>
      ShopState.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
