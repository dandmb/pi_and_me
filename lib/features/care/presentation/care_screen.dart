import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../navigation/presentation/main_shell_screen.dart';
import '../../shop/presentation/shop_controller.dart';
import '../domain/care_interaction_mode.dart';
import '../domain/pi_companion.dart';
import '../domain/play_environment.dart';
import 'care_controller.dart';
import 'interactive_play_area.dart';
import 'widgets/kibble_widget.dart';
import 'widgets/tennis_ball_widget.dart';

/// Écran 4 : Soins et Aire de jeu de Pi le chiot (Bilingue FR/EN).
/// Inclut le tutoriel interactif Showcase / Feature Discovery,
/// la douche pour chien pour le lavage, la chambre étoilée pour le dodo,
/// le lancer de balle et la gamelle de croquettes sans aucun emoji artificiel.
class CareScreen extends ConsumerStatefulWidget {
  final CareInteractionMode initialMode;
  final bool isEmbedded;
  final bool isActive;

  const CareScreen({
    super.key,
    this.initialMode = CareInteractionMode.play,
    this.isEmbedded = false,
    this.isActive = true,
  });

  @override
  ConsumerState<CareScreen> createState() => _CareScreenState();
}

class _CareScreenState extends ConsumerState<CareScreen> {
  late CareInteractionMode _activeMode = widget.initialMode;
  Timer? _fetchTimer;
  Timer? _returnTimer;
  Timer? _eatingTimer;

  // Clés Globales pour le tutoriel interactif Showcase / Feature Discovery
  final GlobalKey _envShowcaseKey = GlobalKey();
  final GlobalKey _gaugesShowcaseKey = GlobalKey();
  final GlobalKey _actionControlShowcaseKey = GlobalKey();
  final GlobalKey _actionTrayShowcaseKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    ShowcaseView.register(
      onFinish: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_completed_care_showcase_v1', true);
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!widget.isActive) return;
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool('has_completed_care_showcase_v1') ?? false;
      if (!seen && mounted) {
        _startShowcase();
      }
    });
  }

  @override
  void didUpdateWidget(covariant CareScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final prefs = await SharedPreferences.getInstance();
        final seen = prefs.getBool('has_completed_care_showcase_v1') ?? false;
        if (!seen && mounted) {
          _startShowcase();
        }
      });
    } else if (!widget.isActive && oldWidget.isActive) {
      try {
        ShowcaseView.get().dismiss();
      } catch (_) {}
    }
  }

  void _startShowcase() {
    ShowcaseView.get().startShowCase([
      _envShowcaseKey,
      _gaugesShowcaseKey,
      _actionControlShowcaseKey,
      _actionTrayShowcaseKey,
    ]);
  }

  @override
  void dispose() {
    try {
      ShowcaseView.get().unregister();
    } catch (_) {}
    _fetchTimer?.cancel();
    _returnTimer?.cancel();
    _eatingTimer?.cancel();
    super.dispose();
  }

  /// Change de mode d'interaction et efface immédiatement le message du mode précédent
  void _switchMode(CareInteractionMode newMode) async {
    if (_activeMode == newMode) return;

    // 1. Annule les timers actifs du mode en cours
    _fetchTimer?.cancel();
    _returnTimer?.cancel();
    _eatingTimer?.cancel();

    // 2. Efface le message de Pi pour éviter toute rémanence entre les actions
    ref.read(careControllerProvider.notifier).clearMessage();

    // 3. Gestion du réveil si on quitte le mode dodo
    if (_activeMode == CareInteractionMode.sleep && newMode != CareInteractionMode.sleep) {
      ref.read(careControllerProvider.notifier).wakeUpPi();
    }

    setState(() {
      _activeMode = newMode;
    });

    // 4. Si passage au mode dodo, installer Pi dans son panier avec le cadre de nuit
    if (newMode == CareInteractionMode.sleep) {
      final strings = ref.read(stringsProvider);
      ref.read(careControllerProvider.notifier).sleepPi(strings.piRested);
    }
  }

  /// Lance une balle de tennis sur le terrain à un endroit aléatoire (distant de Pi)
  void _throwBall() {
    final companion = ref.read(careControllerProvider);
    final strings = ref.read(stringsProvider);
    final notifier = ref.read(careControllerProvider.notifier);

    if (companion.balls <= 0) {
      _showRewardPrompt(strings.noBallsLeft);
      return;
    }

    if (companion.isBallActive) {
      _showRewardPrompt(strings.ballInPlay);
      return;
    }

    _fetchTimer?.cancel();
    _returnTimer?.cancel();

    // Génère des coordonnées aléatoires distantes d'au moins 0.45 de Pi
    final random = math.Random();
    double targetX;
    double targetY;
    int attempts = 0;
    do {
      targetX = (random.nextDouble() * 1.5) - 0.75;
      targetY = (random.nextDouble() * 0.90) - 0.35;
      final dist = math.sqrt(
        math.pow(targetX - companion.piX, 2) +
            math.pow(targetY - companion.piY, 2),
      );
      if (dist >= 0.45 || attempts > 25) break;
      attempts++;
    } while (true);

    notifier.throwBall(targetX, targetY, strings.piChasingBall);

    // Après 2 secondes, Pi démarre automatiquement pour aller chercher la balle
    _fetchTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      final current = ref.read(careControllerProvider);
      if (!current.isBallActive) return;

      notifier.moveTo(
        targetX,
        targetY,
        message: strings.isFrench ? 'J\'attrape la balle !' : 'Catching the ball!',
      );

      _returnTimer = Timer(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        notifier.collectAndReturnBall(strings.piFetchedBall);
      });
    });
  }

  /// Sert une croquette dans l'assiette du coin
  void _serveFood() {
    final companion = ref.read(careControllerProvider);
    final strings = ref.read(stringsProvider);
    final notifier = ref.read(careControllerProvider.notifier);

    if (companion.croquettes <= 0) {
      _showRewardPrompt(strings.noFoodLeft);
      return;
    }

    if (companion.bowlFoodCount >= 3) {
      _showRewardPrompt(strings.bowlFull);
      return;
    }

    notifier.serveBowl(message: strings.bowlFilled);
  }

  /// Appelle Pi pour venir manger les croquettes servies dans l'assiette
  void _comeEat() {
    final companion = ref.read(careControllerProvider);
    final strings = ref.read(stringsProvider);
    final notifier = ref.read(careControllerProvider.notifier);

    if (companion.bowlFoodCount <= 0 || companion.isEating) return;

    // Pi se dirige vers l'assiette située en (-0.68, 0.48)
    const bowlX = -0.68;
    const bowlY = 0.48;

    notifier.startEating(bowlX, bowlY, strings.piEating);

    // Le repas dure exactement 5 secondes
    _eatingTimer?.cancel();
    _eatingTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      // Pi termine son repas, gagne de la Faim/Joie et rentre au centre
      notifier.finishEating(strings.piFinishedEating);
    });
  }

  /// Lave Pi des taches de saleté accumulées en jouant
  void _cleanPi() {
    final strings = ref.read(stringsProvider);
    final notifier = ref.read(careControllerProvider.notifier);

    notifier.cleanPi(strings.piCleaned);
  }

  /// Gestion des clics tactiles sur la surface de jeu
  void _onSurfaceTapped(double normX, double normY) {
    final strings = ref.read(stringsProvider);
    final companion = ref.read(careControllerProvider);
    final notifier = ref.read(careControllerProvider.notifier);

    // Si Pi est en train de manger, ne pas interrompre le repas de 5s
    if (companion.isEating) return;

    switch (_activeMode) {
      case CareInteractionMode.play:
        notifier.moveTo(normX, normY);

        // Si une balle est en jeu, vérifier si Pi s'est approché de la balle
        if (companion.isBallActive) {
          final ballX = companion.activeBallX!;
          final ballY = companion.activeBallY!;
          final dist = math.sqrt(
            math.pow(normX - ballX, 2) + math.pow(normY - ballY, 2),
          );

          if (dist <= 0.28) {
            _fetchTimer?.cancel();
            _returnTimer?.cancel();

            notifier.moveTo(
              ballX,
              ballY,
              message: strings.isFrench ? 'Balle trouvée !' : 'Ball found!',
            );

            _returnTimer = Timer(const Duration(milliseconds: 600), () {
              if (!mounted) return;
              notifier.collectAndReturnBall(strings.piFetchedBall);
            });
          }
        }
        break;

      case CareInteractionMode.feed:
        // En mode Nourrir, un tap près de l'assiette appelle Pi à manger
        final distToBowl = math.sqrt(
          math.pow(normX - (-0.68), 2) + math.pow(normY - 0.48, 2),
        );
        if (distToBowl <= 0.35 && companion.bowlFoodCount > 0) {
          _comeEat();
        } else {
          notifier.moveTo(normX, normY);
        }
        break;

      case CareInteractionMode.clean:
        _cleanPi();
        break;

      case CareInteractionMode.walk:
        notifier.moveTo(normX, normY);
        break;

      case CareInteractionMode.sleep:
        notifier.rest(normX, normY, strings.piRested);
        break;
    }
  }

  void _showRewardPrompt(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.sky600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final companion = ref.watch(careControllerProvider);
    final strings = ref.watch(stringsProvider);
    final shopState = ref.watch(shopControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s4,
            vertical: AppSpace.s2,
          ),
          child: Column(
            children: [
              // 1. Barre supérieure : Retour, Titre, Aide Showcase & Solde d'Os dorés (si non embarqué)
              if (!widget.isEmbedded) ...[
                _buildHeader(context, companion, strings),
                const SizedBox(height: AppSpace.s2),
              ] else ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _startShowcase,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: AppSpace.s1),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(color: AppColors.ink200, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.help_outline_rounded, size: 16, color: AppColors.sky700),
                          const SizedBox(width: 4),
                          Text(
                            strings.isFrench ? 'Aide' : 'Help',
                            style: AppText.label.copyWith(fontSize: 12, color: AppColors.sky800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              // 2. Sélecteur de cadres / décors (Salon, Jardin, Plage, Forêt)
              Showcase(
                key: _envShowcaseKey,
                title: strings.isFrench ? 'Décors immersifs' : 'Play Environments',
                description: strings.isFrench
                    ? 'Choisis l\'endroit où Pi va s\'amuser : Salon, Jardin, Plage ou Forêt.'
                    : 'Choose where Pi plays: Living Room, Garden, Beach or Forest.',
                targetBorderRadius: BorderRadius.circular(20),
                child: _buildEnvironmentSelector(companion, strings),
              ),

              const SizedBox(height: AppSpace.s2),

              // 3. Les Jauges vitales (Faim, Joie, Énergie, Propreté)
              Showcase(
                key: _gaugesShowcaseKey,
                title: strings.isFrench ? 'Besoins vitaux de Pi' : 'Pi\'s Vital Gauges',
                description: strings.isFrench
                    ? 'Surveille la faim, la joie, l\'énergie et la propreté de Pi !'
                    : 'Monitor Pi\'s hunger, joy, energy, and cleanliness!',
                targetBorderRadius: BorderRadius.circular(16),
                child: _buildGaugesRow(companion, strings),
              ),

              const SizedBox(height: AppSpace.s2),

              // 4. Surface de jeu interactive & déplacement de Pi
              Expanded(
                child: InteractivePlayArea(
                  companion: companion,
                  activeMode: _activeMode,
                  equippedAccessoryId: shopState.equippedAccessoryId,
                  onSurfaceTapped: _onSurfaceTapped,
                ),
              ),

              const SizedBox(height: AppSpace.s2),

              // 5. Barre contextuelle selon le mode actif
              Showcase(
                key: _actionControlShowcaseKey,
                title: strings.isFrench ? 'Barre d\'interaction' : 'Interaction Bar',
                description: strings.isFrench
                    ? 'Lance la balle, sers les croquettes, lave Pi ou prépare sa sieste !'
                    : 'Throw the ball, serve kibbles, wash Pi, or prepare for bedtime!',
                targetBorderRadius: BorderRadius.circular(20),
                child: _buildModeControlBar(companion, strings),
              ),

              const SizedBox(height: AppSpace.s2),

              // 6. Plateau tactile d'actions (Jouer, Nourrir, Laver, Guider, Dodo)
              Showcase(
                key: _actionTrayShowcaseKey,
                title: strings.isFrench ? 'Actions de soin' : 'Care & Play Tray',
                description: strings.isFrench
                    ? 'Prends soin de Pi : Jouer à la balle, Nourrir, Laver dans la douche, Guider ou Dodo !'
                    : 'Take care of Pi: Play fetch, Feed, Wash in dog shower, Guide, or Sleep!',
                targetBorderRadius: BorderRadius.circular(24),
                child: _buildActionTray(companion, strings),
              ),

              // 7. Barre de navigation inférieure (si non embarqué)
              if (!widget.isEmbedded) ...[
                const SizedBox(height: AppSpace.s2),
                _buildBottomDock(context, strings),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeControlBar(PiCompanion companion, dynamic strings) {
    if (_activeMode == CareInteractionMode.play) {
      return _buildPlayControlBar(companion, strings);
    } else if (_activeMode == CareInteractionMode.feed) {
      return _buildFeedControlBar(companion, strings);
    } else if (_activeMode == CareInteractionMode.clean) {
      return _buildCleanControlBar(companion, strings);
    } else if (_activeMode == CareInteractionMode.sleep) {
      return _buildSleepControlBar(companion, strings);
    }
    return const SizedBox.shrink();
  }

  Widget _buildSleepControlBar(PiCompanion companion, dynamic strings) {
    final isSleeping = companion.isSleeping;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.ink200, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.ink100,
            offset: Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.nightlight_round,
                  size: 18,
                  color: Color(0xFF6366F1),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isSleeping
                        ? (strings.isFrench ? 'Pi dort paisiblement... Chut !' : 'Pi is sleeping peacefully... Shh!')
                        : (strings.isFrench ? 'Pi a besoin d\'un bon dodo' : 'Pi needs a good nap'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodyS.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 38,
            width: 130,
            child: ChunkyButton(
              label: isSleeping
                  ? (strings.isFrench ? 'Réveiller' : 'Wake up')
                  : (strings.isFrench ? 'Faire dodo' : 'Go to sleep'),
              icon: Icon(
                isSleeping ? Icons.wb_sunny_rounded : Icons.bedtime_rounded,
                size: 15,
                color: Colors.white,
              ),
              variant: isSleeping ? ChunkyButtonVariant.secondary : ChunkyButtonVariant.primary,
              height: 38,
              width: 130,
              isFullWidth: false,
              onPressed: () {
                final notifier = ref.read(careControllerProvider.notifier);
                if (isSleeping) {
                  notifier.wakeUpPi();
                } else {
                  notifier.sleepPi(strings.piRested);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    PiCompanion companion,
    dynamic strings,
  ) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainShellScreen(initialIndex: 0)),
              (route) => false,
            );
          },
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.ink200, width: 1.5),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color: AppColors.ink600,
            ),
          ),
        ),
        const SizedBox(width: AppSpace.s2),
        Expanded(
          child: Text(
            strings.careTitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.h3.copyWith(color: AppColors.ink900, fontSize: 17),
          ),
        ),
        const SizedBox(width: AppSpace.s2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _startShowcase,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.ink200, width: 1.5),
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  size: 18,
                  color: AppColors.ink600,
                ),
              ),
            ),
            const SizedBox(width: AppSpace.s2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.amber50,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars_rounded, size: 16, color: AppColors.gold600),
                  const SizedBox(width: 4),
                  Text(
                    '${companion.bones}',
                    style: AppText.bodyS.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.amber900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnvironmentSelector(PiCompanion companion, dynamic strings) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: PlayEnvironment.values.map((env) {
          final isSelected = companion.environment == env;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpace.s2),
            child: GestureDetector(
              onTap: () {
                ref
                    .read(careControllerProvider.notifier)
                    .changeEnvironment(env, isFrench: strings.isFrench);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.s3,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.sky50 : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: isSelected ? AppColors.sky600 : AppColors.ink200,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: AppColors.sky700,
                            offset: Offset(0, 2),
                            blurRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      env.icon,
                      size: 16,
                      color: isSelected ? AppColors.sky700 : AppColors.ink600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      env.getLabel(strings.isFrench),
                      style: AppText.bodyS.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w900 : FontWeight.w700,
                        color: isSelected ? AppColors.sky700 : AppColors.ink600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGaugesRow(PiCompanion companion, dynamic strings) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s2,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.ink200, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildGaugeItem(
              icon: Icons.restaurant_rounded,
              label: strings.hunger,
              val: companion.hunger,
              color: AppColors.green500,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildGaugeItem(
              icon: Icons.sports_tennis_rounded,
              label: strings.joy,
              val: companion.joy,
              color: AppColors.sky500,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildGaugeItem(
              icon: Icons.bedtime_rounded,
              label: strings.energy,
              val: companion.energy,
              color: AppColors.teal400,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildGaugeItem(
              icon: Icons.auto_awesome_rounded,
              label: strings.cleanliness,
              val: companion.cleanliness,
              color: const Color(0xFF6366F1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGaugeItem({
    required IconData icon,
    required String label,
    required double val,
    required Color color,
  }) {
    final percent = (val * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 10, color: color),
                  const SizedBox(width: 2),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        maxLines: 1,
                        style: AppText.bodyS.copyWith(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$percent%',
                style: AppText.bodyS.copyWith(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: val,
            minHeight: 5,
            backgroundColor: AppColors.ink100,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  /// Barre de contrôle du jeu de balle : Row de balles + Bouton "Lancer la balle"
  Widget _buildPlayControlBar(PiCompanion companion, dynamic strings) {
    final hasBalls = companion.balls > 0;
    final isBallActive = companion.isBallActive;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.ink200, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.ink100,
            offset: Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  strings.balls,
                  style: AppText.bodyS.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink900,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: AppSpace.s2),
                if (!hasBalls)
                  Text(
                    strings.available(0),
                    style: AppText.bodyS.copyWith(
                      color: AppColors.ink500,
                      fontSize: 11,
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          companion.balls,
                          (index) => const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.5),
                            child: TennisBallWidget(size: 24),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.s2),
          SizedBox(
            height: 38,
            width: 148,
            child: ChunkyButton(
              label: strings.throwBallAction,
              icon: const Icon(
                Icons.sports_tennis_rounded,
                size: 16,
                color: Colors.white,
              ),
              variant: ChunkyButtonVariant.primary,
              height: 38,
              width: 148,
              isFullWidth: false,
              onPressed: (hasBalls && !isBallActive) ? _throwBall : null,
            ),
          ),
        ],
      ),
    );
  }

  /// Barre de contrôle pour Nourrir :
  /// Row des croquettes disponibles + Bouton « Servir » + Bouton « Viens manger ! »
  Widget _buildFeedControlBar(PiCompanion companion, dynamic strings) {
    final hasCroquettes = companion.croquettes > 0;
    final canServe = hasCroquettes && companion.bowlFoodCount < 3 && !companion.isEating;
    final canComeEat = companion.bowlFoodCount > 0 && !companion.isEating;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.ink200, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.ink100,
            offset: Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Row des croquettes disponibles
          Expanded(
            child: Row(
              children: [
                Text(
                  strings.croquettes,
                  style: AppText.bodyS.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink900,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: AppSpace.s2),
                if (!hasCroquettes)
                  Text(
                    strings.available(0),
                    style: AppText.bodyS.copyWith(
                      color: AppColors.ink500,
                      fontSize: 11,
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          companion.croquettes,
                          (index) => const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.5),
                            child: KibbleWidget(size: 22),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: AppSpace.s2),

          // En train de manger (5 secondes)
          if (companion.isEating)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.green50,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.green600, width: 1.5),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.green600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    strings.isFrench ? 'Repas en cours...' : 'Eating...',
                    style: AppText.bodyS.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.green700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // Bouton Servir
            SizedBox(
              height: 38,
              width: companion.bowlFoodCount > 0 ? 82 : 105,
              child: ChunkyButton(
                label: strings.serveAction,
                icon: const Icon(
                  Icons.soup_kitchen_rounded,
                  size: 15,
                  color: Colors.white,
                ),
                variant: ChunkyButtonVariant.success,
                height: 38,
                width: companion.bowlFoodCount > 0 ? 82 : 105,
                isFullWidth: false,
                onPressed: canServe ? _serveFood : null,
              ),
            ),

            if (companion.bowlFoodCount > 0) ...[
              const SizedBox(width: 6),
              // Bouton Viens manger !
              SizedBox(
                height: 38,
                width: 120,
                child: ChunkyButton(
                  label: strings.comeEatAction,
                  icon: const Icon(
                    Icons.restaurant_rounded,
                    size: 15,
                    color: Colors.white,
                  ),
                  variant: ChunkyButtonVariant.primary,
                  height: 38,
                  width: 120,
                  isFullWidth: false,
                  onPressed: canComeEat ? _comeEat : null,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  /// Barre de contrôle pour Nettoyer / Laver Pi
  Widget _buildCleanControlBar(PiCompanion companion, dynamic strings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.ink200, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.ink100,
            offset: Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  companion.isDirty ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                  size: 18,
                  color: companion.isDirty ? const Color(0xFFEA580C) : AppColors.green600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    companion.isDirty
                        ? (strings.isFrench ? 'Pi a besoin d\'un bon bain !' : 'Pi needs a good bath!')
                        : (strings.isFrench ? 'Pi est tout propre et brillant !' : 'Pi is all clean and fresh!'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodyS.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 38,
            width: 120,
            child: ChunkyButton(
              label: strings.cleanAction,
              icon: const Icon(
                Icons.shower_rounded,
                size: 16,
                color: Colors.white,
              ),
              variant: ChunkyButtonVariant.primary,
              height: 38,
              width: 120,
              isFullWidth: false,
              onPressed: companion.isDirty ? _cleanPi : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTray(PiCompanion companion, dynamic strings) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.s2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.ink200, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.ink100,
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              mode: CareInteractionMode.play,
              icon: Icons.sports_tennis_rounded,
              label: strings.playAction,
              subtitle: strings.available(companion.balls),
              accentColor: AppColors.sky600,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildActionButton(
              mode: CareInteractionMode.feed,
              icon: Icons.restaurant_rounded,
              label: strings.feedAction,
              subtitle: strings.available(companion.croquettes),
              accentColor: AppColors.green600,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildActionButton(
              mode: CareInteractionMode.clean,
              icon: Icons.shower_rounded,
              label: strings.cleanAction,
              subtitle: companion.isDirty
                  ? (strings.isFrench ? 'Sale' : 'Dirty')
                  : (strings.isFrench ? 'Propre' : 'Clean'),
              accentColor: const Color(0xFF6366F1),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildActionButton(
              mode: CareInteractionMode.walk,
              icon: Icons.navigation_rounded,
              label: strings.walkAction,
              subtitle: strings.unlimited,
              accentColor: const Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildActionButton(
              mode: CareInteractionMode.sleep,
              icon: Icons.bed_rounded,
              label: strings.sleepAction,
              subtitle: strings.unlimited,
              accentColor: AppColors.teal400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required CareInteractionMode mode,
    required IconData icon,
    required String label,
    required String subtitle,
    required Color accentColor,
  }) {
    final isSelected = _activeMode == mode;

    return GestureDetector(
      onTap: () => _switchMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.12) : AppColors.bg,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? accentColor : AppColors.ink200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? accentColor : AppColors.ink600,
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: AppText.bodyS.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  color: isSelected ? accentColor : AppColors.ink900,
                ),
              ),
            ),
            const SizedBox(height: 1),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                subtitle,
                style: AppText.bodyS.copyWith(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? accentColor : AppColors.ink500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomDock(BuildContext context, dynamic strings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.ink200, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Soigner (actif)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.sky50,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.sky500, width: 1),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  size: 18,
                  color: AppColors.sky600,
                ),
                const SizedBox(width: 6),
                Text(
                  strings.careDockLabel,
                  style: AppText.bodyS.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.sky700,
                  ),
                ),
              ],
            ),
          ),

          // 2. Salon
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainShellScreen(initialIndex: 0)),
                (route) => false,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.home_rounded,
                    size: 18,
                    color: AppColors.ink500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    strings.salonDockLabel,
                    style: AppText.bodyS.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Boutique
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainShellScreen(initialIndex: 2)),
                (route) => false,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.storefront_rounded,
                    size: 18,
                    color: AppColors.ink500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    strings.shopDockLabel,
                    style: AppText.bodyS.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
