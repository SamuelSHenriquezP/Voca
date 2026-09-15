import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/voca_colors.dart';

class WaveformWidget extends StatefulWidget {
  final bool isSpeaking;
  final Color barColor;
  final int barCount;
  final double maxHeight;
  final double minHeight;
  final double barWidth;
  final double spacing;

  const WaveformWidget({
    super.key,
    this.isSpeaking = true,
    this.barColor = VocaColors.electricCyan,
    this.barCount = 18,
    this.maxHeight = 48.0,
    this.minHeight = 8.0,
    this.barWidth = 4.0,
    this.spacing = 3.5,
  });

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant WaveformWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpeaking && !_animationController.isAnimating) {
      _animationController.repeat();
    } else if (!widget.isSpeaking && _animationController.isAnimating) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(widget.barCount, (index) {
            double value = 0.5;
            if (widget.isSpeaking) {
              final wave = math.sin(
                (_animationController.value * 2 * math.pi) + (index * 0.45),
              );
              value = (wave + 1) / 2; // Normalize 0..1
              // Add frequency variation
              final secondary = math.cos(
                (_animationController.value * 4 * math.pi) - (index * 0.3),
              );
              value = (value * 0.7) + ((secondary + 1) / 4 * 0.3);
            }

            final barHeight = widget.minHeight +
                (widget.maxHeight - widget.minHeight) * value.clamp(0.1, 1.0);

            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
              width: widget.barWidth,
              height: barHeight,
              decoration: BoxDecoration(
                color: widget.barColor,
                borderRadius: BorderRadius.circular(widget.barWidth / 2),
              ),
            );
          }),
        );
      },
    );
  }
}

