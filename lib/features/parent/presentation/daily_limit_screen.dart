import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../care/presentation/widgets/animated_pi_mascot.dart';
import '../../navigation/presentation/main_shell_screen.dart';
import '../../profile/presentation/profile_controller.dart';
import '../../shop/presentation/shop_controller.dart';
import 'daily_limit_controller.dart';
import 'parent_dashboard_screen.dart';
import 'widgets/daily_quota_indicator.dart';
import 'widgets/parental_gate_dialog.dart';

/// Écran 6 (AppFlow 2.4) : Limite quotidienne atteinte (6/6) & Repos bienveillant.
/// Conforme aux normes Google Play Familles / COPPA pour la régulation du temps d'écran :
/// - Mascotte Pi endormie avec particules de "Zzz" animées.
/// - Compte à rebours avant la réinitialisation de minuit.
/// - Suggestion d'activité hors-écran du jour (créative, ludique et motrice).
/// - Accès maintenu aux soins doux (nourrir, laver, câliner Pi) sans pression de quiz.
class DailyLimitScreen extends ConsumerStatefulWidget {
  const DailyLimitScreen({super.key});

  @override
  ConsumerState<DailyLimitScreen> createState() => _DailyLimitScreenState();
}

class _DailyLimitScreenState extends ConsumerState<DailyLimitScreen> {
  Timer? _countdownTimer;
  late Duration _timeUntilMidnight;

  @override
  void initState() {
    super.initState();
    _timeUntilMidnight = DailyLimitController.timeUntilMidnight();
    // Rafraîchit le compte à rebours toutes les 30 secondes
    _countdownTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() {
          _timeUntilMidnight = DailyLimitController.timeUntilMidnight();
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _getOfflineActivity(dynamic strings) {
    final activities = [
      strings.offlineActivityWindowCount,
      strings.offlineActivityPlayOutside,
      strings.offlineActivityDrawPi,
      strings.offlineActivityReadBook,
      strings.offlineActivityFindShapes,
    ];
    final dayIndex = DateTime.now().day % activities.length;
    return activities[dayIndex] as String;
  }

  void _backToHome(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const MainShellScreen(initialIndex: 0),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final profile = ref.watch(activeProfileProvider).value;
    final limitState = ref.watch(dailyLimitControllerProvider);
    final shopState = ref.watch(shopControllerProvider);

    final childName = profile?.name ?? strings.defaultFriendName;
    final hours = _timeUntilMidnight.inHours;
    final minutes = _timeUntilMidnight.inMinutes % 60;

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: context.appBg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.s5,
              vertical: AppSpace.s3,
            ),
            child: Column(
              children: [
                // 1. Barre supérieure : Quota 6/6 complété & Bouton de fermeture
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DailyQuotaIndicator(
                      usedSessions: limitState.usedSessionsToday,
                      maxSessions: limitState.maxDailySessions,
                      isLimitReached: true,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 28),
                      color: context.appSubText,
                      onPressed: () => _backToHome(context),
                      tooltip: strings.close,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpace.s2),

                // Contenu central scrollable
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpace.s2),

                        // 2. Pi endormi avec "Zzz" flottants
                        _SleepingPiMascotArea(
                          equippedAccessoryIds: shopState.equippedAccessoryIds,
                        ),

                        const SizedBox(height: AppSpace.s4),

                        // 3. Message bienveillant et félicitations
                        Text(
                          strings.piRestingTitle(childName),
                          style: AppText.h2.copyWith(
                            color: context.appText,
                            fontSize: 22,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpace.s2),
                        Text(
                          strings.piRestingSubtitle,
                          style: AppText.body.copyWith(
                            color: context.appSubText,
                            fontSize: 15,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: AppSpace.s5),

                        // 4. Carte "Prochaine réinitialisation dans :" (Heure de minuit)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpace.s4),
                          decoration: BoxDecoration(
                            color: context.isDark
                                ? const Color(0xFF1E1B4B)
                                : AppColors.night50,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(
                              color: context.isDark
                                  ? const Color(0xFF4338CA)
                                  : AppColors.night700.withValues(alpha: 0.25),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: context.isDark
                                    ? Colors.black26
                                    : AppColors.night700.withValues(alpha: 0.08),
                                offset: const Offset(0, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.alarm_rounded,
                                    size: 20,
                                    color: AppColors.night700,
                                  ),
                                  const SizedBox(width: AppSpace.s2),
                                  Text(
                                    strings.nextResetIn,
                                    style: AppText.label.copyWith(
                                      color: context.isDark
                                          ? const Color(0xFFA5B4FC)
                                          : AppColors.night700,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpace.s2),
                              Text(
                                strings.resetCountdownFormatted(hours, minutes),
                                style: AppText.mathL.copyWith(
                                  color: context.isDark
                                      ? const Color(0xFFC7D2FE)
                                      : AppColors.night700,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpace.s4),

                        // 5. Carte "L'activité hors-écran du jour :"
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpace.s4),
                          decoration: BoxDecoration(
                            color: context.appSurface,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(
                              color: context.appBorder,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: context.appShadow,
                                offset: const Offset(0, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: context.isDark
                                          ? const Color(0xFF451A03)
                                          : AppColors.amber50,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.lightbulb_rounded,
                                      size: 20,
                                      color: AppColors.gold600,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpace.s2),
                                  Expanded(
                                    child: Text(
                                      strings.offlineActivityHeader,
                                      style: AppText.label.copyWith(
                                        color: context.appText,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpace.s3),
                              Text(
                                '"${_getOfflineActivity(strings)}"',
                                style: AppText.bodyL.copyWith(
                                  color: context.isDark
                                      ? const Color(0xFFE2E8F0)
                                      : AppColors.ink900,
                                  fontStyle: FontStyle.italic,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpace.s4),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpace.s3),

                // 6. Bouton d'action : Retour au Salon
                ChunkyButton(
                  label: strings.returnToHome,
                  variant: ChunkyButtonVariant.primary,
                  height: 56,
                  onPressed: () => _backToHome(context),
                ),

                const SizedBox(height: AppSpace.s2),

                // 7. Accès réservé aux parents (déblocage ou ajustement des quotas)
                TextButton.icon(
                  key: const Key('daily_limit_parent_access_button'),
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final unlocked = await ParentalGateDialog.show(context);
                    if (unlocked == true && navigator.mounted) {
                      navigator.push(
                        MaterialPageRoute(
                          builder: (_) => const ParentDashboardScreen(),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.sky600),
                  label: Text(
                    strings.parentSettingsEntryTitle,
                    style: AppText.buttonM.copyWith(
                      color: AppColors.sky600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Zone de rendu de Pi endormi avec "Zzz" flottants animés.
class _SleepingPiMascotArea extends StatefulWidget {
  final List<String>? equippedAccessoryIds;

  const _SleepingPiMascotArea({this.equippedAccessoryIds});

  @override
  State<_SleepingPiMascotArea> createState() => _SleepingPiMascotAreaState();
}

class _SleepingPiMascotAreaState extends State<_SleepingPiMascotArea>
    with SingleTickerProviderStateMixin {
  late final AnimationController _zzzController;

  bool get _isTestEnv {
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _zzzController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (!_isTestEnv) {
      _zzzController.repeat();
    }
  }

  @override
  void dispose() {
    _zzzController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      width: 200,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Ombre de contact au sol
          Positioned(
            bottom: 6,
            child: Container(
              width: 130,
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.elliptical(130, 18),
                ),
                gradient: RadialGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Mascotte Pi en mode dodo
          AnimatedPiMascot(
            piSize: 130,
            isSleeping: true,
            equippedAccessoryIds: widget.equippedAccessoryIds,
          ),

          // Particules "Zzz" flottantes et animées en fondu vers le haut
          Positioned(
            top: 4,
            right: 18,
            child: AnimatedBuilder(
              animation: _zzzController,
              builder: (context, _) {
                final progress = _zzzController.value;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildFloatingZ(
                      progress: (progress + 0.0) % 1.0,
                      offsetY: 30,
                      scale: 0.8,
                      text: 'z',
                    ),
                    _buildFloatingZ(
                      progress: (progress + 0.33) % 1.0,
                      offsetY: 45,
                      scale: 1.0,
                      text: 'Z',
                    ),
                    _buildFloatingZ(
                      progress: (progress + 0.66) % 1.0,
                      offsetY: 60,
                      scale: 1.3,
                      text: 'Z',
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingZ({
    required double progress,
    required double offsetY,
    required double scale,
    required String text,
  }) {
    final double dy = -progress * offsetY;
    final double dx = (progress * 14.0) - 7.0;
    final double opacity = progress < 0.2
        ? (progress / 0.2)
        : progress > 0.8
            ? ((1.0 - progress) / 0.2)
            : 1.0;

    return Transform.translate(
      offset: Offset(dx, dy),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Text(
            text,
            style: AppText.mathM.copyWith(
              color: AppColors.night700,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
