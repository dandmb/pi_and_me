import 'package:flutter/material.dart';
import 'kibble_widget.dart';

/// Gamelle / Assiette pour chiot posée dans le coin du terrain.
/// Affiche visuellement le niveau de remplissage des croquettes servies (0 à 3).
class FoodBowlWidget extends StatelessWidget {
  final int foodCount; // 0 à 3
  final double width;
  final double height;

  const FoodBowlWidget({
    super.key,
    required this.foodCount,
    this.width = 68.0,
    this.height = 44.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Ombre de contact au sol
          Positioned(
            bottom: 0,
            child: Container(
              width: width * 0.90,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.20),
                borderRadius: BorderRadius.all(
                  Radius.elliptical(width * 0.90, 10),
                ),
              ),
            ),
          ),

          // Corps de la gamelle (Céramique bleu ciel / ardoise moderne)
          Positioned(
            bottom: 4,
            child: Container(
              width: width,
              height: height * 0.75,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE0F2FE), // Rebord lumineux
                    Color(0xFFBAE6FD), // Corps bleu ciel
                    Color(0xFF38BDF8), // Base robuste
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.elliptical(34, 18),
                  top: Radius.elliptical(34, 10),
                ),
                border: Border.all(color: const Color(0xFF0284C7), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    offset: const Offset(0, 3),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Icon(
                    Icons.pets,
                    size: width * 0.25,
                    color: const Color(0xFF0284C7).withValues(alpha: 0.40),
                  ),
                ),
              ),
            ),
          ),

          // Intérieur / Creux de l'assiette
          Positioned(
            top: 6,
            child: Container(
              width: width * 0.82,
              height: height * 0.38,
              decoration: BoxDecoration(
                color: const Color(0xFF0C4A6E).withValues(alpha: 0.25),
                borderRadius: BorderRadius.all(
                  Radius.elliptical(width * 0.82, height * 0.38),
                ),
                border: Border.all(
                  color: const Color(0xFF0369A1).withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
          ),

          // Croquettes servies dans l'assiette (remplissage progressif 1 à 3)
          if (foodCount > 0)
            Positioned(
              top: 4,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCroquettesPile(foodCount),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCroquettesPile(int count) {
    switch (count) {
      case 1:
        return const KibbleWidget(size: 20);
      case 2:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            KibbleWidget(size: 18),
            SizedBox(width: 3),
            KibbleWidget(size: 18),
          ],
        );
      case 3:
      default:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const KibbleWidget(size: 17),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                KibbleWidget(size: 17),
                SizedBox(width: 2),
                KibbleWidget(size: 17),
              ],
            ),
          ],
        );
    }
  }
}
