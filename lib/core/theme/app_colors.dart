import 'package:flutter/material.dart';

/// Palette de couleurs officielle de Pi & Moi (WCAG 2.1 AA compliant).
/// Conforme au document de référence DESIGN_SYSTEM.md.
abstract final class AppColors {
  // Bleus (Marque & Actions principales)
  static const sky500 = Color(0xFF1CB0F6); // Marque, sélection, jauges
  static const sky600 = Color(0xFF1899D6); // Face bouton principal (Contraste 3.2:1 AA grand)
  static const sky700 = Color(0xFF0D8ABC); // Bord chunky bouton principal, dégradé bas splash
  static const sky800 = Color(0xFF0B7BB5); // Texte bleu sur fond blanc (4.65:1 AA ✅)
  static const sky50 = Color(0xFFE8F7FE);  // Fond tuile/puce sélectionnée

  // Verts (Réussite & Soins)
  static const green500 = Color(0xFF20BF55); // Jauge Faim, pastille ✓
  static const green600 = Color(0xFF178A3E); // Face bouton valider / achat
  static const green700 = Color(0xFF15803D); // Texte vert, bord chunky vert (5.02:1 ✅)
  static const green50 = Color(0xFFE8F8EE);  // Fond tuile bonne réponse

  // Or & Ambre (Récompenses & Os)
  static const gold400 = Color(0xFFFFBF69); // Os dorés, étoiles
  static const gold600 = Color(0xFFE09A3E); // Bord chunky doré
  static const amber50 = Color(0xFFFFFBEB); // Fond pastille solde
  static const amber900 = Color(0xFF78350F); // Texte pastille solde

  // Sarcelle (Énergie)
  static const teal400 = Color(0xFF2EC4B6); // Jauge Énergie

  // Corail (Erreur douce)
  static const coral500 = Color(0xFFE71D36); // Erreur douce, contour, texte (4.54:1 ✅)
  static const coral50 = Color(0xFFFDECEE);  // Fond mauvaise réponse

  // Nuit (Limite quotidienne)
  static const night700 = Color(0xFF3730A3);
  static const night50 = Color(0xFFEEF2FF);

  // Neutres & Encre
  static const ink900 = Color(0xFF011627); // Texte principal (17.39:1 ✅)
  static const ink600 = Color(0xFF475569); // Texte secondaire
  static const ink500 = Color(0xFF64748B); // Texte tertiaire
  static const ink300 = Color(0xFFCBD5E1); // Bord chunky neutre
  static const ink200 = Color(0xFFE2E8F0); // Bordures cartes
  static const ink100 = Color(0xFFF1F5F9); // Rails de jauge
  static const bg = Color(0xFFF8F9FA);     // Fond d'écran
  static const surface = Color(0xFFFFFFFF);// Cartes, tuiles

  // Mode Sombre (Vrai Noir AMOLED / Pure Black Theme)
  static const darkBg = Color(0xFF000000);         // Fond noir pur (AMOLED Black)
  static const darkSurface = Color(0xFF121212);    // Cartes, conteneurs & docks sombres
  static const darkSurfaceAlt = Color(0xFF1E1E1E); // Cartes secondaires sombres
  static const darkInk100 = Color(0xFF181818);
  static const darkInk200 = Color(0xFF2A2A2A);     // Bordures sombres neutres
  static const darkInk300 = Color(0xFF383838);     // Bords chunky sombres
  static const darkInk500 = Color(0xFF8E8E93);     // Texte tertiaire sombre
  static const darkInk600 = Color(0xFFCCCCCC);     // Texte secondaire sombre
  static const darkInk900 = Color(0xFFFFFFFF);     // Texte principal blanc pur
  static const darkSky50 = Color(0xFF0A2233);      // Fond bleu nuit accent
  static const darkSky500 = Color(0xFF38BDF8);     // Marque claire pour contraste sombre

  // Aides sémantiques adaptées au mode clair / sombre
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color bgOf(BuildContext context) =>
      isDark(context) ? darkBg : bg;

  static Color surfaceOf(BuildContext context) =>
      isDark(context) ? darkSurface : surface;

  static Color surfaceAltOf(BuildContext context) =>
      isDark(context) ? darkSurfaceAlt : ink100;

  static Color borderOf(BuildContext context) =>
      isDark(context) ? darkInk200 : ink200;

  static Color textOf(BuildContext context) =>
      isDark(context) ? darkInk900 : ink900;

  static Color subTextOf(BuildContext context) =>
      isDark(context) ? darkInk600 : ink600;

  static Color shadowOf(BuildContext context) =>
      isDark(context) ? Colors.black.withValues(alpha: 0.3) : ink100;
}

extension AppThemeX on BuildContext {
  bool get isDark => AppColors.isDark(this);
  Color get appBg => AppColors.bgOf(this);
  Color get appSurface => AppColors.surfaceOf(this);
  Color get appSurfaceAlt => AppColors.surfaceAltOf(this);
  Color get appBorder => AppColors.borderOf(this);
  Color get appText => AppColors.textOf(this);
  Color get appSubText => AppColors.subTextOf(this);
  Color get appShadow => AppColors.shadowOf(this);
}
