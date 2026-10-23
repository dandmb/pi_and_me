import 'package:flutter/material.dart';

/// Palette de couleurs officielle de MathPup (WCAG 2.1 AA compliant).
/// Conforme au document de référence DESIGN_SYSTEM.md.
abstract final class AppColors {
  // Bleus & Sarcelles (Primary MaterialTheme & Actions principales)
  static const sky500 = Color(
    0xFF006879,
  ); // Marque, sélection, jauges (Primary M3)
  static const sky600 = Color(
    0xFF006879,
  ); // Face bouton principal (Contraste 4.6:1 AA)
  static const sky700 = Color(
    0xFF004E5B,
  ); // Bord chunky bouton principal (onPrimaryContainer)
  static const sky800 = Color(0xFF003640); // Texte bleu/sarcelle sur fond blanc
  static const sky50 = Color(
    0xFFE0F7FC,
  ); // Fond tuile/puce sélectionnée (Primary Container doux)

  // Verts (Tertiary MaterialTheme : Réussite & Soins)
  static const green500 = Color(
    0xFF0D6B58,
  ); // Jauge Faim, pastille ✓ (Tertiary M3)
  static const green600 = Color(0xFF0D6B58); // Face bouton valider / achat
  static const green700 = Color(
    0xFF005142,
  ); // Texte vert, bord chunky vert (onTertiaryContainer)
  static const green50 = Color(0xFFE6FAF3); // Fond tuile bonne réponse

  // Or & Ambre (Secondary MaterialTheme : Récompenses & Os dorés)
  static const gold400 = Color(
    0xFFFAE287,
  ); // Os dorés, étoiles (SecondaryContainer M3)
  static const gold600 = Color(0xFF6F5D0E); // Bord chunky doré (Secondary M3)
  static const amber50 = Color(0xFFFDF8E1); // Fond pastille solde
  static const amber900 = Color(
    0xFF544600,
  ); // Texte pastille solde (onSecondaryContainer)

  // Sarcelle Énergie (Tertiary / Primary Container)
  static const teal400 = Color(0xFF267A67); // Jauge Énergie

  // Corail (Erreur douce)
  static const coral500 = Color(0xFFBA1A1A); // Erreur douce conforme M3
  static const coral50 = Color(0xFFFFEDEA); // Fond mauvaise réponse

  // Nuit (Limite quotidienne)
  static const night700 = Color(0xFF004E5B);
  static const night50 = Color(0xFFE0F7FC);

  // Neutres & Encre (MaterialTheme Surface & Text)
  static const ink900 = Color(0xFF171C1E); // Texte principal onSurface M3
  static const ink600 = Color(
    0xFF3F484B,
  ); // Texte secondaire onSurfaceVariant M3
  static const ink500 = Color(0xFF6F797B); // Texte tertiaire outline M3
  static const ink300 = Color(
    0xFFBFC8CB,
  ); // Bord chunky neutre outlineVariant M3
  static const ink200 = Color(
    0xFFDEE3E5,
  ); // Bordures cartes surfaceContainerHighest M3
  static const ink100 = Color(
    0xFFEFF4F6,
  ); // Rails de jauge surfaceContainerLow M3
  static const bg = Color(0xFFF5FAFC); // Fond d'écran surface M3
  static const surface = Color(
    0xFFFFFFFF,
  ); // Cartes, tuiles (SurfaceContainerLowest)

  // Mode Sombre (MaterialTheme darkScheme)
  static const darkBg = Color(0xFF0F1416); // Dark surface M3
  static const darkSurface = Color(0xFF171C1E); // Dark surfaceContainerLow M3
  static const darkSurfaceAlt = Color(
    0xFF252B2D,
  ); // Dark surfaceContainerHigh M3
  static const darkInk100 = Color(0xFF1B2122);
  static const darkInk200 = Color(0xFF3F484B); // Bordures sombres
  static const darkInk300 = Color(0xFF899295); // Bords chunky sombres
  static const darkInk500 = Color(0xFF899295); // Texte tertiaire sombre
  static const darkInk600 = Color(0xFFBFC8CB); // Texte secondaire sombre
  static const darkInk900 = Color(0xFFDEE3E5); // Texte principal onSurface M3
  static const darkSky50 = Color(0xFF002A32); // Fond nuit accent
  static const darkSky500 = Color(0xFF84D2E6); // Dark primary M3

  // Aides sémantiques adaptées au mode clair / sombre
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color bgOf(BuildContext context) => isDark(context) ? darkBg : bg;

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
