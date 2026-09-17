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
      duration: const Duration(milliseconds: 400),
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

  _CharacterTheme get _theme {
    switch (widget.type) {
      case CartoonCharacterType.alex:
        return const _CharacterTheme(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF818CF8),
          accent: Color(0xFF06B6D4),
          bgGradient: [Color(0xFFEEF2FF), Color(0xFFC7D2FE)],
          accessoryIcon: Icons.headphones_rounded,
          accessoryColor: Color(0xFF06B6D4),
          badgeLabel: 'COACH',
        );
      case CartoonCharacterType.officerMiller:
        return const _CharacterTheme(
          primary: Color(0xFF1E3A8A),
          secondary: Color(0xFF3B82F6),
          accent: Color(0xFFF59E0B),
          bgGradient: [Color(0xFFEFF6FF), Color(0xFFBFDBFE)],
          accessoryIcon: Icons.shield_rounded,
          accessoryColor: Color(0xFFF59E0B),
          badgeLabel: 'CUSTOMS',
        );
      case CartoonCharacterType.baristaMateo:
        return const _CharacterTheme(
          primary: Color(0xFFD97706),
          secondary: Color(0xFFF59E0B),
          accent: Color(0xFF10B981),
          bgGradient: [Color(0xFFFFFBEB), Color(0xFFFDE68A)],
          accessoryIcon: Icons.local_cafe_rounded,
          accessoryColor: Color(0xFF92400E),
          badgeLabel: 'BARISTA',
        );
      case CartoonCharacterType.directorMarcus:
        return const _CharacterTheme(
          primary: Color(0xFF0F766E),
          secondary: Color(0xFF14B8A6),
          accent: Color(0xFF8B5CF6),
          bgGradient: [Color(0xFFF0FDFA), Color(0xFF99F6E4)],
          accessoryIcon: Icons.business_center_rounded,
          accessoryColor: Color(0xFF0F766E),
          badgeLabel: 'TECH',
        );
      case CartoonCharacterType.conciergePierre:
        return const _CharacterTheme(
          primary: Color(0xFF9F1239),
          secondary: Color(0xFFE11D48),
          accent: Color(0xFFFBBF24),
          bgGradient: [Color(0xFFFFF1F2), Color(0xFFFECDD3)],
          accessoryIcon: Icons.vpn_key_rounded,
          accessoryColor: Color(0xFFD97706),
          badgeLabel: 'HOTEL',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double s = widget.size;
    final theme = _theme;

    Widget avatarCore = AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Container(
          width: s,
          height: s,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: theme.bgGradient,
            ),
            border: Border.all(
              color: widget.isSpeaking ? theme.primary : Colors.white,
              width: s > 60 ? 3.0 : 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.primary.withOpacity(widget.isSpeaking ? 0.35 : 0.12),
                blurRadius: widget.isSpeaking ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Layer 1: Stylized Face & Character Vector
                CustomPaint(
                  size: Size(s, s),
                  painter: _CharmingCharacterPainter(
                    type: widget.type,
                    theme: theme,
                    speakingT: _animController.value,
                  ),
                ),

                // Layer 2: Micro accessory badge on larger avatars
                if (s >= 64)
                  Positioned(
                    right: s * 0.08,
                    bottom: s * 0.08,
                    child: Container(
                      padding: EdgeInsets.all(s * 0.05),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        theme.accessoryIcon,
                        size: s * 0.22,
                        color: theme.accessoryColor,
                      ),
                    ),
                  ),
              ],
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
          end: -2.5,
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOutSine,
        );

    if (!widget.showRipple || !widget.isSpeaking) {
      return avatarCore;
    }

    // Glowing harmonic ripples when character is speaking
    return SizedBox(
      width: s * 1.35,
      height: s * 1.35,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: s * 1.3,
            height: s * 1.3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.primary.withOpacity(0.35),
                width: 2.0,
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.92, 0.92),
                end: const Offset(1.14, 1.14),
                duration: const Duration(milliseconds: 800),
              ),
          Container(
            width: s * 1.15,
            height: s * 1.15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.primary.withOpacity(0.12),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.96, 0.96),
                end: const Offset(1.06, 1.06),
                duration: const Duration(milliseconds: 600),
              ),
          avatarCore,
        ],
      ),
    );
  }
}

class _CharacterTheme {
  final Color primary;
  final Color secondary;
  final Color accent;
  final List<Color> bgGradient;
  final IconData accessoryIcon;
  final Color accessoryColor;
  final String badgeLabel;

  const _CharacterTheme({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.bgGradient,
    required this.accessoryIcon,
    required this.accessoryColor,
    required this.badgeLabel,
  });
}

class _CharmingCharacterPainter extends CustomPainter {
  final CartoonCharacterType type;
  final _CharacterTheme theme;
  final double speakingT;

  _CharmingCharacterPainter({
    required this.type,
    required this.theme,
    required this.speakingT,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    switch (type) {
      case CartoonCharacterType.alex:
        _paintAlex(canvas, w, h);
        break;
      case CartoonCharacterType.officerMiller:
        _paintOfficerMiller(canvas, w, h);
        break;
      case CartoonCharacterType.baristaMateo:
        _paintBaristaMateo(canvas, w, h);
        break;
      case CartoonCharacterType.directorMarcus:
        _paintDirectorMarcus(canvas, w, h);
        break;
      case CartoonCharacterType.conciergePierre:
        _paintConciergePierre(canvas, w, h);
        break;
    }
  }

  // =========================================================================
  // 1. ALEX - THE ADORABLE PURPLE & CYAN STUDY COMPANION
  // =========================================================================
  void _paintAlex(Canvas canvas, double w, double h) {
    // Soft cute body shoulders
    final hoodiePaint = Paint()..color = const Color(0xFF6366F1);
    final hoodiePath = Path()
      ..moveTo(w * 0.15, h * 1.0)
      ..quadraticBezierTo(w * 0.28, h * 0.74, w * 0.5, h * 0.74)
      ..quadraticBezierTo(w * 0.72, h * 0.74, w * 0.85, h * 1.0)
      ..close();
    canvas.drawPath(hoodiePath, hoodiePaint);

    // White tee collar
    final shirtPaint = Paint()..color = Colors.white;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.82), width: w * 0.28, height: h * 0.14),
      shirtPaint,
    );

    // Head - Cute rounded anime proportions
    final skinPaint = Paint()..color = const Color(0xFFFFDFC4); // Natural warm peach skin
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.52), width: w * 0.58, height: h * 0.52),
      skinPaint,
    );

    // Stylish modern messy hair / bangs
    final hairPaint = Paint()..color = const Color(0xFF312E81); // Deep stylish indigo hair
    final hairPath = Path()
      ..moveTo(w * 0.22, h * 0.44)
      ..quadraticBezierTo(w * 0.24, h * 0.22, w * 0.5, h * 0.22)
      ..quadraticBezierTo(w * 0.76, h * 0.22, w * 0.78, h * 0.44)
      ..quadraticBezierTo(w * 0.68, h * 0.36, w * 0.56, h * 0.40)
      ..quadraticBezierTo(w * 0.48, h * 0.32, w * 0.38, h * 0.42)
      ..quadraticBezierTo(w * 0.28, h * 0.38, w * 0.22, h * 0.44)
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    // Cyan Studio Headphones Band
    final hpBandPaint = Paint()
      ..color = const Color(0xFF06B6D4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.44), width: w * 0.64, height: h * 0.54),
      math.pi * 1.1,
      math.pi * 0.8,
      false,
      hpBandPaint,
    );

    // Headphone Ear Cushions
    final cushionPaint = Paint()..color = const Color(0xFF0891B2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.18, h * 0.52), width: w * 0.12, height: h * 0.22),
        Radius.circular(w * 0.06),
      ),
      cushionPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.82, h * 0.52), width: w * 0.12, height: h * 0.22),
        Radius.circular(w * 0.06),
      ),
      cushionPaint,
    );

    // Cute Cheerful Eyes with twin sparkle lights
    _drawSparkleEye(canvas, Offset(w * 0.39, h * 0.51), w * 0.052);
    _drawSparkleEye(canvas, Offset(w * 0.61, h * 0.51), w * 0.052);

    // Rosy Blush
    _drawBlush(canvas, Offset(w * 0.30, h * 0.58), w * 0.09, h * 0.045);
    _drawBlush(canvas, Offset(w * 0.70, h * 0.58), w * 0.09, h * 0.045);

    // Animated Happy Mouth
    _drawSmilingMouth(canvas, Offset(w * 0.5, h * 0.63), w * 0.14, speakingT);
  }

  // =========================================================================
  // 2. OFFICER MILLER - CRISP NAVY UNIFORM & AVIATOR CONFIDENCE
  // =========================================================================
  void _paintOfficerMiller(Canvas canvas, double w, double h) {
    // Navy Uniform Jacket
    final jacketPaint = Paint()..color = const Color(0xFF1E3A8A);
    final jacketPath = Path()
      ..moveTo(w * 0.12, h * 1.0)
      ..quadraticBezierTo(w * 0.26, h * 0.72, w * 0.5, h * 0.72)
      ..quadraticBezierTo(w * 0.74, h * 0.72, w * 0.88, h * 1.0)
      ..close();
    canvas.drawPath(jacketPath, jacketPaint);

    // Gold epaulettes
    final goldPaint = Paint()..color = const Color(0xFFF59E0B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.22, h * 0.82), width: w * 0.16, height: h * 0.05),
        const Radius.circular(3),
      ),
      goldPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.78, h * 0.82), width: w * 0.16, height: h * 0.05),
        const Radius.circular(3),
      ),
      goldPaint,
    );

    // White Shirt & Gold Necktie
    final shirtPaint = Paint()..color = Colors.white;
    final tiePaint = Paint()..color = const Color(0xFFD97706);
    final collarPath = Path()
      ..moveTo(w * 0.42, h * 0.74)
      ..lineTo(w * 0.5, h * 0.86)
      ..lineTo(w * 0.58, h * 0.74)
      ..close();
    canvas.drawPath(collarPath, shirtPaint);

    final tiePath = Path()
      ..moveTo(w * 0.47, h * 0.84)
      ..lineTo(w * 0.53, h * 0.84)
      ..lineTo(w * 0.55, h * 1.0)
      ..lineTo(w * 0.45, h * 1.0)
      ..close();
    canvas.drawPath(tiePath, tiePaint);

    // Friendly Face
    final skinPaint = Paint()..color = const Color(0xFFFBD2B5);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.55), width: w * 0.56, height: h * 0.48),
      skinPaint,
    );

    // Navy Officer Peaked Cap
    final capPaint = Paint()..color = const Color(0xFF1E293B);
    final capVisorPaint = Paint()..color = const Color(0xFF0F172A);
    final capPath = Path()
      ..moveTo(w * 0.18, h * 0.38)
      ..quadraticBezierTo(w * 0.22, h * 0.14, w * 0.5, h * 0.14)
      ..quadraticBezierTo(w * 0.78, h * 0.14, w * 0.82, h * 0.38)
      ..close();
    canvas.drawPath(capPath, capPaint);

    // Cap Visor
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.38), width: w * 0.70, height: h * 0.10),
      capVisorPaint,
    );

    // Golden Star Badge on Cap
    canvas.drawCircle(Offset(w * 0.5, h * 0.26), w * 0.05, goldPaint);

    // Cool Aviator Glasses
    final aviatorPaint = Paint()..color = const Color(0xFF0F172A);
    final aviatorFramePaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Left lens
    final leftLens = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.38, h * 0.48), width: w * 0.18, height: h * 0.14),
      Radius.circular(w * 0.05),
    );
    // Right lens
    final rightLens = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.62, h * 0.48), width: w * 0.18, height: h * 0.14),
      Radius.circular(w * 0.05),
    );

    canvas.drawRRect(leftLens, aviatorPaint);
    canvas.drawRRect(rightLens, aviatorPaint);
    canvas.drawRRect(leftLens, aviatorFramePaint);
    canvas.drawRRect(rightLens, aviatorFramePaint);

    // Bridge
    canvas.drawLine(Offset(w * 0.47, h * 0.45), Offset(w * 0.53, h * 0.45), aviatorFramePaint);

    // Lens Sheen Reflection
    final sheenPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(w * 0.32, h * 0.44), Offset(w * 0.42, h * 0.52), sheenPaint);
    canvas.drawLine(Offset(w * 0.56, h * 0.44), Offset(w * 0.66, h * 0.52), sheenPaint);

    // Confident, Friendly Smile
    _drawSmilingMouth(canvas, Offset(w * 0.5, h * 0.65), w * 0.16, speakingT);
  }

  // =========================================================================
  // 3. BARISTA MATEO - WARM COFFEE BEANIE & ARTISAN GLASSES
  // =========================================================================
  void _paintBaristaMateo(Canvas canvas, double w, double h) {
    // Dark Green Artisan Apron
    final apronPaint = Paint()..color = const Color(0xFF065F46);
    final apronPath = Path()
      ..moveTo(w * 0.16, h * 1.0)
      ..quadraticBezierTo(w * 0.28, h * 0.74, w * 0.5, h * 0.74)
      ..quadraticBezierTo(w * 0.72, h * 0.74, w * 0.84, h * 1.0)
      ..close();
    canvas.drawPath(apronPath, apronPaint);

    // Apron Straps
    final strapPaint = Paint()
      ..color = const Color(0xFF78350F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawLine(Offset(w * 0.35, h * 0.76), Offset(w * 0.22, h * 1.0), strapPaint);
    canvas.drawLine(Offset(w * 0.65, h * 0.76), Offset(w * 0.78, h * 1.0), strapPaint);

    // Warm Face
    final skinPaint = Paint()..color = const Color(0xFFFED7AA);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.54), width: w * 0.58, height: h * 0.50),
      skinPaint,
    );

    // Knit Coffee Beanie (Warm amber/brown)
    final beaniePaint = Paint()..color = const Color(0xFF92400E);
    final beaniePath = Path()
      ..moveTo(w * 0.18, h * 0.44)
      ..quadraticBezierTo(w * 0.22, h * 0.14, w * 0.5, h * 0.14)
      ..quadraticBezierTo(w * 0.78, h * 0.14, w * 0.82, h * 0.44)
      ..close();
    canvas.drawPath(beaniePath, beaniePaint);

    // Beanie Fold
    final foldPaint = Paint()..color = const Color(0xFFB45309);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.40), width: w * 0.66, height: h * 0.10),
        const Radius.circular(6),
      ),
      foldPaint,
    );

    // Tortoiseshell Round Glasses
    final glassesPaint = Paint()
      ..color = const Color(0xFF78350F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8;
    canvas.drawCircle(Offset(w * 0.38, h * 0.50), w * 0.08, glassesPaint);
    canvas.drawCircle(Offset(w * 0.62, h * 0.50), w * 0.08, glassesPaint);
    canvas.drawLine(Offset(w * 0.46, h * 0.50), Offset(w * 0.54, h * 0.50), glassesPaint);

    // Friendly Eyes
    _drawSparkleEye(canvas, Offset(w * 0.38, h * 0.50), w * 0.045);
    _drawSparkleEye(canvas, Offset(w * 0.62, h * 0.50), w * 0.045);

    // Rosy Cheeks
    _drawBlush(canvas, Offset(w * 0.28, h * 0.57), w * 0.08, h * 0.04);
    _drawBlush(canvas, Offset(w * 0.72, h * 0.57), w * 0.08, h * 0.04);

    // Warm Barista Smile
    _drawSmilingMouth(canvas, Offset(w * 0.5, h * 0.64), w * 0.15, speakingT);
  }

  // =========================================================================
  // 4. DIRECTOR MARCUS - MODERN TECH EXECUTIVE & RECTANGULAR FRAMES
  // =========================================================================
  void _paintDirectorMarcus(Canvas canvas, double w, double h) {
    // Charcoal Smart-Casual Blazer
    final blazerPaint = Paint()..color = const Color(0xFF0F766E);
    final blazerPath = Path()
      ..moveTo(w * 0.14, h * 1.0)
      ..quadraticBezierTo(w * 0.26, h * 0.74, w * 0.5, h * 0.74)
      ..quadraticBezierTo(w * 0.74, h * 0.74, w * 0.86, h * 1.0)
      ..close();
    canvas.drawPath(blazerPath, blazerPaint);

    // Crisp White Shirt Lapel
    final shirtPaint = Paint()..color = Colors.white;
    final shirtPath = Path()
      ..moveTo(w * 0.40, h * 0.74)
      ..lineTo(w * 0.5, h * 0.90)
      ..lineTo(w * 0.60, h * 0.74)
      ..close();
    canvas.drawPath(shirtPath, shirtPaint);

    // Sharp Confident Face
    final skinPaint = Paint()..color = const Color(0xFFFDE68A).withRed(250).withGreen(225).withBlue(195);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.52), width: w * 0.56, height: h * 0.50),
      skinPaint,
    );

    // Neat Modern Haircut
    final hairPaint = Paint()..color = const Color(0xFF1E293B);
    final hairPath = Path()
      ..moveTo(w * 0.20, h * 0.44)
      ..quadraticBezierTo(w * 0.22, h * 0.20, w * 0.5, h * 0.18)
      ..quadraticBezierTo(w * 0.78, h * 0.20, w * 0.80, h * 0.44)
      ..quadraticBezierTo(w * 0.68, h * 0.32, w * 0.50, h * 0.32)
      ..quadraticBezierTo(w * 0.32, h * 0.32, w * 0.20, h * 0.44)
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    // Modern Rectangular Glasses
    final framePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.38, h * 0.50), width: w * 0.17, height: h * 0.11),
        const Radius.circular(4),
      ),
      framePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.62, h * 0.50), width: w * 0.17, height: h * 0.11),
        const Radius.circular(4),
      ),
      framePaint,
    );
    canvas.drawLine(Offset(w * 0.47, h * 0.50), Offset(w * 0.53, h * 0.50), framePaint);

    // Focused Eyes
    _drawSparkleEye(canvas, Offset(w * 0.38, h * 0.50), w * 0.046);
    _drawSparkleEye(canvas, Offset(w * 0.62, h * 0.50), w * 0.046);

    // Tech Founder Confident Smile
    _drawSmilingMouth(canvas, Offset(w * 0.5, h * 0.64), w * 0.14, speakingT);
  }

  // =========================================================================
  // 5. CONCIERGE PIERRE - REFINED BURGUNDY VEST & GOLDEN KEYS
  // =========================================================================
  void _paintConciergePierre(Canvas canvas, double w, double h) {
    // Tailored Burgundy Hotel Vest
    final vestPaint = Paint()..color = const Color(0xFF881337);
    final vestPath = Path()
      ..moveTo(w * 0.14, h * 1.0)
      ..quadraticBezierTo(w * 0.26, h * 0.74, w * 0.5, h * 0.74)
      ..quadraticBezierTo(w * 0.74, h * 0.74, w * 0.86, h * 1.0)
      ..close();
    canvas.drawPath(vestPath, vestPaint);

    // White Shirt & Gold Bow Tie
    final shirtPaint = Paint()..color = Colors.white;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.80), width: w * 0.24, height: h * 0.12),
      shirtPaint,
    );

    // Elegant Bow Tie
    final bowPaint = Paint()..color = const Color(0xFFF59E0B);
    final leftWing = Path()
      ..moveTo(w * 0.5, h * 0.78)
      ..lineTo(w * 0.40, h * 0.74)
      ..lineTo(w * 0.40, h * 0.82)
      ..close();
    final rightWing = Path()
      ..moveTo(w * 0.5, h * 0.78)
      ..lineTo(w * 0.60, h * 0.74)
      ..lineTo(w * 0.60, h * 0.82)
      ..close();
    canvas.drawPath(leftWing, bowPaint);
    canvas.drawPath(rightWing, bowPaint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.78), w * 0.035, bowPaint);

    // Refined Face
    final skinPaint = Paint()..color = const Color(0xFFFFDFC4);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.52), width: w * 0.56, height: h * 0.50),
      skinPaint,
    );

    // Elegant Slicked Back Hair
    final hairPaint = Paint()..color = const Color(0xFF475569);
    final hairPath = Path()
      ..moveTo(w * 0.20, h * 0.42)
      ..quadraticBezierTo(w * 0.22, h * 0.20, w * 0.5, h * 0.18)
      ..quadraticBezierTo(w * 0.78, h * 0.20, w * 0.80, h * 0.42)
      ..quadraticBezierTo(w * 0.70, h * 0.32, w * 0.50, h * 0.30)
      ..quadraticBezierTo(w * 0.30, h * 0.32, w * 0.20, h * 0.42)
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    // Hospitable Eyes
    _drawSparkleEye(canvas, Offset(w * 0.39, h * 0.49), w * 0.048);
    _drawSparkleEye(canvas, Offset(w * 0.61, h * 0.49), w * 0.048);

    // Neat Parisian Curved Mustache
    final stachePaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    final stachePath = Path()
      ..moveTo(w * 0.34, h * 0.59)
      ..quadraticBezierTo(w * 0.44, h * 0.62, w * 0.5, h * 0.59)
      ..quadraticBezierTo(w * 0.56, h * 0.62, w * 0.66, h * 0.59);
    canvas.drawPath(stachePath, stachePaint);

    // Polite French Smile
    _drawSmilingMouth(canvas, Offset(w * 0.5, h * 0.65), w * 0.13, speakingT);
  }

  // =========================================================================
  // SHARED ANIME / CARTOON RENDERING HELPERS
  // =========================================================================
  void _drawSparkleEye(Canvas canvas, Offset center, double radius) {
    // Dark Pupil
    final pupilPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawCircle(center, radius, pupilPaint);

    // Large Sparkle
    final sparklePaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(center.dx - radius * 0.35, center.dy - radius * 0.35),
      radius * 0.42,
      sparklePaint,
    );

    // Small Secondary Sparkle
    canvas.drawCircle(
      Offset(center.dx + radius * 0.38, center.dy + radius * 0.38),
      radius * 0.22,
      sparklePaint,
    );
  }

  void _drawBlush(Canvas canvas, Offset center, double width, double height) {
    final blushPaint = Paint()..color = const Color(0xFFFB7185).withOpacity(0.50);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: width, height: height),
      blushPaint,
    );
  }

  void _drawSmilingMouth(Canvas canvas, Offset center, double width, double speakingT) {
    final mouthPaint = Paint()
      ..color = const Color(0xFF991B1B)
      ..style = PaintingStyle.fill;

    final openH = (width * 0.4) + (speakingT * width * 0.35);

    // Cheerful crescent open smile
    final mouthPath = Path()
      ..moveTo(center.dx - width * 0.5, center.dy)
      ..quadraticBezierTo(center.dx, center.dy + openH, center.dx + width * 0.5, center.dy)
      ..close();
    canvas.drawPath(mouthPath, mouthPaint);

    // Cute upper teeth shine
    final teethPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + (openH * 0.22)),
          width: width * 0.55,
          height: openH * 0.32,
        ),
        const Radius.circular(2),
      ),
      teethPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CharmingCharacterPainter oldDelegate) {
    return oldDelegate.speakingT != speakingT || oldDelegate.type != type;
  }
}
