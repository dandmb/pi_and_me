import 'package:flutter/material.dart';
import 'app_dimens.dart';
import 'theme.dart';

/// Configuration ThemeData officielle de MathPup basée sur MaterialTheme (M3).
ThemeData buildAppTheme([TextTheme? textTheme]) {
  final tt = textTheme ?? Typography.material2021().black;
  final base = MaterialTheme(tt).light();
  final cs = base.colorScheme;

  return base.copyWith(
    splashFactory: NoSplash.splashFactory, // Rétroaction physique via ChunkyButton
    appBarTheme: AppBarTheme(
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: tt.titleLarge?.copyWith(
        color: cs.onSurface,
        fontWeight: FontWeight.bold,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: cs.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      titleTextStyle: tt.titleLarge?.copyWith(
        color: cs.onSurface,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: tt.bodyMedium?.copyWith(
        color: cs.onSurfaceVariant,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: cs.primary,
      unselectedLabelColor: cs.onSurfaceVariant,
      indicatorColor: cs.primary,
      labelStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.bold),
      unselectedLabelStyle: tt.labelLarge,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: cs.primary,
      contentTextStyle: tt.bodyMedium?.copyWith(
        color: cs.onPrimary,
        fontWeight: FontWeight.bold,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    ),
  );
}

/// Configuration ThemeData Sombre officielle de MathPup basée sur MaterialTheme (M3).
ThemeData buildAppDarkTheme([TextTheme? textTheme]) {
  final tt = textTheme ?? Typography.material2021().white;
  final base = MaterialTheme(tt).dark();
  final cs = base.colorScheme;

  return base.copyWith(
    splashFactory: NoSplash.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: tt.titleLarge?.copyWith(
        color: cs.onSurface,
        fontWeight: FontWeight.bold,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: cs.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      titleTextStyle: tt.titleLarge?.copyWith(
        color: cs.onSurface,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: tt.bodyMedium?.copyWith(
        color: cs.onSurfaceVariant,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: cs.primary,
      unselectedLabelColor: cs.onSurfaceVariant,
      indicatorColor: cs.primary,
      labelStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.bold),
      unselectedLabelStyle: tt.labelLarge,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: cs.surfaceContainerHigh,
      contentTextStyle: tt.bodyMedium?.copyWith(
        color: cs.onSurface,
        fontWeight: FontWeight.bold,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    ),
  );
}

