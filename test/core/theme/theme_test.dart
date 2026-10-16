import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_et_moi/core/theme/app_colors.dart';
import 'package:pi_et_moi/core/theme/app_dimens.dart';
import 'package:pi_et_moi/core/theme/app_text.dart';
import 'package:pi_et_moi/core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('Design System - AppColors', () {
    test('Official brand and CTA colors are correctly defined', () {
      expect(AppColors.sky500, const Color(0xFF006879));
      expect(AppColors.sky600, const Color(0xFF006879)); // CTA face
      expect(AppColors.sky700, const Color(0xFF004E5B)); // Chunky edge
      expect(AppColors.green600, const Color(0xFF0D6B58));
      expect(AppColors.gold400, const Color(0xFFFAE287));
      expect(AppColors.ink900, const Color(0xFF171C1E));
    });

    test('Zero action orange is enforced in primary tokens', () {
      expect(AppColors.sky600 != const Color(0xFFF28C38), isTrue);
      expect(AppColors.sky600 != const Color(0xFFFF9F1C), isTrue);
    });
  });

  group('Design System - AppSpace & AppRadius', () {
    test('Metrics match kid friendly guidelines', () {
      expect(AppSpace.minKidTarget, 56.0);
      expect(AppSpace.minParentTarget, 48.0);
      expect(AppEdge.primary, 6.0);
      expect(AppEdge.standard, 4.0);
      expect(AppRadius.lg, 16.0);
      expect(AppRadius.xl, 24.0);
    });
  });

  group('Design System - AppText', () {
    test('Typography scales are defined with Abril Fatface, ABeeZee and Lexend', () {
      expect(AppText.display.fontSize, 44);
      expect(AppText.h1.fontSize, 30);
      expect(AppText.mathXL.fontSize, 44);
      expect(AppText.mathL.fontSize, 28);
      expect(AppText.display.fontWeight, FontWeight.w700);
      expect(AppText.h1.fontWeight, FontWeight.w700);
      expect(AppText.display.fontFamily, contains('AbrilFatface'));
      expect(AppText.body.fontFamily, contains('ABeeZee'));
      expect(AppText.mathXL.fontFamily, contains('Lexend'));
    });
  });

  group('Design System - AppTheme', () {
    test('buildAppTheme uses Material 3 and custom color scheme', () {
      final theme = buildAppTheme();
      expect(theme.useMaterial3, isTrue);
      expect(theme.scaffoldBackgroundColor, AppColors.bg);
      expect(theme.colorScheme.primary, AppColors.sky600);
    });
  });
}
