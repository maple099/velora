import 'package:flutter/material.dart';

import '../../screens/suggestions/recipe_detail_page.dart';
import 'recipe_result_tile.dart';

class ResultCards extends StatelessWidget {
  final List<Map<String, String>> recipes;

  const ResultCards({super.key, required this.recipes});

  bool _isError(String text) {
    final lower = text.toLowerCase();

    return lower.contains('gemini failed') ||
        lower.contains('gemini error') ||
        lower.contains('api key') ||
        lower.contains('internet') ||
        lower.contains('failed to generate');
  }

  String _previewText(String content) {
    final clean = content
        .replaceAll('*', '')
        .replaceAll('#', '')
        .replaceAll('-', '')
        .trim();

    final lines = clean
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (lines.isEmpty) return 'Tap to view full AI suggestion.';

    return lines.first.length > 80
        ? '${lines.first.substring(0, 80)}...'
        : lines.first;
  }

  @override
  Widget build(BuildContext context) {
    final firstText = recipes.isNotEmpty
        ? '${recipes.first['title'] ?? ''} ${recipes.first['content'] ?? ''}'
        : '';

    /// 🔥 SHOW ERROR (WITH REAL MESSAGE)
    if (_isError(firstText)) {
      return _ErrorCard(message: firstText);
    }

    /// 🔥 NORMAL RESULT
    return Column(
      children: [
        _InfoBanner(count: recipes.length),
        const SizedBox(height: 12),

        ...recipes.map((recipe) {
          final title = recipe['title'] ?? 'AI Suggestion';
          final content = recipe['content'] ?? '';

          return RecipeResultTile(
            title: title,
            subtitle: _previewText(content),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      RecipeDetailPage(title: title, content: content),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFF97316),
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message, // 🔥 SHOW REAL ERROR HERE
              style: const TextStyle(
                color: Color(0xFF9A3412),
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final int count;

  const _InfoBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9D5FF)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Gemini found $count suggestion${count == 1 ? '' : 's'} for you. Tap one recipe to view full details.',
              style: const TextStyle(
                color: Color(0xFF6B21A8),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
