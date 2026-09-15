import 'package:flutter/material.dart';
import '../theme/voca_colors.dart';
import '../theme/voca_typography.dart';
import '../utils/haptic_feedback_utils.dart';

enum VocaButtonVariant {
  primary, // Purple
  success, // Emerald Green
  accent, // Pink
  warning, // Orange
  cyan, // Electric Cyan
  danger, // Ruby Red
  gold, // Gold / XP
  neutral, // White with border
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
    this.height = 54,
    this.width,
    this.depth = 5.0,
    this.borderRadius = 18.0,
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
    if (!_isEnabled) return VocaColors.lockedGray;
    switch (widget.variant) {
      case VocaButtonVariant.primary:
        return VocaColors.primaryPurple;
      case VocaButtonVariant.success:
        return VocaColors.emeraldGreen;
      case VocaButtonVariant.accent:
        return VocaColors.accentPink;
      case VocaButtonVariant.warning:
        return VocaColors.sunOrange;
      case VocaButtonVariant.cyan:
        return VocaColors.electricCyan;
      case VocaButtonVariant.danger:
        return VocaColors.rubyRed;
      case VocaButtonVariant.gold:
        return VocaColors.goldXp;
      case VocaButtonVariant.neutral:
        return VocaColors.cardBackground;
      case VocaButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color get _shadowColor {
    if (!_isEnabled) return VocaColors.lockedGrayShadow;
    switch (widget.variant) {
      case VocaButtonVariant.primary:
        return VocaColors.primaryPurpleShadow;
      case VocaButtonVariant.success:
        return VocaColors.emeraldGreenShadow;
      case VocaButtonVariant.accent:
        return VocaColors.accentPinkShadow;
      case VocaButtonVariant.warning:
        return VocaColors.sunOrangeShadow;
      case VocaButtonVariant.cyan:
        return VocaColors.electricCyanShadow;
      case VocaButtonVariant.danger:
        return VocaColors.rubyRedShadow;
      case VocaButtonVariant.gold:
        return VocaColors.goldXpShadow;
      case VocaButtonVariant.neutral:
        return VocaColors.borderSubtle;
      case VocaButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color get _textColor {
    if (!_isEnabled) return Colors.white;
    switch (widget.variant) {
      case VocaButtonVariant.neutral:
        return VocaColors.darkSlate;
      case VocaButtonVariant.gold:
        return const Color(0xFF6A4700);
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
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
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
                      fontSize: widget.height < 48 ? 14 : 16,
                    ),
                  ),
              ],
            );

    Widget button = GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.isFullWidth ? double.infinity : widget.width,
        height: totalHeight,
        child: Stack(
          children: [
            // Bottom 3D Shadow Layer
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
                        ? Border.all(color: VocaColors.borderSubtle, width: 2)
                        : null,
                  ),
                ),
              ),

            // Top Pushable Surface Layer (Translates down when pressed)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 60),
              curve: Curves.easeOutCubic,
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
                      ? Border.all(color: VocaColors.borderLight, width: 2)
                      : null,
                ),
                child: content,
              ),
            ),
          ],
        ),
      ),
    );

    return button;
  }
}

