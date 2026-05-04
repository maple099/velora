import 'package:flutter/material.dart';

class EmptyCard extends StatelessWidget {
  final String text;

  const EmptyCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }
}
