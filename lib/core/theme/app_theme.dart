import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Configuration ThemeData officielle de Pi & Moi (DESIGN_SYSTEM.md §8.4).
ThemeData buildAppTheme() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
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

/// Configuration ThemeData Sombre officielle de Pi & Moi.
ThemeData buildAppDarkTheme() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      fontFamily: 'Quicksand',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkSky500,
        onPrimary: AppColors.darkBg,
        secondary: AppColors.green500,
        onSecondary: Colors.white,
        tertiary: AppColors.gold400,
        onTertiary: AppColors.darkBg,
        error: AppColors.coral500,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkInk900,
        outline: AppColors.darkInk200,
      ),
      splashFactory: NoSplash.splashFactory,
    );

