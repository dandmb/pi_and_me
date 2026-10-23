import 'package:flutter/material.dart';

/// Affiche des taches de terre / boue stylisées sur le chiot Pi quand il joue dehors.
class DirtSplattersWidget extends StatelessWidget {
  final int dirtCount; // 0 à 4

  const DirtSplattersWidget({super.key, required this.dirtCount});

  @override
  Widget build(BuildContext context) {
    if (dirtCount <= 0) return const SizedBox.shrink();

    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Tache 1 : Patte avant et solde boueux (très visible)
          if (dirtCount >= 1) ...[
            Positioned(
              left: 38,
              bottom: 8,
              child: _buildMudPatch(width: 18, height: 12, angle: 0.15),
            ),
            Positioned(left: 34, bottom: 18, child: _buildMudDrop(size: 4)),
          ],

          // Tache 2 : Flanc droit & patte arrière
          if (dirtCount >= 2) ...[
            Positioned(
              right: 18,
              bottom: 14,
              child: _buildMudPatch(width: 22, height: 14, angle: -0.25),
            ),
            Positioned(right: 28, bottom: 26, child: _buildMudDrop(size: 5)),
            Positioned(right: 14, bottom: 24, child: _buildMudDrop(size: 3.5)),
          ],

          // Tache 3 : Poitrail et ventre
          if (dirtCount >= 3) ...[
            Positioned(
              left: 42,
              top: 48,
              child: _buildMudPatch(width: 20, height: 13, angle: 0.35),
            ),
            Positioned(left: 36, top: 44, child: _buildMudDrop(size: 4.5)),
          ],

          // Tache 4 : Joue / oreille / front de Pi
          if (dirtCount >= 4) ...[
            Positioned(
              left: 24,
              top: 26,
              child: _buildMudPatch(width: 16, height: 11, angle: -0.3),
            ),
            Positioned(left: 20, top: 20, child: _buildMudDrop(size: 4)),
            Positioned(right: 32, top: 30, child: _buildMudDrop(size: 3.5)),
          ],
        ],
      ),
    );
  }

  Widget _buildMudPatch({
    required double width,
    required double height,
    required double angle,
  }) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF5C2C16)
              .withValues(alpha: 0.88), // Terre boueuse sombre
          borderRadius: BorderRadius.all(Radius.elliptical(width, height)),
          border: Border.all(color: const Color(0xFF331608), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.20),
              offset: const Offset(0, 1.5),
              blurRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMudDrop({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF451A03),
        shape: BoxShape.circle,
      ),
    );
  }
}
