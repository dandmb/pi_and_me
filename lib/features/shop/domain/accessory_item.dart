import 'package:flutter/material.dart';
import '../../profile/domain/school_grade.dart';
import 'accessory_category.dart';

/// Représente un accessoire ou déguisement disponible pour Pi le chiot.
class AccessoryItem {
  final String id;
  final String nameFr;
  final String nameEn;
  final String descriptionFr;
  final String descriptionEn;
  final AccessoryCategory category;
  final int price;
  final SchoolGrade? requiredGrade;
  final IconData previewIcon;
  final Color primaryColor;
  final Color accentColor;

  const AccessoryItem({
    required this.id,
    required this.nameFr,
    required this.nameEn,
    required this.descriptionFr,
    required this.descriptionEn,
    required this.category,
    required this.price,
    this.requiredGrade,
    required this.previewIcon,
    required this.primaryColor,
    required this.accentColor,
  });

  String getName(bool isFrench) => isFrench ? nameFr : nameEn;
  String getDescription(bool isFrench) => isFrench ? descriptionFr : descriptionEn;

  /// Vérifie si l'article est déverrouillable selon la classe de l'enfant
  bool isGradeUnlocked(SchoolGrade currentGrade) {
    if (requiredGrade == null) return true;
    return currentGrade.index >= requiredGrade!.index;
  }
}

/// Catalogue officiel de tous les accessoires de la Boutique de Pi
class ShopCatalog {
  static const List<AccessoryItem> items = [
    // 1. Chapeaux
    AccessoryItem(
      id: 'blue_cap',
      nameFr: 'Casquette Bleue',
      nameEn: 'Blue Cap',
      descriptionFr: 'Une casquette sportive parfaite pour aller chercher la balle !',
      descriptionEn: 'A sporty cap ready for playing fetch!',
      category: AccessoryCategory.hats,
      price: 50,
      previewIcon: Icons.sports_baseball_rounded,
      primaryColor: Color(0xFF1899D6),
      accentColor: Color(0xFF0D8ABC),
    ),
    AccessoryItem(
      id: 'top_hat',
      nameFr: 'Haut-de-forme',
      nameEn: 'Top Hat',
      descriptionFr: 'Un chapeau très chic pour les chiots distingués.',
      descriptionEn: 'A dapper top hat for distinguished puppies.',
      category: AccessoryCategory.hats,
      price: 80,
      previewIcon: Icons.theater_comedy_rounded,
      primaryColor: Color(0xFF1E293B),
      accentColor: Color(0xFFE2E8F0),
    ),
    AccessoryItem(
      id: 'winter_beanie',
      nameFr: 'Bonnet d\'hiver',
      nameEn: 'Winter Beanie',
      descriptionFr: 'Garde les oreilles de Pi bien au chaud lors des fraîches journées.',
      descriptionEn: 'Keeps Pi\'s ears warm during chilly winter days.',
      category: AccessoryCategory.hats,
      price: 60,
      previewIcon: Icons.ac_unit_rounded,
      primaryColor: Color(0xFFEF4444),
      accentColor: Color(0xFFFFFFFF),
    ),
    AccessoryItem(
      id: 'royal_crown',
      nameFr: 'Couronne Royale',
      nameEn: 'Royal Crown',
      descriptionFr: 'Réservée aux champions des mathématiques !',
      descriptionEn: 'Reserved for math champions!',
      category: AccessoryCategory.hats,
      price: 150,
      requiredGrade: SchoolGrade.cm1,
      previewIcon: Icons.emoji_events_rounded,
      primaryColor: Color(0xFFF59E0B),
      accentColor: Color(0xFFDC2626),
    ),

    // 2. Lunettes
    AccessoryItem(
      id: 'nerd_glasses',
      nameFr: 'Lunettes Rondes',
      nameEn: 'Round Glasses',
      descriptionFr: 'Le look savant pour résoudre toutes les équations avec brio.',
      descriptionEn: 'The scholar look to solve every equation with style.',
      category: AccessoryCategory.glasses,
      price: 70,
      previewIcon: Icons.auto_awesome_rounded,
      primaryColor: Color(0xFF0284C7),
      accentColor: Color(0xFF38BDF8),
    ),
    AccessoryItem(
      id: 'sun_glasses',
      nameFr: 'Lunettes de Soleil',
      nameEn: 'Sunglasses',
      descriptionFr: 'Idéales pour se prélasser à la plage ou courir sous le soleil.',
      descriptionEn: 'Ideal for chilling at the beach or running under the sun.',
      category: AccessoryCategory.glasses,
      price: 90,
      previewIcon: Icons.wb_sunny_rounded,
      primaryColor: Color(0xFF0F172A),
      accentColor: Color(0xFFA855F7),
    ),

    // 3. Colliers & Foulards
    AccessoryItem(
      id: 'red_bowtie',
      nameFr: 'Nœud Papillon Rouge',
      nameEn: 'Red Bowtie',
      descriptionFr: 'Élégant et joyeux pour fêter les victoires aux quiz.',
      descriptionEn: 'Smart and cheerful to celebrate quiz victories.',
      category: AccessoryCategory.collars,
      price: 40,
      previewIcon: Icons.stars_rounded,
      primaryColor: Color(0xFFDC2626),
      accentColor: Color(0xFF991B1B),
    ),
    AccessoryItem(
      id: 'pirate_bandana',
      nameFr: 'Bandana Aventurier',
      nameEn: 'Explorer Bandana',
      descriptionFr: 'Pour les chiots courageux qui explorent la forêt secrète.',
      descriptionEn: 'For brave puppies exploring the secret forest.',
      category: AccessoryCategory.collars,
      price: 65,
      previewIcon: Icons.explore_rounded,
      primaryColor: Color(0xFF10B981),
      accentColor: Color(0xFF047857),
    ),

    // 4. Capes
    AccessoryItem(
      id: 'hero_cape',
      nameFr: 'Cape de Super-Héros',
      nameEn: 'Superhero Cape',
      descriptionFr: 'Pour voler au secours des fractions et des multiplications !',
      descriptionEn: 'To fly to the rescue of fractions and multiplications!',
      category: AccessoryCategory.capes,
      price: 110,
      previewIcon: Icons.offline_bolt_rounded,
      primaryColor: Color(0xFFE11D48),
      accentColor: Color(0xFFFBBF24),
    ),
    AccessoryItem(
      id: 'star_cape',
      nameFr: 'Cape Étoilée',
      nameEn: 'Starry Wizard Cape',
      descriptionFr: 'Ornée d\'étoiles magiques pour les maîtres de la géométrie.',
      descriptionEn: 'Adorned with magic stars for geometry masters.',
      category: AccessoryCategory.capes,
      price: 140,
      requiredGrade: SchoolGrade.cm2,
      previewIcon: Icons.nightlight_round,
      primaryColor: Color(0xFF6366F1),
      accentColor: Color(0xFFFDE047),
    ),
  ];

  static AccessoryItem? findById(String? id) {
    if (id == null) return null;
    try {
      return items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<AccessoryItem> getByCategory(AccessoryCategory category) {
    return items.where((item) => item.category == category).toList();
  }
}
