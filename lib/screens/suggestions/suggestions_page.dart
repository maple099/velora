import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../logic/ai_cache_service.dart';
import '../../logic/ai_quota_service.dart';
import '../../logic/cook_now_service.dart';
import '../../logic/gemini_service.dart';
import '../../logic/suggestion_helper.dart';
import '../../models/inventory_item.dart';
import '../../widgets/suggestions/cache_notice.dart';
import '../../widgets/suggestions/empty_card.dart';
import '../../widgets/suggestions/premium_loading_card.dart';
import '../../widgets/suggestions/quota_status_card.dart';
import '../../widgets/suggestions/result_cards.dart';
import '../../widgets/suggestions/suggestion_sections.dart';

class SuggestionsPage extends StatefulWidget {
  const SuggestionsPage({super.key});

  @override
  State<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  final GeminiService _gemini = GeminiService();
  final CookNowService _cookNowService = CookNowService();
  final AiCacheService _cacheService = AiCacheService();
  final AiQuotaService _quotaService = AiQuotaService();
  final SuggestionHelper _helper = SuggestionHelper();

  bool _isLoading = false;
  bool _isCached = false;
  bool _isRecipeResult = true;
  bool _didAutoLoad = false;

  int _usedQuota = 0;
  int _cooldownSeconds = 0;

  Timer? _cooldownTimer;
  Timer? _resetTimer;

  String _resultText = '';
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

  Future<void> _autoLoadCache(List<InventoryItem> items) async {
    if (_didAutoLoad) return;
    _didAutoLoad = true;

    final cached = await _cacheService.getCachedResult(
      type: 'recipes_v2',
      items: items,
    );

    if (cached == null || cached.isEmpty) return;
    if (!mounted) return;

    setState(() {
      _resultText = cached;
      _isCached = true;
      _isRecipeResult = true;
    });
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

    await _generateWithCache(type: type, items: items, fetcher: fetcher);
  }

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

    final result = await fetcher();

    if (!mounted) return;

    if (_isErrorResult(result)) {
      final retrySeconds = _extractSeconds(result);

      if (retrySeconds > 0) {
        _startCooldown(retrySeconds);
      }

      setState(() {
        _resultText = result;
        _isCached = false;
        _isLoading = false;
      });
      return;
    }

    await _cacheService.saveResult(type: type, items: items, result: result);

    await _quotaService.addUsage();
    await _loadQuota();

    if (!mounted) return;

    setState(() {
      _resultText = result;
      _isCached = false;
      _isLoading = false;
    });
  }

  Future<void> _cookRecipe(List<InventoryItem> usedItems) async {
    try {
      await _cookNowService.cookRecipe(usedItems);
      _showSnack('Ingredients marked as used.');
    } catch (e) {
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

  void _updateResetCountdown() {
    final now = DateTime.now();
    final resetTime = _nextGeminiResetMalaysiaTime(now);
    final diff = resetTime.difference(now);

    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);

    final resetHour = resetTime.hour.toString().padLeft(2, '0');
    final resetMinute = resetTime.minute.toString().padLeft(2, '0');

    if (!mounted) return;

    setState(() {
      _resetCountdown = '${hours}h ${minutes}m';
      _resetTimeText = 'Resets around $resetHour:$resetMinute Malaysia time';
    });
  }

  DateTime _nextGeminiResetMalaysiaTime(DateTime nowMalaysia) {
    final nowUtc = nowMalaysia.toUtc();

    final currentPtOffset = _pacificOffsetHours(nowUtc);
    final nowPt = nowUtc.add(Duration(hours: currentPtOffset));

    var resetPt = DateTime(nowPt.year, nowPt.month, nowPt.day + 1);

    if (nowPt.hour == 0 && nowPt.minute == 0) {
      resetPt = DateTime(nowPt.year, nowPt.month, nowPt.day);
    }

    final resetUtc = resetPt.subtract(Duration(hours: currentPtOffset));
    return resetUtc.toLocal();
  }

  int _pacificOffsetHours(DateTime utcDate) {
    final year = utcDate.year;
    final dstStart = _secondSundayOfMarchUtc(year);
    final dstEnd = _firstSundayOfNovemberUtc(year);

    final isDst = utcDate.isAfter(dstStart) && utcDate.isBefore(dstEnd);
    return isDst ? -7 : -8;
  }

  DateTime _secondSundayOfMarchUtc(int year) {
    final marchFirst = DateTime.utc(year, 3, 1);
    final daysUntilSunday = (DateTime.sunday - marchFirst.weekday) % 7;
    final secondSunday = marchFirst.add(Duration(days: daysUntilSunday + 7));

    return DateTime.utc(
      secondSunday.year,
      secondSunday.month,
      secondSunday.day,
      10,
    );
  }

  DateTime _firstSundayOfNovemberUtc(int year) {
    final novFirst = DateTime.utc(year, 11, 1);
    final daysUntilSunday = (DateTime.sunday - novFirst.weekday) % 7;
    final firstSunday = novFirst.add(Duration(days: daysUntilSunday));

    return DateTime.utc(
      firstSunday.year,
      firstSunday.month,
      firstSunday.day,
      9,
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
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
        ResultCards(
          results: _helper.parseRecipes(_resultText),
          inventoryItems: items,
          isRecipeResult: _isRecipeResult,
          onCookRecipe: _isRecipeResult ? _cookRecipe : null,
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
