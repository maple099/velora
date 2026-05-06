import 'package:flutter/material.dart';

class QuotaStatusCard extends StatelessWidget {
  final int used;
  final int limit;
  final int remaining;
  final int cooldownSeconds;
  final String resetCountdown;
  final String resetTimeText;
  final String geminiStatus;

  const QuotaStatusCard({
    super.key,
    required this.used,
    required this.limit,
    required this.remaining,
    required this.cooldownSeconds,
    required this.resetCountdown,
    required this.resetTimeText,
    required this.geminiStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isQuota = geminiStatus.toLowerCase().contains('quota');

    final color = isQuota ? const Color(0xFFEF4444) : const Color(0xFF7C3AED);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$remaining / $limit Velora requests left today',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reset estimate: $resetCountdown',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            resetTimeText,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Gemini API: $geminiStatus',
                    style: TextStyle(
                      color: color,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
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
