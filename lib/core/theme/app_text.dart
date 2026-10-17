import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

TextStyle _display(double s, FontWeight w, double h, {double ls = 0, Color color = AppColors.ink900}) =>
    GoogleFonts.abrilFatface(
      fontSize: s,
      fontWeight: w,
      height: h,
      letterSpacing: ls,
      color: color,
    );

TextStyle _body(double s, FontWeight w, double h, {double ls = 0, Color color = AppColors.ink900}) =>
    GoogleFonts.aBeeZee(
      fontSize: s,
      fontWeight: w,
      height: h,
      letterSpacing: ls,
      color: color,
    );

TextStyle _math(double s, FontWeight w, double h, {double ls = 0, Color color = AppColors.ink900}) =>
    GoogleFonts.lexend(
      fontSize: s,
      fontWeight: w,
      height: h,
      letterSpacing: ls,
      color: color,
    );

/// Typographie officielle de MathPup :
/// - Abril Fatface pour les grands titres display (GoogleFonts)
/// - ABeeZee pour les interfaces, textes et boutons (GoogleFonts)
/// - Lexend pour les nombres et calculs mathématiques (GoogleFonts)
abstract final class AppText {
  // Styles Display & Titres (Abril Fatface)
  static TextStyle get display => _display(44, FontWeight.w700, 1.10, ls: -0.5);
  static TextStyle get h1 => _display(30, FontWeight.w700, 1.20, ls: -0.3);
  static TextStyle get h2 => _display(24, FontWeight.w700, 1.25);
  static TextStyle get h3 => _display(20, FontWeight.w700, 1.25);

  // Styles Corps & Interface (ABeeZee)
  static TextStyle get subtitle => _body(18, FontWeight.w700, 1.30);
  static TextStyle get subtitleM => _body(16, FontWeight.w700, 1.30);
  static TextStyle get question => _body(20, FontWeight.w600, 1.40);
  static TextStyle get questionYoung => _body(22, FontWeight.w600, 1.40); // CP–CE1
  static TextStyle get bodyL => _body(18, FontWeight.w600, 1.45);
  static TextStyle get body => _body(16, FontWeight.w600, 1.45);
  static TextStyle get bodyS => _body(14, FontWeight.w600, 1.40, color: AppColors.ink600);
  static TextStyle get buttonL => _body(18, FontWeight.w700, 1.0, ls: 0.3, color: Colors.white);
  static TextStyle get buttonM => _body(16, FontWeight.w700, 1.0, ls: 0.2, color: Colors.white);
  static TextStyle get label => _body(14, FontWeight.w700, 1.20);
  static TextStyle get overline => _body(13, FontWeight.w700, 1.20, ls: 1.0, color: AppColors.ink500);

  // Styles Lexend (Tous les nombres, calculs, fractions, compteurs & textes de lecture fluide)
  static TextStyle get guideSubtitle => _math(13.5, FontWeight.w400, 1.45);
  static TextStyle get guideSubtitleM => _math(12.5, FontWeight.w400, 1.40);
  static TextStyle get mathXL => _math(44, FontWeight.w800, 1.10);
  static TextStyle get mathL => _math(28, FontWeight.w700, 1.10);
  static TextStyle get mathM => _math(20, FontWeight.w700, 1.20);
  static TextStyle get mathS => _math(16, FontWeight.w700, 1.20);
  static TextStyle get mathXS => _math(13, FontWeight.w600, 1.20, color: AppColors.ink600);
}
