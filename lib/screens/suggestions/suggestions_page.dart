import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../logic/ai_cache_service.dart';
import '../../logic/ai_generate_service.dart';
import '../../logic/ai_inventory_checker.dart';
import '../../logic/ai_quota_service.dart';
import '../../logic/ai_recipe_save_service.dart';
import '../../logic/ai_reset_helper.dart';
import '../../logic/gemini_service.dart';
import '../../logic/suggestion_helper.dart';
import '../../models/inventory_item.dart';

import '../../widgets/suggestions/quota_status_card.dart';
import '../../widgets/suggestions/suggestion_sections.dart';

import 'restock_suggestion_service.dart';

import 'widgets_suggestions/restock_suggestion_card.dart';
import 'widgets_suggestions/suggestion_ai_result.dart';

class SuggestionsPage extends StatefulWidget {
  const SuggestionsPage({super.key});

  @override
  State<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  final GeminiService _gemini = GeminiService();
  final AiQuotaService _quotaService = AiQuotaService();
  final AiGenerateService _aiService = AiGenerateService();
  final AiCacheService _cacheService = AiCacheService();
  final AiInventoryChecker _inventoryChecker = AiInventoryChecker();
  final AiRecipeSaveService _recipeSaveService = AiRecipeSaveService();
  final SuggestionHelper _helper = SuggestionHelper();

  final RestockSuggestionService _restockService = RestockSuggestionService();

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
  String _geminiStatus = 'Ready';

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

    final cached = await _cacheService.getCachedResult(
      type: 'recipes_v2',
      items: items,
    );

    if (!mounted || cached == null || cached.isEmpty) return;

    setState(() {
      _resultText = cached;
      _resultSignature = _cacheService.buildCurrentSignature(items);
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

    setState(() {
      _isRecipeResult = isRecipe;
      _geminiStatus = 'Checking';
    });

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
    });

    final data = await _aiService.generate(
      type: type,
      items: items,
      fetcher: fetcher,
    );

    if (!mounted) return;

    final result = data['result'] ?? '';

    if (data['isError'] == true || _isErrorResult(result)) {
      _handleAiError(result);

      return;
    }

    await _loadQuota();

    final isCachedResult = data['isCached'] ?? false;

    if (type == 'recipes_v2' && isCachedResult == false) {
      await _saveGeneratedRecipes(result, items);
    }

    if (!mounted) return;

    setState(() {
      _resultText = result;
      _resultSignature = data['signature'] ?? '';
      _isCached = isCachedResult;
      _isLoading = false;
      _geminiStatus = isCachedResult ? 'Using cache' : 'Available';
    });
  }

  void _handleAiError(String result) {
    final retrySeconds = _extractSeconds(result);

    if (retrySeconds > 0) {
      _startCooldown(retrySeconds);
    }

    setState(() {
      _resultText = result;
      _resultSignature = '';
      _isCached = false;
      _isLoading = false;
      _geminiStatus = _statusFromError(result);
    });
  }

  Future<void> _saveGeneratedRecipes(
    String result,
    List<InventoryItem> items,
  ) async {
    final recipes = _helper.parseRecipes(result);

    final savedCount = await _recipeSaveService.saveGeneratedRecipes(
      recipes: recipes,
      items: items,
      rawResult: result,
    );

    if (savedCount <= 0) return;

    final message = savedCount == 1
        ? 'New AI recipe saved for later.'
        : '$savedCount new AI recipes saved for later.';

    _showSnack(message);
  }

  void _startCooldown(int seconds) {
    _cooldownTimer?.cancel();

    setState(() => _cooldownSeconds = seconds);

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds <= 1) {
        timer.cancel();

        if (mounted) {
          setState(() => _cooldownSeconds = 0);
        }

        return;
      }

      if (mounted) {
        setState(() => _cooldownSeconds--);
      }
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

  String _statusFromError(String text) {
    final lower = text.toLowerCase();

    if (lower.contains('quota')) {
      return 'Quota limited';
    }

    if (lower.contains('api key')) {
      return 'API key error';
    }

    if (lower.contains('network')) {
      return 'Network error';
    }

    return 'Temporary error';
  }

  void _showSnack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
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

            final restockSuggestions = _restockService.generateSuggestions(
              snapshot.data!.docs,
            );

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
                    geminiStatus: _geminiStatus,
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

                  if (restockSuggestions.isNotEmpty) ...[
                    const SizedBox(height: 26),

                    const SuggestionSectionTitle(
                      title: 'Smart Restock Suggestions',
                    ),

                    const SizedBox(height: 12),

                    ...restockSuggestions.map(
                      (suggestion) =>
                          RestockSuggestionCard(suggestion: suggestion),
                    ),
                  ],

                  const SizedBox(height: 26),

                  SuggestionSectionTitle(
                    title: _isRecipeResult ? 'AI Recipes' : 'Restock Advice',
                  ),

                  const SizedBox(height: 12),

                  SuggestionAiResult(
                    isLoading: _isLoading,
                    isRecipeResult: _isRecipeResult,
                    isCached: _isCached,
                    inventoryChanged: _inventoryChanged,
                    resultText: _resultText,
                    items: items,
                    helper: _helper,
                    recipeSaveService: _recipeSaveService,
                    onRegenerate: () => _generateRecipes(items),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
