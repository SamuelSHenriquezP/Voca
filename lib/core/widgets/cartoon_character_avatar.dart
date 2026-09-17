import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum CartoonCharacterType {
  alex,
  officerMiller,
  baristaMateo,
  directorMarcus,
  conciergePierre,
}

class CartoonCharacterAvatar extends StatefulWidget {
  final CartoonCharacterType type;
  final double size;
  final bool isSpeaking;
  final bool showRipple;
  final String? emotion;

  const CartoonCharacterAvatar({
    super.key,
    required this.type,
    this.size = 80,
    this.isSpeaking = false,
    this.showRipple = true,
    this.emotion,
  });

  /// Factory from string IDs or names
  factory CartoonCharacterAvatar.fromId(
    String idOrName, {
    double size = 80,
    bool isSpeaking = false,
    bool showRipple = true,
    String? emotion,
  }) {
    final lower = idOrName.toLowerCase();
    CartoonCharacterType type;
    if (lower.contains('miller') || lower.contains('customs') || lower.contains('officer')) {
      type = CartoonCharacterType.officerMiller;
    } else if (lower.contains('mateo') || lower.contains('barista') || lower.contains('coffee')) {
      type = CartoonCharacterType.baristaMateo;
    } else if (lower.contains('marcus') || lower.contains('tech') || lower.contains('interview') || lower.contains('director')) {
      type = CartoonCharacterType.directorMarcus;
    } else if (lower.contains('pierre') || lower.contains('concierge') || lower.contains('hotel')) {
      type = CartoonCharacterType.conciergePierre;
    } else {
      type = CartoonCharacterType.alex;
    }

    return CartoonCharacterAvatar(
      type: type,
      size: size,
      isSpeaking: isSpeaking,
      showRipple: showRipple,
      emotion: emotion,
    );
  }

  @override
  State<CartoonCharacterAvatar> createState() => _CartoonCharacterAvatarState();
}

class _CartoonCharacterAvatarState extends State<CartoonCharacterAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    if (widget.isSpeaking) {
      _animController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant CartoonCharacterAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpeaking != oldWidget.isSpeaking) {
      if (widget.isSpeaking) {
        _animController.repeat(reverse: true);
      } else {
        _animController.animateTo(0, duration: const Duration(milliseconds: 200));
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color get _bgAccentColor {
    switch (widget.type) {
      case CartoonCharacterType.alex:
        return const Color(0xFF6366F1);
      case CartoonCharacterType.officerMiller:
        return const Color(0xFF3B82F6);
      case CartoonCharacterType.baristaMateo:
        return const Color(0xFFF59E0B);
      case CartoonCharacterType.directorMarcus:
        return const Color(0xFF06B6D4);
      case CartoonCharacterType.conciergePierre:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double s = widget.size;

    Widget avatarCore = AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Container(
          width: s,
          height: s,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _bgAccentColor.withOpacity(0.22),
                const Color(0xFF0F172A),
              ],
            ),
            border: Border.all(
              color: widget.isSpeaking ? _bgAccentColor : Colors.white.withOpacity(0.3),
              width: s > 60 ? 3.0 : 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isSpeaking
                    ? _bgAccentColor.withOpacity(0.4)
                    : Colors.black.withOpacity(0.25),
                blurRadius: widget.isSpeaking ? 18 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: CustomPaint(
              size: Size(s, s),
              painter: _CartoonAvatarPainter(
                type: widget.type,
                speakingT: _animController.value,
              ),
            ),
          ),
        );
      },
    );

    // Subtle gentle breathing idle animation
    avatarCore = avatarCore
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(
          begin: 0,
          end: -3.0,
          duration: const Duration(milliseconds: 1400),
          curve: Curves.easeInOutSine,
        );

    if (!widget.showRipple || !widget.isSpeaking) {
      return avatarCore;
    }

    // Ripples when speaking
    return SizedBox(
      width: s * 1.45,
      height: s * 1.45,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: s * 1.4,
            height: s * 1.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _bgAccentColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.88, 0.88),
                end: const Offset(1.16, 1.16),
                duration: const Duration(milliseconds: 900),
              ),
          Container(
            width: s * 1.2,
            height: s * 1.2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _bgAccentColor.withOpacity(0.12),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.08, 1.08),
                duration: const Duration(milliseconds: 700),
              ),
          avatarCore,
        ],
      ),
    );
  }
}

class _CartoonAvatarPainter extends CustomPainter {
  final CartoonCharacterType type;
  final double speakingT;

  _CartoonAvatarPainter({
    required this.type,
    required this.speakingT,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case CartoonCharacterType.alex:
        _paintAlex(canvas, size);
        break;
      case CartoonCharacterType.officerMiller:
        _paintOfficerMiller(canvas, size);
        break;
      case CartoonCharacterType.baristaMateo:
        _paintBaristaMateo(canvas, size);
        break;
      case CartoonCharacterType.directorMarcus:
        _paintDirectorMarcus(canvas, size);
        break;
      case CartoonCharacterType.conciergePierre:
        _paintConciergePierre(canvas, size);
        break;
    }
  }

  // ==========================================
  // 1. ALEX - THE CUTE CARTOON MASCOT COMPANION
  // ==========================================
  void _paintAlex(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Outer ears (Fox/Owl whimsical ears)
    final earPaint = Paint()..color = const Color(0xFF6366F1);
    final innerEarPaint = Paint()..color = const Color(0xFFF472B6);

    // Left Ear
    final leftEar = Path()
      ..moveTo(w * 0.22, h * 0.42)
      ..lineTo(w * 0.16, h * 0.12)
      ..lineTo(w * 0.42, h * 0.3)
      ..close();
    canvas.drawPath(leftEar, earPaint);

    final leftInner = Path()
      ..moveTo(w * 0.24, h * 0.38)
      ..lineTo(w * 0.20, h * 0.18)
      ..lineTo(w * 0.38, h * 0.30)
      ..close();
    canvas.drawPath(leftInner, innerEarPaint);

    // Right Ear
    final rightEar = Path()
      ..moveTo(w * 0.78, h * 0.42)
      ..lineTo(w * 0.84, h * 0.12)
      ..lineTo(w * 0.58, h * 0.3)
      ..close();
    canvas.drawPath(rightEar, earPaint);

    final rightInner = Path()
      ..moveTo(w * 0.76, h * 0.38)
      ..lineTo(w * 0.80, h * 0.18)
      ..lineTo(w * 0.62, h * 0.30)
      ..close();
    canvas.drawPath(rightInner, innerEarPaint);

    // Body Shoulders
    final bodyPaint = Paint()..color = const Color(0xFF4F46E5);
    final bodyPath = Path()
      ..moveTo(w * 0.18, h * 1.0)
      ..quadraticBezierTo(w * 0.3, h * 0.78, w * 0.5, h * 0.78)
      ..quadraticBezierTo(w * 0.7, h * 0.78, w * 0.82, h * 1.0)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Chest fluff
    final fluffPaint = Paint()..color = Colors.white;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.86), width: w * 0.34, height: h * 0.22),
      fluffPaint,
    );

    // Head (Large cute round shape)
    final headPaint = Paint()..color = const Color(0xFF818CF8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.52), width: w * 0.68, height: h * 0.56),
        Radius.circular(w * 0.28),
      ),
      headPaint,
    );

    // Cheerful Rosy Blush Cheeks
    final blushPaint = Paint()..color = const Color(0xFFFB7185).withOpacity(0.65);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.26, h * 0.58), width: w * 0.13, height: h * 0.08),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.74, h * 0.58), width: w * 0.13, height: h * 0.08),
      blushPaint,
    );

    // Big Kawaii Anime Eyes
    final eyePaint = Paint()..color = const Color(0xFF0F172A);
    final shinePaint = Paint()..color = Colors.white;
    final pupilCyan = Paint()..color = const Color(0xFF38BDF8);

    // Left Eye
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.37, h * 0.48), width: w * 0.15, height: h * 0.20),
      eyePaint,
    );
    canvas.drawCircle(Offset(w * 0.37, h * 0.50), w * 0.05, pupilCyan);
    canvas.drawCircle(Offset(w * 0.35, h * 0.44), w * 0.035, shinePaint);
    canvas.drawCircle(Offset(w * 0.40, h * 0.52), w * 0.018, shinePaint);

    // Right Eye
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.63, h * 0.48), width: w * 0.15, height: h * 0.20),
      eyePaint,
    );
    canvas.drawCircle(Offset(w * 0.63, h * 0.50), w * 0.05, pupilCyan);
    canvas.drawCircle(Offset(w * 0.61, h * 0.44), w * 0.035, shinePaint);
    canvas.drawCircle(Offset(w * 0.66, h * 0.52), w * 0.018, shinePaint);

    // Nose
    final nosePaint = Paint()..color = const Color(0xFF312E81);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.55), width: w * 0.065, height: h * 0.04),
      nosePaint,
    );

    // Mouth (Animated opening when talking)
    final mouthPaint = Paint()
      ..color = const Color(0xFFE11D48)
      ..style = PaintingStyle.fill;
    final mouthBorder = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final mouthOpenH = (0.04 + (speakingT * 0.08)) * h;
    final mouthPath = Path()
      ..moveTo(w * 0.43, h * 0.61)
      ..quadraticBezierTo(w * 0.5, h * 0.61 + mouthOpenH, w * 0.57, h * 0.61)
      ..close();
    canvas.drawPath(mouthPath, mouthPaint);
    canvas.drawPath(mouthPath, mouthBorder);

    // Cute Antenna / Head Tufts
    final tuftPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.23), w * 0.045, tuftPaint);
  }

  // ==================================================
  // 2. OFFICER MILLER - CARTOON BORDER CUSTOMS OFFICER
  // ==================================================
  void _paintOfficerMiller(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Shoulders (Navy Uniform with gold epaulets)
    final uniformPaint = Paint()..color = const Color(0xFF1E3A8A);
    final shoulderPath = Path()
      ..moveTo(w * 0.1, h * 1.0)
      ..quadraticBezierTo(w * 0.25, h * 0.72, w * 0.5, h * 0.72)
      ..quadraticBezierTo(w * 0.75, h * 0.72, w * 0.9, h * 1.0)
      ..close();
    canvas.drawPath(shoulderPath, uniformPaint);

    // Gold Epaulets
    final goldPaint = Paint()..color = const Color(0xFFF59E0B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.24, h * 0.79), width: w * 0.16, height: h * 0.06),
        const Radius.circular(3),
      ),
      goldPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.76, h * 0.79), width: w * 0.16, height: h * 0.06),
        const Radius.circular(3),
      ),
      goldPaint,
    );

    // White Shirt Collar & Gold Tie
    final shirtPaint = Paint()..color = Colors.white;
    final tiePaint = Paint()..color = const Color(0xFFD97706);
    final collarPath = Path()
      ..moveTo(w * 0.42, h * 0.72)
      ..lineTo(w * 0.5, h * 0.85)
      ..lineTo(w * 0.58, h * 0.72)
      ..close();
    canvas.drawPath(collarPath, shirtPaint);

    final tiePath = Path()
      ..moveTo(w * 0.47, h * 0.82)
      ..lineTo(w * 0.53, h * 0.82)
      ..lineTo(w * 0.55, h * 0.98)
      ..lineTo(w * 0.50, h * 1.0)
      ..lineTo(w * 0.45, h * 0.98)
      ..close();
    canvas.drawPath(tiePath, tiePaint);

    // Chunky Friendly Face
    final skinPaint = Paint()..color = const Color(0xFFFBCFE8).withRed(248).withGreen(205).withBlue(175);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.55), width: w * 0.56, height: h * 0.46),
        Radius.circular(w * 0.22),
      ),
      skinPaint,
    );

    // Big Friendly Eyes
    final eyePaint = Paint()..color = const Color(0xFF0F172A);
    final shinePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.38, h * 0.50), w * 0.05, eyePaint);
    canvas.drawCircle(Offset(w * 0.62, h * 0.50), w * 0.05, eyePaint);
    canvas.drawCircle(Offset(w * 0.36, h * 0.48), w * 0.018, shinePaint);
    canvas.drawCircle(Offset(w * 0.60, h * 0.48), w * 0.018, shinePaint);

    // Thick Expressive Eyebrows
    final browPaint = Paint()
      ..color = const Color(0xFF78350F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.30, h * 0.43), Offset(w * 0.45, h * 0.44), browPaint);
    canvas.drawLine(Offset(w * 0.70, h * 0.43), Offset(w * 0.55, h * 0.44), browPaint);

    // Large Comical Bushy Brown Mustache (bounces when speaking)
    final mustacheY = h * 0.63 + (speakingT * 4.0);
    final mustachePaint = Paint()..color = const Color(0xFF78350F);
    final leftStache = Path()
      ..moveTo(w * 0.5, mustacheY)
      ..quadraticBezierTo(w * 0.38, mustacheY - 6, w * 0.26, mustacheY + 8)
      ..quadraticBezierTo(w * 0.38, mustacheY + 14, w * 0.5, mustacheY + 4)
      ..close();
    canvas.drawPath(leftStache, mustachePaint);

    final rightStache = Path()
      ..moveTo(w * 0.5, mustacheY)
      ..quadraticBezierTo(w * 0.62, mustacheY - 6, w * 0.74, mustacheY + 8)
      ..quadraticBezierTo(w * 0.62, mustacheY + 14, w * 0.5, mustacheY + 4)
      ..close();
    canvas.drawPath(rightStache, mustachePaint);

    // Round cartoon nose
    final nosePaint = Paint()..color = const Color(0xFFE08E66);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, mustacheY - 4), width: w * 0.14, height: h * 0.09),
      nosePaint,
    );

    // Customs Officer Cap (Navy with gold star badge and shiny black visor)
    final capCrownPaint = Paint()..color = const Color(0xFF1E3A8A);
    final capCrown = Path()
      ..moveTo(w * 0.16, h * 0.36)
      ..cubicTo(w * 0.18, h * 0.10, w * 0.82, h * 0.10, w * 0.84, h * 0.36)
      ..close();
    canvas.drawPath(capCrown, capCrownPaint);

    // Cap Band & Gold Shield
    final capBandPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.35), width: w * 0.72, height: h * 0.09),
        const Radius.circular(4),
      ),
      capBandPaint,
    );

    // Gold Star Shield on Cap
    canvas.drawCircle(Offset(w * 0.5, h * 0.28), w * 0.065, goldPaint);
    final starPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.5, h * 0.28), w * 0.025, starPaint);

    // Black Shiny Visor
    final visorPaint = Paint()..color = const Color(0xFF09090B);
    final visorPath = Path()
      ..moveTo(w * 0.18, h * 0.38)
      ..quadraticBezierTo(w * 0.5, h * 0.48, w * 0.82, h * 0.38)
      ..quadraticBezierTo(w * 0.5, h * 0.42, w * 0.18, h * 0.38)
      ..close();
    canvas.drawPath(visorPath, visorPaint);
  }

  // ==================================================
  // 3. BARISTA MATEO - ARTISAN COFFEE SHOP ROASTER
  // ==================================================
  void _paintBaristaMateo(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Apron and Shoulders (Rustic warm brown canvas with straps)
    final apronPaint = Paint()..color = const Color(0xFF78350F);
    final shoulderPath = Path()
      ..moveTo(w * 0.12, h * 1.0)
      ..quadraticBezierTo(w * 0.25, h * 0.74, w * 0.5, h * 0.74)
      ..quadraticBezierTo(w * 0.75, h * 0.74, w * 0.88, h * 1.0)
      ..close();
    canvas.drawPath(shoulderPath, apronPaint);

    // Apron Leather Straps
    final strapPaint = Paint()
      ..color = const Color(0xFF451A03)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.32, h * 0.74), Offset(w * 0.32, h * 1.0), strapPaint);
    canvas.drawLine(Offset(w * 0.68, h * 0.74), Offset(w * 0.68, h * 1.0), strapPaint);

    // Steaming coffee cup enamel badge on apron
    final badgePaint = Paint()..color = const Color(0xFFFDE68A);
    canvas.drawCircle(Offset(w * 0.5, h * 0.88), w * 0.05, badgePaint);
    final steamPaint = Paint()
      ..color = const Color(0xFF92400E)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.88), width: w * 0.04, height: h * 0.025),
      steamPaint,
    );

    // Friendly Face
    final skinPaint = Paint()..color = const Color(0xFFFED7AA);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.56), width: w * 0.54, height: h * 0.44),
      skinPaint,
    );

    // Hipster Circular Wire Glasses
    final glassesPaint = Paint()
      ..color = const Color(0xFF27272A)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(w * 0.37, h * 0.51), w * 0.10, glassesPaint);
    canvas.drawCircle(Offset(w * 0.63, h * 0.51), w * 0.10, glassesPaint);
    canvas.drawLine(Offset(w * 0.47, h * 0.51), Offset(w * 0.53, h * 0.51), glassesPaint);

    // Warm Happy Eyes behind glasses
    final eyePaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawCircle(Offset(w * 0.37, h * 0.51), w * 0.04, eyePaint);
    canvas.drawCircle(Offset(w * 0.63, h * 0.51), w * 0.04, eyePaint);

    // Cheerful Smile (animated mouth)
    final mouthPaint = Paint()
      ..color = const Color(0xFFBE123C)
      ..style = PaintingStyle.fill;
    final mouthH = (0.04 + (speakingT * 0.06)) * h;
    final smilePath = Path()
      ..moveTo(w * 0.42, h * 0.65)
      ..quadraticBezierTo(w * 0.5, h * 0.65 + mouthH, w * 0.58, h * 0.65)
      ..close();
    canvas.drawPath(smilePath, mouthPaint);

    // Rosy Cheeks
    final cheekPaint = Paint()..color = const Color(0xFFF43F5E).withOpacity(0.4);
    canvas.drawCircle(Offset(w * 0.28, h * 0.60), w * 0.05, cheekPaint);
    canvas.drawCircle(Offset(w * 0.72, h * 0.60), w * 0.05, cheekPaint);

    // Fun Curly Hair Tufts popping out
    final hairPaint = Paint()..color = const Color(0xFF451A03);
    canvas.drawCircle(Offset(w * 0.25, h * 0.44), w * 0.06, hairPaint);
    canvas.drawCircle(Offset(w * 0.75, h * 0.44), w * 0.06, hairPaint);

    // Slouchy Mustard Yellow Beanie
    final beaniePaint = Paint()..color = const Color(0xFFF59E0B);
    final beanieFold = Paint()..color = const Color(0xFFD97706);

    final beanieCrown = Path()
      ..moveTo(w * 0.22, h * 0.40)
      ..cubicTo(w * 0.22, h * 0.12, w * 0.78, h * 0.12, w * 0.78, h * 0.40)
      ..close();
    canvas.drawPath(beanieCrown, beaniePaint);

    // Beanie Fold Ribbing
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.38), width: w * 0.62, height: h * 0.09),
        const Radius.circular(5),
      ),
      beanieFold,
    );
  }

  // ==================================================
  // 4. DIRECTOR MARCUS - TECH ENGINEERING LEAD
  // ==================================================
  void _paintDirectorMarcus(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Modern Tech Charcoal Hoodie with Neon code bracket
    final hoodiePaint = Paint()..color = const Color(0xFF1E293B);
    final shoulderPath = Path()
      ..moveTo(w * 0.1, h * 1.0)
      ..quadraticBezierTo(w * 0.25, h * 0.74, w * 0.5, h * 0.74)
      ..quadraticBezierTo(w * 0.75, h * 0.74, w * 0.9, h * 1.0)
      ..close();
    canvas.drawPath(shoulderPath, hoodiePaint);

    // Cyan glowing badge on hoodie
    final cyanPaint = Paint()..color = const Color(0xFF06B6D4);
    canvas.drawCircle(Offset(w * 0.5, h * 0.88), w * 0.045, cyanPaint);

    // Sharp Confident Face with Neat Beard
    final skinPaint = Paint()..color = const Color(0xFFFCD34D).withRed(225).withGreen(185).withBlue(155);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.55), width: w * 0.54, height: h * 0.46),
        Radius.circular(w * 0.20),
      ),
      skinPaint,
    );

    // Trimmed Designer Beard
    final beardPaint = Paint()..color = const Color(0xFF18181B);
    final beardPath = Path()
      ..moveTo(w * 0.26, h * 0.56)
      ..quadraticBezierTo(w * 0.28, h * 0.77, w * 0.5, h * 0.77)
      ..quadraticBezierTo(w * 0.72, h * 0.77, w * 0.74, h * 0.56)
      ..quadraticBezierTo(w * 0.68, h * 0.68, w * 0.5, h * 0.69)
      ..quadraticBezierTo(w * 0.32, h * 0.68, w * 0.26, h * 0.56)
      ..close();
    canvas.drawPath(beardPath, beardPaint);

    // Confident Smart Smile
    final mouthPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.66 + (speakingT * 3)), width: w * 0.14, height: h * 0.045),
        const Radius.circular(4),
      ),
      mouthPaint,
    );

    // Modern Rectangular Tech Glasses
    final glassesPaint = Paint()
      ..color = const Color(0xFF0284C7)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.38, h * 0.48), width: w * 0.17, height: h * 0.11),
        const Radius.circular(3),
      ),
      glassesPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.62, h * 0.48), width: w * 0.17, height: h * 0.11),
        const Radius.circular(3),
      ),
      glassesPaint,
    );
    canvas.drawLine(Offset(w * 0.47, h * 0.48), Offset(w * 0.53, h * 0.48), glassesPaint);

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawCircle(Offset(w * 0.38, h * 0.48), w * 0.035, eyePaint);
    canvas.drawCircle(Offset(w * 0.62, h * 0.48), w * 0.035, eyePaint);

    // Stylish Swept Hair
    final hairPaint = Paint()..color = const Color(0xFF18181B);
    final hairPath = Path()
      ..moveTo(w * 0.24, h * 0.38)
      ..quadraticBezierTo(w * 0.32, h * 0.20, w * 0.60, h * 0.22)
      ..quadraticBezierTo(w * 0.78, h * 0.24, w * 0.76, h * 0.38)
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    // Studio Over-Ear Headphones with Glowing Cyan Rings
    final phoneBand = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.44), width: w * 0.74, height: h * 0.54),
      math.pi,
      math.pi,
      false,
      phoneBand,
    );

    // Ear Cups (Left & Right)
    final cupPaint = Paint()..color = const Color(0xFF0284C7);
    final ringGlow = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.16, h * 0.50), width: w * 0.09, height: h * 0.19),
        const Radius.circular(6),
      ),
      cupPaint,
    );
    canvas.drawCircle(Offset(w * 0.16, h * 0.50), w * 0.03, ringGlow);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.84, h * 0.50), width: w * 0.09, height: h * 0.19),
        const Radius.circular(6),
      ),
      cupPaint,
    );
    canvas.drawCircle(Offset(w * 0.84, h * 0.50), w * 0.03, ringGlow);
  }

  // ==================================================
  // 5. CONCIERGE PIERRE - DAPPER LUXURY HOTEL HOST
  // ==================================================
  void _paintConciergePierre(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Emerald Tuxedo Shoulders & Gold Crossed Keys
    final tuxPaint = Paint()..color = const Color(0xFF064E3B);
    final shoulderPath = Path()
      ..moveTo(w * 0.12, h * 1.0)
      ..quadraticBezierTo(w * 0.25, h * 0.74, w * 0.5, h * 0.74)
      ..quadraticBezierTo(w * 0.75, h * 0.74, w * 0.88, h * 1.0)
      ..close();
    canvas.drawPath(shoulderPath, tuxPaint);

    // Satin Lapels
    final lapelPaint = Paint()..color = const Color(0xFF022C22);
    final leftLapel = Path()
      ..moveTo(w * 0.30, h * 0.74)
      ..lineTo(w * 0.44, h * 0.98)
      ..lineTo(w * 0.36, h * 1.0)
      ..close();
    canvas.drawPath(leftLapel, lapelPaint);

    // Gold Bowtie
    final goldPaint = Paint()..color = const Color(0xFFF59E0B);
    final bowPath = Path()
      ..moveTo(w * 0.42, h * 0.74)
      ..lineTo(w * 0.42, h * 0.80)
      ..lineTo(w * 0.58, h * 0.74)
      ..lineTo(w * 0.58, h * 0.80)
      ..close();
    canvas.drawPath(bowPath, goldPaint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.77), w * 0.025, goldPaint);

    // Slim Refined Face
    final skinPaint = Paint()..color = const Color(0xFFFED7AA).withRed(245).withGreen(215).withBlue(190);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.54), width: w * 0.48, height: h * 0.46),
      skinPaint,
    );

    // Sophisticated Hair (Slicked Side-Part)
    final hairPaint = Paint()..color = const Color(0xFF292524);
    final hairPath = Path()
      ..moveTo(w * 0.22, h * 0.42)
      ..cubicTo(w * 0.24, h * 0.18, w * 0.76, h * 0.18, w * 0.78, h * 0.42)
      ..quadraticBezierTo(w * 0.50, h * 0.32, w * 0.22, h * 0.42)
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    // Arched Left Eyebrow & Golden Monocle on Right Eye
    final browPaint = Paint()
      ..color = const Color(0xFF292524)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    // Inquisitive arched eyebrow
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.37, h * 0.43), width: w * 0.14, height: h * 0.08),
      math.pi * 1.1,
      math.pi * 0.8,
      false,
      browPaint,
    );
    canvas.drawLine(Offset(w * 0.58, h * 0.46), Offset(w * 0.68, h * 0.44), browPaint);

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF1C1917);
    canvas.drawCircle(Offset(w * 0.37, h * 0.49), w * 0.035, eyePaint);
    canvas.drawCircle(Offset(w * 0.63, h * 0.49), w * 0.035, eyePaint);

    // Golden Monocle with delicate chain
    final monoclePaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(w * 0.63, h * 0.49), w * 0.09, monoclePaint);
    final chainPaint = Paint()
      ..color = const Color(0xFFD97706)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.71, h * 0.53), Offset(w * 0.76, h * 0.74), chainPaint);

    // Dapper Twirled French Mustache
    final stachePaint = Paint()
      ..color = const Color(0xFF292524)
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final stacheY = h * 0.62 + (speakingT * 3);
    final leftCurl = Path()
      ..moveTo(w * 0.5, stacheY)
      ..quadraticBezierTo(w * 0.38, stacheY + 2, w * 0.30, stacheY - 4);
    canvas.drawPath(leftCurl, stachePaint);
    final rightCurl = Path()
      ..moveTo(w * 0.5, stacheY)
      ..quadraticBezierTo(w * 0.62, stacheY + 2, w * 0.70, stacheY - 4);
    canvas.drawPath(rightCurl, stachePaint);

    // Polite Sophisticated Smirk
    final smirkPaint = Paint()
      ..color = const Color(0xFF831843)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.5, stacheY + 6), width: w * 0.12, height: h * 0.05),
      0,
      math.pi,
      false,
      smirkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CartoonAvatarPainter oldDelegate) {
    return oldDelegate.speakingT != speakingT || oldDelegate.type != type;
  }
}
