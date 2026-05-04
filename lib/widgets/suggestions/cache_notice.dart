import 'package:flutter/material.dart';

class CacheNotice extends StatelessWidget {
  const CacheNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Showing cached AI result to save Gemini quota.',
              style: TextStyle(
                color: Color(0xFF047857),
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
