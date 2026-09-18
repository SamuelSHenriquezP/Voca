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
  }) : headShape = head ?? headShape,
       hairStyle = hair ?? hairStyle,
       eyesStyle = eyes ?? eyesStyle,
       mouthStyle = mouth ?? mouthStyle,
       outfitStyle = outfit ?? outfitStyle,
       backdropIndex = backdrop ?? backdropIndex;

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
                  color: isDarkBackdrop ? const Color(0xFF3F3F46) : const Color(0xFF18181B),
                  width: s > 50 ? 2.4 : 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    offset: const Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
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

    final strokeColor = isDark ? Colors.white : const Color(0xFF18181B);
    final fillSkinColor = isDark ? const Color(0xFF27272A) : Colors.white;

    final line = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.8, w * 0.034)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillSkin = Paint()
      ..color = fillSkinColor
      ..style = PaintingStyle.fill;

    final fillDark = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.fill;

    // 1. OUTFIT / TORSO (Behind head)
    _drawOutfit(canvas, size, line, fillSkin, fillDark);

    // 2. HEAD & EARS
    _drawHeadAndEars(canvas, size, line, fillSkin);

    // 3. HAIR
    _drawHair(canvas, size, line, fillDark, fillSkin);

    // 4. EYES & GLASSES
    _drawEyes(canvas, size, line, fillDark);

    // 5. NOSE
    _drawNose(canvas, size, line);

    // 6. MOUTH & FACIAL HAIR
    _drawMouth(canvas, size, line, fillDark);
  }

  // =========================================================================
  // 1. OUTFIT / SHOULDERS
  // =========================================================================
  void _drawOutfit(Canvas canvas, Size size, Paint line, Paint fillSkin, Paint fillDark) {
    final w = size.width;
    final h = size.height;

    final bodyPath = Path()
      ..moveTo(w * 0.12, h)
      ..lineTo(w * 0.88, h)
      ..lineTo(w * 0.82, h * 0.80)
      ..quadraticBezierTo(w * 0.5, h * 0.85, w * 0.18, h * 0.80)
      ..close();

    canvas.drawPath(bodyPath, fillSkin);
    canvas.drawPath(bodyPath, line);

    switch (outfitStyle) {
      case 0: // Turtleneck (Classic Notion)
        final neckPath = Path()
          ..moveTo(w * 0.36, h * 0.82)
          ..lineTo(w * 0.36, h * 0.68)
          ..quadraticBezierTo(w * 0.50, h * 0.70, w * 0.64, h * 0.68)
          ..lineTo(w * 0.64, h * 0.82)
          ..close();
        canvas.drawPath(neckPath, fillSkin);
        canvas.drawPath(neckPath, line);

        // Turtleneck rib folds
        canvas.drawLine(Offset(w * 0.38, h * 0.74), Offset(w * 0.62, h * 0.74), line);
        break;

      case 1: // Hoodie
        final hoodLeft = Path()
          ..moveTo(w * 0.28, h * 0.80)
          ..quadraticBezierTo(w * 0.36, h * 0.66, w * 0.44, h * 0.80);
        final hoodRight = Path()
          ..moveTo(w * 0.56, h * 0.80)
          ..quadraticBezierTo(w * 0.64, h * 0.66, w * 0.72, h * 0.80);
        canvas.drawPath(hoodLeft, line);
        canvas.drawPath(hoodRight, line);
        // Drawstrings
        canvas.drawLine(Offset(w * 0.46, h * 0.82), Offset(w * 0.46, h * 0.94), line);
        canvas.drawLine(Offset(w * 0.54, h * 0.82), Offset(w * 0.54, h * 0.94), line);
        break;

      case 2: // Collared button-up
        final collarLeft = Path()
          ..moveTo(w * 0.50, h * 0.78)
          ..lineTo(w * 0.34, h * 0.74)
          ..lineTo(w * 0.44, h * 0.84)
          ..close();
        final collarRight = Path()
          ..moveTo(w * 0.50, h * 0.78)
          ..lineTo(w * 0.66, h * 0.74)
          ..lineTo(w * 0.56, h * 0.84)
          ..close();
        canvas.drawPath(collarLeft, fillSkin);
        canvas.drawPath(collarLeft, line);
        canvas.drawPath(collarRight, fillSkin);
        canvas.drawPath(collarRight, line);
        // Placket line
        canvas.drawLine(Offset(w * 0.50, h * 0.84), Offset(w * 0.50, h), line);
        break;

      case 4: // Scarf
        final scarfPath = Path()
          ..moveTo(w * 0.30, h * 0.76)
          ..quadraticBezierTo(w * 0.50, h * 0.85, w * 0.70, h * 0.76)
          ..quadraticBezierTo(w * 0.75, h * 0.88, w * 0.50, h * 0.90)
          ..quadraticBezierTo(w * 0.25, h * 0.88, w * 0.30, h * 0.76)
          ..close();
        canvas.drawPath(scarfPath, fillDark);
        // Scarf tail hanging
        final tail = Path()
          ..moveTo(w * 0.54, h * 0.88)
          ..lineTo(w * 0.62, h * 0.88)
          ..lineTo(w * 0.60, h)
          ..lineTo(w * 0.52, h)
          ..close();
        canvas.drawPath(tail, fillDark);
        break;

      case 3: // Crewneck T-shirt
      default:
        final crewCollar = Path()
          ..moveTo(w * 0.38, h * 0.75)
          ..quadraticBezierTo(w * 0.50, h * 0.83, w * 0.62, h * 0.75);
        canvas.drawPath(crewCollar, line);
        break;
    }
  }

  // =========================================================================
  // 2. HEAD & EARS
  // =========================================================================
  void _drawHeadAndEars(Canvas canvas, Size size, Paint line, Paint fillSkin) {
    final w = size.width;
    final h = size.height;

    // Ears
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.25, h * 0.50), width: w * 0.08, height: h * 0.12), fillSkin);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.25, h * 0.50), width: w * 0.08, height: h * 0.12), line);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.75, h * 0.50), width: w * 0.08, height: h * 0.12), fillSkin);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.75, h * 0.50), width: w * 0.08, height: h * 0.12), line);

    // Inner ear lines
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.25, h * 0.50), width: w * 0.04, height: h * 0.06), math.pi * 0.5, math.pi, false, line);
    canvas.drawArc(Rect.fromCenter(center: Offset(w * 0.75, h * 0.50), width: w * 0.04, height: h * 0.06), -math.pi * 0.5, math.pi, false, line);

    Path headPath;
    switch (headShape) {
      case 1: // Square Jaw
        headPath = Path()
          ..moveTo(w * 0.30, h * 0.28)
          ..quadraticBezierTo(w * 0.50, h * 0.22, w * 0.70, h * 0.28)
          ..lineTo(w * 0.72, h * 0.58)
          ..quadraticBezierTo(w * 0.68, h * 0.74, w * 0.50, h * 0.74)
          ..quadraticBezierTo(w * 0.32, h * 0.74, w * 0.28, h * 0.58)
          ..close();
        break;

      case 2: // Round / Cute
        headPath = Path()
          ..addOval(Rect.fromCenter(center: Offset(w * 0.50, h * 0.50), width: w * 0.52, height: h * 0.48));
        break;

      case 3: // Oblong
        headPath = Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(w * 0.50, h * 0.49), width: w * 0.44, height: h * 0.52),
            Radius.circular(w * 0.20),
          ));
        break;

      case 0: // Classic Oval
      default:
        headPath = Path()
          ..addOval(Rect.fromCenter(center: Offset(w * 0.50, h * 0.49), width: w * 0.47, height: h * 0.50));
        break;
    }

    canvas.drawPath(headPath, fillSkin);
    canvas.drawPath(headPath, line);
  }

  // =========================================================================
  // 3. HAIR (Minimalist Notion Ink Silhouette)
  // =========================================================================
  void _drawHair(Canvas canvas, Size size, Paint line, Paint fillDark, Paint fillSkin) {
    final w = size.width;
    final h = size.height;

    switch (hairStyle) {
      case 0: // Classic Side Part (Notion signature)
        final hair = Path()
          ..moveTo(w * 0.26, h * 0.46)
          ..quadraticBezierTo(w * 0.24, h * 0.22, w * 0.50, h * 0.20)
          ..quadraticBezierTo(w * 0.76, h * 0.22, w * 0.74, h * 0.46)
          ..quadraticBezierTo(w * 0.62, h * 0.32, w * 0.44, h * 0.32)
          ..quadraticBezierTo(w * 0.32, h * 0.36, w * 0.26, h * 0.46)
          ..close();
        canvas.drawPath(hair, fillDark);
        canvas.drawPath(hair, line);
        break;

      case 1: // Messy Curls / Afro
        final curls = Path()
          ..moveTo(w * 0.24, h * 0.48)
          ..arcToPoint(Offset(w * 0.26, h * 0.32), radius: Radius.circular(w * 0.10))
          ..arcToPoint(Offset(w * 0.38, h * 0.20), radius: Radius.circular(w * 0.10))
          ..arcToPoint(Offset(w * 0.56, h * 0.18), radius: Radius.circular(w * 0.10))
          ..arcToPoint(Offset(w * 0.72, h * 0.26), radius: Radius.circular(w * 0.10))
          ..arcToPoint(Offset(w * 0.76, h * 0.48), radius: Radius.circular(w * 0.10))
          ..quadraticBezierTo(w * 0.50, h * 0.34, w * 0.24, h * 0.48)
          ..close();
        canvas.drawPath(curls, fillDark);
        canvas.drawPath(curls, line);
        break;

      case 2: // Top Bun
        // Base hair
        final base = Path()
          ..moveTo(w * 0.26, h * 0.44)
          ..quadraticBezierTo(w * 0.28, h * 0.22, w * 0.50, h * 0.22)
          ..quadraticBezierTo(w * 0.72, h * 0.22, w * 0.74, h * 0.44)
          ..quadraticBezierTo(w * 0.50, h * 0.32, w * 0.26, h * 0.44)
          ..close();
        canvas.drawPath(base, fillDark);
        canvas.drawPath(base, line);

        // Bun on top
        final bun = Path()
          ..addOval(Rect.fromCenter(center: Offset(w * 0.50, h * 0.16), width: w * 0.18, height: h * 0.14));
        canvas.drawPath(bun, fillDark);
        canvas.drawPath(bun, line);
        break;

      case 3: // Bob Cut / Shoulder Length
        final bob = Path()
          ..moveTo(w * 0.22, h * 0.62)
          ..lineTo(w * 0.24, h * 0.38)
          ..quadraticBezierTo(w * 0.26, h * 0.20, w * 0.50, h * 0.20)
          ..quadraticBezierTo(w * 0.74, h * 0.20, w * 0.76, h * 0.38)
          ..lineTo(w * 0.78, h * 0.62)
          ..quadraticBezierTo(w * 0.72, h * 0.52, w * 0.68, h * 0.38)
          ..quadraticBezierTo(w * 0.50, h * 0.34, w * 0.32, h * 0.38)
          ..quadraticBezierTo(w * 0.28, h * 0.52, w * 0.22, h * 0.62)
          ..close();
        canvas.drawPath(bob, fillDark);
        canvas.drawPath(bob, line);
        break;

      case 4: // Modern Messy Fringe
        final fringe = Path()
          ..moveTo(w * 0.26, h * 0.44)
          ..quadraticBezierTo(w * 0.24, h * 0.20, w * 0.50, h * 0.18)
          ..quadraticBezierTo(w * 0.76, h * 0.20, w * 0.74, h * 0.44)
          ..lineTo(w * 0.64, h * 0.34)
          ..lineTo(w * 0.56, h * 0.40)
          ..lineTo(w * 0.48, h * 0.32)
          ..lineTo(w * 0.38, h * 0.40)
          ..close();
        canvas.drawPath(fringe, fillDark);
        canvas.drawPath(fringe, line);
        break;

      case 5: // Beanie Cap
        final beanie = Path()
          ..moveTo(w * 0.22, h * 0.38)
          ..quadraticBezierTo(w * 0.26, h * 0.14, w * 0.50, h * 0.13)
          ..quadraticBezierTo(w * 0.74, h * 0.14, w * 0.78, h * 0.38)
          ..close();
        canvas.drawPath(beanie, fillDark);
        canvas.drawPath(beanie, line);
        // Beanie folded rim
        final rim = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(w * 0.50, h * 0.37), width: w * 0.56, height: h * 0.08),
          Radius.circular(w * 0.03),
        );
        canvas.drawRRect(rim, fillSkin);
        canvas.drawRRect(rim, line);
        break;

      case 7: // Ponytail
        // Base hair
        final basePony = Path()
          ..moveTo(w * 0.26, h * 0.44)
          ..quadraticBezierTo(w * 0.28, h * 0.22, w * 0.50, h * 0.22)
          ..quadraticBezierTo(w * 0.72, h * 0.22, w * 0.74, h * 0.44)
          ..quadraticBezierTo(w * 0.50, h * 0.34, w * 0.26, h * 0.44)
          ..close();
        canvas.drawPath(basePony, fillDark);
        canvas.drawPath(basePony, line);
        // Ponytail swoosh to the side
        final ponySwoosh = Path()
          ..moveTo(w * 0.70, h * 0.32)
          ..quadraticBezierTo(w * 0.90, h * 0.36, w * 0.88, h * 0.58)
          ..quadraticBezierTo(w * 0.82, h * 0.50, w * 0.72, h * 0.42)
          ..close();
        canvas.drawPath(ponySwoosh, fillDark);
        canvas.drawPath(ponySwoosh, line);
        break;

      case 6: // Buzzcut / Clean
      default:
        // Subtle dotted texture or minimalist crop line
        canvas.drawArc(
          Rect.fromCenter(center: Offset(w * 0.50, h * 0.38), width: w * 0.46, height: h * 0.30),
          math.pi * 0.85,
          math.pi * 1.3,
          false,
          line,
        );
        break;
    }
  }

  // =========================================================================
  // 4. EYES & GLASSES
  // =========================================================================
  void _drawEyes(Canvas canvas, Size size, Paint line, Paint fillDark) {
    final w = size.width;
    final h = size.height;

    final eyeY = h * 0.48;
    final leftX = w * 0.42;
    final rightX = w * 0.58;

    if (isBlinking && eyesStyle != 5) {
      // Cute blinking closed eyelid arcs
      final blinkLeft = Path()
        ..moveTo(leftX - (w * 0.035), eyeY)
        ..quadraticBezierTo(leftX, eyeY - (h * 0.02), leftX + (w * 0.035), eyeY);
      final blinkRight = Path()
        ..moveTo(rightX - (w * 0.035), eyeY)
        ..quadraticBezierTo(rightX, eyeY - (h * 0.02), rightX + (w * 0.035), eyeY);
      canvas.drawPath(blinkLeft, line);
      canvas.drawPath(blinkRight, line);
      return;
    }

    switch (eyesStyle) {
      case 0: // Iconic Notion Round Glasses
        final glassR = w * 0.075;
        // Lenses
        canvas.drawCircle(Offset(leftX, eyeY), glassR, line);
        canvas.drawCircle(Offset(rightX, eyeY), glassR, line);
        // Bridge
        canvas.drawLine(Offset(leftX + glassR, eyeY), Offset(rightX - glassR, eyeY), line);
        // Temples
        canvas.drawLine(Offset(leftX - glassR, eyeY), Offset(w * 0.28, eyeY - (h * 0.01)), line);
        canvas.drawLine(Offset(rightX + glassR, eyeY), Offset(w * 0.72, eyeY - (h * 0.01)), line);
        // Eyes inside
        canvas.drawCircle(Offset(leftX, eyeY), w * 0.022, fillDark);
        canvas.drawCircle(Offset(rightX, eyeY), w * 0.022, fillDark);
        break;

      case 2: // Square Wireframe Glasses
        final rectL = Rect.fromCenter(center: Offset(leftX, eyeY), width: w * 0.15, height: h * 0.11);
        final rectR = Rect.fromCenter(center: Offset(rightX, eyeY), width: w * 0.15, height: h * 0.11);
        canvas.drawRRect(RRect.fromRectAndRadius(rectL, Radius.circular(w * 0.02)), line);
        canvas.drawRRect(RRect.fromRectAndRadius(rectR, Radius.circular(w * 0.02)), line);
        canvas.drawLine(Offset(rectL.right, eyeY), Offset(rectR.left, eyeY), line);
        canvas.drawCircle(Offset(leftX, eyeY), w * 0.022, fillDark);
        canvas.drawCircle(Offset(rightX, eyeY), w * 0.022, fillDark);
        break;

      case 3: // Wink Eye
        // Left eye: open dot with brow
        canvas.drawCircle(Offset(leftX, eyeY), w * 0.028, fillDark);
        // Right eye: wink arc
        final wink = Path()
          ..moveTo(rightX - (w * 0.04), eyeY)
          ..quadraticBezierTo(rightX, eyeY - (h * 0.025), rightX + (w * 0.04), eyeY);
        canvas.drawPath(wink, line);
        // Eyebrows
        canvas.drawLine(Offset(leftX - (w * 0.03), eyeY - (h * 0.04)), Offset(leftX + (w * 0.03), eyeY - (h * 0.045)), line);
        break;

      case 4: // Gentle Smile Squints
        final leftSmile = Path()
          ..moveTo(leftX - (w * 0.04), eyeY)
          ..quadraticBezierTo(leftX, eyeY - (h * 0.02), leftX + (w * 0.04), eyeY);
        final rightSmile = Path()
          ..moveTo(rightX - (w * 0.04), eyeY)
          ..quadraticBezierTo(rightX, eyeY - (h * 0.02), rightX + (w * 0.04), eyeY);
        canvas.drawPath(leftSmile, line);
        canvas.drawPath(rightSmile, line);
        break;

      case 5: // Dark Sunglasses
        final shadesL = Rect.fromCenter(center: Offset(leftX, eyeY), width: w * 0.16, height: h * 0.10);
        final shadesR = Rect.fromCenter(center: Offset(rightX, eyeY), width: w * 0.16, height: h * 0.10);
        canvas.drawRRect(RRect.fromRectAndRadius(shadesL, Radius.circular(w * 0.02)), fillDark);
        canvas.drawRRect(RRect.fromRectAndRadius(shadesR, Radius.circular(w * 0.02)), fillDark);
        canvas.drawLine(Offset(shadesL.right, eyeY), Offset(shadesR.left, eyeY), line);
        break;

      case 1: // Focused Dot Eyes & Brows
      default:
        canvas.drawCircle(Offset(leftX, eyeY), w * 0.028, fillDark);
        canvas.drawCircle(Offset(rightX, eyeY), w * 0.028, fillDark);
        // Eyebrows
        canvas.drawLine(Offset(leftX - (w * 0.03), eyeY - (h * 0.045)), Offset(leftX + (w * 0.03), eyeY - (h * 0.045)), line);
        canvas.drawLine(Offset(rightX - (w * 0.03), eyeY - (h * 0.045)), Offset(rightX + (w * 0.03), eyeY - (h * 0.045)), line);
        break;
    }
  }

  // =========================================================================
  // 5. NOSE
  // =========================================================================
  void _drawNose(Canvas canvas, Size size, Paint line) {
    final w = size.width;
    final h = size.height;

    // Classic Notion L-shaped nose
    final nose = Path()
      ..moveTo(w * 0.50, h * 0.50)
      ..lineTo(w * 0.50, h * 0.56)
      ..lineTo(w * 0.54, h * 0.56);
    canvas.drawPath(nose, line);
  }

  // =========================================================================
  // 6. MOUTH & FACIAL HAIR
  // =========================================================================
  void _drawMouth(Canvas canvas, Size size, Paint line, Paint fillDark) {
    final w = size.width;
    final h = size.height;
    final mouthY = h * 0.63;

    switch (mouthStyle) {
      case 1: // Warm Open Smile
        final openMouth = Path()
          ..moveTo(w * 0.44, mouthY)
          ..quadraticBezierTo(w * 0.50, mouthY + (h * 0.06), w * 0.56, mouthY)
          ..close();
        canvas.drawPath(openMouth, fillDark);
        break;

      case 2: // Focused / Straight line
        canvas.drawLine(Offset(w * 0.45, mouthY + (h * 0.01)), Offset(w * 0.55, mouthY + (h * 0.01)), line);
        break;

      case 3: // Intellectual Mustache
        final stache = Path()
          ..moveTo(w * 0.50, mouthY - (h * 0.01))
          ..quadraticBezierTo(w * 0.44, mouthY - (h * 0.03), w * 0.40, mouthY + (h * 0.02))
          ..quadraticBezierTo(w * 0.46, mouthY, w * 0.50, mouthY)
          ..quadraticBezierTo(w * 0.54, mouthY, w * 0.60, mouthY + (h * 0.02))
          ..quadraticBezierTo(w * 0.56, mouthY - (h * 0.03), w * 0.50, mouthY - (h * 0.01))
          ..close();
        canvas.drawPath(stache, fillDark);
        // Small smile under
        canvas.drawLine(Offset(w * 0.47, mouthY + (h * 0.03)), Offset(w * 0.53, mouthY + (h * 0.03)), line);
        break;

      case 4: // Neat Beard Outline
        final beard = Path()
          ..moveTo(w * 0.36, h * 0.56)
          ..quadraticBezierTo(w * 0.36, h * 0.72, w * 0.50, h * 0.73)
          ..quadraticBezierTo(w * 0.64, h * 0.72, w * 0.64, h * 0.56);
        canvas.drawPath(beard, line);
        // Goatee / soul patch
        canvas.drawCircle(Offset(w * 0.50, mouthY + (h * 0.04)), w * 0.018, fillDark);
        // Smile
        final smile = Path()
          ..moveTo(w * 0.45, mouthY)
          ..quadraticBezierTo(w * 0.50, mouthY + (h * 0.03), w * 0.55, mouthY);
        canvas.drawPath(smile, line);
        break;

      case 0: // Subtle Smirk
      default:
        final smirk = Path()
          ..moveTo(w * 0.45, mouthY)
          ..quadraticBezierTo(w * 0.51, mouthY + (h * 0.03), w * 0.56, mouthY - (h * 0.005));
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
