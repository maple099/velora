import 'package:flutter/material.dart';

class ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isPrimary ? const Color(0xFF7C3AED) : Colors.white;
    final textColor = isPrimary ? Colors.white : const Color(0xFF7C3AED);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: textColor, size: 26),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isPrimary ? Colors.white70 : const Color(0xFF6B7280),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
