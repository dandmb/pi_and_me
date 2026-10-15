import 'package:flutter/material.dart';

/// Widget vectoriel représentant une croquette croustillante / biscuit d'os (sans aucun emoji).
class KibbleWidget extends StatelessWidget {
  final double size;

  const KibbleWidget({
    super.key,
    this.size = 26.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.72,
      decoration: BoxDecoration(
        color: const Color(0xFFD97706), // Brun doré biscuit
        borderRadius: BorderRadius.circular(size * 0.35),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF59E0B), // Ambre doré éclatant
            Color(0xFFD97706), // Doré cuit
            Color(0xFFB45309), // Ombrage croustillant
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            offset: const Offset(0, 2),
            blurRadius: 2,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF92400E).withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Center(
        child: Container(
          width: size * 0.40,
          height: size * 0.20,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(size * 0.10),
          ),
        ),
      ),
    );
  }
}
