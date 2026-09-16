import 'dart:math' as math;
import 'package:flutter/material.dart';

class BossCanvasWidget extends StatefulWidget {
  final String avatarId;
  final double size;
  final bool isAttacking;
  final bool isTakingDamage;
  final bool isDefeated;

  const BossCanvasWidget({
    super.key,
    required this.avatarId,
    this.size = 180,
    this.isAttacking = false,
    this.isTakingDamage = false,
    this.isDefeated = false,
  });

  @override
  State<BossCanvasWidget> createState() => _BossCanvasWidgetState();
}

class _BossCanvasWidgetState extends State<BossCanvasWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _entryController;
  late AnimationController _lungeController;

  @override
  void initState() {
    super.initState();
    // 1. Idle Breathing & Levitating
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // 2. Entrance Spring
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // 3. Attack Lunge
    _lungeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
  }

  @override
  void didUpdateWidget(covariant BossCanvasWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAttacking && !oldWidget.isAttacking) {
      _lungeController.forward(from: 0.0).then((_) {
        if (mounted) _lungeController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _entryController.dispose();
    _lungeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _entryController, _lungeController]),
      builder: (context, child) {
        // Entrance curve
        final entryScale = CurvedAnimation(
          parent: _entryController,
          curve: Curves.easeOutBack,
        ).value;
        final entryOpacity = CurvedAnimation(
          parent: _entryController,
          curve: Curves.easeIn,
        ).value;

        // Floating idle hover (sine wave)
        final idleHoverY = math.sin(_pulseController.value * 2 * math.pi) * 8.0;

        // Attack Lunge (forward thrust)
        final lungeY = _lungeController.value * 22.0;

        // Damage Shudder (high frequency shake)
        final damageShakeX = widget.isTakingDamage
            ? math.sin(_pulseController.value * 30 * math.pi) * 7.0
            : 0.0;

        // Defeat scale & opacity
        final defeatScale = widget.isDefeated ? 0.0 : 1.0;

        final totalScale = entryScale * defeatScale * (0.97 + (_pulseController.value * 0.04));
        final totalY = idleHoverY + lungeY;

        return Opacity(
          opacity: (entryOpacity * defeatScale).clamp(0.0, 1.0),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(damageShakeX, totalY)
              ..scale(totalScale, totalScale),
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _getPainter(
                widget.avatarId,
                _pulseController.value,
                widget.isAttacking,
                widget.isTakingDamage,
              ),
            ),
          ),
        );
      },
    );
  }

  CustomPainter _getPainter(
    String id,
    double progress,
    bool isAttacking,
    bool isTakingDamage,
  ) {
    switch (id) {
      case 'monotone_warden':
        return MonotoneWardenPainter(
          pulse: progress,
          isAttacking: isAttacking,
          isTakingDamage: isTakingDamage,
        );
      case 'redundant_colossus':
        return RedundantColossusPainter(
          pulse: progress,
          isAttacking: isAttacking,
          isTakingDamage: isTakingDamage,
        );
      case 'sphinx_ambiguity':
        return SphinxAmbiguityPainter(
          pulse: progress,
          isAttacking: isAttacking,
          isTakingDamage: isTakingDamage,
        );
      case 'echo_master':
        return EchoMasterPainter(
          pulse: progress,
          isAttacking: isAttacking,
          isTakingDamage: isTakingDamage,
        );
      default:
        return SyntaxGolemPainter(
          pulse: progress,
          isAttacking: isAttacking,
          isTakingDamage: isTakingDamage,
        );
    }
  }
}

// 1. THE MONOTONE WARDEN
class MonotoneWardenPainter extends CustomPainter {
  final double pulse;
  final bool isAttacking;
  final bool isTakingDamage;

  const MonotoneWardenPainter({
    required this.pulse,
    required this.isAttacking,
    required this.isTakingDamage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.44;

    // Background Aura Glow
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          (isTakingDamage
                  ? const Color(0xFFEF4444)
                  : (isAttacking ? const Color(0xFFF59E0B) : const Color(0xFF0284C7)))
              .withOpacity(0.35 + (pulse * 0.15)),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.3));
    canvas.drawCircle(center, radius * 1.3, auraPaint);

    // Mechanical Torso / Plate
    final armorPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    final armorBorder = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Hexagonal Head & Shoulders
    final path = Path();
    final top = center.dy - radius * 0.75;
    final bottom = center.dy + radius * 0.75;
    final left = center.dx - radius * 0.75;
    final right = center.dx + radius * 0.75;

    path.moveTo(center.dx, top);
    path.lineTo(right, center.dy - radius * 0.3);
    path.lineTo(right * 0.9, bottom);
    path.lineTo(center.dx, bottom * 0.92);
    path.lineTo(left * 1.1, bottom);
    path.lineTo(left, center.dy - radius * 0.3);
    path.close();

    canvas.drawPath(path, armorPaint);
    canvas.drawPath(path, armorBorder);

    // Visor: Horizontal Acoustic Waveform
    final visorRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - radius * 0.2),
      width: radius * 1.0,
      height: 18,
    );
    final visorPaint = Paint()..color = const Color(0xFF0284C7);
    canvas.drawRRect(RRect.fromRectAndRadius(visorRect, const Radius.circular(9)), visorPaint);

    // Visor Core Slit
    final slitPaint = Paint()
      ..color = isTakingDamage ? Colors.redAccent : const Color(0xFFE0F2FE)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(visorRect.left + 8, visorRect.center.dy),
      Offset(visorRect.right - 8, visorRect.center.dy),
      slitPaint,
    );

    // Acoustic Frequency Ring in Chest
    final coreCenter = Offset(center.dx, center.dy + radius * 0.32);
    final coreRadius = 24.0 + (pulse * 4.0);
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF38BDF8),
          const Color(0xFF0284C7).withOpacity(0.2),
        ],
      ).createShader(Rect.fromCircle(center: coreCenter, radius: coreRadius));
    canvas.drawCircle(coreCenter, coreRadius, corePaint);

    // Oscillating Sine Ring
    final ringPaint = Paint()
      ..color = const Color(0xFFBAE6FD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(coreCenter, 14, ringPaint);
  }

  @override
  bool shouldRepaint(covariant MonotoneWardenPainter oldDelegate) {
    return oldDelegate.pulse != pulse ||
        oldDelegate.isAttacking != isAttacking ||
        oldDelegate.isTakingDamage != isTakingDamage;
  }
}

// 2. THE REDUNDANT COLOSSUS
class RedundantColossusPainter extends CustomPainter {
  final double pulse;
  final bool isAttacking;
  final bool isTakingDamage;

  const RedundantColossusPainter({
    required this.pulse,
    required this.isAttacking,
    required this.isTakingDamage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.45;

    // Emerald / Jade Aura
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          (isTakingDamage ? const Color(0xFFEF4444) : const Color(0xFF059669))
              .withOpacity(0.35 + (pulse * 0.15)),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.3));
    canvas.drawCircle(center, radius * 1.3, auraPaint);

    // Stone Monolith Body (Pyramidal Steps)
    final stonePaint = Paint()..color = const Color(0xFF1E293B);
    final stoneBorder = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Outer Octagon
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) + (math.pi / 8);
      final r = radius * 0.85;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, stonePaint);
    canvas.drawPath(path, stoneBorder);

    // Inner Runic Inscription Plate
    final innerR = radius * 0.52 + (pulse * 3);
    final innerPaint = Paint()
      ..color = const Color(0xFF064E3B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerR, innerPaint);

    // Glowing Central Glyph (Tri-pillar syntax rune)
    final glyphPaint = Paint()
      ..color = const Color(0xFF6EE7B7)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx - 18, center.dy - 22),
      Offset(center.dx - 18, center.dy + 22),
      glyphPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 28),
      Offset(center.dx, center.dy + 28),
      glyphPaint,
    );
    canvas.drawLine(
      Offset(center.dx + 18, center.dy - 22),
      Offset(center.dx + 18, center.dy + 22),
      glyphPaint,
    );
    canvas.drawLine(
      Offset(center.dx - 24, center.dy - 12),
      Offset(center.dx + 24, center.dy - 12),
      glyphPaint,
    );
  }

  @override
  bool shouldRepaint(covariant RedundantColossusPainter oldDelegate) => true;
}

// 3. THE SPHINX OF AMBIGUITY
class SphinxAmbiguityPainter extends CustomPainter {
  final double pulse;
  final bool isAttacking;
  final bool isTakingDamage;

  const SphinxAmbiguityPainter({
    required this.pulse,
    required this.isAttacking,
    required this.isTakingDamage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.45;

    // Golden Amber Radiance
    final aura = Paint()
      ..shader = RadialGradient(
        colors: [
          (isTakingDamage ? const Color(0xFFEF4444) : const Color(0xFFD97706))
              .withOpacity(0.35 + (pulse * 0.15)),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.3));
    canvas.drawCircle(center, radius * 1.3, aura);

    // Geometric Wing Blades
    final wingPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (int side in [-1, 1]) {
      final wingPath = Path();
      wingPath.moveTo(center.dx + (side * 20), center.dy);
      wingPath.lineTo(center.dx + (side * radius * 0.9), center.dy - radius * 0.6);
      wingPath.lineTo(center.dx + (side * radius * 0.6), center.dy - radius * 0.1);
      wingPath.lineTo(center.dx + (side * radius * 0.8), center.dy + radius * 0.4);
      wingPath.close();
      canvas.drawPath(wingPath, wingPaint);
    }

    // All-Seeing Rhombus Face
    final facePaint = Paint()..color = const Color(0xFF1E1B4B);
    final faceBorder = Paint()
      ..color = const Color(0xFFFCD34D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final facePath = Path();
    facePath.moveTo(center.dx, center.dy - radius * 0.65);
    facePath.lineTo(center.dx + radius * 0.45, center.dy);
    facePath.lineTo(center.dx, center.dy + radius * 0.65);
    facePath.lineTo(center.dx - radius * 0.45, center.dy);
    facePath.close();

    canvas.drawPath(facePath, facePaint);
    canvas.drawPath(facePath, faceBorder);

    // Central Prism Eye
    final eyePaint = Paint()
      ..color = const Color(0xFFFDE68A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 14 + (pulse * 4), eyePaint);

    final pupilPaint = Paint()..color = const Color(0xFF451A03);
    canvas.drawCircle(center, 6, pupilPaint);
  }

  @override
  bool shouldRepaint(covariant SphinxAmbiguityPainter oldDelegate) => true;
}

// 4. THE ECHO MASTER
class EchoMasterPainter extends CustomPainter {
  final double pulse;
  final bool isAttacking;
  final bool isTakingDamage;

  const EchoMasterPainter({
    required this.pulse,
    required this.isAttacking,
    required this.isTakingDamage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.46;

    // Deep Royal Violet Nebula
    final nebula = Paint()
      ..shader = RadialGradient(
        colors: [
          (isTakingDamage ? const Color(0xFFEF4444) : const Color(0xFF7C3AED))
              .withOpacity(0.4 + (pulse * 0.15)),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.3));
    canvas.drawCircle(center, radius * 1.3, nebula);

    // Orbital Resonance Rings (3 concentric pulsing ellipses)
    final ringPaint = Paint()
      ..color = const Color(0xFFA78BFA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 1; i <= 3; i++) {
      final r = (radius * 0.3 * i) + (pulse * 6 * (i % 2 == 0 ? -1 : 1));
      canvas.drawCircle(center, r, ringPaint);

      // Rotating Node on each ring
      final angle = (pulse * 2 * math.pi) + (i * math.pi / 2);
      final nx = center.dx + r * math.cos(angle);
      final ny = center.dy + r * math.sin(angle);
      final nodePaint = Paint()..color = const Color(0xFFEDE9FE);
      canvas.drawCircle(Offset(nx, ny), 5.5, nodePaint);
    }

    // Radiant Core Singularity
    final corePaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Colors.white,
          Color(0xFF8B5CF6),
          Color(0xFF4C1D95),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 24));
    canvas.drawCircle(center, 22 + (pulse * 3), corePaint);
  }

  @override
  bool shouldRepaint(covariant EchoMasterPainter oldDelegate) => true;
}

// 5. SYNTAX GOLEM (Generic Mob)
class SyntaxGolemPainter extends CustomPainter {
  final double pulse;
  final bool isAttacking;
  final bool isTakingDamage;

  const SyntaxGolemPainter({
    required this.pulse,
    required this.isAttacking,
    required this.isTakingDamage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          (isTakingDamage ? const Color(0xFFEF4444) : const Color(0xFF0284C7))
              .withOpacity(0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.2));
    canvas.drawCircle(center, radius * 1.2, glow);

    // Diamond Shards
    final shardPaint = Paint()..color = const Color(0xFF1E293B);
    final shardBorder = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    path.moveTo(center.dx, center.dy - radius * 0.7);
    path.lineTo(center.dx + radius * 0.6, center.dy);
    path.lineTo(center.dx, center.dy + radius * 0.7);
    path.lineTo(center.dx - radius * 0.6, center.dy);
    path.close();

    canvas.drawPath(path, shardPaint);
    canvas.drawPath(path, shardBorder);

    // Glowing Cross
    final crossPaint = Paint()
      ..color = const Color(0xFF7DD3FC)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx - 16, center.dy),
      Offset(center.dx + 16, center.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 16),
      Offset(center.dx, center.dy + 16),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant SyntaxGolemPainter oldDelegate) => true;
}
