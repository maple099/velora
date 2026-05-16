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
    final isCoolingDown = cooldownSeconds > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Groq AI Status',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _StatusRow(label: 'Status', value: geminiStatus),
          _StatusRow(label: 'Used Today', value: '$used / $limit'),
          _StatusRow(label: 'Remaining', value: '$remaining'),
          if (resetCountdown.isNotEmpty)
            _StatusRow(label: 'Reset In', value: resetCountdown),
          if (resetTimeText.isNotEmpty)
            _StatusRow(label: 'Reset Time', value: resetTimeText),
          if (isCoolingDown)
            _StatusRow(label: 'Cooldown', value: '$cooldownSeconds seconds'),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatusRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.78),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
