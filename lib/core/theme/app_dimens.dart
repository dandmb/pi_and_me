/// Dimensions, espacements et rayons officiels de Pi & Moi.
/// Conforme à DESIGN_SYSTEM.md §4 et §5.
abstract final class AppSpace {
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 20.0;
  static const s6 = 24.0;
  static const s8 = 32.0;
  static const s10 = 40.0;
  static const s12 = 48.0;

  static const screenH = s5;
  static const minKidTarget = 56.0;
  static const minParentTarget = 48.0;
  static const maxContentWidth = 480.0;
}

abstract final class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const pill = 999.0;
}

abstract final class AppEdge {
  static const primary = 6.0;
  static const standard = 4.0;
}

abstract final class AppMotion {
  static const instant = Duration(milliseconds: 80);
  static const fast = Duration(milliseconds: 150);
  static const base = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
}
