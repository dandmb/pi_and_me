import 'package:flutter/material.dart';

/// Rendu visuel haute précision des accessoires superposés sur la mascotte Pi.
/// Chaque accessoire est un calque transparent haute fidélité (420x482)
/// calibré sur les coordonnées anatomiques exactes de la mascotte Pi :
/// crâne entre les oreilles, niveau des yeux, collier et dos pour les capes.
class AccessoryOverlayWidget extends StatelessWidget {
  final String? accessoryId;
  final double piSize;

  const AccessoryOverlayWidget({
    super.key,
    required this.accessoryId,
    this.piSize = 130,
  });

  @override
  Widget build(BuildContext context) {
    if (accessoryId == null || accessoryId!.isEmpty) {
      return const SizedBox.shrink();
    }

    final double width = piSize * (420.0 / 482.0);

    return IgnorePointer(
      child: Image.asset(
        'assets/images/accessories/$accessoryId.png',
        width: width,
        height: piSize,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      ),
    );
  }
}
