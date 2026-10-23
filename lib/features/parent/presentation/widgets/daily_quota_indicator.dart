import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text.dart';
import '../../../care/presentation/widgets/tennis_ball_widget.dart';

/// Indicateur de quota de parties quotidiennes conforme au DESIGN_SYSTEM (§6.3) :
/// - 6 icônes balles 20 px (pleines = jouées, opacité 0.30 = restantes).
/// - Score `mathS` (Lexend 16 w700-800) « X/6 ».
/// - Pastille blanche (ou thème sombre) de hauteur 36 px avec bordure fine.
class DailyQuotaIndicator extends StatelessWidget {
  final int usedSessions;
  final int maxSessions;
  final VoidCallback? onTap;
  final bool isLimitReached;

  const DailyQuotaIndicator({
    super.key,
    required this.usedSessions,
    this.maxSessions = 6,
    this.onTap,
    this.isLimitReached = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMax = maxSessions > 0 ? maxSessions : 6;
    final clampedUsed = usedSessions.clamp(0, effectiveMax);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3),
        decoration: BoxDecoration(
          color: isLimitReached
              ? (context.isDark ? const Color(0xFF1E1B4B) : AppColors.night50)
              : context.appSurface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isLimitReached
                ? AppColors.night700.withValues(alpha: 0.40)
                : context.appBorder,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: context.appShadow,
              offset: const Offset(0, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Rangée de 6 balles de tennis (20 px chacune, espacées de 4 px)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(effectiveMax, (index) {
                final isPlayed = index < clampedUsed;
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < effectiveMax - 1 ? 4.0 : 0.0,
                  ),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isPlayed ? 1.0 : 0.30,
                    child: const TennisBallWidget(size: 20),
                  ),
                );
              }),
            ),
            const SizedBox(width: AppSpace.s2),
            // Compteur de score en police mathématique (Lexend)
            Text(
              '$clampedUsed/$effectiveMax',
              style: AppText.mathS.copyWith(
                color: isLimitReached
                    ? (context.isDark
                          ? const Color(0xFFA5B4FC)
                          : AppColors.night700)
                    : context.appText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
