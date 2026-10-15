import 'package:flutter/material.dart';

/// Catégories d'accessoires pour personnaliser Pi le chiot.
enum AccessoryCategory {
  hats,
  glasses,
  collars,
  capes;

  String getLabel(bool isFrench) {
    switch (this) {
      case AccessoryCategory.hats:
        return isFrench ? 'Chapeaux' : 'Hats';
      case AccessoryCategory.glasses:
        return isFrench ? 'Lunettes' : 'Glasses';
      case AccessoryCategory.collars:
        return isFrench ? 'Colliers' : 'Collars';
      case AccessoryCategory.capes:
        return isFrench ? 'Capes' : 'Capes';
    }
  }

  IconData get icon {
    switch (this) {
      case AccessoryCategory.hats:
        return Icons.military_tech_rounded;
      case AccessoryCategory.glasses:
        return Icons.visibility_rounded;
      case AccessoryCategory.collars:
        return Icons.verified_rounded;
      case AccessoryCategory.capes:
        return Icons.shield_rounded;
    }
  }
}
