import 'dart:math' as math;
import 'package:flutter/material.dart';

class NotionAvatar extends StatefulWidget {
  final int headShape;    // 0: Oval, 1: Square, 2: Round, 3: Oblong
  final int hairStyle;    // 0: Part, 1: Curls, 2: Bun, 3: Bob, 4: Fringe, 5: Beanie, 6: Buzz, 7: Ponytail
  final int eyesStyle;    // 0: Round Glasses, 1: Dots, 2: Square Glasses, 3: Wink, 4: Smile, 5: Shades
  final int mouthStyle;   // 0: Smirk, 1: Open Smile, 2: Focused Line, 3: Mustache, 4: Beard
  final int outfitStyle;  // 0: Turtleneck, 1: Hoodie, 2: Collar, 3: Crewneck, 4: Scarf
  final int backdropIndex;// 0: Cream, 1: Sage, 2: Lavender, 3: Apricot, 4: Slate
  final double size;
  final bool isAnimated;
  final VoidCallback? onTap;

  const NotionAvatar({
    super.key,
    int? head,
    int? hair,
    int? eyes,
    int? mouth,
    int? outfit,
    int? backdrop,
    int headShape = 0,
    int hairStyle = 0,
    int eyesStyle = 0,
    int mouthStyle = 0,
    int outfitStyle = 0,
    int backdropIndex = 0,
    this.size = 64,
    this.isAnimated = true,
    this.onTap,
  })  : headShape = head ?? headShape,
        hairStyle = hair ?? hairStyle,
        eyesStyle = eyes ?? eyesStyle,
        mouthStyle = mouth ?? mouthStyle,
        outfitStyle = outfit ?? outfitStyle,
        backdropIndex = backdrop ?? backdropIndex;

  /// Generate a deterministic, personality-aligned Notion avatar from an ID or Name
  factory NotionAvatar.fromId(
    String idOrName, {
    Key? key,
    double size = 64,
    bool isAnimated = true,
    VoidCallback? onTap,
  }) {
    final lower = idOrName.toLowerCase();
    int head = 0;
    int hair = 0;
    int eyes = 0;
    int mouth = 0;
    int outfit = 0;
    int backdrop = 0;

    if (lower.contains('miller') || lower.contains('customs') || lower.contains('officer')) {
      head = 1; // Square
      hair = 6; // Buzz
      eyes = 2; // Square Glasses
      mouth = 2; // Focused Line
      outfit = 2; // Collar
      backdrop = 4; // Slate
    } else if (lower.contains('mateo') || lower.contains('barista') || lower.contains('coffee')) {
      head = 0; // Oval
      hair = 1; // Curls
      eyes = 4; // Smile
      mouth = 3; // Mustache
      outfit = 1; // Hoodie
      backdrop = 3; // Apricot
    } else if (lower.contains('marcus') || lower.contains('tech') || lower.contains('director') || lower.contains('interview')) {
      head = 3; // Oblong
      hair = 0; // Part
      eyes = 0; // Round Glasses
      mouth = 0; // Smirk
      outfit = 0; // Turtleneck
      backdrop = 1; // Sage
    } else if (lower.contains('pierre') || lower.contains('concierge') || lower.contains('hotel')) {
      head = 2; // Round
      hair = 2; // Bun
      eyes = 1; // Dots
      mouth = 4; // Beard
      outfit = 4; // Scarf
      backdrop = 2; // Lavender
    } else if (lower.contains('alex')) {
      head = 0; // Oval
      hair = 4; // Fringe
      eyes = 0; // Round Glasses
      mouth = 1; // Smile
      outfit = 3; // Crewneck
      backdrop = 0; // Cream
    } else {
      final hash = idOrName.hashCode.abs();
      head = hash % 4;
      hair = (hash ~/ 4) % 8;
      eyes = (hash ~/ 32) % 6;
      mouth = (hash ~/ 192) % 5;
      outfit = (hash ~/ 960) % 5;
      backdrop = (hash ~/ 4800) % 5;
    }

    return NotionAvatar(
      key: key,
      head: head,
      hair: hair,
      eyes: eyes,
      mouth: mouth,
      outfit: outfit,
      backdrop: backdrop,
      size: size,
      isAnimated: isAnimated,
      onTap: onTap,
    );
  }

  @override
  State<NotionAvatar> createState() => _NotionAvatarState();
}

class _NotionAvatarState extends State<NotionAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    if (widget.isAnimated) {
      _anim.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant NotionAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimated && !_anim.isAnimating) {
      _anim.repeat(reverse: true);
    } else if (!widget.isAnimated && _anim.isAnimating) {
      _anim.stop();
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Color _getBackdropColor() {
    switch (widget.backdropIndex) {
      case 1:
        return const Color(0xFFF0FDF4); // Sage
      case 2:
        return const Color(0xFFF5F3FF); // Lavender
      case 3:
        return const Color(0xFFFFF7ED); // Warm apricot
      case 4:
        return const Color(0xFF18181B); // Obsidian Slate
      case 0:
      default:
        return const Color(0xFFFAF9F6); // Warm Ivory
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final isDarkBackdrop = widget.backdropIndex == 4;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          final t = _anim.value;
          final scaleY = widget.isAnimated ? 1.0 + (math.sin(t * math.pi) * 0.02) : 1.0;
          final scaleX = widget.isAnimated ? 1.0 - (math.sin(t * math.pi) * 0.012) : 1.0;
          final isBlinking = widget.isAnimated && (t > 0.90 && t < 0.98);

          return Transform.scale(
            scaleX: scaleX,
            scaleY: scaleY,
            alignment: Alignment.bottomCenter,
            child: Container(
              width: s,
              height: s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getBackdropColor(),
                border: Border.all(
                  color: isDarkBackdrop ? const Color(0xFF3F3F46) : const Color(0xFF0F172A),
                  width: s > 50 ? 2.0 : 1.3,
                ),
                boxShadow: s > 50
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
              child: ClipOval(
                child: CustomPaint(
                  size: Size(s, s),
                  painter: _NotionAvatarPainter(
                    headShape: widget.headShape,
                    hairStyle: widget.hairStyle,
                    eyesStyle: widget.eyesStyle,
                    mouthStyle: widget.mouthStyle,
                    outfitStyle: widget.outfitStyle,
                    isDark: isDarkBackdrop,
                    isBlinking: isBlinking,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotionAvatarPainter extends CustomPainter {
  final int headShape;
  final int hairStyle;
  final int eyesStyle;
  final int mouthStyle;
  final int outfitStyle;
  final bool isDark;
  final bool isBlinking;

  _NotionAvatarPainter({
    required this.headShape,
    required this.hairStyle,
    required this.eyesStyle,
    required this.mouthStyle,
    required this.outfitStyle,
    required this.isDark,
    required this.isBlinking,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final strokeColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final skinColor = isDark ? const Color(0xFF27272A) : const Color(0xFFFAF9F6);
    final hairColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final garmentColor = isDark ? const Color(0xFF3F3F46) : const Color(0xFF1E293B);

    final strokeW = (w * 0.034).clamp(1.1, 2.5);

    final line = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillSkin = Paint()
      ..color = skinColor
      ..style = PaintingStyle.fill;

    final fillHair = Paint()
      ..color = hairColor
      ..style = PaintingStyle.fill;

    final fillGarment = Paint()
      ..color = garmentColor
      ..style = PaintingStyle.fill;

    // Center coordinates & proportions
    final cx = w * 0.50;
    final cy = h * 0.43;
    final hw = w * 0.42;
    final hh = h * 0.44;

    // 1. GARMENT / SHOULDERS (Seamlessly anchors the bottom)
    _drawGarment(canvas, size, line, fillGarment, strokeColor);

    // 2. NECK
    _drawNeck(canvas, cx, cy, hw, hh, h, line, fillSkin);

    // 3. EARS
    _drawEars(canvas, cx, cy, hw, hh, w, h, line, fillSkin);

    // 4. HEAD
    _drawHead(canvas, cx, cy, hw, hh, line, fillSkin);

    // 5. HAIR
    _drawHair(canvas, cx, cy, hw, hh, w, h, line, fillHair, fillSkin);

    // 6. EYES & GLASSES
    _drawEyes(canvas, cx, cy, hw, hh, w, h, line, fillHair);

    // 7. NOSE
    _drawNose(canvas, cx, cy, hh, w, line);

    // 8. MOUTH & FACIAL DETAILS
    _drawMouth(canvas, cx, cy, hh, w, h, line, fillSkin, fillHair);
  }

  void _drawGarment(Canvas canvas, Size size, Paint line, Paint fillGarment, Color strokeColor) {
    final w = size.width;
    final h = size.height;

    final body = Path()
      ..moveTo(0, h)
      ..lineTo(w, h)
      ..lineTo(w * 0.88, h * 0.74)
      ..quadraticBezierTo(w * 0.50, h * 0.71, w * 0.12, h * 0.74)
      ..close();
    canvas.drawPath(body, fillGarment);

    switch (outfitStyle) {
      case 0: // Turtleneck
        final turtleRect = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(w * 0.50, h * 0.70), width: w * 0.22, height: h * 0.10),
          Radius.circular(w * 0.04),
        );
        canvas.drawRRect(turtleRect, fillGarment);
        canvas.drawRRect(turtleRect, line);
        canvas.drawLine(Offset(w * 0.41, h * 0.70), Offset(w * 0.59, h * 0.70), line);
        break;

      case 1: // Hoodie
        final hoodL = Path()
          ..moveTo(w * 0.36, h * 0.74)
          ..quadraticBezierTo(w * 0.42, h * 0.65, w * 0.48, h * 0.75);
        final hoodR = Path()
          ..moveTo(w * 0.52, h * 0.75)
          ..quadraticBezierTo(w * 0.58, h * 0.65, w * 0.64, h * 0.74);
        canvas.drawPath(hoodL, line);
        canvas.drawPath(hoodR, line);
        canvas.drawLine(Offset(w * 0.46, h * 0.76), Offset(w * 0.46, h * 0.86), line);
        canvas.drawLine(Offset(w * 0.54, h * 0.76), Offset(w * 0.54, h * 0.86), line);
        break;

      case 2: // Collared Button-up
        final collarL = Path()
          ..moveTo(w * 0.50, h * 0.74)
          ..lineTo(w * 0.38, h * 0.70)
          ..lineTo(w * 0.46, h * 0.78)
          ..close();
        final collarR = Path()
          ..moveTo(w * 0.50, h * 0.74)
          ..lineTo(w * 0.62, h * 0.70)
          ..lineTo(w * 0.54, h * 0.78)
          ..close();
        final collarPaint = Paint()
          ..color = strokeColor.withOpacity(0.12)
          ..style = PaintingStyle.fill;
        canvas.drawPath(collarL, collarPaint);
        canvas.drawPath(collarL, line);
        canvas.drawPath(collarR, collarPaint);
        canvas.drawPath(collarR, line);
        canvas.drawLine(Offset(w * 0.50, h * 0.78), Offset(w * 0.50, h), line);
        break;

      case 4: // Scarf
        final scarf = Path()
          ..moveTo(w * 0.33, h * 0.71)
          ..quadraticBezierTo(w * 0.50, h * 0.78, w * 0.67, h * 0.71)
          ..quadraticBezierTo(w * 0.71, h * 0.80, w * 0.50, h * 0.82)
          ..quadraticBezierTo(w * 0.29, h * 0.80, w * 0.33, h * 0.71)
          ..close();
        canvas.drawPath(scarf, line);
        break;

      case 3: // Crewneck
      default:
        final crew = Path()
          ..moveTo(w * 0.38, h * 0.72)
          ..quadraticBezierTo(w * 0.50, h * 0.78, w * 0.62, h * 0.72);
        canvas.drawPath(crew, line);
        break;
    }
  }

  void _drawNeck(Canvas canvas, double cx, double cy, double hw, double hh, double h, Paint line, Paint fillSkin) {
    final neckWidth = hw * 0.40;
    final neckTop = cy + hh * 0.30;
    final neckBottom = h * 0.75;

    final neckPath = Path()
      ..moveTo(cx - neckWidth / 2, neckTop)
      ..lineTo(cx - neckWidth / 2, neckBottom)
      ..lineTo(cx + neckWidth / 2, neckBottom)
      ..lineTo(cx + neckWidth / 2, neckTop)
      ..close();
    canvas.drawPath(neckPath, fillSkin);
    canvas.drawLine(Offset(cx - neckWidth / 2, neckTop), Offset(cx - neckWidth / 2, neckBottom), line);
    canvas.drawLine(Offset(cx + neckWidth / 2, neckTop), Offset(cx + neckWidth / 2, neckBottom), line);
  }

  void _drawEars(Canvas canvas, double cx, double cy, double hw, double hh, double w, double h, Paint line, Paint fillSkin) {
    final earW = w * 0.065;
    final earH = h * 0.095;
    final earY = cy + hh * 0.05;

    final leftEarRect = Rect.fromCenter(center: Offset(cx - hw * 0.49, earY), width: earW, height: earH);
    canvas.drawOval(leftEarRect, fillSkin);
    canvas.drawOval(leftEarRect, line);

    final rightEarRect = Rect.fromCenter(center: Offset(cx + hw * 0.49, earY), width: earW, height: earH);
    canvas.drawOval(rightEarRect, fillSkin);
    canvas.drawOval(rightEarRect, line);
  }

  void _drawHead(Canvas canvas, double cx, double cy, double hw, double hh, Paint line, Paint fillSkin) {
    Path headPath;
    switch (headShape) {
      case 1: // Square Jaw
        headPath = Path()
          ..moveTo(cx - hw * 0.48, cy - hh * 0.40)
          ..quadraticBezierTo(cx, cy - hh * 0.54, cx + hw * 0.48, cy - hh * 0.40)
          ..lineTo(cx + hw * 0.48, cy + hh * 0.20)
          ..quadraticBezierTo(cx + hw * 0.44, cy + hh * 0.48, cx + hw * 0.22, cy + hh * 0.48)
          ..lineTo(cx - hw * 0.22, cy + hh * 0.48)
          ..quadraticBezierTo(cx - hw * 0.44, cy + hh * 0.48, cx - hw * 0.48, cy + hh * 0.20)
          ..close();
        break;

      case 2: // Round
        headPath = Path()
          ..addOval(Rect.fromCenter(center: Offset(cx, cy), width: hw * 1.04, height: hh * 0.96));
        break;

      case 3: // Oblong
        headPath = Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx, cy), width: hw * 0.90, height: hh * 1.04),
            Radius.circular(hw * 0.42),
          ));
        break;

      case 0: // Oval
      default:
        headPath = Path()
          ..addOval(Rect.fromCenter(center: Offset(cx, cy), width: hw, height: hh));
        break;
    }

    canvas.drawPath(headPath, fillSkin);
    canvas.drawPath(headPath, line);
  }

  void _drawHair(Canvas canvas, double cx, double cy, double hw, double hh, double w, double h, Paint line, Paint fillHair, Paint fillSkin) {
    switch (hairStyle) {
      case 0: // Classic Side Part
        final hair = Path()
          ..moveTo(cx - hw * 0.50, cy - hh * 0.05)
          ..quadraticBezierTo(cx - hw * 0.52, cy - hh * 0.60, cx, cy - hh * 0.60)
          ..quadraticBezierTo(cx + hw * 0.52, cy - hh * 0.60, cx + hw * 0.50, cy - hh * 0.05)
          ..quadraticBezierTo(cx + hw * 0.35, cy - hh * 0.32, cx - hw * 0.05, cy - hh * 0.35)
          ..quadraticBezierTo(cx - hw * 0.35, cy - hh * 0.25, cx - hw * 0.50, cy - hh * 0.05)
          ..close();
        canvas.drawPath(hair, fillHair);
        canvas.drawPath(hair, line);
        break;

      case 1: // Soft Waves / Curls
        final curls = Path()
          ..moveTo(cx - hw * 0.50, cy - hh * 0.05)
          ..quadraticBezierTo(cx - hw * 0.54, cy - hh * 0.56, cx - hw * 0.20, cy - hh * 0.62)
          ..quadraticBezierTo(cx, cy - hh * 0.66, cx + hw * 0.20, cy - hh * 0.62)
          ..quadraticBezierTo(cx + hw * 0.54, cy - hh * 0.56, cx + hw * 0.50, cy - hh * 0.05)
          ..quadraticBezierTo(cx + hw * 0.25, cy - hh * 0.30, cx, cy - hh * 0.32)
          ..quadraticBezierTo(cx - hw * 0.25, cy - hh * 0.30, cx - hw * 0.50, cy - hh * 0.05)
          ..close();
        canvas.drawPath(curls, fillHair);
        canvas.drawPath(curls, line);
        break;

      case 2: // Top Bun
        final base = Path()
          ..moveTo(cx - hw * 0.50, cy - hh * 0.08)
          ..quadraticBezierTo(cx - hw * 0.50, cy - hh * 0.58, cx, cy - hh * 0.58)
          ..quadraticBezierTo(cx + hw * 0.50, cy - hh * 0.58, cx + hw * 0.50, cy - hh * 0.08)
          ..quadraticBezierTo(cx, cy - hh * 0.36, cx - hw * 0.50, cy - hh * 0.08)
          ..close();
        canvas.drawPath(base, fillHair);
        canvas.drawPath(base, line);
        final bunRect = Rect.fromCenter(center: Offset(cx, cy - hh * 0.68), width: w * 0.16, height: h * 0.13);
        canvas.drawOval(bunRect, fillHair);
        canvas.drawOval(bunRect, line);
        break;

      case 3: // Sleek Bob Cut
        final bob = Path()
          ..moveTo(cx - hw * 0.52, cy + hh * 0.20)
          ..lineTo(cx - hw * 0.50, cy - hh * 0.30)
          ..quadraticBezierTo(cx - hw * 0.50, cy - hh * 0.58, cx, cy - hh * 0.58)
          ..quadraticBezierTo(cx + hw * 0.50, cy - hh * 0.58, cx + hw * 0.50, cy - hh * 0.30)
          ..lineTo(cx + hw * 0.52, cy + hh * 0.20)
          ..quadraticBezierTo(cx + hw * 0.40, cy - hh * 0.10, cx + hw * 0.36, cy - hh * 0.28)
          ..quadraticBezierTo(cx, cy - hh * 0.35, cx - hw * 0.36, cy - hh * 0.28)
          ..quadraticBezierTo(cx - hw * 0.40, cy - hh * 0.10, cx - hw * 0.52, cy + hh * 0.20)
          ..close();
        canvas.drawPath(bob, fillHair);
        canvas.drawPath(bob, line);
        break;

      case 4: // Fringe
        final fringe = Path()
          ..moveTo(cx - hw * 0.50, cy - hh * 0.10)
          ..quadraticBezierTo(cx - hw * 0.50, cy - hh * 0.58, cx, cy - hh * 0.58)
          ..quadraticBezierTo(cx + hw * 0.50, cy - hh * 0.58, cx + hw * 0.50, cy - hh * 0.10)
          ..lineTo(cx + hw * 0.32, cy - hh * 0.24)
          ..lineTo(cx + hw * 0.14, cy - hh * 0.20)
          ..lineTo(cx - hw * 0.08, cy - hh * 0.25)
          ..lineTo(cx - hw * 0.30, cy - hh * 0.20)
          ..close();
        canvas.drawPath(fringe, fillHair);
        canvas.drawPath(fringe, line);
        break;

      case 5: // Beanie
        final beanie = Path()
          ..moveTo(cx - hw * 0.52, cy - hh * 0.25)
          ..quadraticBezierTo(cx, cy - hh * 0.72, cx + hw * 0.52, cy - hh * 0.25)
          ..close();
        canvas.drawPath(beanie, fillHair);
        canvas.drawPath(beanie, line);
        final rim = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy - hh * 0.25), width: hw * 1.10, height: h * 0.08),
          Radius.circular(w * 0.03),
        );
        canvas.drawRRect(rim, fillSkin);
        canvas.drawRRect(rim, line);
        break;

      case 7: // High Ponytail (Gracefully contained, NO exceeding boundary!)
        final basePony = Path()
          ..moveTo(cx - hw * 0.50, cy - hh * 0.05)
          ..quadraticBezierTo(cx - hw * 0.50, cy - hh * 0.58, cx, cy - hh * 0.58)
          ..quadraticBezierTo(cx + hw * 0.50, cy - hh * 0.58, cx + hw * 0.50, cy - hh * 0.05)
          ..quadraticBezierTo(cx, cy - hh * 0.34, cx - hw * 0.50, cy - hh * 0.05)
          ..close();
        canvas.drawPath(basePony, fillHair);
        canvas.drawPath(basePony, line);
        final pony = Path()
          ..moveTo(cx + hw * 0.38, cy - hh * 0.45)
          ..quadraticBezierTo(cx + w * 0.25, cy - hh * 0.25, cx + w * 0.23, cy + hh * 0.10)
          ..quadraticBezierTo(cx + w * 0.18, cy - hh * 0.05, cx + hw * 0.32, cy - hh * 0.30)
          ..close();
        canvas.drawPath(pony, fillHair);
        canvas.drawPath(pony, line);
        break;

      case 6: // Buzzcut / Clean Crop
      default:
        final buzz = Path()
          ..moveTo(cx - hw * 0.49, cy - hh * 0.15)
          ..quadraticBezierTo(cx - hw * 0.50, cy - hh * 0.54, cx, cy - hh * 0.54)
          ..quadraticBezierTo(cx + hw * 0.50, cy - hh * 0.54, cx + hw * 0.49, cy - hh * 0.15)
          ..quadraticBezierTo(cx + hw * 0.30, cy - hh * 0.36, cx, cy - hh * 0.36)
          ..quadraticBezierTo(cx - hw * 0.30, cy - hh * 0.36, cx - hw * 0.49, cy - hh * 0.15)
          ..close();
        canvas.drawPath(buzz, fillHair);
        canvas.drawPath(buzz, line);
        break;
    }
  }

  void _drawEyes(Canvas canvas, double cx, double cy, double hw, double hh, double w, double h, Paint line, Paint fillHair) {
    final eyeY = cy + hh * 0.02;
    final eyeDist = w * 0.082;
    final leftX = cx - eyeDist;
    final rightX = cx + eyeDist;

    if (isBlinking && eyesStyle != 5) {
      final blinkL = Path()
        ..moveTo(leftX - w * 0.03, eyeY)
        ..quadraticBezierTo(leftX, eyeY + h * 0.015, leftX + w * 0.03, eyeY);
      final blinkR = Path()
        ..moveTo(rightX - w * 0.03, eyeY)
        ..quadraticBezierTo(rightX, eyeY + h * 0.015, rightX + w * 0.03, eyeY);
      canvas.drawPath(blinkL, line);
      canvas.drawPath(blinkR, line);
      return;
    }

    switch (eyesStyle) {
      case 0: // Round Glasses
        final glassR = w * 0.065;
        canvas.drawCircle(Offset(leftX, eyeY), glassR, line);
        canvas.drawCircle(Offset(rightX, eyeY), glassR, line);
        canvas.drawLine(Offset(leftX + glassR, eyeY), Offset(rightX - glassR, eyeY), line);
        canvas.drawCircle(Offset(leftX, eyeY), w * 0.020, fillHair);
        canvas.drawCircle(Offset(rightX, eyeY), w * 0.020, fillHair);
        break;

      case 2: // Square Wireframe Glasses
        final rL = Rect.fromCenter(center: Offset(leftX, eyeY), width: w * 0.13, height: h * 0.09);
        final rR = Rect.fromCenter(center: Offset(rightX, eyeY), width: w * 0.13, height: h * 0.09);
        canvas.drawRRect(RRect.fromRectAndRadius(rL, Radius.circular(w * 0.02)), line);
        canvas.drawRRect(RRect.fromRectAndRadius(rR, Radius.circular(w * 0.02)), line);
        canvas.drawLine(Offset(rL.right, eyeY), Offset(rR.left, eyeY), line);
        canvas.drawCircle(Offset(leftX, eyeY), w * 0.020, fillHair);
        canvas.drawCircle(Offset(rightX, eyeY), w * 0.020, fillHair);
        break;

      case 3: // Wink
        canvas.drawCircle(Offset(leftX, eyeY), w * 0.024, fillHair);
        final wink = Path()
          ..moveTo(rightX - w * 0.035, eyeY)
          ..quadraticBezierTo(rightX, eyeY + h * 0.015, rightX + w * 0.035, eyeY);
        canvas.drawPath(wink, line);
        canvas.drawLine(Offset(leftX - w * 0.03, eyeY - h * 0.04), Offset(leftX + w * 0.03, eyeY - h * 0.045), line);
        break;

      case 4: // Friendly Smile Squint
        final smileL = Path()
          ..moveTo(leftX - w * 0.035, eyeY + h * 0.005)
          ..quadraticBezierTo(leftX, eyeY - h * 0.015, leftX + w * 0.035, eyeY + h * 0.005);
        final smileR = Path()
          ..moveTo(rightX - w * 0.035, eyeY + h * 0.005)
          ..quadraticBezierTo(rightX, eyeY - h * 0.015, rightX + w * 0.035, eyeY + h * 0.005);
        canvas.drawPath(smileL, line);
        canvas.drawPath(smileR, line);
        break;

      case 5: // Shades
        final sL = Rect.fromCenter(center: Offset(leftX, eyeY), width: w * 0.14, height: h * 0.09);
        final sR = Rect.fromCenter(center: Offset(rightX, eyeY), width: w * 0.14, height: h * 0.09);
        canvas.drawRRect(RRect.fromRectAndRadius(sL, Radius.circular(w * 0.02)), fillHair);
        canvas.drawRRect(RRect.fromRectAndRadius(sR, Radius.circular(w * 0.02)), fillHair);
        canvas.drawLine(Offset(sL.right, eyeY), Offset(sR.left, eyeY), line);
        break;

      case 1: // Clean Dots & Brows
      default:
        canvas.drawCircle(Offset(leftX, eyeY), w * 0.024, fillHair);
        canvas.drawCircle(Offset(rightX, eyeY), w * 0.024, fillHair);
        canvas.drawLine(Offset(leftX - w * 0.03, eyeY - h * 0.042), Offset(leftX + w * 0.03, eyeY - h * 0.042), line);
        canvas.drawLine(Offset(rightX - w * 0.03, eyeY - h * 0.042), Offset(rightX + w * 0.03, eyeY - h * 0.042), line);
        break;
    }
  }

  void _drawNose(Canvas canvas, double cx, double cy, double hh, double w, Paint line) {
    final nose = Path()
      ..moveTo(cx, cy + hh * 0.05)
      ..lineTo(cx, cy + hh * 0.16)
      ..lineTo(cx + w * 0.032, cy + hh * 0.16);
    canvas.drawPath(nose, line);
  }

  void _drawMouth(Canvas canvas, double cx, double cy, double hh, double w, double h, Paint line, Paint fillSkin, Paint fillHair) {
    final mouthY = cy + hh * 0.28;
    final mw = w * 0.065;

    switch (mouthStyle) {
      case 1: // Open Smile (Contoured Stroke, never a solid black cavern)
        final openSmile = Path()
          ..moveTo(cx - mw, mouthY)
          ..quadraticBezierTo(cx, mouthY + h * 0.030, cx + mw, mouthY)
          ..quadraticBezierTo(cx, mouthY + h * 0.010, cx - mw, mouthY)
          ..close();
        canvas.drawPath(openSmile, fillSkin);
        canvas.drawPath(openSmile, line);
        break;

      case 2: // Focused Line
        canvas.drawLine(Offset(cx - mw * 0.8, mouthY), Offset(cx + mw * 0.8, mouthY), line);
        break;

      case 3: // Mustache
        final stache = Path()
          ..moveTo(cx, mouthY - h * 0.008)
          ..quadraticBezierTo(cx - mw * 0.5, mouthY - h * 0.02, cx - mw, mouthY + h * 0.015)
          ..quadraticBezierTo(cx - mw * 0.4, mouthY, cx, mouthY)
          ..quadraticBezierTo(cx + mw * 0.4, mouthY, cx + mw, mouthY + h * 0.015)
          ..quadraticBezierTo(cx + mw * 0.5, mouthY - h * 0.02, cx, mouthY - h * 0.008)
          ..close();
        canvas.drawPath(stache, fillHair);
        canvas.drawLine(Offset(cx - mw * 0.5, mouthY + h * 0.02), Offset(cx + mw * 0.5, mouthY + h * 0.02), line);
        break;

      case 4: // Beard Contour
        final beard = Path()
          ..moveTo(cx - mw * 1.8, mouthY - h * 0.04)
          ..quadraticBezierTo(cx, mouthY + h * 0.12, cx + mw * 1.8, mouthY - h * 0.04);
        canvas.drawPath(beard, line);
        canvas.drawCircle(Offset(cx, mouthY + h * 0.035), w * 0.018, fillHair);
        final smile = Path()
          ..moveTo(cx - mw, mouthY)
          ..quadraticBezierTo(cx, mouthY + h * 0.02, cx + mw, mouthY);
        canvas.drawPath(smile, line);
        break;

      case 0: // Subtle Smirk
      default:
        final smirk = Path()
          ..moveTo(cx - mw, mouthY)
          ..quadraticBezierTo(cx, mouthY + h * 0.022, cx + mw, mouthY - h * 0.005);
        canvas.drawPath(smirk, line);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _NotionAvatarPainter oldDelegate) {
    return oldDelegate.headShape != headShape ||
        oldDelegate.hairStyle != hairStyle ||
        oldDelegate.eyesStyle != eyesStyle ||
        oldDelegate.mouthStyle != mouthStyle ||
        oldDelegate.outfitStyle != outfitStyle ||
        oldDelegate.isDark != isDark ||
        oldDelegate.isBlinking != isBlinking;
  }
}

