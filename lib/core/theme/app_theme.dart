import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Configuration ThemeData officielle de Pi & Moi (DESIGN_SYSTEM.md §8.4).
ThemeData buildAppTheme() => ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bg,
      fontFamily: 'Quicksand',
      colorScheme: const ColorScheme.light(
        primary: AppColors.sky600,
        onPrimary: Colors.white,
        secondary: AppColors.green600,
        onSecondary: Colors.white,
        tertiary: AppColors.gold400,
        onTertiary: AppColors.ink900,
        error: AppColors.coral500,
        surface: AppColors.surface,
        onSurface: AppColors.ink900,
        outline: AppColors.ink200,
      ),
      splashFactory: NoSplash.splashFactory, // Rétroaction physique via ChunkyButton
    );
