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
  String getDescription(bool isFrench) =>
      isFrench ? descriptionFr : descriptionEn;

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
      descriptionFr:
          'Une casquette sportive parfaite pour aller chercher la balle !',
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
      descriptionFr:
          'Garde les oreilles de Pi bien au chaud lors des fraîches journées.',
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
    AccessoryItem(
      id: 'wizard_hat',
      nameFr: 'Chapeau de Magicien',
      nameEn: 'Wizard Hat',
      descriptionFr: 'Un chapeau pointu d\'apprenti sorcier pour lancer des sorts de calcul !',
      descriptionEn: 'A wizard hat to cast brilliant math spells!',
      category: AccessoryCategory.hats,
      price: 120,
      requiredGrade: SchoolGrade.ce2,
      previewIcon: Icons.auto_fix_high_rounded,
      primaryColor: Color(0xFF6366F1),
      accentColor: Color(0xFFFBBF24),
    ),
    AccessoryItem(
      id: 'chef_toque',
      nameFr: 'Toque de Pâtissier',
      nameEn: 'Pastry Chef Hat',
      descriptionFr: 'Pour mitonner de délicieuses recettes de calcul mental !',
      descriptionEn: 'For baking delicious mental math recipes!',
      category: AccessoryCategory.hats,
      price: 55,
      previewIcon: Icons.cake_rounded,
      primaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFF97316),
    ),
    AccessoryItem(
      id: 'flower_crown',
      nameFr: 'Couronne de Fleurs',
      nameEn: 'Flower Crown',
      descriptionFr:
          'Une couronne de marguerites et roses pastel pleine de fraîcheur !',
      descriptionEn: 'A fresh flower crown of daisies and pastel roses!',
      category: AccessoryCategory.hats,
      price: 75,
      previewIcon: Icons.local_florist_rounded,
      primaryColor: Color(0xFFEC4899),
      accentColor: Color(0xFFFDE047),
    ),
    AccessoryItem(
      id: 'gamer_headphones',
      nameFr: 'Casque Gamer Néon',
      nameEn: 'Neon Gamer Headset',
      descriptionFr:
          'Un casque ultra-tendance aux reflets néon pour réviser en rythme !',
      descriptionEn:
          'An ultra-trendy neon headset to practice math to the beat!',
      category: AccessoryCategory.hats,
      price: 115,
      requiredGrade: SchoolGrade.ce1,
      previewIcon: Icons.headphones_rounded,
      primaryColor: Color(0xFF06B6D4),
      accentColor: Color(0xFFEC4899),
    ),

    // 2. Lunettes
    AccessoryItem(
      id: 'nerd_glasses',
      nameFr: 'Lunettes Rondes',
      nameEn: 'Round Glasses',
      descriptionFr:
          'Le look savant pour résoudre toutes les équations avec brio.',
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
      descriptionFr:
          'Idéales pour se prélasser à la plage ou courir sous le soleil.',
      descriptionEn:
          'Ideal for chilling at the beach or running under the sun.',
      category: AccessoryCategory.glasses,
      price: 90,
      previewIcon: Icons.wb_sunny_rounded,
      primaryColor: Color(0xFF0F172A),
      accentColor: Color(0xFFA855F7),
    ),
    AccessoryItem(
      id: 'star_glasses',
      nameFr: 'Lunettes Étoiles Noires',
      nameEn: 'Black Star Glasses',
      descriptionFr: 'Des montures noires en étoile très stylées pour voir la magie des maths !',
      descriptionEn:
          'Stylish black star frames to see the magic in every math problem!',
      category: AccessoryCategory.glasses,
      price: 85,
      previewIcon: Icons.star_rounded,
      primaryColor: Color(0xFF1E293B),
      accentColor: Color(0xFF64748B),
    ),
    AccessoryItem(
      id: 'swimming_goggles',
      nameFr: 'Masque de Plongeur',
      nameEn: 'Swim Goggles',
      descriptionFr:
          'Prêt pour explorer les profondeurs des tables de multiplication !',
      descriptionEn: 'Ready to dive into multiplication tables!',
      category: AccessoryCategory.glasses,
      price: 65,
      previewIcon: Icons.scuba_diving_rounded,
      primaryColor: Color(0xFF0D9488),
      accentColor: Color(0xFF38BDF8),
    ),
    AccessoryItem(
      id: 'heart_glasses',
      nameFr: 'Lunettes Cœur',
      nameEn: 'Heart Sunglasses',
      descriptionFr:
          'Des lunettes teintées en forme de cœur rose bonbon pleines de tendresse !',
      descriptionEn:
          'Sweet pink heart-shaped tinted sunglasses full of puppy love!',
      category: AccessoryCategory.glasses,
      price: 95,
      previewIcon: Icons.favorite_rounded,
      primaryColor: Color(0xFFF43F5E),
      accentColor: Color(0xFFFDA4AF),
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
      descriptionFr:
          'Pour les chiots courageux qui explorent la forêt secrète.',
      descriptionEn: 'For brave puppies exploring the secret forest.',
      category: AccessoryCategory.collars,
      price: 65,
      previewIcon: Icons.explore_rounded,
      primaryColor: Color(0xFF10B981),
      accentColor: Color(0xFF047857),
    ),
    AccessoryItem(
      id: 'bell_collar',
      nameFr: 'Collier à Grelot',
      nameEn: 'Jingle Bell Collar',
      descriptionFr:
          'Un grelot doré scintillant qui tinte gaiement à chaque pas.',
      descriptionEn:
          'A shiny golden bell that jingles happily with every step.',
      category: AccessoryCategory.collars,
      price: 45,
      previewIcon: Icons.notifications_active_rounded,
      primaryColor: Color(0xFFDC2626),
      accentColor: Color(0xFFF59E0B),
    ),
    AccessoryItem(
      id: 'gold_chain',
      nameFr: 'Médaille d\'Or',
      nameEn: 'Gold Champion Medal',
      descriptionFr:
          'La médaille officielle des as du calcul mental et de la logique !',
      descriptionEn: 'The official medal for mental math and logic masters!',
      category: AccessoryCategory.collars,
      price: 130,
      requiredGrade: SchoolGrade.cm1,
      previewIcon: Icons.military_tech_rounded,
      primaryColor: Color(0xFFF59E0B),
      accentColor: Color(0xFFB45309),
    ),
    AccessoryItem(
      id: 'cozy_scarf',
      nameFr: 'Écharpe Tricotée',
      nameEn: 'Cozy Knitted Scarf',
      descriptionFr:
          'Une écharpe moelleuse rayée rouge et crème pour les fraîches journées.',
      descriptionEn:
          'A cozy red and cream striped knitted scarf for chilly days.',
      category: AccessoryCategory.collars,
      price: 60,
      previewIcon: Icons.waves_rounded,
      primaryColor: Color(0xFFDC2626),
      accentColor: Color(0xFFFEF3C7),
    ),
    AccessoryItem(
      id: 'diamond_collar',
      nameFr: 'Collier Diamant Étoilé',
      nameEn: 'Star Diamond Collar',
      descriptionFr:
          'Un collier violet de grand prestige serti d\'un diamant taillé en étoile !',
      descriptionEn:
          'A prestigious royal violet collar set with a shining star diamond!',
      category: AccessoryCategory.collars,
      price: 145,
      requiredGrade: SchoolGrade.ce2,
      previewIcon: Icons.diamond_rounded,
      primaryColor: Color(0xFF8B5CF6),
      accentColor: Color(0xFF67E8F9),
    ),

    // 4. Capes
    AccessoryItem(
      id: 'hero_cape',
      nameFr: 'Cape de Super-Héros',
      nameEn: 'Superhero Cape',
      descriptionFr:
          'Pour voler au secours des fractions et des multiplications !',
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
      descriptionFr:
          'Ornée d\'étoiles magiques pour les maîtres de la géométrie.',
      descriptionEn: 'Adorned with magic stars for geometry masters.',
      category: AccessoryCategory.capes,
      price: 140,
      requiredGrade: SchoolGrade.cm2,
      previewIcon: Icons.nightlight_round,
      primaryColor: Color(0xFF6366F1),
      accentColor: Color(0xFFFDE047),
    ),
    AccessoryItem(
      id: 'cosmic_cape',
      nameFr: 'Cape Galactique',
      nameEn: 'Cosmic Cape',
      descriptionFr:
          'Tissée dans les étoiles lointaines pour voyager à grande vitesse !',
      descriptionEn: 'Woven with starlight to travel at the speed of math!',
      category: AccessoryCategory.capes,
      price: 160,
      requiredGrade: SchoolGrade.cm2,
      previewIcon: Icons.auto_awesome_rounded,
      primaryColor: Color(0xFF4338CA),
      accentColor: Color(0xFFA855F7),
    ),
    AccessoryItem(
      id: 'leaf_cape',
      nameFr: 'Cape de la Forêt',
      nameEn: 'Forest Ranger Cape',
      descriptionFr: 'Camouflage parfait pour jouer et chercher la balle entre les arbres.',
      descriptionEn:
          'Perfect camouflage to play and fetch balls among the trees.',
      category: AccessoryCategory.capes,
      price: 85,
      previewIcon: Icons.forest_rounded,
      primaryColor: Color(0xFF15803D),
      accentColor: Color(0xFF86EFAC),
    ),
    AccessoryItem(
      id: 'royal_cape',
      nameFr: 'Cape Royale',
      nameEn: 'Royal Velvet Cape',
      descriptionFr:
          'Une somptueuse cape de velours pourpre bordée d\'or et d\'hermine royale !',
      descriptionEn:
          'A sumptuous royal purple velvet cape trimmed with gold and ermine!',
      category: AccessoryCategory.capes,
      price: 135,
      requiredGrade: SchoolGrade.ce1,
      previewIcon: Icons.shield_rounded,
      primaryColor: Color(0xFF7C3AED),
      accentColor: Color(0xFFF59E0B),
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
