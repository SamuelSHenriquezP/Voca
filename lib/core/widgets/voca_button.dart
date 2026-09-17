import 'package:flutter/material.dart';
import '../theme/voca_colors.dart';
import '../theme/voca_typography.dart';
import '../utils/haptic_feedback_utils.dart';

enum VocaButtonVariant {
  primary, // Indigo
  success, // Emerald
  accent, // Rose
  warning, // Amber
  cyan, // Sky Blue
  danger, // Red
  gold, // Bronze / Gold
  neutral, // Clean White with subtle border
  ghost, // Transparent
}

class VocaButton extends StatefulWidget {
  final String? text;
  final Widget? icon;
  final Widget? child;
  final VoidCallback? onPressed;
  final VocaButtonVariant variant;
  final double height;
  final double? width;
  final double depth;
  final double borderRadius;
  final bool isFullWidth;
  final bool isLoading;

  const VocaButton({
    super.key,
    this.text,
    this.icon,
    this.child,
    required this.onPressed,
    this.variant = VocaButtonVariant.primary,
    this.height = 48,
    this.width,
    this.depth = 4.0,
    this.borderRadius = 14.0,
    this.isFullWidth = false,
    this.isLoading = false,
  });

  @override
  State<VocaButton> createState() => _VocaButtonState();
}

class _VocaButtonState extends State<VocaButton> {
  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  Color get _surfaceColor {
    if (!_isEnabled) return const Color(0xFFF4F4F5);
    switch (widget.variant) {
      case VocaButtonVariant.primary:
        return const Color(0xFF4F46E5);
      case VocaButtonVariant.success:
        return const Color(0xFF059669);
      case VocaButtonVariant.accent:
        return const Color(0xFFE11D48);
      case VocaButtonVariant.warning:
        return const Color(0xFFD97706);
      case VocaButtonVariant.cyan:
        return const Color(0xFF0284C7);
      case VocaButtonVariant.danger:
        return const Color(0xFFDC2626);
      case VocaButtonVariant.gold:
        return const Color(0xFFB45309);
      case VocaButtonVariant.neutral:
        return Colors.white;
      case VocaButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color get _shadowColor {
    if (!_isEnabled) return const Color(0xFFE4E4E7);
    switch (widget.variant) {
      case VocaButtonVariant.primary:
        return const Color(0xFF3730A3);
      case VocaButtonVariant.success:
        return const Color(0xFF047857);
      case VocaButtonVariant.accent:
        return const Color(0xFFBE123C);
      case VocaButtonVariant.warning:
        return const Color(0xFF92400E);
      case VocaButtonVariant.cyan:
        return const Color(0xFF0369A1);
      case VocaButtonVariant.danger:
        return const Color(0xFF991B1B);
      case VocaButtonVariant.gold:
        return const Color(0xFF78350F);
      case VocaButtonVariant.neutral:
        return const Color(0xFFE4E4E7);
      case VocaButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color get _textColor {
    if (!_isEnabled) return const Color(0xFFA1A1AA);
    switch (widget.variant) {
      case VocaButtonVariant.neutral:
        return VocaColors.darkSlate;
      case VocaButtonVariant.ghost:
        return VocaColors.primaryPurple;
      default:
        return Colors.white;
    }
  }

  void _onTapDown(TapDownDetails details) {
    if (!_isEnabled) return;
    setState(() => _isPressed = true);
    HapticUtils.light();
  }

  void _onTapUp(TapUpDetails details) {
    if (!_isEnabled) return;
    setState(() => _isPressed = false);
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    if (!_isEnabled) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDepth = widget.variant == VocaButtonVariant.ghost ? 0.0 : widget.depth;
    final totalHeight = widget.height + effectiveDepth;
    final currentOffset = _isPressed ? effectiveDepth : 0.0;

    Widget content = widget.isLoading
        ? SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(_textColor),
            ),
          )
        : widget.child ??
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  widget.icon!,
                  if (widget.text != null) const SizedBox(width: 8),
                ],
                if (widget.text != null)
                  Text(
                    widget.text!,
                    style: VocaTypography.buttonText.copyWith(
                      color: _textColor,
                      fontSize: widget.height < 46 ? 13 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.isFullWidth ? double.infinity : widget.width,
        height: totalHeight,
        child: Stack(
          children: [
            // Minimalist 3D Lip
            if (effectiveDepth > 0)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: widget.height,
                child: Container(
                  decoration: BoxDecoration(
                    color: _shadowColor,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: widget.variant == VocaButtonVariant.neutral
                        ? Border.all(color: const Color(0xFFE4E4E7), width: 1)
                        : null,
                  ),
                ),
              ),

            // Top Pushable Face
            AnimatedPositioned(
              duration: const Duration(milliseconds: 40),
              curve: Curves.easeOut,
              left: 0,
              right: 0,
              top: currentOffset,
              height: widget.height,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: widget.variant == VocaButtonVariant.neutral
                      ? Border.all(color: const Color(0xFFE4E4E7), width: 1)
                      : (widget.variant == VocaButtonVariant.ghost
                          ? null
                          : Border.all(color: Colors.white.withOpacity(0.18), width: 1)),
                ),
                child: content,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
