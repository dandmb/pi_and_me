import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text.dart';
import '../../shop/presentation/widgets/accessory_overlay_widget.dart';
import '../domain/care_interaction_mode.dart';
import '../domain/pi_companion.dart';
import '../domain/play_environment.dart';
import 'widgets/dirt_splatters_widget.dart';
import 'widgets/food_bowl_widget.dart';
import 'widgets/tennis_ball_widget.dart';

/// Surface de jeu interactive plein écran / grand cadre.
/// Supporte 4 environnements de plein air/salon, la douche pour chien dédiée au lavage,
/// la chambre étoilée pour le dodo, l'assiette de nourriture et Pi avec ses postures.
class InteractivePlayArea extends ConsumerWidget {
  final PiCompanion companion;
  final CareInteractionMode activeMode;
  final String? equippedAccessoryId;
  final Function(double normX, double normY) onSurfaceTapped;

  const InteractivePlayArea({
    super.key,
    required this.companion,
    this.activeMode = CareInteractionMode.play,
    this.equippedAccessoryId,
    required this.onSurfaceTapped,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final env = companion.environment;
    final isSleeping = companion.isSleeping;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            if (w == 0 || h == 0) return;

            final rawX = (details.localPosition.dx / w) * 2 - 1.0;
            final rawY = (details.localPosition.dy / h) * 2 - 1.0;

            final clampedX = rawX.clamp(-0.80, 0.80);
            final clampedY = rawY.clamp(-0.45, 0.65);

            onSurfaceTapped(clampedX, clampedY);
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              border: Border.all(color: AppColors.ink200, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.ink100,
                  offset: Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              child: Stack(
                children: [
                  // 1. Fond thématique selon le mode (Douche, Dodo étoilé ou décors classiques)
                  Positioned.fill(
                    child: _buildBackground(env, activeMode),
                  ),

                  // 2. L'assiette / gamelle posée dans le coin (uniquement en mode Nourrir ou si croquettes présentes)
                  if (activeMode == CareInteractionMode.feed || companion.bowlFoodCount > 0)
                    Align(
                      alignment: const Alignment(-0.68, 0.52),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tapis d'alimentation sous la gamelle
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                              color: AppColors.ink200.withValues(alpha: 0.8),
                              width: 1,
                            ),
                          ),
                          child: FoodBowlWidget(
                            foodCount: companion.bowlFoodCount,
                            width: 60,
                            height: 38,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. Balle de tennis lancée sur le terrain
                  if (companion.isBallActive)
                    AnimatedAlign(
                      alignment: Alignment(
                        companion.activeBallX!,
                        companion.activeBallY!,
                      ),
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutQuad,
                      child: const _ActiveBallTarget(),
                    ),

                  // 4. Si Pi dort et qu'on n'est pas dans l'onglet Dodo : Pi n'apparaît pas
                  if (companion.isSleeping && activeMode != CareInteractionMode.sleep)
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: (context.isDark ? AppColors.darkSurface : AppColors.surface).withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(color: const Color(0xFF818CF8), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: context.isDark ? const Color(0xFF312E81) : const Color(0xFFEEF2FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.bedtime_rounded,
                                size: 30,
                                color: Color(0xFF818CF8),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              strings.piSleepingTitle,
                              style: AppText.h3.copyWith(
                                color: context.appText,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              strings.piSleepingDesc,
                              textAlign: TextAlign.center,
                              style: AppText.bodyS.copyWith(
                                color: context.appSubText,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 5. Pi le chiot (uniquement s'il est éveillé ou s'il est dans sa chambre Dodo)
                  if (!companion.isSleeping || activeMode == CareInteractionMode.sleep)
                    AnimatedAlign(
                      alignment: Alignment(companion.piX, companion.piY),
                      duration: const Duration(milliseconds: 650),
                      curve: Curves.easeOutBack,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Bulle de statut / parole flexible sans coupure
                          if (companion.statusMessage != null) ...[
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 240,
                                minWidth: 80,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpace.s3,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(AppRadius.lg),
                                  border: Border.all(
                                    color: AppColors.ink200,
                                    width: 1.5,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: AppColors.ink100,
                                      offset: Offset(0, 3),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  companion.statusMessage!,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  softWrap: true,
                                  style: AppText.bodyS.copyWith(
                                    color: AppColors.ink900,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            CustomPaint(
                              size: const Size(12, 6),
                              painter: _BubbleTailPainter(),
                            ),
                            const SizedBox(height: 2),
                          ],

                          // Sprite de Pi avec ombre et taches de saleté éventuelles
                          SizedBox(
                            width: isSleeping ? 140 : 110,
                            height: 104,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Ombre de contact au sol
                                Positioned(
                                  bottom: 0,
                                  child: Container(
                                    width: isSleeping ? 116 : 76,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.all(
                                        Radius.elliptical(isSleeping ? 116 : 86, 12),
                                      ),
                                    ),
                                  ),
                                ),

                                // Sprite de Pi (yeux fermés pi_sleeping.png si dodo, sinon pi_transparent.png)
                                Positioned(
                                  bottom: isSleeping ? 2 : 4,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Transform.flip(
                                        flipX: companion.isFacingLeft,
                                        child: Image.asset(
                                          isSleeping
                                              ? 'assets/images/pi_sleeping.png'
                                              : 'assets/images/pi_transparent.png',
                                          height: isSleeping ? 84 : 96,
                                          width: isSleeping ? 132 : null,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(
                                            Icons.pets,
                                            size: 72,
                                            color: AppColors.sky600,
                                          ),
                                        ),
                                      ),
                                      if (equippedAccessoryId != null && !isSleeping)
                                        Transform.flip(
                                          flipX: companion.isFacingLeft,
                                          child: AccessoryOverlayWidget(
                                            accessoryId: equippedAccessoryId,
                                            piSize: 96,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // Particules "Zzz" flottantes au-dessus de la tête
                                if (isSleeping)
                                  const Positioned(
                                    top: -12,
                                    right: 8,
                                    child: _SleepingZzzWidget(),
                                  ),

                                // Bulles de savon dans la baignoire de douche
                                if (activeMode == CareInteractionMode.clean)
                                  const Positioned.fill(
                                    child: _SoapBubblesWidget(),
                                  ),

                                // Taches de saleté / boue visibles sur le pelage si Pi s'est sali en jouant
                                if (companion.isDirty)
                                  Positioned(
                                    bottom: isSleeping ? 18 : 6,
                                    child: DirtSplattersWidget(
                                      dirtCount: companion.dirtCount,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),


                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Sélecteur de décor selon le mode d'interaction actif :
  /// - Douche pour chien en mode Laver
  /// - Chambre étoilée avec panier douillet en mode Dodo
  /// - Décors choisis (Salon, Jardin, Plage, Forêt) pour Jouer, Nourrir, Guider
  Widget _buildBackground(PlayEnvironment env, CareInteractionMode mode) {
    if (mode == CareInteractionMode.clean) {
      return _buildDogShowerBackground();
    }
    if (mode == CareInteractionMode.sleep) {
      return _buildCozyBedroomBackground();
    }
    return _buildEnvironmentBackground(env);
  }

  /// Décor 5 : Douche / Salle de bain de toilettage pour chien (Mode Laver)
  Widget _buildDogShowerBackground() {
    return Stack(
      children: [
        Column(
          children: [
            // Mur supérieur carrelé en faïence aqua / blanc
            Expanded(
              flex: 4,
              child: Container(
                color: const Color(0xFFE0F2FE),
                child: Stack(
                  children: [
                    // Joints horizontaux du carrelage
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        4,
                        (_) => Container(height: 1, color: const Color(0xFFBAE6FD).withValues(alpha: 0.7)),
                      ),
                    ),
                    // Joints verticaux du carrelage
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        8,
                        (_) => Container(width: 1, color: const Color(0xFFBAE6FD).withValues(alpha: 0.7)),
                      ),
                    ),
                    // Pommeau de douche chromé à gauche avec jet d'eau
                    Positioned(
                      left: 20,
                      top: 10,
                      child: _buildShowerFixture(),
                    ),
                    // Étagère de toilettage à droite (shampoing canin et éponge)
                    Positioned(
                      right: 18,
                      top: 18,
                      child: _buildGroomingShelf(),
                    ),
                  ],
                ),
              ),
            ),

            // Frise carrelée de séparation bleue
            Container(height: 6, color: const Color(0xFF0284C7)),

            // Sol carrelé étanche vert d'eau avec grande baignoire pour chien
            Expanded(
              flex: 6,
              child: Container(
                color: const Color(0xFFF0FDF4),
                child: Stack(
                  children: [
                    // Grille d'évacuation d'eau au sol
                    Positioned(
                      right: 32,
                      bottom: 16,
                      child: _buildFloorDrain(),
                    ),
                    // Grande baignoire de lavage canin ergonomique au centre
                    Center(
                      child: _buildDogWashTub(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Décor 6 : Chambre nocturne chaleureuse avec ciel étoilé et panier douillet (Mode Dodo)
  Widget _buildCozyBedroomBackground() {
    return Stack(
      children: [
        Column(
          children: [
            // Mur bleu nuit profond dégradé
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF000000), Color(0xFF111111)],
                  ),
                ),
                child: Stack(
                  children: [
                    // Fenêtre en ogive montrant le croissant de lune et les étoiles
                    Positioned(
                      left: 24,
                      top: 12,
                      child: _buildNightWindow(),
                    ),
                    // Lampe de chevet diffusant une lueur dorée apaisante
                    Positioned(
                      right: 22,
                      top: 16,
                      child: _buildNightLamp(),
                    ),
                  ],
                ),
              ),
            ),

            // Plinthe en bois sombre
            Container(height: 6, color: const Color(0xFF262626)),

            // Parquet sombre de chambre avec panier douillet au centre
            Expanded(
              flex: 5,
              child: Container(
                color: const Color(0xFF141414),
                child: Stack(
                  children: [
                    // Grand panier douillet pour chien au centre
                    Center(
                      child: _buildPlushDogBed(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShowerFixture() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tuyau chromé
            Container(width: 5, height: 42, color: const Color(0xFF94A3B8)),
            // Pommeau orienté
            Transform.rotate(
              angle: 0.45,
              child: Container(
                width: 26,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                  border: Border.all(color: const Color(0xFF64748B), width: 1.5),
                ),
              ),
            ),
          ],
        ),
        // Gouttelettes d'eau scintillantes
        Padding(
          padding: const EdgeInsets.only(left: 12, top: 2),
          child: Row(
            children: [
              _buildWaterDrop(3),
              const SizedBox(width: 4),
              _buildWaterDrop(4),
              const SizedBox(width: 4),
              _buildWaterDrop(3),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWaterDrop(double size) {
    return Container(
      width: size,
      height: size * 1.4,
      decoration: const BoxDecoration(
        color: Color(0xFF38BDF8),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(2),
          bottom: Radius.circular(6),
        ),
      ),
    );
  }

  Widget _buildGroomingShelf() {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Bouteille de shampoing pour chien
            Container(
              width: 16,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF0284C7), width: 1),
              ),
              child: const Center(
                child: Icon(Icons.pets, size: 9, color: Colors.white),
              ),
            ),
            const SizedBox(width: 6),
            // Éponge jaune alvéolée
            Container(
              width: 22,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFFFDE047),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFEAB308), width: 1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        // Tablette en verre
        Container(
          width: 58,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: const Color(0xFF94A3B8), width: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildFloorDrain() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFCBD5E1),
        border: Border.all(color: const Color(0xFF64748B), width: 1.5),
      ),
      child: const Center(
        child: Icon(Icons.grain, size: 14, color: Color(0xFF475569)),
      ),
    );
  }

  Widget _buildDogWashTub() {
    return Container(
      width: 230,
      height: 84,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.elliptical(230, 84)),
        border: Border.all(color: const Color(0xFF38BDF8), width: 3.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.25),
            offset: const Offset(0, 5),
            blurRadius: 4,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Eau bleutée moussante
          Container(
            width: 210,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFBAE6FD).withValues(alpha: 0.65),
              borderRadius: const BorderRadius.all(Radius.elliptical(210, 68)),
            ),
          ),
          // Mousse blanche sur les bords
          Positioned(
            top: 6,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                8,
                (i) => Container(
                  width: 14 + (i % 3) * 4.0,
                  height: 10 + (i % 2) * 3.0,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNightWindow() {
    return Container(
      width: 60,
      height: 68,
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30), bottom: Radius.circular(8)),
        border: Border.all(color: const Color(0xFF475569), width: 3),
      ),
      child: Stack(
        children: [
          // Croissant de lune
          Positioned(
            top: 10,
            right: 12,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFDE047),
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF020617),
                  ),
                ),
              ),
            ),
          ),
          // Étoiles scintillantes
          const Positioned(left: 10, top: 16, child: Icon(Icons.star, size: 8, color: Colors.white)),
          const Positioned(left: 20, top: 38, child: Icon(Icons.star, size: 6, color: Colors.white70)),
          const Positioned(right: 16, top: 46, child: Icon(Icons.star, size: 7, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildNightLamp() {
    return Column(
      children: [
        // Halo de lumière tamisée
        Container(
          width: 50,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFFDE047).withValues(alpha: 0.22),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 24,
              height: 14,
              decoration: const BoxDecoration(
                color: Color(0xFFFBBF24),
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
            ),
          ),
        ),
        // Pied de lampe
        Container(width: 4, height: 16, color: const Color(0xFFD97706)),
        // Socle
        Container(width: 18, height: 4, decoration: BoxDecoration(color: const Color(0xFFB45309), borderRadius: BorderRadius.circular(2))),
      ],
    );
  }

  Widget _buildPlushDogBed() {
    return Container(
      width: 220,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A), // Rebord panier marine
        borderRadius: const BorderRadius.all(Radius.elliptical(220, 80)),
        border: Border.all(color: const Color(0xFFF59E0B), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            offset: const Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 190,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7), // Coussin moelleux doux
            borderRadius: const BorderRadius.all(Radius.elliptical(190, 60)),
            border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
          ),
        ),
      ),
    );
  }

  /// Décors enrichis et bien équipés (aucun emoji)
  Widget _buildEnvironmentBackground(PlayEnvironment env) {
    switch (env) {
      case PlayEnvironment.livingRoom:
        return Stack(
          children: [
            Column(
              children: [
                // Mur supérieur avec cimaise et tableau
                Expanded(
                  flex: 4,
                  child: Container(
                    color: const Color(0xFFF1F5F9),
                    child: Stack(
                      children: [
                        // Cimaise / moulure murale
                        Positioned(
                          top: 18,
                          left: 0,
                          right: 0,
                          child: Container(height: 2, color: const Color(0xFFE2E8F0)),
                        ),
                        // Horloge murale circulaire
                        Positioned(
                          left: 28,
                          top: 26,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  offset: const Offset(0, 2),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.access_time_rounded, size: 16, color: AppColors.ink500),
                            ),
                          ),
                        ),
                        // Tableau décoratif minimaliste
                        Center(
                          child: Container(
                            width: 74,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFCBD5E1), width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  offset: const Offset(0, 3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFFBBF24),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Plante d'intérieur en pot
                        Positioned(
                          right: 24,
                          bottom: 0,
                          child: _buildIndoorPlant(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Plinthe en bois blanc
                Container(height: 8, color: const Color(0xFFE2E8F0)),

                // Plancher en bois chaleureux avec lignes de parquet
                Expanded(
                  flex: 6,
                  child: Container(
                    color: const Color(0xFFFEF3C7),
                    child: Stack(
                      children: [
                        // Rainures de lattes de parquet
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            4,
                            (_) => Container(
                              height: 1,
                              color: const Color(0xFFFDE68A).withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        // Grand tapis tissé cosy
                        Center(
                          child: Container(
                            width: 230,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDE68A),
                              borderRadius: const BorderRadius.all(
                                Radius.elliptical(230, 80),
                              ),
                              border: Border.all(color: const Color(0xFFF59E0B), width: 2),
                            ),
                          ),
                        ),
                        // Canapé douillet sur le côté droit
                        Positioned(
                          right: 8,
                          top: 10,
                          child: _buildSofa(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

      case PlayEnvironment.garden:
        return Stack(
          children: [
            Column(
              children: [
                // Ciel ensoleillé avec nuages
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFBAE6FD), Color(0xFFE0F2FE)],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Soleil rayonnant
                        Positioned(
                          right: 22,
                          top: 12,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDE047),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFDE047).withValues(alpha: 0.5),
                                  blurRadius: 12,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Nuages vectoriels légers
                        Positioned(left: 30, top: 18, child: _buildCloud(44, 18)),
                        Positioned(left: 140, top: 28, child: _buildCloud(36, 14)),
                      ],
                    ),
                  ),
                ),

                // Clôture en bois de jardin (picket fence)
                Container(
                  height: 18,
                  color: const Color(0xFFF1F5F9),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      14,
                      (_) => Container(
                        width: 8,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                        ),
                      ),
                    ),
                  ),
                ),

                // Pelouse verdoyante avec buisson et chemin de pierres
                Expanded(
                  flex: 6,
                  child: Container(
                    color: const Color(0xFF86EFAC),
                    child: Stack(
                      children: [
                        // Buisson fleuri à droite
                        Positioned(
                          right: 14,
                          top: 8,
                          child: _buildGardenHedge(),
                        ),
                        // Pas japonais / pierres du chemin
                        Positioned(left: 55, top: 22, child: _buildPathStone(24, 14)),
                        Positioned(left: 80, top: 54, child: _buildPathStone(28, 16)),
                        // Fleurs stylisées
                        Positioned(left: 20, top: 16, child: _VectorFloralDot(color: Color(0xFFF472B6))),
                        Positioned(right: 70, top: 28, child: _VectorFloralDot(color: Color(0xFFFBBF24))),
                        Positioned(left: 40, bottom: 20, child: _VectorFloralDot(color: Color(0xFF38BDF8))),
                        Positioned(right: 90, bottom: 25, child: _VectorFloralDot(color: Color(0xFFFB7185))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

      case PlayEnvironment.beach:
        return Stack(
          children: [
            Column(
              children: [
                // Ciel dégagé avec mouette stylisée
                Expanded(
                  flex: 3,
                  child: Container(
                    color: const Color(0xFF7DD3FC),
                    child: Stack(
                      children: [
                        Positioned(right: 40, top: 15, child: _buildCloud(40, 16)),
                        // Petite mouette stylisée
                        Positioned(
                          left: 45,
                          top: 20,
                          child: CustomPaint(
                            size: const Size(20, 10),
                            painter: _SeagullPainter(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Mer en dégradé azur avec écume
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 4,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ),

                // Plage avec parasol de plage et coquillages vectoriels
                Expanded(
                  flex: 5,
                  child: Container(
                    color: const Color(0xFFFDE68A),
                    child: Stack(
                      children: [
                        // Grand parasol rayé planté dans le sable
                        Positioned(
                          right: 20,
                          top: 8,
                          child: _buildBeachUmbrella(),
                        ),
                        // Serviette de plage rayée
                        Positioned(
                          right: 68,
                          top: 36,
                          child: Container(
                            width: 38,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF43F5E),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        ),
                        // Galets et étoile de mer vectoriels
                        Positioned(left: 40, top: 20, child: _VectorPebble(width: 14, height: 8)),
                        Positioned(right: 55, bottom: 22, child: _VectorPebble(width: 18, height: 10)),
                        Positioned(
                          left: 75,
                          bottom: 26,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFB7185),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

      case PlayEnvironment.forest:
        return Stack(
          children: [
            Column(
              children: [
                // Ciel sous-bois avec crêtes de collines lointaines
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFC7D2FE), Color(0xFFE0E7FF)],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Silhouette de montagne lointaine
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 30,
                            decoration: const BoxDecoration(
                              color: Color(0xFF818CF8),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
                            ),
                          ),
                        ),
                        // Rangée de sapins majestueux
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const [
                              _VectorPineTree(height: 42, color: Color(0xFF065F46)),
                              _VectorPineTree(height: 56, color: Color(0xFF047857)),
                              _VectorPineTree(height: 46, color: Color(0xFF065F46)),
                              _VectorPineTree(height: 60, color: Color(0xFF064E3B)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Sol de sous-bois avec rondin de bois et champignons
                Expanded(
                  flex: 6,
                  child: Container(
                    color: const Color(0xFFA7F3D0),
                    child: Stack(
                      children: [
                        // Rondin de bois / souche d'arbre
                        Positioned(
                          right: 24,
                          top: 14,
                          child: _buildTreeStump(),
                        ),
                        // Champignons des bois vectoriels
                        Positioned(
                          right: 70,
                          top: 24,
                          child: _buildMushroom(),
                        ),
                        // Végétation stylisée
                        Positioned(left: 35, top: 18, child: _VectorLeafDot()),
                        Positioned(right: 85, top: 40, child: _VectorLeafDot()),
                        Positioned(left: 75, bottom: 22, child: _VectorLeafDot()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }

  // --- Composants décoratifs vectoriels riches ---

  Widget _buildIndoorPlant() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Feuilles vertes
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                borderRadius: BorderRadius.all(Radius.elliptical(14, 20)),
              ),
            ),
            Container(
              width: 16,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF059669),
                borderRadius: BorderRadius.all(Radius.elliptical(16, 24)),
              ),
            ),
          ],
        ),
        // Pot en terre cuite
        Container(
          width: 22,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFFEA580C),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(5)),
            border: Border.all(color: const Color(0xFFC2410C), width: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildSofa() {
    return Container(
      width: 60,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFF475569), // Canapé gris ardoise moderne
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            offset: const Offset(0, 3),
            blurRadius: 4,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Coussin jaune moutarde sur le canapé
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFFFBBF24),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloud(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }

  Widget _buildGardenHedge() {
    return Container(
      width: 50,
      height: 26,
      decoration: BoxDecoration(
        color: const Color(0xFF15803D),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: const Color(0xFF166534), width: 1.5),
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFDE047),
          ),
        ),
      ),
    );
  }

  Widget _buildPathStone(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.all(Radius.elliptical(w, h)),
        border: Border.all(color: const Color(0xFF94A3B8), width: 1),
      ),
    );
  }

  Widget _buildBeachUmbrella() {
    return Column(
      children: [
        // Toile de parasol rayée rouge/blanche
        Container(
          width: 48,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFFEF4444),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Row(
            children: [
              Expanded(child: Container(color: Colors.white)),
              Expanded(child: Container(color: const Color(0xFFEF4444))),
              Expanded(child: Container(color: Colors.white)),
            ],
          ),
        ),
        // Mât du parasol
        Container(width: 3, height: 32, color: Colors.white),
      ],
    );
  }

  Widget _buildTreeStump() {
    return Container(
      width: 38,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFF78350F), // Bois écorce
        borderRadius: const BorderRadius.vertical(
          top: Radius.elliptical(19, 8),
          bottom: Radius.circular(6),
        ),
        border: Border.all(color: const Color(0xFF451A03), width: 1.5),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 32,
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFFB45309), // Cernes du bois
            borderRadius: const BorderRadius.all(Radius.elliptical(16, 6)),
          ),
        ),
      ),
    );
  }

  Widget _buildMushroom() {
    return Column(
      children: [
        // Chapeau rouge à pois
        Container(
          width: 16,
          height: 10,
          decoration: const BoxDecoration(
            color: Color(0xFFDC2626),
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: const Center(
            child: CircleAvatar(radius: 2, backgroundColor: Colors.white),
          ),
        ),
        // Pied blanc
        Container(width: 4, height: 6, color: Colors.white),
      ],
    );
  }
}

/// Balle de tennis active posée sur le terrain avec indicateur de contact
class _ActiveBallTarget extends StatelessWidget {
  const _ActiveBallTarget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 2,
            child: Container(
              width: 24,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.18),
                borderRadius: const BorderRadius.all(
                  Radius.elliptical(24, 6),
                ),
              ),
            ),
          ),
          const TennisBallWidget(size: 30),
        ],
      ),
    );
  }
}

/// Flèche triangulaire sous la bulle de parole de Pi
class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.ink200
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _VectorFloralDot extends StatelessWidget {
  final Color color;
  const _VectorFloralDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}

class _VectorPebble extends StatelessWidget {
  final double width;
  final double height;
  const _VectorPebble({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFD97706).withValues(alpha: 0.25),
        borderRadius: BorderRadius.all(Radius.elliptical(width, height)),
      ),
    );
  }
}

class _VectorPineTree extends StatelessWidget {
  final double height;
  final Color color;
  const _VectorPineTree({required this.height, this.color = const Color(0xFF065F46)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(height * 0.55, height),
      painter: _PineTreePainter(color: color),
    );
  }
}

class _PineTreePainter extends CustomPainter {
  final Color color;
  _PineTreePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(w / 2, 0);
    path.lineTo(w * 0.85, h * 0.45);
    path.lineTo(w * 0.65, h * 0.45);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.lineTo(w * 0.35, h * 0.45);
    path.lineTo(w * 0.15, h * 0.45);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SeagullPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(0, h * 0.8);
    path.quadraticBezierTo(w * 0.25, 0, w * 0.5, h * 0.6);
    path.quadraticBezierTo(w * 0.75, 0, w, h * 0.8);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _VectorLeafDot extends StatelessWidget {
  const _VectorLeafDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFF047857).withValues(alpha: 0.35),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Lettres "Zzz" flottantes en dégradé pastel apaisant
class _SleepingZzzWidget extends StatelessWidget {
  const _SleepingZzzWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: const [
        Text(
          'Z',
          style: TextStyle(
            color: Color(0xFF67E8F9),
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            shadows: [
              Shadow(color: Color(0xFF0284C7), blurRadius: 4),
            ],
          ),
        ),
        Text(
          'z',
          style: TextStyle(
            color: Color(0xFF38BDF8),
            fontSize: 13,
            fontWeight: FontWeight.w800,
            shadows: [
              Shadow(color: Color(0xFF0284C7), blurRadius: 3),
            ],
          ),
        ),
        Text(
          'z',
          style: TextStyle(
            color: Color(0xFF818CF8),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Bulles de savon étincelantes dans la baignoire de douche
class _SoapBubblesWidget extends StatelessWidget {
  const _SoapBubblesWidget();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 6,
          bottom: 22,
          child: _buildBubble(14),
        ),
        Positioned(
          left: 18,
          bottom: 40,
          child: _buildBubble(10),
        ),
        Positioned(
          right: 8,
          bottom: 28,
          child: _buildBubble(16),
        ),
        Positioned(
          right: 22,
          bottom: 48,
          child: _buildBubble(11),
        ),
        Positioned(
          left: 42,
          bottom: 8,
          child: _buildBubble(12),
        ),
        Positioned(
          right: 44,
          bottom: 12,
          child: _buildBubble(13),
        ),
      ],
    );
  }

  Widget _buildBubble(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE0F2FE).withValues(alpha: 0.65),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
            blurRadius: 3,
          ),
        ],
      ),
      child: Align(
        alignment: const Alignment(-0.4, -0.4),
        child: Container(
          width: size * 0.25,
          height: size * 0.25,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
