import 'package:flutter/material.dart';
import 'app_colors.dart';

const _q = 'Quicksand';
const _l = 'Lexend';

TextStyle _t(String f, double s, FontWeight w, double h, {double ls = 0, Color color = AppColors.ink900}) =>
    TextStyle(
      fontFamily: f,
      fontSize: s,
      fontWeight: w,
      height: h,
      letterSpacing: ls,
      color: color,
    );

/// Typographie officielle de Pi & Moi : Quicksand (mots) + Lexend (chiffres).
/// Conforme à DESIGN_SYSTEM.md §3 et Annexe A.
abstract final class AppText {
  // Styles Quicksand (Mots, interface, énoncés)
  static final TextStyle display = _t(_q, 44, FontWeight.w700, 1.10, ls: -0.5);
  static final TextStyle h1 = _t(_q, 30, FontWeight.w700, 1.20, ls: -0.3);
  static final TextStyle h2 = _t(_q, 24, FontWeight.w700, 1.25);
  static final TextStyle h3 = _t(_q, 20, FontWeight.w700, 1.30);
  static final TextStyle question = _t(_q, 20, FontWeight.w600, 1.40);
  static final TextStyle questionYoung = _t(_q, 22, FontWeight.w600, 1.40); // CP–CE1
  static final TextStyle bodyL = _t(_q, 18, FontWeight.w600, 1.45);
  static final TextStyle body = _t(_q, 16, FontWeight.w600, 1.45);
  static final TextStyle bodyS = _t(_q, 14, FontWeight.w600, 1.40, color: AppColors.ink600);
  static final TextStyle buttonL = _t(_q, 18, FontWeight.w700, 1.0, ls: 0.3, color: Colors.white);
  static final TextStyle buttonM = _t(_q, 16, FontWeight.w700, 1.0, ls: 0.2, color: Colors.white);
  static final TextStyle label = _t(_q, 14, FontWeight.w700, 1.20);
  static final TextStyle overline = _t(_q, 13, FontWeight.w700, 1.20, ls: 1.0, color: AppColors.ink500);

  // Styles Lexend (Tous les nombres, calculs, fractions, compteurs)
  static final TextStyle mathXL = _t(_l, 44, FontWeight.w800, 1.10);
  static final TextStyle mathL = _t(_l, 28, FontWeight.w700, 1.10);
  static final TextStyle mathM = _t(_l, 20, FontWeight.w700, 1.20);
  static final TextStyle mathS = _t(_l, 16, FontWeight.w700, 1.20);
  static final TextStyle mathXS = _t(_l, 13, FontWeight.w600, 1.20, color: AppColors.ink600);
}
