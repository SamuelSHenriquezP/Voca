import 'package:flutter/material.dart';
import '../../../core/widgets/bouncy_tap.dart';

class ExerciseHeader extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int hearts;
  final VoidCallback onClose;
  final VoidCallback? onPerksTap;

  const ExerciseHeader({
    super.key,
    required this.progress,
    required this.hearts,
    required this.onClose,
    this.onPerksTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.0),
          ),
        ),
        child: Row(
          children: [
            // Minimalist Close Button
            BouncyTap(
              onTap: onClose,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Color(0xFF64748B),
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Clean Minimalist Hairline Progress Bar
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.02, 1.0),
                  minHeight: 6,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F172A)),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Quiet Minimalist Lives Counter Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_rounded, color: Color(0xFF0F172A), size: 14),
                  const SizedBox(width: 5),
                  Text(
                    '$hearts',
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            // Optional Tactical Perks Menu Button
            if (onPerksTap != null) ...[
              const SizedBox(width: 8),
              BouncyTap(
                onTap: onPerksTap,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFF0F172A),
                    size: 15,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

