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
  // 1. ALEX RIVERA - REALISTIC LANGUAGE COACH
  // =========================================================================
  void _paintAlex(Canvas canvas, double w, double h) {
    // Shoulders - Minimalist Lavender/Navy Sweater
    final sweaterPaint = Paint()..color = const Color(0xFF4F46E5);
    final bodyPath = Path()
      ..moveTo(w * 0.12, h * 1.0)
      ..quadraticBezierTo(w * 0.25, h * 0.72, w * 0.5, h * 0.72)
      ..quadraticBezierTo(w * 0.75, h * 0.72, w * 0.88, h * 1.0)
      ..close();
    canvas.drawPath(bodyPath, sweaterPaint);

    // White Shirt Collar peek
    final shirtPaint = Paint()..color = Colors.white;
    final collarPath = Path()
      ..moveTo(w * 0.40, h * 0.72)
      ..lineTo(w * 0.5, h * 0.82)
      ..lineTo(w * 0.60, h * 0.72)
      ..close();
    canvas.drawPath(collarPath, shirtPaint);

    // Neck & Shadow
    final skinShadowPaint = Paint()..color = const Color(0xFFE2B79D);
    final skinPaint = Paint()..color = const Color(0xFFFAD4C0);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.68), width: w * 0.20, height: h * 0.14),
      skinShadowPaint,
    );

    // Face Shape - Natural Human Oval
    final headRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.50), width: w * 0.46, height: h * 0.46);
    canvas.drawOval(headRect, skinPaint);

    // Ears
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.26, h * 0.51), width: w * 0.08, height: h * 0.12), skinPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.74, h * 0.51), width: w * 0.08, height: h * 0.12), skinPaint);

    // Modern White Wireless Earbud (Coach aesthetic)
    final earbudPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.73, h * 0.51), w * 0.025, earbudPaint);

    // Natural Modern Dark Haircut (Side-parted, stylish)
    final hairPaint = Paint()..color = const Color(0xFF1E293B);
    final hairPath = Path()
      ..moveTo(w * 0.25, h * 0.44)
      ..quadraticBezierTo(w * 0.24, h * 0.20, w * 0.48, h * 0.18)
      ..quadraticBezierTo(w * 0.76, h * 0.20, w * 0.75, h * 0.44)
      ..quadraticBezierTo(w * 0.68, h * 0.32, w * 0.52, h * 0.34)
      ..quadraticBezierTo(w * 0.38, h * 0.28, w * 0.25, h * 0.44)
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    // Natural Eyebrows
    _drawRealisticEyebrow(canvas, Offset(w * 0.33, h * 0.44), Offset(w * 0.41, h * 0.42), Offset(w * 0.46, h * 0.44), const Color(0xFF1E293B), 2.0);
    _drawRealisticEyebrow(canvas, Offset(w * 0.54, h * 0.44), Offset(w * 0.59, h * 0.42), Offset(w * 0.67, h * 0.44), const Color(0xFF1E293B), 2.0);

    // Realistic Eyes
    _drawRealisticEye(canvas, Offset(w * 0.39, h * 0.48), w * 0.08, h * 0.045, const Color(0xFF3B2F2F));
    _drawRealisticEye(canvas, Offset(w * 0.61, h * 0.48), w * 0.08, h * 0.045, const Color(0xFF3B2F2F));

    // Nose Line
    _drawRealisticNose(canvas, Offset(w * 0.50, h * 0.48), Offset(w * 0.50, h * 0.56), const Color(0xFFD49B7E));

    // Realistic Natural Smile
    _drawRealisticMouth(canvas, Offset(w * 0.50, h * 0.62), w * 0.14, speakingT);
  }

  // =========================================================================
  // 2. OFFICER MILLER - REALISTIC JFK CUSTOMS OFFICER
  // =========================================================================
  void _paintOfficerMiller(Canvas canvas, double w, double h) {
    // Regulation Navy Uniform Jacket
    final jacketPaint = Paint()..color = const Color(0xFF1E3A8A);
    final jacketPath = Path()
      ..moveTo(w * 0.10, h * 1.0)
      ..quadraticBezierTo(w * 0.24, h * 0.70, w * 0.5, h * 0.70)
      ..quadraticBezierTo(w * 0.76, h * 0.70, w * 0.90, h * 1.0)
      ..close();
    canvas.drawPath(jacketPath, jacketPaint);

    // Gold Insignia Epaulettes on shoulders
    final goldPaint = Paint()..color = const Color(0xFFF59E0B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * 0.20, h * 0.79), width: w * 0.14, height: h * 0.04), const Radius.circular(2)),
      goldPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * 0.80, h * 0.79), width: w * 0.14, height: h * 0.04), const Radius.circular(2)),
      goldPaint,
    );

    // Crisp White Shirt & Navy Regulation Tie
    final shirtPaint = Paint()..color = Colors.white;
    final tiePaint = Paint()..color = const Color(0xFF0F172A);
    final collarPath = Path()
      ..moveTo(w * 0.41, h * 0.70)
      ..lineTo(w * 0.5, h * 0.84)
      ..lineTo(w * 0.59, h * 0.70)
      ..close();
    canvas.drawPath(collarPath, shirtPaint);

    final tiePath = Path()
      ..moveTo(w * 0.47, h * 0.81)
      ..lineTo(w * 0.53, h * 0.81)
      ..lineTo(w * 0.55, h * 1.0)
      ..lineTo(w * 0.45, h * 1.0)
      ..close();
    canvas.drawPath(tiePath, tiePaint);

    // Gold Tie Clip
    canvas.drawLine(Offset(w * 0.47, h * 0.89), Offset(w * 0.53, h * 0.89), goldPaint..strokeWidth = 2.0);

    // Gold Customs Shield Badge on chest
    final badgePath = Path()
      ..moveTo(w * 0.28, h * 0.84)
      ..lineTo(w * 0.34, h * 0.84)
      ..lineTo(w * 0.34, h * 0.90)
      ..lineTo(w * 0.31, h * 0.93)
      ..lineTo(w * 0.28, h * 0.90)
      ..close();
    canvas.drawPath(badgePath, goldPaint..style = PaintingStyle.fill);

    // Neck
    final skinShadowPaint = Paint()..color = const Color(0xFFDCAC8F);
    final skinPaint = Paint()..color = const Color(0xFFF5CEB3);
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.5, h * 0.67), width: w * 0.22, height: h * 0.12), skinShadowPaint);

    // Structured Mature Face
    final headRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.51), width: w * 0.47, height: h * 0.45);
    canvas.drawOval(headRect, skinPaint);

    // Ears
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.26, h * 0.52), width: w * 0.08, height: h * 0.12), skinPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.74, h * 0.52), width: w * 0.08, height: h * 0.12), skinPaint);

    // Peaked Service Officer Cap
    final capPaint = Paint()..color = const Color(0xFF1E293B);
    final capPath = Path()
      ..moveTo(w * 0.20, h * 0.38)
      ..quadraticBezierTo(w * 0.22, h * 0.14, w * 0.50, h * 0.14)
      ..quadraticBezierTo(w * 0.78, h * 0.14, w * 0.80, h * 0.38)
      ..close();
    canvas.drawPath(capPath, capPaint);

    // Gold Cap Chin Strap & Star Badge
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * 0.5, h * 0.36), width: w * 0.60, height: h * 0.025), const Radius.circular(1)),
      goldPaint,
    );
    canvas.drawCircle(Offset(w * 0.5, h * 0.26), w * 0.04, goldPaint);

    // Polished Black Cap Visor
    final visorPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.39), width: w * 0.68, height: h * 0.09), visorPaint);

    // Professional Observant Eyebrows
    _drawRealisticEyebrow(canvas, Offset(w * 0.32, h * 0.46), Offset(w * 0.41, h * 0.44), Offset(w * 0.47, h * 0.46), const Color(0xFF0F172A), 2.2);
    _drawRealisticEyebrow(canvas, Offset(w * 0.53, h * 0.46), Offset(w * 0.59, h * 0.44), Offset(w * 0.68, h * 0.46), const Color(0xFF0F172A), 2.2);

    // Realistic Attentive Eyes
    _drawRealisticEye(canvas, Offset(w * 0.39, h * 0.49), w * 0.08, h * 0.042, const Color(0xFF2C3E50));
    _drawRealisticEye(canvas, Offset(w * 0.61, h * 0.49), w * 0.08, h * 0.042, const Color(0xFF2C3E50));

    // Strong Defined Nose
    _drawRealisticNose(canvas, Offset(w * 0.50, h * 0.48), Offset(w * 0.50, h * 0.57), const Color(0xFFC7957B));

    // Composed Professional Smile
    _drawRealisticMouth(canvas, Offset(w * 0.50, h * 0.63), w * 0.15, speakingT);
  }

  // =========================================================================
  // 3. BARISTA MATEO - REALISTIC ARTISAN SPECIALTY BARISTA
  // =========================================================================
  void _paintBaristaMateo(Canvas canvas, double w, double h) {
    // Forest Green Artisan Canvas Apron over White Roll-Sleeve Shirt
    final shirtPaint = Paint()..color = const Color(0xFFF1F5F9);
    final shirtPath = Path()
      ..moveTo(w * 0.12, h * 1.0)
      ..quadraticBezierTo(w * 0.25, h * 0.72, w * 0.5, h * 0.72)
      ..quadraticBezierTo(w * 0.75, h * 0.72, w * 0.88, h * 1.0)
      ..close();
    canvas.drawPath(shirtPath, shirtPaint);

    final apronPaint = Paint()..color = const Color(0xFF065F46); // Forest green apron
    final apronPath = Path()
      ..moveTo(w * 0.24, h * 1.0)
      ..lineTo(w * 0.30, h * 0.76)
      ..lineTo(w * 0.70, h * 0.76)
      ..lineTo(w * 0.76, h * 1.0)
      ..close();
    canvas.drawPath(apronPath, apronPaint);

    // Leather crossed straps with brass rivets
    final strapPaint = Paint()
      ..color = const Color(0xFF78350F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8;
    canvas.drawLine(Offset(w * 0.32, h * 0.76), Offset(w * 0.22, h * 1.0), strapPaint);
    canvas.drawLine(Offset(w * 0.68, h * 0.76), Offset(w * 0.78, h * 1.0), strapPaint);

    // Brass Rivets
    final rivetPaint = Paint()..color = const Color(0xFFD97706);
    canvas.drawCircle(Offset(w * 0.32, h * 0.78), w * 0.018, rivetPaint);
    canvas.drawCircle(Offset(w * 0.68, h * 0.78), w * 0.018, rivetPaint);

    // Neck
    final skinShadowPaint = Paint()..color = const Color(0xFFE0B496);
    final skinPaint = Paint()..color = const Color(0xFFF8D5B8);
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.5, h * 0.68), width: w * 0.20, height: h * 0.12), skinShadowPaint);

    // Warm Mediterranean Face
    final headRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.51), width: w * 0.46, height: h * 0.46);
    canvas.drawOval(headRect, skinPaint);

    // Ears
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.26, h * 0.52), width: w * 0.08, height: h * 0.12), skinPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.74, h * 0.52), width: w * 0.08, height: h * 0.12), skinPaint);

    // Short Textured Dark Wavy Hair
    final hairPaint = Paint()..color = const Color(0xFF3E2723);
    final hairPath = Path()
      ..moveTo(w * 0.24, h * 0.46)
      ..quadraticBezierTo(w * 0.23, h * 0.22, w * 0.50, h * 0.19)
      ..quadraticBezierTo(w * 0.77, h * 0.22, w * 0.76, h * 0.46)
      ..quadraticBezierTo(w * 0.69, h * 0.33, w * 0.53, h * 0.31)
      ..quadraticBezierTo(w * 0.36, h * 0.30, w * 0.24, h * 0.46)
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    // Warm Eyebrows
    _drawRealisticEyebrow(canvas, Offset(w * 0.32, h * 0.44), Offset(w * 0.40, h * 0.42), Offset(w * 0.46, h * 0.44), const Color(0xFF3E2723), 2.0);
    _drawRealisticEyebrow(canvas, Offset(w * 0.54, h * 0.44), Offset(w * 0.60, h * 0.42), Offset(w * 0.68, h * 0.44), const Color(0xFF3E2723), 2.0);

    // Chic Round Tortoiseshell Glasses
    final glassesPaint = Paint()
      ..color = const Color(0xFF78350F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawCircle(Offset(w * 0.38, h * 0.49), w * 0.075, glassesPaint);
    canvas.drawCircle(Offset(w * 0.62, h * 0.49), w * 0.075, glassesPaint);
    canvas.drawLine(Offset(w * 0.455, h * 0.49), Offset(w * 0.545, h * 0.49), glassesPaint);

    // Realistic Friendly Warm Eyes behind glasses
    _drawRealisticEye(canvas, Offset(w * 0.38, h * 0.49), w * 0.072, h * 0.040, const Color(0xFF451A03));
    _drawRealisticEye(canvas, Offset(w * 0.62, h * 0.49), w * 0.072, h * 0.040, const Color(0xFF451A03));

    // Nose
    _drawRealisticNose(canvas, Offset(w * 0.50, h * 0.48), Offset(w * 0.50, h * 0.56), const Color(0xFFCA9377));

    // Subtle neat groomed stubble shadow
    final stubblePaint = Paint()..color = const Color(0xFF78350F).withOpacity(0.08);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.64), width: w * 0.26, height: h * 0.12), stubblePaint);

    // Genuine Warm Barista Smile
    _drawRealisticMouth(canvas, Offset(w * 0.50, h * 0.63), w * 0.14, speakingT);
  }

  // =========================================================================
  // 4. DIRECTOR MARCUS - REALISTIC TECH EXECUTIVE
  // =========================================================================
  void _paintDirectorMarcus(Canvas canvas, double w, double h) {
    // Tailored Charcoal-Teal Executive Blazer
    final blazerPaint = Paint()..color = const Color(0xFF0F766E);
    final blazerPath = Path()
      ..moveTo(w * 0.11, h * 1.0)
      ..quadraticBezierTo(w * 0.24, h * 0.71, w * 0.5, h * 0.71)
      ..quadraticBezierTo(w * 0.76, h * 0.71, w * 0.89, h * 1.0)
      ..close();
    canvas.drawPath(blazerPath, blazerPaint);

    // Crisp Open-Collar Executive White Shirt
    final shirtPaint = Paint()..color = Colors.white;
    final shirtPath = Path()
      ..moveTo(w * 0.40, h * 0.71)
      ..lineTo(w * 0.50, h * 0.88)
      ..lineTo(w * 0.60, h * 0.71)
      ..close();
    canvas.drawPath(shirtPath, shirtPaint);

    // Lapel Notches
    final lapelPaint = Paint()
      ..color = const Color(0xFF115E59)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(w * 0.32, h * 0.71), Offset(w * 0.42, h * 0.86), lapelPaint);
    canvas.drawLine(Offset(w * 0.68, h * 0.71), Offset(w * 0.58, h * 0.86), lapelPaint);

    // Neck
    final skinShadowPaint = Paint()..color = const Color(0xFFD6B299);
    final skinPaint = Paint()..color = const Color(0xFFEED3BE);
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.5, h * 0.68), width: w * 0.21, height: h * 0.12), skinShadowPaint);

    // Distinguished Face
    final headRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.50), width: w * 0.46, height: h * 0.46);
    canvas.drawOval(headRect, skinPaint);

    // Ears
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.26, h * 0.51), width: w * 0.08, height: h * 0.12), skinPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.74, h * 0.51), width: w * 0.08, height: h * 0.12), skinPaint);

    // Modern Neat Executive Taper Fade
    final hairPaint = Paint()..color = const Color(0xFF1E293B);
    final hairPath = Path()
      ..moveTo(w * 0.24, h * 0.44)
      ..quadraticBezierTo(w * 0.23, h * 0.22, w * 0.50, h * 0.19)
      ..quadraticBezierTo(w * 0.77, h * 0.22, w * 0.76, h * 0.44)
      ..quadraticBezierTo(w * 0.66, h * 0.32, w * 0.50, h * 0.31)
      ..quadraticBezierTo(w * 0.34, h * 0.32, w * 0.24, h * 0.44)
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    // Modern Rectangular Titanium Glasses
    final glassesPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * 0.38, h * 0.48), width: w * 0.15, height: h * 0.08), const Radius.circular(3)),
      glassesPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * 0.62, h * 0.48), width: w * 0.15, height: h * 0.08), const Radius.circular(3)),
      glassesPaint,
    );
    canvas.drawLine(Offset(w * 0.455, h * 0.48), Offset(w * 0.545, h * 0.48), glassesPaint);

    // Focused Eyebrows
    _drawRealisticEyebrow(canvas, Offset(w * 0.32, h * 0.43), Offset(w * 0.40, h * 0.41), Offset(w * 0.46, h * 0.43), const Color(0xFF1E293B), 2.2);
    _drawRealisticEyebrow(canvas, Offset(w * 0.54, h * 0.43), Offset(w * 0.60, h * 0.41), Offset(w * 0.68, h * 0.43), const Color(0xFF1E293B), 2.2);

    // Focused Intellectual Eyes
    _drawRealisticEye(canvas, Offset(w * 0.38, h * 0.48), w * 0.075, h * 0.040, const Color(0xFF2D3748));
    _drawRealisticEye(canvas, Offset(w * 0.62, h * 0.48), w * 0.075, h * 0.040, const Color(0xFF2D3748));

    // Nose
    _drawRealisticNose(canvas, Offset(w * 0.50, h * 0.47), Offset(w * 0.50, h * 0.56), const Color(0xFFBA8E74));

    // Confident Executive Smile
    _drawRealisticMouth(canvas, Offset(w * 0.50, h * 0.62), w * 0.14, speakingT);
  }

  // =========================================================================
  // 5. CONCIERGE PIERRE - REALISTIC LUXURY HOTEL CONCIERGE
  // =========================================================================
  void _paintConciergePierre(Canvas canvas, double w, double h) {
    // Tailored Burgundy Concierge Vest
    final vestPaint = Paint()..color = const Color(0xFF881337);
    final vestPath = Path()
      ..moveTo(w * 0.12, h * 1.0)
      ..quadraticBezierTo(w * 0.25, h * 0.72, w * 0.5, h * 0.72)
      ..quadraticBezierTo(w * 0.75, h * 0.72, w * 0.88, h * 1.0)
      ..close();
    canvas.drawPath(vestPath, vestPaint);

    // Crisp High-Collar Formal Shirt
    final shirtPaint = Paint()..color = Colors.white;
    final shirtPath = Path()
      ..moveTo(w * 0.41, h * 0.72)
      ..lineTo(w * 0.5, h * 0.84)
      ..lineTo(w * 0.59, h * 0.72)
      ..close();
    canvas.drawPath(shirtPath, shirtPaint);

    // Elegant Silk Bow Tie
    final bowPaint = Paint()..color = const Color(0xFF1E293B);
    final leftWing = Path()
      ..moveTo(w * 0.5, h * 0.77)
      ..lineTo(w * 0.42, h * 0.73)
      ..lineTo(w * 0.42, h * 0.81)
      ..close();
    final rightWing = Path()
      ..moveTo(w * 0.5, h * 0.77)
      ..lineTo(w * 0.58, h * 0.73)
      ..lineTo(w * 0.58, h * 0.81)
      ..close();
    canvas.drawPath(leftWing, bowPaint);
    canvas.drawPath(rightWing, bowPaint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.77), w * 0.028, bowPaint);

    // Golden "Les Clefs d'Or" Crossed Keys Pin on Left Lapel
    final goldPin = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.28, h * 0.79), Offset(w * 0.34, h * 0.85), goldPin);
    canvas.drawLine(Offset(w * 0.34, h * 0.79), Offset(w * 0.28, h * 0.85), goldPin);
    canvas.drawCircle(Offset(w * 0.31, h * 0.82), w * 0.015, Paint()..color = const Color(0xFFF59E0B));

    // Neck
    final skinShadowPaint = Paint()..color = const Color(0xFFDEB499);
    final skinPaint = Paint()..color = const Color(0xFFF5D0B5);
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.5, h * 0.68), width: w * 0.20, height: h * 0.12), skinShadowPaint);

    // Refined Parisian Face
    final headRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.50), width: w * 0.46, height: h * 0.46);
    canvas.drawOval(headRect, skinPaint);

    // Ears
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.26, h * 0.51), width: w * 0.08, height: h * 0.12), skinPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.74, h * 0.51), width: w * 0.08, height: h * 0.12), skinPaint);

    // Side-Parted Slate / Silver-Tinged Hair
    final hairPaint = Paint()..color = const Color(0xFF475569);
    final hairPath = Path()
      ..moveTo(w * 0.24, h * 0.44)
      ..quadraticBezierTo(w * 0.23, h * 0.21, w * 0.50, h * 0.19)
      ..quadraticBezierTo(w * 0.77, h * 0.21, w * 0.76, h * 0.44)
      ..quadraticBezierTo(w * 0.67, h * 0.31, w * 0.50, h * 0.30)
      ..quadraticBezierTo(w * 0.33, h * 0.31, w * 0.24, h * 0.44)
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    // Refined Eyebrows
    _drawRealisticEyebrow(canvas, Offset(w * 0.33, h * 0.44), Offset(w * 0.41, h * 0.42), Offset(w * 0.46, h * 0.44), const Color(0xFF334155), 2.0);
    _drawRealisticEyebrow(canvas, Offset(w * 0.54, h * 0.44), Offset(w * 0.59, h * 0.42), Offset(w * 0.67, h * 0.44), const Color(0xFF334155), 2.0);

    // Attentive Courteous Eyes
    _drawRealisticEye(canvas, Offset(w * 0.39, h * 0.48), w * 0.078, h * 0.042, const Color(0xFF334155));
    _drawRealisticEye(canvas, Offset(w * 0.61, h * 0.48), w * 0.078, h * 0.042, const Color(0xFF334155));

    // Refined Aristocratic Nose
    _drawRealisticNose(canvas, Offset(w * 0.50, h * 0.47), Offset(w * 0.50, h * 0.56), const Color(0xFFC9957B));

    // Finely Groomed Parisian Curved Mustache
    final stachePaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final stachePath = Path()
      ..moveTo(w * 0.38, h * 0.59)
      ..quadraticBezierTo(w * 0.45, h * 0.61, w * 0.50, h * 0.59)
      ..quadraticBezierTo(w * 0.55, h * 0.61, w * 0.62, h * 0.59);
    canvas.drawPath(stachePath, stachePaint);

    // Polite Diplomatic Smile
    _drawRealisticMouth(canvas, Offset(w * 0.50, h * 0.63), w * 0.13, speakingT);
  }

  // =========================================================================
  // REALISTIC HUMAN DETAIL HELPERS (NO ANIME / NO LED / NO 3D)
  // =========================================================================
  void _drawRealisticEye(Canvas canvas, Offset center, double width, double height, Color irisColor) {
    // Sclera (Eye white)
    final scleraPaint = Paint()..color = const Color(0xFFFAFAFA);
    final eyeRect = Rect.fromCenter(center: center, width: width, height: height);
    canvas.drawOval(eyeRect, scleraPaint);

    // Iris
    final irisRadius = height * 0.44;
    final irisPaint = Paint()..color = irisColor;
    canvas.drawCircle(center, irisRadius, irisPaint);

    // Pupil
    final pupilPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawCircle(center, irisRadius * 0.50, pupilPaint);

    // Crisp Specular Light Dot
    final specPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - irisRadius * 0.32, center.dy - irisRadius * 0.32), irisRadius * 0.28, specPaint);

    // Natural Eyelid Line
    final lidPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final lidPath = Path()
      ..moveTo(center.dx - width * 0.5, center.dy)
      ..quadraticBezierTo(center.dx, center.dy - height * 0.65, center.dx + width * 0.5, center.dy);
    canvas.drawPath(lidPath, lidPaint);
  }

  void _drawRealisticEyebrow(Canvas canvas, Offset start, Offset mid, Offset end, Color color, double thickness) {
    final browPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;
    final browPath = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, end.dx, end.dy);
    canvas.drawPath(browPath, browPaint);
  }

  void _drawRealisticNose(Canvas canvas, Offset bridge, Offset tip, Color color) {
    final nosePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    final nosePath = Path()
      ..moveTo(bridge.dx, bridge.dy)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(tip.dx + 4.0, tip.dy);
    canvas.drawPath(nosePath, nosePaint);
  }

  void _drawRealisticMouth(Canvas canvas, Offset center, double width, double speakingT) {
    final lipColor = const Color(0xFFB91C1C).withOpacity(0.70);
    final openH = 2.0 + (speakingT * 5.0);

    if (openH > 3.0) {
      // Gentle opening while speaking
      final mouthPaint = Paint()..color = const Color(0xFF450A0A);
      final mouthPath = Path()
        ..moveTo(center.dx - width * 0.5, center.dy)
        ..quadraticBezierTo(center.dx, center.dy + openH, center.dx + width * 0.5, center.dy)
        ..close();
      canvas.drawPath(mouthPath, mouthPaint);

      // White teeth line
      final teethPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(center.dx - width * 0.25, center.dy + 1.2),
        Offset(center.dx + width * 0.25, center.dy + 1.2),
        teethPaint,
      );
    } else {
      // Natural serene smile line
      final smilePaint = Paint()
        ..color = lipColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      final smilePath = Path()
        ..moveTo(center.dx - width * 0.5, center.dy)
        ..quadraticBezierTo(center.dx, center.dy + 3.0, center.dx + width * 0.5, center.dy);
      canvas.drawPath(smilePath, smilePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CharmingCharacterPainter oldDelegate) {
    return oldDelegate.speakingT != speakingT || oldDelegate.type != type;
  }
}

