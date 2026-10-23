import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../shop/presentation/widgets/accessory_overlay_widget.dart';
import 'dirt_splatters_widget.dart';
import 'tennis_ball_widget.dart';

/// Mascotte Pi animée de niveau App Store :
/// - Queue découpée (`pi_tail.png`) qui bat réellement derrière le corps (`pi_body.png`) sans traits noirs figés.
/// - Expressions faciales vivantes (clignement naturel des yeux toutes les ~3,2s, yeux plissés de joie `^ ^`,
///   bouche et langue animées qui mâchent pendant le repas).
/// - Au repos : position assise emblématique avec respiration douce.
/// - En déplacement (balle, gamelle, promenade) : bonds de course paraboliques avec inclinaison,
///   ombre au sol réactive et nuages d'élan sous les pattes.
/// - Au retour de balle : porte la balle de tennis dans sa gueule.
/// - Accessoires 100% solidaires (placés par-dessus le visage pour que Pi cligne des yeux derrière ses lunettes).
class AnimatedPiMascot extends StatefulWidget {
  final double piX;
  final double piY;
  final bool isSleeping;
  final bool isEating;
  final bool isBallActive;
  final bool isFacingLeft;
  final bool isDirty;
  final int dirtCount;
  final String? equippedAccessoryId;
  final List<String>? equippedAccessoryIds;
  final double piSize;
  final bool isCelebrating;
  final bool enableTapInteraction;
  final VoidCallback? onTap;

  const AnimatedPiMascot({
    super.key,
    this.piX = 0.0,
    this.piY = 0.2,
    this.isSleeping = false,
    this.isEating = false,
    this.isBallActive = false,
    this.isFacingLeft = false,
    this.isDirty = false,
    this.dirtCount = 0,
    this.equippedAccessoryId,
    this.equippedAccessoryIds,
    this.piSize = 96,
    this.isCelebrating = false,
    this.enableTapInteraction = true,
    this.onTap,
  });

  @override
  State<AnimatedPiMascot> createState() => _AnimatedPiMascotState();
}

class _AnimatedPiMascotState extends State<AnimatedPiMascot>
    with TickerProviderStateMixin {
  late final AnimationController _idleController;
  late final AnimationController _lifeCycleController;
  late final AnimationController _runController;
  late final AnimationController _eatController;
  late final AnimationController _joyController;

  bool _isCarryingBallOnReturn = false;

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

    // 1. Respiration douce au repos (aller-retour de 1.8s)
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // 2. Cycle de vie continu (battement de queue + clignement naturel des yeux sur 3.4s)
    _lifeCycleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );

    if (!_isTestEnv) {
      _idleController.repeat(reverse: true);
      _lifeCycleController.repeat();
    }

    // 3. Course / bonds lors des déplacements (durée synchronisée avec AnimatedAlign 650ms)
    _runController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 650),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed ||
              status == AnimationStatus.dismissed) {
            if (_isCarryingBallOnReturn && mounted) {
              setState(() {
                _isCarryingBallOnReturn = false;
              });
            }
          }
        });

    // 4. Repas à la gamelle (mastication + hochement vers la gamelle)
    _eatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    if (widget.isEating && !_isTestEnv) {
      _eatController.repeat(reverse: true);
    }

    // 5. Saut de joie ponctuel (caresse, bain) ou continu (célébration de fin de quiz)
    _joyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    if (widget.isCelebrating && !_isTestEnv) {
      _joyController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedPiMascot oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Déclenche les bonds de course dès que la position cible (piX, piY) change
    final hasMoved =
        (widget.piX - oldWidget.piX).abs() > 0.001 ||
        (widget.piY - oldWidget.piY).abs() > 0.001;

    if (hasMoved && !widget.isSleeping) {
      if (oldWidget.isBallActive && !widget.isBallActive) {
        _isCarryingBallOnReturn = true;
      }
      _runController.forward(from: 0.0);
    }

    // Gestion de l'animation de repas
    if (widget.isEating && !oldWidget.isEating) {
      if (!_isTestEnv) {
        _eatController.repeat(reverse: true);
      }
    } else if (!widget.isEating && oldWidget.isEating) {
      _eatController.stop();
      _eatController.value = 0.0;
    }

    // Gestion de la célébration continue (ex: écran de résultats du quiz)
    if (widget.isCelebrating && !oldWidget.isCelebrating) {
      if (!_isTestEnv) {
        _joyController.repeat();
      }
    } else if (!widget.isCelebrating && oldWidget.isCelebrating) {
      _joyController.stop();
      _joyController.value = 0.0;
    }

    // Saut de joie quand Pi vient d'être lavé via le bouton Laver
    if (oldWidget.dirtCount > 0 &&
        widget.dirtCount == 0 &&
        !widget.isSleeping) {
      _joyController.forward(from: 0.0);
    }
  }

  void _handleTap() {
    if (!widget.enableTapInteraction) return;
    if (!widget.isSleeping &&
        !_runController.isAnimating &&
        !widget.isCelebrating) {
      _joyController.forward(from: 0.0);
    }
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _idleController.dispose();
    _lifeCycleController.dispose();
    _runController.dispose();
    _eatController.dispose();
    _joyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSleeping = widget.isSleeping;
    final boxWidth = isSleeping ? 140.0 : (widget.piSize * 1.15);
    final boxHeight = isSleeping ? 104.0 : (widget.piSize * 1.08);
    final baseShadowWidth = isSleeping ? 116.0 : (widget.piSize * 0.79);
    final spriteWidth = widget.piSize * (420.0 / 482.0);

    return GestureDetector(
      behavior: widget.enableTapInteraction
          ? HitTestBehavior.translucent
          : HitTestBehavior.deferToChild,
      onTap: widget.enableTapInteraction ? _handleTap : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _idleController,
          _lifeCycleController,
          _runController,
          _eatController,
          _joyController,
        ]),
        builder: (context, _) {
          final isRunning = _runController.isAnimating;
          final isJumpingJoy =
              _joyController.isAnimating || widget.isCelebrating;
          final isEatingAtBowl = widget.isEating && !isRunning && !isSleeping;
          final joyVal = (_isTestEnv && widget.isCelebrating)
              ? 0.5
              : _joyController.value;

          double translateY = 0.0;
          double rotationAngle = 0.0;
          double scaleX = 1.0;
          double scaleY = 1.0;
          double shadowScale = 1.0;
          double shadowAlpha = 0.15;

          final dirSign = widget.isFacingLeft ? -1.0 : 1.0;
          final lifeT = _lifeCycleController.value;

          // Calcul du battement de la queue (plus rapide quand Pi court, mange ou saute de joie)
          double tailAngle;
          if (isRunning) {
            tailAngle = 0.24 * math.sin(_runController.value * 6.0 * math.pi);
          } else if (isEatingAtBowl) {
            tailAngle = 0.22 * math.sin(_eatController.value * 2.0 * math.pi);
          } else if (isJumpingJoy) {
            tailAngle = 0.26 * math.sin(joyVal * 6.0 * math.pi);
          } else {
            // 3 battements souples par cycle de 3.4s
            tailAngle = 0.15 * math.sin(lifeT * 6.0 * math.pi);
          }

          // Clignement naturel des yeux (entre 88% et 94% du cycle de 3.4s, soit ~200ms toutes les 3.4s)
          final isBlinking =
              !_isTestEnv &&
              !isSleeping &&
              !isJumpingJoy &&
              (lifeT > 0.88 && lifeT < 0.94);

          // Ouverture de la bouche (mâche pendant le repas, ou sourit langue sortie pendant un saut de joie)
          double mouthOpen = 0.0;
          if (isEatingAtBowl) {
            mouthOpen = _isTestEnv
                ? 0.85
                : Curves.easeInOutSine.transform(_eatController.value);
          } else if (isJumpingJoy) {
            mouthOpen = 0.75 * math.sin(joyVal * math.pi);
          }

          if (isSleeping) {
            final breath = Curves.easeInOutSine.transform(
              _idleController.value,
            );
            scaleY = 1.0 + 0.025 * breath;
            scaleX = 1.0 - 0.012 * breath;
          } else if (isRunning) {
            final t = _runController.value;
            final stridePhase = t * 3.0 * math.pi;
            final hop = math.sin(stridePhase).abs();
            final envelope = math.sin(t * math.pi);

            translateY = -16.0 * hop;
            rotationAngle =
                dirSign *
                (0.15 * envelope + 0.06 * math.cos(stridePhase * 2.0));
            scaleX = 1.0 + 0.06 * hop - 0.04 * (1.0 - hop) * envelope;
            scaleY = 1.0 - 0.04 * hop + 0.05 * (1.0 - hop) * envelope;

            shadowScale = 1.0 - 0.34 * hop;
            shadowAlpha = 0.15 * (1.0 - 0.45 * hop);
          } else if (isEatingAtBowl) {
            final munch = Curves.easeInOutSine.transform(_eatController.value);
            rotationAngle = dirSign * (0.08 + 0.13 * munch);
            translateY = 2.5 * munch;
            scaleY = 1.0 - 0.04 * munch;
            scaleX = 1.0 + 0.03 * munch;
          } else if (isJumpingJoy) {
            final jt = joyVal;
            final hop = math.sin(jt * math.pi);
            translateY = -14.0 * hop;
            rotationAngle = 0.08 * math.sin(jt * 4.0 * math.pi) * (1.0 - jt);
            scaleY = 1.0 + 0.06 * hop;
            scaleX = 1.0 - 0.04 * hop;
            shadowScale = 1.0 - 0.30 * hop;
            shadowAlpha = 0.15 * (1.0 - 0.40 * hop);
          } else {
            final breath = Curves.easeInOutSine.transform(
              _idleController.value,
            );
            scaleY = 1.0 + 0.028 * breath;
            scaleX = 1.0 - 0.014 * breath;
            rotationAngle = 0.012 * math.sin(breath * math.pi - math.pi / 2);
          }

          return SizedBox(
            width: boxWidth,
            height: boxHeight,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // 1. Ombre de contact au sol (réagit à la hauteur de saut)
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: baseShadowWidth * shadowScale,
                    height: 12 * shadowScale.clamp(0.75, 1.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: shadowAlpha),
                      borderRadius: BorderRadius.all(
                        Radius.elliptical(
                          baseShadowWidth * shadowScale,
                          12 * shadowScale.clamp(0.75, 1.0),
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. Petits nuages d'élan sous les pattes pendant la course
                if (isRunning)
                  Positioned(
                    bottom: 4,
                    left: widget.isFacingLeft ? null : 6,
                    right: widget.isFacingLeft ? 6 : null,
                    child: _RunningDustPuffs(progress: _runController.value),
                  ),

                // 3. Corps de Pi + Queue animée + Visage animé + Accessoire + Saleté
                Positioned(
                  bottom: isSleeping ? 2 : 4,
                  child: Transform.translate(
                    offset: Offset(0, translateY),
                    child: Transform.rotate(
                      angle: rotationAngle,
                      alignment: Alignment.bottomCenter,
                      child: Transform.scale(
                        scaleX: scaleX,
                        scaleY: scaleY,
                        alignment: Alignment.bottomCenter,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            if (isSleeping)
                              Transform.flip(
                                flipX: widget.isFacingLeft,
                                child: Image.asset(
                                  'assets/images/pi_sleeping.png',
                                  height: 84,
                                  width: 132,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        Icons.pets,
                                        size: widget.piSize * 0.75,
                                        color: AppColors.sky600,
                                      ),
                                ),
                              )
                            else
                              Transform.flip(
                                flipX: widget.isFacingLeft,
                                child: SizedBox(
                                  width: spriteWidth,
                                  height: widget.piSize,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    clipBehavior: Clip.none,
                                    children: [
                                      // A. Queue découpée qui bat réellement autour de sa racine
                                      Transform.rotate(
                                        angle: tailAngle,
                                        alignment: const Alignment(-0.60, 0.56),
                                        child: Image.asset(
                                          'assets/images/pi_tail.png',
                                          width: spriteWidth,
                                          height: widget.piSize,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, _, _) =>
                                              const SizedBox.shrink(),
                                        ),
                                      ),

                                      // B. Corps de Pi (sans les traits noirs statiques)
                                      Image.asset(
                                        'assets/images/pi_body.png',
                                        width: spriteWidth,
                                        height: widget.piSize,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (
                                              context,
                                              error,
                                              stackTrace,
                                            ) => Image.asset(
                                              'assets/images/pi_transparent.png',
                                              width: spriteWidth,
                                              height: widget.piSize,
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, _, _) => Icon(
                                                Icons.pets,
                                                size: widget.piSize * 0.75,
                                                color: AppColors.sky600,
                                              ),
                                            ),
                                      ),

                                      // C. Expressions faciales (clignement des yeux, yeux joyeux ^ ^, bouche qui mâche)
                                      // Placées SOUS l'accessoire pour que les lunettes restent par-dessus les yeux !
                                      if (isBlinking ||
                                          isJumpingJoy ||
                                          mouthOpen > 0.05)
                                        CustomPaint(
                                          size: Size(
                                            spriteWidth,
                                            widget.piSize,
                                          ),
                                          painter: _PiFacialExpressionsPainter(
                                            isBlinking: isBlinking,
                                            isHappyEyes: isJumpingJoy,
                                            mouthOpen: mouthOpen,
                                          ),
                                        ),

                                      // D. Accessoires équipés combinés (calibrés 1:1 avec le gabarit 420x482)
                                      if (widget.equippedAccessoryId != null ||
                                          (widget.equippedAccessoryIds !=
                                                  null &&
                                              widget
                                                  .equippedAccessoryIds!
                                                  .isNotEmpty))
                                        AccessoryOverlayWidget(
                                          accessoryId:
                                              widget.equippedAccessoryId,
                                          accessoryIds:
                                              widget.equippedAccessoryIds,
                                          piSize: widget.piSize,
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                            // Balle de tennis tenue dans la gueule pendant le trajet retour
                            if (_isCarryingBallOnReturn && !isSleeping)
                              Positioned(
                                top: widget.piSize * 0.38,
                                left: widget.isFacingLeft ? 6 : null,
                                right: widget.isFacingLeft ? null : 6,
                                child: const TennisBallWidget(size: 20),
                              ),

                            // Taches de boue / saleté (suivent les mouvements de Pi)
                            if (widget.isDirty)
                              Positioned(
                                bottom: isSleeping ? 14 : 2,
                                child: DirtSplattersWidget(
                                  dirtCount: widget.dirtCount,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 4. Coeurs gourmands pendant le repas ou saut de joie
                if (isEatingAtBowl)
                  Positioned(
                    top: -8,
                    left: widget.isFacingLeft ? 4 : null,
                    right: widget.isFacingLeft ? null : 4,
                    child: _FloatingHeartsEffect(
                      progress: _eatController.value,
                    ),
                  ),

                if (isJumpingJoy)
                  Positioned(
                    top: -14,
                    child: _FloatingHeartsEffect(progress: joyVal),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Peintre vectoriel calibré au pixel près sur la toile 420x482 de Pi :
/// - Paupières dorées (#E8A561 / #EAA45F) lors du clignement naturel ou des yeux rieurs `^ ^`.
/// - Bouche animée (#4C191D) et petite langue rose (#FB7185) sous le museau lors du repas ou d'une joie.
class _PiFacialExpressionsPainter extends CustomPainter {
  final bool isBlinking;
  final bool isHappyEyes;
  final double mouthOpen;

  _PiFacialExpressionsPainter({
    required this.isBlinking,
    required this.isHappyEyes,
    required this.mouthOpen,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 420.0;
    final sy = size.height / 482.0;

    final darkOutline = Paint()
      ..color = const Color(0xFF4C191D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5 * sx
      ..strokeCap = StrokeCap.round;

    // 1. Yeux fermés (clignement) ou plissés de joie (^ ^)
    if (isBlinking || isHappyEyes) {
      final leftFurPaint = Paint()
        ..color = const Color(0xFFE8A561)
        ..style = PaintingStyle.fill;
      final rightFurPaint = Paint()
        ..color = const Color(0xFFEAA45F)
        ..style = PaintingStyle.fill;

      // Recouvre les globes oculaires avec la teinte exacte du pelage de Pi
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(224.0 * sx, 133.0 * sy),
          width: 54.0 * sx,
          height: 45.0 * sy,
        ),
        leftFurPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(319.0 * sx, 126.0 * sy),
          width: 45.0 * sx,
          height: 43.0 * sy,
        ),
        rightFurPaint,
      );

      if (isHappyEyes) {
        // Yeux joyeux en arc vers le haut (^ ^)
        final leftHappyPath = Path()
          ..moveTo(203.0 * sx, 138.0 * sy)
          ..quadraticBezierTo(224.0 * sx, 117.0 * sy, 245.0 * sx, 136.0 * sy);
        final rightHappyPath = Path()
          ..moveTo(301.0 * sx, 131.0 * sy)
          ..quadraticBezierTo(319.0 * sx, 111.0 * sy, 336.0 * sx, 129.0 * sy);

        canvas.drawPath(leftHappyPath, darkOutline);
        canvas.drawPath(rightHappyPath, darkOutline);
      } else {
        // Clignement doux (paupière baissée)
        final leftBlinkPath = Path()
          ..moveTo(202.0 * sx, 134.0 * sy)
          ..quadraticBezierTo(224.0 * sx, 146.0 * sy, 246.0 * sx, 132.0 * sy);
        final rightBlinkPath = Path()
          ..moveTo(300.0 * sx, 127.0 * sy)
          ..quadraticBezierTo(319.0 * sx, 139.0 * sy, 337.0 * sx, 125.0 * sy);

        canvas.drawPath(leftBlinkPath, darkOutline);
        canvas.drawPath(rightBlinkPath, darkOutline);
      }
    }

    // 2. Bouche ouverte qui mâche ou tire la langue de bonheur
    if (mouthOpen > 0.05) {
      final openFactor = mouthOpen.clamp(0.0, 1.0);
      final mouthWidth = 34.0 * sx;
      final mouthHeight = (6.0 + 18.0 * openFactor) * sy;
      final mouthCenter = Offset(283.0 * sx, (201.0 + 4.0 * openFactor) * sy);

      final mouthRect = Rect.fromCenter(
        center: mouthCenter,
        width: mouthWidth,
        height: mouthHeight,
      );

      final mouthInteriorPaint = Paint()
        ..color = const Color(0xFF4C191D)
        ..style = PaintingStyle.fill;

      final mouthPath = Path()
        ..moveTo(mouthRect.left, mouthRect.top)
        ..quadraticBezierTo(
          mouthCenter.dx,
          mouthRect.top + 3.0 * sy,
          mouthRect.right,
          mouthRect.top,
        )
        ..arcToPoint(
          Offset(mouthRect.left, mouthRect.top),
          radius: Radius.elliptical(mouthWidth / 2, mouthHeight),
          clockwise: true,
        )
        ..close();

      canvas.drawPath(mouthPath, mouthInteriorPaint);

      // Petite langue rose à l'intérieur de la bouche
      if (openFactor > 0.25) {
        final tonguePaint = Paint()
          ..color = const Color(0xFFFB7185)
          ..style = PaintingStyle.fill;

        canvas.save();
        canvas.clipPath(mouthPath);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(mouthCenter.dx, mouthRect.bottom - 2.0 * sy),
            width: mouthWidth * 0.72,
            height: mouthHeight * 0.75,
          ),
          tonguePaint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PiFacialExpressionsPainter oldDelegate) {
    return oldDelegate.isBlinking != isBlinking ||
        oldDelegate.isHappyEyes != isHappyEyes ||
        (oldDelegate.mouthOpen - mouthOpen).abs() > 0.01;
  }
}

/// Petits nuages de poussière / élan derrière les pattes quand Pi court
class _RunningDustPuffs extends StatelessWidget {
  final double progress;

  const _RunningDustPuffs({required this.progress});

  @override
  Widget build(BuildContext context) {
    final cycle = (progress * 3.0) % 1.0;
    final opacity = (1.0 - cycle).clamp(0.0, 0.75);
    final spread = cycle * 12.0;

    return Opacity(
      opacity: opacity,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: Offset(-spread, -cycle * 6.0),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 3),
          Transform.translate(
            offset: Offset(-spread * 0.5, -cycle * 3.0),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.70),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Petits coeurs flottants lors du repas ou d'une caresse
class _FloatingHeartsEffect extends StatelessWidget {
  final double progress;

  const _FloatingHeartsEffect({required this.progress});

  @override
  Widget build(BuildContext context) {
    final dy = -8.0 * progress;
    final opacity = (1.0 - (progress - 0.5).abs() * 1.4).clamp(0.2, 1.0);

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, dy),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.favorite_rounded, size: 14, color: Color(0xFFF43F5E)),
            SizedBox(width: 4),
            Icon(Icons.favorite_rounded, size: 11, color: Color(0xFFFB7185)),
          ],
        ),
      ),
    );
  }
}
