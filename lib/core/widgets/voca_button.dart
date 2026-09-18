import 'package:flutter/material.dart';
import '../theme/voca_typography.dart';
import '../utils/haptic_feedback_utils.dart';

enum VocaButtonVariant {
  primary, // Cheerful Violet
  success, // Vibrant Emerald
  accent, // Coral Rose
  warning, // Sunny Amber
  cyan, // Sky Blue
  danger, // Soft Red
  gold, // Warm Honey
  neutral, // Clean Crisp White
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
  final double depth; // Kept for API compatibility but zeroed
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
    this.height = 50,
    this.width,
    this.depth = 0.0,
    this.borderRadius = 16.0,
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
    if (!_isEnabled) return const Color(0xFFF1F5F9);
    switch (widget.variant) {
      case VocaButtonVariant.primary:
        return const Color(0xFF0F172A); // Carbon Black
      case VocaButtonVariant.success:
        return const Color(0xFF1E293B); // Dark Slate
      case VocaButtonVariant.accent:
        return const Color(0xFF334155); // Slate
      case VocaButtonVariant.warning:
        return const Color(0xFF334155);
      case VocaButtonVariant.cyan:
        return const Color(0xFF475569);
      case VocaButtonVariant.danger:
        return const Color(0xFF1E293B);
      case VocaButtonVariant.gold:
        return const Color(0xFF0F172A);
      case VocaButtonVariant.neutral:
        return Colors.white;
      case VocaButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color get _textColor {
    if (!_isEnabled) return const Color(0xFF94A3B8);
    switch (widget.variant) {
      case VocaButtonVariant.neutral:
        return const Color(0xFF0F172A);
      case VocaButtonVariant.ghost:
        return const Color(0xFF0F172A);
      default:
        return Colors.white;
    }
  }

  Border? get _border {
    if (widget.variant == VocaButtonVariant.neutral) {
      return Border.all(color: const Color(0xFFE2E8F0), width: 1.5);
    }
    if (widget.variant == VocaButtonVariant.ghost) {
      return null;
    }
    return null;
  }

  List<BoxShadow>? get _shadows {
    if (!_isEnabled || widget.variant == VocaButtonVariant.ghost) return null;
    if (widget.variant == VocaButtonVariant.neutral) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];
    }
    return [
      BoxShadow(
        color: _surfaceColor.withOpacity(0.22),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];
  }

  void _onTapDown(TapDownDetails details) {
    if (!_isEnabled) return;
    VocaHaptics.selection();
    setState(() => _isPressed = true);
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
    final Widget content = widget.isLoading
        ? Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation<Color>(_textColor),
              ),
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
                      fontSize: widget.height < 46 ? 13 : 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
              ],
            );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Container(
          width: widget.isFullWidth ? double.infinity : widget.width,
          height: widget.height,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: _border,
            boxShadow: _shadows,
          ),
          child: content,
        ),
      ),
    );
  }
}
