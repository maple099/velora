import '../../../models/inventory_item.dart';

class FallbackRecipeBuilder {
  static Map<String, dynamic>? build(List<InventoryItem> items) {
    final names = items
        .map((item) => item.name.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .take(3)
        .toList();

    if (names.isEmpty) return null;

    final title = '${_titleCase(names.take(2).join(' '))} Quick Stir Fry';

    return {
      'title': title,
      'content': _content(title, names),
      'ingredients': names,
      'steps': [
        'Wash and prepare the ingredients.',
        'Cut the ingredients into small pieces.',
        'Heat a pan with a little oil.',
        'Cook the ingredients for a few minutes.',
        'Serve while hot.',
      ],
      'nearExpiryIngredients': names,
      'whyRecommended':
          'This fallback recipe uses available inventory items when Gemini quota is limited.',
    };
  }

  static String _content(String title, List<String> names) {
    return '''
$title

Ingredients:
${names.map((name) => '- $name').join('\n')}

Steps:
1. Wash and prepare the ingredients.
2. Cut the ingredients into small pieces.
3. Heat a pan with a little oil.
4. Cook the ingredients for a few minutes.
5. Serve while hot.

Why:
This recipe helps use available inventory items while Gemini quota is limited.
''';
  }

  static String _titleCase(String text) {
    return text
        .split(' ')
        .where((word) => word.trim().isNotEmpty)
        .map((word) {
          final clean = word.trim();
          return clean[0].toUpperCase() + clean.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
