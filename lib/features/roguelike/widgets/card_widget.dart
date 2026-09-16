import 'package:flutter/material.dart';
import '../cards/linguistic_card.dart';

class CardWidget extends StatelessWidget {
  final LinguisticCard card;
  final bool isSelected;
  final bool isPlayable;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const CardWidget({
    super.key,
    required this.card,
    this.isSelected = false,
    this.isPlayable = true,
    this.onTap,
    this.width = 135,
    this.height = 190,
  });

  @override
  Widget build(BuildContext context) {
    final borderGlow = card.rarityColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: width,
      height: height,
      transform: isSelected
          ? (Matrix4.identity()..translate(0.0, -14.0))
          : Matrix4.identity(),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark slate card body
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.white : borderGlow.withOpacity(isPlayable ? 0.8 : 0.25),
          width: isSelected ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isSelected ? borderGlow : Colors.black).withOpacity(isSelected ? 0.45 : 0.3),
            blurRadius: isSelected ? 16 : 8,
            offset: Offset(0, isSelected ? 4 : 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isPlayable ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Row: Energy Orb & Type Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Energy Orb
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withOpacity(0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${card.energyCost}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),

                    // Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: card.typeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: card.typeColor.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(card.typeIcon, size: 11, color: card.typeColor),
                          const SizedBox(width: 3),
                          Text(
                            card.type.name.toUpperCase(),
                            style: TextStyle(
                              color: card.typeColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // 2. English Phrase
                Text(
                  card.phrase,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),

                const SizedBox(height: 3),

                // 3. IPA Phonetics
                Text(
                  card.ipa,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10,
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                // 4. Effect Description
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    card.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFE2E8F0),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // 5. Bottom Status: CEFR & Critical Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      card.cefrLevel,
                      style: TextStyle(
                        color: card.rarityColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          size: 11,
                          color: Color(0xFFFBBF24),
                        ),
                        SizedBox(width: 2),
                        Text(
                          'CRIT x2',
                          style: TextStyle(
                            color: Color(0xFFFBBF24),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
