import 'dart:math' as math;
import 'package:flutter/material.dart';

enum AdventureArchetype {
  finn,
  jake,
  bmo,
  marceline,
  princess,
}

class AdventureCartoonAvatar extends StatefulWidget {
  final AdventureArchetype archetype;
  final double size;
  final Color? customColor;
  final String expression; // 'happy', 'wink', 'determined', 'surprised', 'sweat', 'victory'
  final bool isAnimated;
  final VoidCallback? onTap;

  const AdventureCartoonAvatar({
    super.key,
    required this.archetype,
    this.size = 80,
    this.customColor,
    this.expression = 'happy',
    this.isAnimated = true,
    this.onTap,
  });

  factory AdventureCartoonAvatar.fromName(
    String name, {
    double size = 80,
    Color? customColor,
    String expression = 'happy',
    bool isAnimated = true,
    VoidCallback? onTap,
  }) {
    final lower = name.toLowerCase();
    AdventureArchetype arch = AdventureArchetype.finn;
    if (lower.contains('jake') || lower.contains('perro') || lower.contains('dog')) {
      arch = AdventureArchetype.jake;
    } else if (lower.contains('bmo') || lower.contains('robot') || lower.contains('consola')) {
      arch = AdventureArchetype.bmo;
    } else if (lower.contains('marceline') || lower.contains('vampire') || lower.contains('rock')) {
      arch = AdventureArchetype.marceline;
    } else if (lower.contains('princess') || lower.contains('princesa') || lower.contains('bubblegum') || lower.contains('chicle')) {
      arch = AdventureArchetype.princess;
    }
    return AdventureCartoonAvatar(
      archetype: arch,
      size: size,
      customColor: customColor,
      expression: expression,
      isAnimated: isAnimated,
      onTap: onTap,
    );
  }

  @override
  State<AdventureCartoonAvatar> createState() => _AdventureCartoonAvatarState();
}

class _AdventureCartoonAvatarState extends State<AdventureCartoonAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.isAnimated) {
      _anim.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AdventureCartoonAvatar oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    final s = widget.size;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, child) {
          final t = _anim.value;
          // Gentle cartoon breathing squash & stretch
          final scaleY = widget.isAnimated ? 1.0 + (math.sin(t * math.pi) * 0.035) : 1.0;
          final scaleX = widget.isAnimated ? 1.0 - (math.sin(t * math.pi) * 0.02) : 1.0;
          final bounceY = widget.expression == 'victory'
              ? -math.sin(t * math.pi * 2).abs() * (s * 0.08)
              : 0.0;

          return Transform.translate(
            offset: Offset(0, bounceY),
            child: Transform.scale(
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
                    color: const Color(0xFF0F172A),
                    width: s > 60 ? 3.0 : 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      offset: const Offset(0, 4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: CustomPaint(
                    size: Size(s, s),
                    painter: _AdventureTimePainter(
                      archetype: widget.archetype,
                      customColor: widget.customColor,
                      expression: widget.expression,
                      animT: t,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getBackdropColor() {
    switch (widget.archetype) {
      case AdventureArchetype.finn:
        return const Color(0xFFE0F2FE); // Soft sky cyan
      case AdventureArchetype.jake:
        return const Color(0xFFFEF3C7); // Warm butter yellow
      case AdventureArchetype.bmo:
        return const Color(0xFFCCFBF1); // Mint teal
      case AdventureArchetype.marceline:
        return const Color(0xFFEDE9FE); // Pastel lavender
      case AdventureArchetype.princess:
        return const Color(0xFFFCE7F3); // Bubblegum pink
    }
  }
}

class _AdventureTimePainter extends CustomPainter {
  final AdventureArchetype archetype;
  final Color? customColor;
  final String expression;
  final double animT;

  _AdventureTimePainter({
    required this.archetype,
    this.customColor,
    required this.expression,
    required this.animT,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final c = Offset(w / 2, h / 2);

    final linePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.2, w * 0.038)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()..style = PaintingStyle.fill;

    switch (archetype) {
      case AdventureArchetype.finn:
        _drawFinn(canvas, size, c, linePaint, fillPaint);
        break;
      case AdventureArchetype.jake:
        _drawJake(canvas, size, c, linePaint, fillPaint);
        break;
      case AdventureArchetype.bmo:
        _drawBmo(canvas, size, c, linePaint, fillPaint);
        break;
      case AdventureArchetype.marceline:
        _drawMarceline(canvas, size, c, linePaint, fillPaint);
        break;
      case AdventureArchetype.princess:
        _drawPrincess(canvas, size, c, linePaint, fillPaint);
        break;
    }
  }

  // =========================================================================
  // 1. FINN EL AVENTURERO (Iconic bear-ear hat, blue tee, green backpack)
  // =========================================================================
  void _drawFinn(Canvas canvas, Size size, Offset c, Paint line, Paint fill) {
    final w = size.width;
    final h = size.height;

    // Body / Shirt (Cyan #38BDF8)
    fill.color = customColor ?? const Color(0xFF38BDF8);
    final shirtPath = Path()
      ..moveTo(w * 0.15, h)
      ..lineTo(w * 0.85, h)
      ..lineTo(w * 0.82, h * 0.74)
      ..quadraticBezierTo(w * 0.5, h * 0.78, w * 0.18, h * 0.74)
      ..close();
    canvas.drawPath(shirtPath, fill);
    canvas.drawPath(shirtPath, line);

    // Green backpack strap (#22C55E)
    fill.color = const Color(0xFF22C55E);
    final strap = Path()
      ..moveTo(w * 0.18, h * 0.76)
      ..lineTo(w * 0.28, h * 0.76)
      ..lineTo(w * 0.22, h)
      ..lineTo(w * 0.12, h)
      ..close();
    canvas.drawPath(strap, fill);
    canvas.drawPath(strap, line);

    // Golden button on backpack
    fill.color = const Color(0xFFFACC15);
    canvas.drawCircle(Offset(w * 0.21, h * 0.83), w * 0.032, fill);
    canvas.drawCircle(Offset(w * 0.21, h * 0.83), w * 0.032, line);

    // Finn Hat - Bear Ears
    fill.color = Colors.white;
    // Left ear
    final leftEar = Path()
      ..addOval(Rect.fromCenter(center: Offset(w * 0.32, h * 0.26), width: w * 0.18, height: h * 0.22));
    canvas.drawPath(leftEar, fill);
    canvas.drawPath(leftEar, line);

    // Right ear
    final rightEar = Path()
      ..addOval(Rect.fromCenter(center: Offset(w * 0.68, h * 0.26), width: w * 0.18, height: h * 0.22));
    canvas.drawPath(rightEar, fill);
    canvas.drawPath(rightEar, line);

    // White Hat Main Hood
    final hoodRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.48), width: w * 0.66, height: h * 0.56),
      Radius.circular(w * 0.30),
    );
    canvas.drawRRect(hoodRect, fill);
    canvas.drawRRect(hoodRect, line);

    // Face Opening (Oval cut in hood)
    fill.color = const Color(0xFFFFDBB5); // Warm Finn skin
    final faceRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.52), width: w * 0.44, height: h * 0.34);
    canvas.drawOval(faceRect, fill);
    canvas.drawOval(faceRect, line);

    // Cheeks
    fill.color = const Color(0xFFFDA4AF).withOpacity(0.45);
    canvas.drawCircle(Offset(w * 0.35, h * 0.56), w * 0.035, fill);
    canvas.drawCircle(Offset(w * 0.65, h * 0.56), w * 0.035, fill);

    // Eyes & Mouth (Adventure Time classic)
    _drawClassicAdventureFace(canvas, size, Offset(w * 0.5, h * 0.50), line, fill);
  }

  // =========================================================================
  // 2. JAKE EL PERRO MÁGICO (Golden yellow, floppy jowls, big round white eyes)
  // =========================================================================
  void _drawJake(Canvas canvas, Size size, Offset c, Paint line, Paint fill) {
    final w = size.width;
    final h = size.height;

    final jakeColor = customColor ?? const Color(0xFFFBBF24);

    // Jake Main Body / Head (big soft potato shape)
    fill.color = jakeColor;
    final bodyPath = Path()
      ..moveTo(w * 0.24, h)
      ..lineTo(w * 0.76, h)
      ..cubicTo(w * 0.90, h * 0.85, w * 0.86, h * 0.25, w * 0.5, h * 0.22)
      ..cubicTo(w * 0.14, h * 0.25, w * 0.10, h * 0.85, w * 0.24, h)
      ..close();
    canvas.drawPath(bodyPath, fill);
    canvas.drawPath(bodyPath, line);

    // Floppy ears on sides
    final leftEar = Path()
      ..moveTo(w * 0.16, h * 0.38)
      ..quadraticBezierTo(w * 0.04, h * 0.50, w * 0.14, h * 0.62)
      ..close();
    canvas.drawPath(leftEar, fill);
    canvas.drawPath(leftEar, line);

    final rightEar = Path()
      ..moveTo(w * 0.84, h * 0.38)
      ..quadraticBezierTo(w * 0.96, h * 0.50, w * 0.86, h * 0.62)
      ..close();
    canvas.drawPath(rightEar, fill);
    canvas.drawPath(rightEar, line);

    // Big Jake White Eyes with thick stroke
    fill.color = Colors.white;
    final eyeRadius = w * 0.12;
    canvas.drawCircle(Offset(w * 0.38, h * 0.44), eyeRadius, fill);
    canvas.drawCircle(Offset(w * 0.38, h * 0.44), eyeRadius, line);

    canvas.drawCircle(Offset(w * 0.62, h * 0.44), eyeRadius, fill);
    canvas.drawCircle(Offset(w * 0.62, h * 0.44), eyeRadius, line);

    // Black Pupils
    fill.color = const Color(0xFF0F172A);
    final pupilOffset = expression == 'wink'
        ? Offset(w * 0.39, h * 0.44)
        : Offset(w * 0.38, h * 0.44);
    canvas.drawCircle(pupilOffset, eyeRadius * 0.52, fill);
    if (expression != 'wink') {
      canvas.drawCircle(Offset(w * 0.62, h * 0.44), eyeRadius * 0.52, fill);
    } else {
      // Winking right eye: happy line
      final winkArc = Path()
        ..moveTo(w * 0.56, h * 0.44)
        ..quadraticBezierTo(w * 0.62, h * 0.39, w * 0.68, h * 0.44);
      canvas.drawPath(winkArc, line);
    }

    // Pupil glints
    fill.color = Colors.white;
    canvas.drawCircle(Offset(w * 0.36, h * 0.42), eyeRadius * 0.16, fill);
    if (expression != 'wink') {
      canvas.drawCircle(Offset(w * 0.60, h * 0.42), eyeRadius * 0.16, fill);
    }

    // Jake's Iconic Overlapping Droopy Jowls / Snout
    fill.color = jakeColor;
    final jowls = Path()
      ..moveTo(w * 0.30, h * 0.58)
      ..cubicTo(w * 0.28, h * 0.72, w * 0.46, h * 0.76, w * 0.50, h * 0.64)
      ..cubicTo(w * 0.54, h * 0.76, w * 0.72, h * 0.72, w * 0.70, h * 0.58)
      ..cubicTo(w * 0.60, h * 0.52, w * 0.40, h * 0.52, w * 0.30, h * 0.58)
      ..close();
    canvas.drawPath(jowls, fill);
    canvas.drawPath(jowls, line);

    // Jake Nose Button
    fill.color = const Color(0xFF0F172A);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.57), width: w * 0.13, height: h * 0.08),
      fill,
    );

    // Mouth / Smile under jowls
    final mouth = Path()
      ..moveTo(w * 0.42, h * 0.73)
      ..quadraticBezierTo(w * 0.50, h * 0.82, w * 0.58, h * 0.73);
    canvas.drawPath(mouth, line);
  }

  // =========================================================================
  // 3. BMO EL ROBOT (Teal console body, digital smiling screen, d-pad, buttons)
  // =========================================================================
  void _drawBmo(Canvas canvas, Size size, Offset c, Paint line, Paint fill) {
    final w = size.width;
    final h = size.height;

    final bmoTeal = customColor ?? const Color(0xFF14B8A6);

    // BMO Main Console Body
    fill.color = bmoTeal;
    final bmoBody = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.54), width: w * 0.68, height: h * 0.78),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(bmoBody, fill);
    canvas.drawRRect(bmoBody, line);

    // Top Screen Area (Pale cyan screen)
    fill.color = const Color(0xFF99F6E4);
    final screen = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.40), width: w * 0.52, height: h * 0.36),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(screen, fill);
    canvas.drawRRect(screen, line);

    // Screen Digital Face (Classic cute BMO eyes ^ _ ^)
    fill.color = const Color(0xFF042F2E);
    if (expression == 'happy' || expression == 'victory') {
      // Happy curved squint eyes
      final leftEye = Path()
        ..moveTo(w * 0.37, h * 0.40)
        ..quadraticBezierTo(w * 0.42, h * 0.35, w * 0.47, h * 0.40);
      final rightEye = Path()
        ..moveTo(w * 0.53, h * 0.40)
        ..quadraticBezierTo(w * 0.58, h * 0.35, w * 0.63, h * 0.40);
      canvas.drawPath(leftEye, line);
      canvas.drawPath(rightEye, line);
    } else {
      canvas.drawCircle(Offset(w * 0.42, h * 0.38), w * 0.035, fill);
      canvas.drawCircle(Offset(w * 0.58, h * 0.38), w * 0.035, fill);
    }

    // Cute BMO smile
    final bmoSmile = Path()
      ..moveTo(w * 0.45, h * 0.43)
      ..quadraticBezierTo(w * 0.50, h * 0.49, w * 0.55, h * 0.43);
    canvas.drawPath(bmoSmile, line);

    // D-PAD on Bottom Left (Yellow #FACC15)
    fill.color = const Color(0xFFFACC15);
    final dpadH = Rect.fromCenter(center: Offset(w * 0.37, h * 0.72), width: w * 0.16, height: h * 0.06);
    final dpadV = Rect.fromCenter(center: Offset(w * 0.37, h * 0.72), width: w * 0.06, height: h * 0.16);
    canvas.drawRect(dpadH, fill);
    canvas.drawRect(dpadV, fill);
    canvas.drawRect(dpadH, line);
    canvas.drawRect(dpadV, line);

    // Round Buttons on Bottom Right (Blue and Red)
    fill.color = const Color(0xFF0284C7); // Blue button
    canvas.drawCircle(Offset(w * 0.62, h * 0.70), w * 0.042, fill);
    canvas.drawCircle(Offset(w * 0.62, h * 0.70), w * 0.042, line);

    fill.color = const Color(0xFFE11D48); // Red triangle/button
    canvas.drawCircle(Offset(w * 0.71, h * 0.76), w * 0.032, fill);
    canvas.drawCircle(Offset(w * 0.71, h * 0.76), w * 0.032, line);
  }

  // =========================================================================
  // 4. MARCELINE LA REINA VAMPIRO (Rockstar hair, pale lavender skin, fangs)
  // =========================================================================
  void _drawMarceline(Canvas canvas, Size size, Offset c, Paint line, Paint fill) {
    final w = size.width;
    final h = size.height;

    // Background Long Black Hair
    fill.color = const Color(0xFF09090B);
    final hairBack = Path()
      ..moveTo(w * 0.10, h)
      ..quadraticBezierTo(w * 0.04, h * 0.45, w * 0.25, h * 0.20)
      ..quadraticBezierTo(w * 0.50, h * 0.14, w * 0.75, h * 0.20)
      ..quadraticBezierTo(w * 0.96, h * 0.45, w * 0.90, h)
      ..close();
    canvas.drawPath(hairBack, fill);

    // Body / Red Flannel Collar (#BE123C)
    fill.color = const Color(0xFFBE123C);
    final body = Path()
      ..moveTo(w * 0.25, h)
      ..lineTo(w * 0.75, h)
      ..lineTo(w * 0.70, h * 0.78)
      ..lineTo(w * 0.30, h * 0.78)
      ..close();
    canvas.drawPath(body, fill);
    canvas.drawPath(body, line);

    // Pale Vampiric Skin (#E2E8F0)
    fill.color = customColor ?? const Color(0xFFE2E8F0);
    final headRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.52), width: w * 0.46, height: h * 0.48);
    canvas.drawOval(headRect, fill);
    canvas.drawOval(headRect, line);

    // Vampire Bite Marks on Neck
    fill.color = const Color(0xFFDC2626);
    canvas.drawCircle(Offset(w * 0.38, h * 0.72), w * 0.016, fill);
    canvas.drawCircle(Offset(w * 0.42, h * 0.75), w * 0.016, fill);

    // Front Rockstar Hair Bangs (Jet black)
    fill.color = const Color(0xFF09090B);
    final bangs = Path()
      ..moveTo(w * 0.20, h * 0.45)
      ..quadraticBezierTo(w * 0.30, h * 0.22, w * 0.50, h * 0.22)
      ..quadraticBezierTo(w * 0.70, h * 0.22, w * 0.80, h * 0.45)
      ..lineTo(w * 0.74, h * 0.42)
      ..quadraticBezierTo(w * 0.65, h * 0.32, w * 0.55, h * 0.38)
      ..quadraticBezierTo(w * 0.42, h * 0.30, w * 0.26, h * 0.45)
      ..close();
    canvas.drawPath(bangs, fill);
    canvas.drawPath(bangs, line);

    // Eyes and Little Fang Smile
    _drawClassicAdventureFace(canvas, size, Offset(w * 0.5, h * 0.52), line, fill, hasFang: true);
  }

  // =========================================================================
  // 5. PRINCESA DULCE / BUBBLEGUM (Pink hair, crown with cyan jewel)
  // =========================================================================
  void _drawPrincess(Canvas canvas, Size size, Offset c, Paint line, Paint fill) {
    final w = size.width;
    final h = size.height;

    // Pink Hair Backing (#F43F5E)
    fill.color = const Color(0xFFF43F5E);
    final hair = Path()
      ..moveTo(w * 0.12, h)
      ..quadraticBezierTo(w * 0.08, h * 0.35, w * 0.30, h * 0.22)
      ..quadraticBezierTo(w * 0.50, h * 0.18, w * 0.70, h * 0.22)
      ..quadraticBezierTo(w * 0.92, h * 0.35, w * 0.88, h)
      ..close();
    canvas.drawPath(hair, fill);
    canvas.drawPath(hair, line);

    // Pink Skin (#FBCFE8)
    fill.color = customColor ?? const Color(0xFFFBCFE8);
    final headRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.54), width: w * 0.44, height: h * 0.44);
    canvas.drawOval(headRect, fill);
    canvas.drawOval(headRect, line);

    // Front Hair curls
    fill.color = const Color(0xFFF43F5E);
    final frontHair = Path()
      ..moveTo(w * 0.28, h * 0.42)
      ..quadraticBezierTo(w * 0.50, h * 0.30, w * 0.72, h * 0.42)
      ..quadraticBezierTo(w * 0.60, h * 0.34, w * 0.50, h * 0.36)
      ..quadraticBezierTo(w * 0.40, h * 0.34, w * 0.28, h * 0.42)
      ..close();
    canvas.drawPath(frontHair, fill);
    canvas.drawPath(frontHair, line);

    // Golden Crown (#FBBF24)
    fill.color = const Color(0xFFFBBF24);
    final crown = Path()
      ..moveTo(w * 0.44, h * 0.26)
      ..lineTo(w * 0.41, h * 0.15)
      ..lineTo(w * 0.50, h * 0.20)
      ..lineTo(w * 0.59, h * 0.15)
      ..lineTo(w * 0.56, h * 0.26)
      ..close();
    canvas.drawPath(crown, fill);
    canvas.drawPath(crown, line);

    // Blue Jewel on Crown
    fill.color = const Color(0xFF38BDF8);
    canvas.drawCircle(Offset(w * 0.50, h * 0.21), w * 0.024, fill);

    // Face
    _drawClassicAdventureFace(canvas, size, Offset(w * 0.5, h * 0.54), line, fill);
  }

  // =========================================================================
  // CLASSIC ADVENTURE TIME EXPRESSIONS (Dots, Big happy bean grins, Tongue)
  // =========================================================================
  void _drawClassicAdventureFace(
    Canvas canvas,
    Size size,
    Offset center,
    Paint line,
    Paint fill, {
    bool hasFang = false,
  }) {
    final w = size.width;
    final h = size.height;

    // Eye spacing
    final eyeY = center.dy - (h * 0.04);
    final leftX = center.dx - (w * 0.10);
    final rightX = center.dx + (w * 0.10);
    final eyeR = w * 0.038;

    fill.color = const Color(0xFF0F172A);

    if (expression == 'happy' || expression == 'victory') {
      // Classic Adventure Time dot eyes
      canvas.drawCircle(Offset(leftX, eyeY), eyeR, fill);
      canvas.drawCircle(Offset(rightX, eyeY), eyeR, fill);

      // Specular shine
      fill.color = Colors.white;
      canvas.drawCircle(Offset(leftX - (eyeR * 0.35), eyeY - (eyeR * 0.35)), eyeR * 0.32, fill);
      canvas.drawCircle(Offset(rightX - (eyeR * 0.35), eyeY - (eyeR * 0.35)), eyeR * 0.32, fill);

      // Wide Open Cartoon Mouth with cute pink tongue (#FB7185)
      final mouthY = center.dy + (h * 0.06);
      final mouthPath = Path()
        ..moveTo(center.dx - (w * 0.12), mouthY)
        ..quadraticBezierTo(center.dx, mouthY + (h * 0.12), center.dx + (w * 0.12), mouthY)
        ..close();

      fill.color = const Color(0xFF881337); // Dark mouth interior
      canvas.drawPath(mouthPath, fill);

      // Pink Tongue inside
      fill.color = const Color(0xFFFB7185);
      final tonguePath = Path()
        ..moveTo(center.dx - (w * 0.06), mouthY + (h * 0.06))
        ..quadraticBezierTo(center.dx, mouthY + (h * 0.12), center.dx + (w * 0.08), mouthY + (h * 0.07))
        ..quadraticBezierTo(center.dx, mouthY + (h * 0.04), center.dx - (w * 0.06), mouthY + (h * 0.06))
        ..close();
      canvas.drawPath(tonguePath, fill);
      canvas.drawPath(mouthPath, line);

      if (hasFang) {
        fill.color = Colors.white;
        final fang = Path()
          ..moveTo(center.dx - (w * 0.08), mouthY)
          ..lineTo(center.dx - (w * 0.05), mouthY + (h * 0.035))
          ..lineTo(center.dx - (w * 0.02), mouthY)
          ..close();
        canvas.drawPath(fang, fill);
      }
    } else if (expression == 'sweat') {
      // Worried / Sweat drop
      canvas.drawCircle(Offset(leftX, eyeY), eyeR * 0.9, fill);
      canvas.drawCircle(Offset(rightX, eyeY), eyeR * 0.9, fill);

      // Squiggly mouth
      final mouthPath = Path()
        ..moveTo(center.dx - (w * 0.08), center.dy + (h * 0.07))
        ..quadraticBezierTo(center.dx - (w * 0.04), center.dy + (h * 0.05), center.dx, center.dy + (h * 0.07))
        ..quadraticBezierTo(center.dx + (w * 0.04), center.dy + (h * 0.09), center.dx + (w * 0.08), center.dy + (h * 0.07));
      canvas.drawPath(mouthPath, line);

      // Floating Cartoon Sweat Drop
      fill.color = const Color(0xFF38BDF8);
      final drop = Path()
        ..moveTo(center.dx + (w * 0.22), center.dy - (h * 0.10))
        ..quadraticBezierTo(center.dx + (w * 0.26), center.dy - (h * 0.04), center.dx + (w * 0.22), center.dy)
        ..quadraticBezierTo(center.dx + (w * 0.18), center.dy - (h * 0.04), center.dx + (w * 0.22), center.dy - (h * 0.10))
        ..close();
      canvas.drawPath(drop, fill);
      canvas.drawPath(drop, line);
    } else {
      // Classic confident grin
      canvas.drawCircle(Offset(leftX, eyeY), eyeR, fill);
      canvas.drawCircle(Offset(rightX, eyeY), eyeR, fill);

      final smilePath = Path()
        ..moveTo(center.dx - (w * 0.09), center.dy + (h * 0.06))
        ..quadraticBezierTo(center.dx, center.dy + (h * 0.12), center.dx + (w * 0.09), center.dy + (h * 0.06));
      canvas.drawPath(smilePath, line);
    }
  }

  @override
  bool shouldRepaint(covariant _AdventureTimePainter oldDelegate) {
    return oldDelegate.archetype != archetype ||
        oldDelegate.customColor != customColor ||
        oldDelegate.expression != expression ||
        oldDelegate.animT != animT;
  }
}

