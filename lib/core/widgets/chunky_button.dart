import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text.dart';

enum ChunkyButtonVariant {
  primary,   // Bleu sky600, bord 6px sky700, texte blanc (Jouer, Valider, etc.)
  secondary, // Blanc surface, bordure 2px, bord 4px ink300, texte ink900
  success,   // Vert green600, bord 4px green700, texte blanc (Achat, Récompense)
  danger,    // Blanc surface, bordure 2px corail, texte corail
}

/// Bouton tactile physique à rebord inférieur 3D (« Chunky »).
/// S'enfonce de [edgeHeight] pixels au toucher sans ombre floue d'IA.
/// Conforme à DESIGN_SYSTEM.md §6.1.
class ChunkyButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final ChunkyButtonVariant variant;
  final Widget? icon;
  final double? width;
  final double height;
  final bool isFullWidth;

  const ChunkyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ChunkyButtonVariant.primary,
    this.icon,
    this.width,
    this.height = 56.0,
    this.isFullWidth = true,
  });

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _isPressed = false;

  double get _edgeHeight {
    if (widget.onPressed == null) return 0;
    return widget.variant == ChunkyButtonVariant.primary ? AppEdge.primary : AppEdge.standard;
  }

  Color _getFaceColor(bool isDark) {
    if (widget.onPressed == null) {
      return isDark ? AppColors.darkSurfaceAlt : AppColors.ink100;
    }
    switch (widget.variant) {
      case ChunkyButtonVariant.primary:
        return AppColors.sky600;
      case ChunkyButtonVariant.secondary:
      case ChunkyButtonVariant.danger:
        return isDark ? AppColors.darkSurface : AppColors.surface;
      case ChunkyButtonVariant.success:
        return AppColors.green600;
    }
  }

  Color _getEdgeColor(bool isDark) {
    if (widget.onPressed == null) return Colors.transparent;
    switch (widget.variant) {
      case ChunkyButtonVariant.primary:
        return AppColors.sky700;
      case ChunkyButtonVariant.secondary:
        return isDark ? AppColors.darkInk200 : AppColors.ink300;
      case ChunkyButtonVariant.success:
        return AppColors.green700;
      case ChunkyButtonVariant.danger:
        return isDark ? const Color(0xFF7F1D1D) : const Color(0xFFF5B5BE);
    }
  }

  TextStyle _getTextStyle(bool isDark) {
    if (widget.onPressed == null) {
      return AppText.buttonM.copyWith(
        color: isDark ? AppColors.darkInk500 : AppColors.ink500,
      );
    }
    switch (widget.variant) {
      case ChunkyButtonVariant.primary:
        return AppText.buttonL;
      case ChunkyButtonVariant.secondary:
        return AppText.buttonM.copyWith(
          color: isDark ? AppColors.darkInk900 : AppColors.ink900,
        );
      case ChunkyButtonVariant.success:
        return AppText.buttonM;
      case ChunkyButtonVariant.danger:
        return AppText.buttonM.copyWith(color: AppColors.coral500);
    }
  }

  Border? _getBorder(bool isDark) {
    if (widget.onPressed == null) return null;
    switch (widget.variant) {
      case ChunkyButtonVariant.secondary:
        return Border.all(
          color: isDark ? AppColors.darkInk200 : AppColors.ink200,
          width: 2,
        );
      case ChunkyButtonVariant.danger:
        return Border.all(color: AppColors.coral500, width: 2);
      default:
        return null;
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    HapticFeedback.lightImpact();
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final edge = _edgeHeight;
    final totalHeight = widget.height;
    final faceHeight = totalHeight - edge;
    final radius = BorderRadius.circular(AppRadius.lg);

    Widget content = Semantics(
      button: true,
      enabled: widget.onPressed != null,
      label: widget.label,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: SizedBox(
          height: totalHeight,
          width: widget.isFullWidth ? double.infinity : widget.width,
          child: Stack(
            children: [
              // Rebord physique inférieur (Chunky Edge)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: totalHeight - 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: _getEdgeColor(isDark),
                    borderRadius: radius,
                  ),
                ),
              ),

              // Face du bouton (qui descend au toucher)
              AnimatedPositioned(
                duration: _isPressed ? AppMotion.instant : AppMotion.fast,
                curve: _isPressed ? Curves.easeOut : Curves.easeOutBack,
                top: _isPressed ? edge : 0,
                left: 0,
                right: 0,
                height: faceHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: _getFaceColor(isDark),
                    borderRadius: radius,
                    border: _getBorder(isDark),
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          widget.icon!,
                          const SizedBox(width: AppSpace.s2),
                        ],
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.label,
                              style: _getTextStyle(isDark),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return content;
  }
}
