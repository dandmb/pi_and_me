import 'package:flutter/material.dart';

/// Widget vectoriel de balle de tennis réaliste et ludique (sans emoji).
class TennisBallWidget extends StatelessWidget {
  final double size;

  const TennisBallWidget({super.key, this.size = 28.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.3),
          radius: 0.8,
          colors: [
            Color(0xFFE2FF4A), // Jaune-vert vif éclatant
            Color(0xFFA3E635), // Vert pomme tennis
            Color(0xFF65A30D), // Ombrage vert olive
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            offset: const Offset(0, 3),
            blurRadius: 3,
          ),
        ],
      ),
      child: CustomPaint(painter: _TennisSeamPainter()),
    );
  }
}

class _TennisSeamPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final seamPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Couture gauche
    final path1 = Path();
    path1.moveTo(w * 0.22, h * 0.08);
    path1.quadraticBezierTo(w * 0.40, h * 0.50, w * 0.22, h * 0.92);
    canvas.drawPath(path1, seamPaint);

    // Couture droite
    final path2 = Path();
    path2.moveTo(w * 0.78, h * 0.08);
    path2.quadraticBezierTo(w * 0.60, h * 0.50, w * 0.78, h * 0.92);
    canvas.drawPath(path2, seamPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
