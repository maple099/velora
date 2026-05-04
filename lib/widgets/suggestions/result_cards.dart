import 'package:flutter/material.dart';

class ResultCards extends StatelessWidget {
  final List<Map<String, String>> recipes;

  const ResultCards({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: recipes.map((recipe) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe['title'] ?? 'AI Suggestion',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF7C3AED),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                recipe['content'] ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
