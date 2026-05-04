import 'package:flutter/material.dart';

class HeaderCard extends StatelessWidget {
  final int totalItems;
  final int nearExpiry;

  const HeaderCard({
    super.key,
    required this.totalItems,
    required this.nearExpiry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 34),
          SizedBox(height: 14),
          Text(
            'Let AI help you today!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Get recipe ideas and restock recommendations.',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
          ),
          SizedBox(height: 18),
        ],
      ),
    );
  }
}
