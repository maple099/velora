import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../logic/ai_cache_service.dart';
import '../../logic/cook_now_service.dart';
import '../../logic/gemini_service.dart';
import '../../logic/suggestion_helper.dart';

import '../../models/inventory_item.dart';

import '../../widgets/suggestions/cache_notice.dart';
import '../../widgets/suggestions/empty_card.dart';
import '../../widgets/suggestions/header_card.dart';
import '../../widgets/suggestions/premium_loading_card.dart';
import '../../widgets/suggestions/result_cards.dart';
import '../../widgets/suggestions/suggestion_sections.dart';

class SuggestionsPage extends StatefulWidget {
  const SuggestionsPage({super.key});

  @override
  State<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  /// 🔥 SERVICES
  final GeminiService _gemini = GeminiService();
  final CookNowService _cookNowService = CookNowService();
  final AiCacheService _cacheService = AiCacheService();
  final SuggestionHelper _helper = SuggestionHelper();

  /// 🔥 STATE
  bool _isLoading = false;
  bool _isCached = false;
  String _resultText = '';

  /// ===============================
  /// 🔥 GENERATE WITH CACHE
  /// ===============================
  Future<void> _generateWithCache({
    required String type,
    required List<InventoryItem> items,
    required Future<String> Function() fetcher,
  }) async {
    setState(() {
      _isLoading = true;
      _isCached = false;
      _resultText = '';
    });

    /// ✅ CHECK CACHE FIRST
    final cached = await _cacheService.getCachedResult(
      type: type,
      items: items,
    );

    if (cached != null && cached.trim().isNotEmpty) {
      if (!mounted) return;

      setState(() {
        _resultText = cached;
        _isCached = true;
        _isLoading = false;
      });
      return;
    }

    /// ❌ NOT CACHED → CALL GEMINI
    final result = await fetcher();

    /// SAVE CACHE
    await _cacheService.saveResult(type: type, items: items, result: result);

    if (!mounted) return;

    setState(() {
      _resultText = result;
      _isCached = false;
      _isLoading = false;
    });
  }

  /// 🔥 ACTIONS
  Future<void> _generateRecipes(List<InventoryItem> items) async {
    await _generateWithCache(
      type: 'recipes',
      items: items,
      fetcher: () => _gemini.generateRecipeSuggestions(items),
    );
  }

  Future<void> _generateRestock(List<InventoryItem> items) async {
    await _generateWithCache(
      type: 'restock',
      items: items,
      fetcher: () => _gemini.generateRestockRecommendations(items),
    );
  }

  /// 🔥 COOK LOGIC
  Future<void> _cookRecipe(List<InventoryItem> usedItems) async {
    try {
      await _cookNowService.cookRecipe(usedItems);
      _showSnack('Ingredients marked as used.');
    } catch (e) {
      _showSnack('Failed to cook recipe.');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  /// ===============================
  /// 🔥 UI BUILDER (AI RESULT)
  /// ===============================
  Widget _buildAiResult(List<InventoryItem> items) {
    /// 🔄 LOADING
    if (_isLoading) {
      return const PremiumLoadingCard();
    }

    /// 💤 EMPTY
    if (_resultText.isEmpty) {
      return const EmptyCard(
        text: 'Press Generate Recipes or Restock Advice to get AI suggestions.',
      );
    }

    /// ✅ RESULT
    return Column(
      children: [
        if (_isCached) const CacheNotice(),

        ResultCards(
          recipes: _helper.parseRecipes(_resultText),
          inventoryItems: items,
          onCookRecipe: _cookRecipe,
        ),
      ],
    );
  }

  /// ===============================
  /// 🔥 MAIN BUILD
  /// ===============================
  @override
  Widget build(BuildContext context) {
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

            /// 🔄 CONVERT DATA
            final items = _helper.convertDocs(snapshot.data!.docs);
            final nearExpiry = _helper.nearExpiryItems(items);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🟣 TITLE
                  const SuggestionPageTitle(),

                  const SizedBox(height: 18),

                  /// 📊 HEADER
                  HeaderCard(
                    totalItems: items.length,
                    nearExpiry: nearExpiry.length,
                  ),

                  const SizedBox(height: 18),

                  /// ⚡ ACTION BUTTONS
                  SuggestionActionButtons(
                    onRecipeTap: () => _generateRecipes(items),
                    onRestockTap: () => _generateRestock(items),
                  ),

                  const SizedBox(height: 24),

                  /// 🔥 NEAR EXPIRY
                  const SuggestionSectionTitle(title: 'Near Expiry Items'),

                  const SizedBox(height: 12),

                  NearExpirySection(
                    nearExpiry: nearExpiry,
                    daysLeftText: _helper.daysLeftText,
                  ),

                  const SizedBox(height: 24),

                  /// 🤖 AI RESULT
                  const SuggestionSectionTitle(title: 'AI Result'),

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
