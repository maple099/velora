import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../logic/ai_generate_service.dart';
import '../../logic/ai_inventory_checker.dart';
import '../../logic/ai_quota_service.dart';
import '../../logic/ai_reset_helper.dart';
import '../../logic/cook_now_service.dart';
import '../../logic/gemini_service.dart';
import '../../logic/suggestion_helper.dart';
import '../../models/inventory_item.dart';
import '../../widgets/suggestions/cache_notice.dart';
import '../../widgets/suggestions/empty_card.dart';
import '../../widgets/suggestions/inventory_changed_card.dart';
import '../../widgets/suggestions/premium_loading_card.dart';
import '../../widgets/suggestions/quota_status_card.dart';
import '../../widgets/suggestions/result_cards.dart';
import '../../widgets/suggestions/suggestion_sections.dart';
import 'recipe_detail_page.dart';
import 'utils/recipe_parser.dart';
import 'widgets/recipe_preview_card.dart';

class SuggestionsPage extends StatefulWidget {
  const SuggestionsPage({super.key});

  @override
  State<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  final GeminiService _gemini = GeminiService();
  final CookNowService _cookNowService = CookNowService();
  final AiQuotaService _quotaService = AiQuotaService();
  final AiGenerateService _aiService = AiGenerateService();
  final AiInventoryChecker _inventoryChecker = AiInventoryChecker();
  final SuggestionHelper _helper = SuggestionHelper();

  bool _isLoading = false;
  bool _isCached = false;
  bool _isRecipeResult = true;
  bool _didAutoLoad = false;
  bool _inventoryChanged = false;

  int _usedQuota = 0;
  int _cooldownSeconds = 0;

  Timer? _cooldownTimer;
  Timer? _resetTimer;

  String _resultText = '';
  String _resultSignature = '';
  String _resetCountdown = '';
  String _resetTimeText = '';

  @override
  void initState() {
    super.initState();
    _loadQuota();
    _updateResetCountdown();

    _resetTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateResetCountdown();
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _resetTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuota() async {
    final used = await _quotaService.getUsedToday();
    if (!mounted) return;
    setState(() => _usedQuota = used);
  }

  void _updateResetCountdown() {
    final data = AiResetHelper.getResetInfo();
    if (!mounted) return;

    setState(() {
      _resetCountdown = data['countdown'] ?? '';
      _resetTimeText = data['timeText'] ?? '';
    });
  }

  Future<void> _autoLoadCache(List<InventoryItem> items) async {
    if (_didAutoLoad) return;
    _didAutoLoad = true;

    final data = await _aiService.generate(
      type: 'recipes_v2',
      items: items,
      fetcher: () => _gemini.generateRecipeSuggestions(items),
    );

    if (!mounted) return;
    if (data['isError'] == true || data['isCached'] != true) return;

    setState(() {
      _resultText = data['result'] ?? '';
      _resultSignature = data['signature'] ?? '';
      _isCached = true;
      _isRecipeResult = true;
      _inventoryChanged = false;
    });
  }

  void _checkInventoryChanged(List<InventoryItem> items) {
    final changed = _inventoryChecker.isInventoryChanged(
      items: items,
      lastSignature: _resultSignature,
      resultText: _resultText,
    );

    if (changed != _inventoryChanged) {
      setState(() => _inventoryChanged = changed);
    }
  }

  Future<void> _generateRecipes(List<InventoryItem> items) async {
    await _generateRequest(
      type: 'recipes_v2',
      items: items,
      isRecipe: true,
      fetcher: () => _gemini.generateRecipeSuggestions(items),
    );
  }

  Future<void> _generateRestock(List<InventoryItem> items) async {
    await _generateRequest(
      type: 'restock_v2',
      items: items,
      isRecipe: false,
      fetcher: () => _gemini.generateRestockRecommendations(items),
    );
  }

  Future<void> _generateRequest({
    required String type,
    required List<InventoryItem> items,
    required bool isRecipe,
    required Future<String> Function() fetcher,
  }) async {
    if (_cooldownSeconds > 0) {
      _showSnack('Please wait $_cooldownSeconds seconds.');
      return;
    }

    setState(() => _isRecipeResult = isRecipe);
    await _generateAiResult(type: type, items: items, fetcher: fetcher);
  }

  Future<void> _generateAiResult({
    required String type,
    required List<InventoryItem> items,
    required Future<String> Function() fetcher,
  }) async {
    setState(() {
      _isLoading = true;
      _isCached = false;
      _inventoryChanged = false;
      _resultText = '';
    });

    final data = await _aiService.generate(
      type: type,
      items: items,
      fetcher: fetcher,
    );

    if (!mounted) return;

    final result = data['result'] ?? '';

    if (data['isError'] == true || _isErrorResult(result)) {
      final retrySeconds = _extractSeconds(result);
      if (retrySeconds > 0) _startCooldown(retrySeconds);

      setState(() {
        _resultText = result;
        _resultSignature = '';
        _isCached = false;
        _isLoading = false;
      });
      return;
    }

    await _loadQuota();

    setState(() {
      _resultText = result;
      _resultSignature = data['signature'] ?? '';
      _isCached = data['isCached'] ?? false;
      _isLoading = false;
    });
  }

  Future<void> _cookRecipe(List<InventoryItem> usedItems) async {
    try {
      await _cookNowService.cookRecipe(usedItems);
      _showSnack('Ingredients marked as used.');
    } catch (_) {
      _showSnack('Failed to cook recipe.');
    }
  }

  void _startCooldown(int seconds) {
    _cooldownTimer?.cancel();
    setState(() => _cooldownSeconds = seconds);

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _cooldownSeconds = 0);
        return;
      }

      if (mounted) setState(() => _cooldownSeconds--);
    });
  }

  int _extractSeconds(String text) {
    final match = RegExp(r'(\d+)\sseconds').firstMatch(text);
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  bool _isErrorResult(String text) {
    final lower = text.toLowerCase();

    return lower.contains('failed') ||
        lower.contains('quota') ||
        lower.contains('api key') ||
        lower.contains('try again') ||
        lower.contains('something went wrong') ||
        lower.contains('no ai suggestion');
  }

  void _showSnack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _openRecipeDetail(
    Map<String, String> recipe,
    List<InventoryItem> items,
  ) {
    final content = RecipeParser.content(recipe);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeDetailPage(
          title: RecipeParser.title(recipe),
          ingredients: RecipeParser.ingredients(content),
          steps: RecipeParser.steps(content),
          nearExpiryIngredients: RecipeParser.nearExpiryNames(items),
          whyRecommended: RecipeParser.why(content),
        ),
      ),
    );
  }

  Widget _buildRecipeCards(List<InventoryItem> items) {
    final recipes = _helper.parseRecipes(_resultText);

    if (recipes.isEmpty) {
      return EmptyCard(text: _resultText);
    }

    return Column(
      children: recipes.map((recipe) {
        return RecipePreviewCard(
          title: RecipeParser.title(recipe),
          content: RecipeParser.content(recipe),
          onTap: () => _openRecipeDetail(recipe, items),
        );
      }).toList(),
    );
  }

  Widget _buildAiResult(List<InventoryItem> items) {
    if (_isLoading) return const PremiumLoadingCard();

    if (_resultText.isEmpty) {
      return const EmptyCard(
        text: 'AI will suggest recipes automatically when available.',
      );
    }

    if (_isErrorResult(_resultText)) {
      return EmptyCard(text: _resultText);
    }

    return Column(
      children: [
        if (_isCached) const CacheNotice(),
        if (_inventoryChanged && _isRecipeResult)
          InventoryChangedCard(onRegenerate: () => _generateRecipes(items)),
        if (_isRecipeResult)
          _buildRecipeCards(items)
        else
          ResultCards(
            results: _helper.parseRecipes(_resultText),
            inventoryItems: items,
            isRecipeResult: false,
            onCookRecipe: null,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _quotaService.remaining(_usedQuota);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('inventory')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = _helper.convertDocs(snapshot.data!.docs);
            final nearExpiry = _helper.nearExpiryItems(items);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _autoLoadCache(items);
              _checkInventoryChanged(items);
            });

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SuggestionPageTitle(),
                  const SizedBox(height: 18),
                  QuotaStatusCard(
                    used: _usedQuota,
                    limit: AiQuotaService.dailyLimit,
                    remaining: remaining,
                    cooldownSeconds: _cooldownSeconds,
                    resetCountdown: _resetCountdown,
                    resetTimeText: _resetTimeText,
                  ),
                  const SizedBox(height: 18),
                  SuggestionActionButtons(
                    onRecipeTap: () => _generateRecipes(items),
                    onRestockTap: () => _generateRestock(items),
                  ),
                  const SizedBox(height: 26),
                  const SuggestionSectionTitle(title: 'Near Expiry Items'),
                  const SizedBox(height: 12),
                  NearExpirySection(
                    nearExpiry: nearExpiry,
                    daysLeftText: _helper.daysLeftText,
                  ),
                  const SizedBox(height: 26),
                  SuggestionSectionTitle(
                    title: _isRecipeResult ? 'AI Recipes' : 'Restock Advice',
                  ),
                  const SizedBox(height: 12),
                  _buildAiResult(items),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
