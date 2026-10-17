import 'package:flutter/material.dart';

/// Rendu visuel haute précision des accessoires superposés sur la mascotte Pi.
/// Chaque accessoire est un calque transparent haute fidélité (420x482)
/// calibré sur les coordonnées anatomiques exactes de la mascotte Pi :
/// crâne entre les oreilles, niveau des yeux, collier et dos pour les capes.
/// Supporte la combinaison simultanée de plusieurs accessoires (ex: cape + collier + lunettes + chapeau).
class AccessoryOverlayWidget extends StatelessWidget {
  final String? accessoryId;
  final List<String>? accessoryIds;
  final double piSize;

  const AccessoryOverlayWidget({
    super.key,
    this.accessoryId,
    this.accessoryIds,
    this.piSize = 130,
  });

  List<String> get _resolvedIds {
    if (accessoryIds != null && accessoryIds!.isNotEmpty) {
      return accessoryIds!.where((id) => id.isNotEmpty).toList();
    }
    if (accessoryId != null && accessoryId!.isNotEmpty) {
      return [accessoryId!];
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final ids = _resolvedIds;
    if (ids.isEmpty) {
      return const SizedBox.shrink();
    }

    final double width = piSize * (420.0 / 482.0);
    final double totalHeight = piSize * (560.0 / 482.0);
    final double topOffset = -piSize * (78.0 / 482.0);

    return IgnorePointer(
      child: SizedBox(
        width: width,
        height: piSize,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            for (final id in ids)
              Positioned(
                top: topOffset,
                left: 0,
                right: 0,
                height: totalHeight,
                child: Image.asset(
                  'assets/images/accessories/$id.png',
                  width: width,
                  height: totalHeight,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
