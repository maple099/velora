import 'package:shared_preferences/shared_preferences.dart';

class SkippedRecipeService {
  static const String _key = 'velora_skipped_recipe_titles';

  const SkippedRecipeService();

  Future<List<String>> getSkippedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> skipRecipe(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final skippedRecipes = prefs.getStringList(_key) ?? [];

    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) return;

    final exists = skippedRecipes.any(
      (item) => _cleanTitle(item) == _cleanTitle(cleanTitle),
    );

    if (exists) return;

    skippedRecipes.add(cleanTitle);
    await prefs.setStringList(_key, skippedRecipes);
  }

  Future<void> clearSkippedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<List<T>> filterSkippedRecipes<T>({
    required List<T> recipes,
    required String Function(T recipe) titleGetter,
  }) async {
    final skippedRecipes = await getSkippedRecipes();

    if (skippedRecipes.isEmpty) return recipes;

    return recipes.where((recipe) {
      final title = _cleanTitle(titleGetter(recipe));

      return !skippedRecipes.any(
        (skippedTitle) => _cleanTitle(skippedTitle) == title,
      );
    }).toList();
  }

  String _cleanTitle(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
