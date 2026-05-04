import 'package:flutter/material.dart';

class QuotaStatusCard extends StatelessWidget {
  final int used;
  final int limit;
  final int remaining;
  final int cooldownSeconds;
  final String resetCountdown;
  final String resetTimeText;

  const QuotaStatusCard({
    super.key,
    required this.used,
    required this.limit,
    required this.remaining,
    required this.cooldownSeconds,
    required this.resetCountdown,
    required this.resetTimeText,
  });

  @override
  Widget build(BuildContext context) {
    final isCooling = cooldownSeconds > 0;
    final isLow = remaining <= 3;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCooling ? const Color(0xFFFFF7ED) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isCooling ? const Color(0xFFFED7AA) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isCooling
                  ? const Color(0xFFFFEDD5)
                  : const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isCooling ? Icons.timer_rounded : Icons.bolt_rounded,
              color: isCooling
                  ? const Color(0xFFF97316)
                  : const Color(0xFF7C3AED),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCooling
                      ? 'Try again in $cooldownSeconds seconds'
                      : '$remaining / $limit AI requests left today',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: isCooling
                        ? const Color(0xFF9A3412)
                        : isLow
                        ? const Color(0xFFB45309)
                        : const Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Reset estimate: $resetCountdown',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  resetTimeText,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
