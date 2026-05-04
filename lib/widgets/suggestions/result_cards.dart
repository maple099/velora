import 'package:flutter/material.dart';

import '../../screens/suggestions/recipe_detail_page.dart';
import 'recipe_result_tile.dart';

class ResultCards extends StatelessWidget {
  final List<Map<String, String>> recipes;

  const ResultCards({super.key, required this.recipes});

  String _previewText(String content) {
    final clean = content
        .replaceAll('*', '')
        .replaceAll('#', '')
        .replaceAll('-', '')
        .trim();

    final lines = clean
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) return 'Tap to view this AI suggestion.';

    return lines.first.length > 80
        ? '${lines.first.substring(0, 80)}...'
        : lines.first;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: recipes.map((recipe) {
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
      }).toList(),
    );
  }
}
