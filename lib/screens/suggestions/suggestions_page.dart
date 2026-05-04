import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../logic/gemini_service.dart';
import '../../models/inventory_item.dart';

// ✅ FIXED IMPORT PATH (widgets not widget)
import '../../widgets/suggestions/action_card.dart';
import '../../widgets/suggestions/empty_card.dart';
import '../../widgets/suggestions/header_card.dart';
import '../../widgets/suggestions/loading_card.dart';
import '../../widgets/suggestions/near_expiry_card.dart';
import '../../widgets/suggestions/result_cards.dart';

class SuggestionsPage extends StatefulWidget {
  const SuggestionsPage({super.key});

  @override
  State<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  final GeminiService _gemini = GeminiService();

  bool _isLoading = false;
  String _resultText = '';

  /// 🔥 GENERATE RECIPES
  Future<void> _generateRecipes(List<InventoryItem> items) async {
    setState(() {
      _isLoading = true;
      _resultText = '';
    });

    final result = await _gemini.generateRecipeSuggestions(items);

    setState(() {
      _resultText = result;
      _isLoading = false;
    });
  }

  /// 🔥 GENERATE RESTOCK
  Future<void> _generateRestock(List<InventoryItem> items) async {
    setState(() {
      _isLoading = true;
      _resultText = '';
    });

    final result = await _gemini.generateRestockRecommendations(items);

    setState(() {
      _resultText = result;
      _isLoading = false;
    });
  }

  /// 🔥 CONVERT FIRESTORE → MODEL
  List<InventoryItem> _convertDocs(List<QueryDocumentSnapshot> docs) {
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      return InventoryItem(
        id: doc.id,
        name: data['name'] ?? '',
        category: data['category'] ?? '',
        quantity: data['quantity'] ?? 0,
        expiryDate: data['expiryDate'] is Timestamp
            ? (data['expiryDate'] as Timestamp).toDate()
            : DateTime.now(),
        imageUrl: data['imageUrl'] ?? '',
        createdAt: data['createdAt'] is Timestamp
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
    }).toList();
  }

  /// 🔥 NEAR EXPIRY FILTER
  List<InventoryItem> _nearExpiryItems(List<InventoryItem> items) {
    final now = DateTime.now();

    final filtered = items.where((item) {
      final daysLeft = item.expiryDate.difference(now).inDays;
      return daysLeft <= 7;
    }).toList();

    filtered.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    return filtered.take(4).toList();
  }

  /// 🔥 PARSE GEMINI TEXT → CARDS
  List<Map<String, String>> _parseRecipes(String text) {
    final recipes = <Map<String, String>>[];
    final parts = text.split('###');

    for (final part in parts) {
      final clean = part.trim();
      if (clean.isEmpty) continue;

      final lines = clean.split('\n');

      recipes.add({
        'title': lines.first.trim(),
        'content': lines.skip(1).join('\n').trim(),
      });
    }

    if (recipes.isEmpty && text.trim().isNotEmpty) {
      recipes.add({'title': 'AI Suggestion', 'content': text});
    }

    return recipes;
  }

  /// 🔥 DAYS LEFT TEXT
  String _daysLeftText(DateTime expiryDate) {
    final days = expiryDate.difference(DateTime.now()).inDays;

    if (days < 0) return 'Expired';
    if (days == 0) return 'Expires today';
    if (days == 1) return 'Expires tomorrow';
    return 'Expires in $days days';
  }

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

            final items = _convertDocs(snapshot.data!.docs);
            final nearExpiry = _nearExpiryItems(items);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE
                  const Text(
                    'AI Suggestions',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Smart recipes & restock advice',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// HEADER CARD
                  HeaderCard(
                    totalItems: items.length,
                    nearExpiry: nearExpiry.length,
                  ),

                  const SizedBox(height: 18),

                  /// ACTION BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: ActionCard(
                          title: 'Generate Recipes',
                          subtitle: 'Reduce food waste',
                          icon: Icons.restaurant,
                          isPrimary: true,
                          onTap: () => _generateRecipes(items),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ActionCard(
                          title: 'Restock Advice',
                          subtitle: 'Smart stock tips',
                          icon: Icons.shopping_cart,
                          isPrimary: false,
                          onTap: () => _generateRestock(items),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// NEAR EXPIRY TITLE
                  const Text(
                    'Near Expiry Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// NEAR EXPIRY LIST
                  if (nearExpiry.isEmpty)
                    const EmptyCard(text: 'No near-expiry items found.')
                  else
                    SizedBox(
                      height: 170, // temporary (we will still improve card)
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: nearExpiry.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final item = nearExpiry[index];

                          return NearExpiryCard(
                            item: item,
                            daysLeft: _daysLeftText(item.expiryDate),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 24),

                  /// RESULT TITLE
                  const Text(
                    'AI Result',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// RESULT STATE
                  if (_isLoading)
                    const LoadingCard()
                  else if (_resultText.isEmpty)
                    const EmptyCard(
                      text:
                          'Press Generate Recipes or Restock Advice to get AI suggestions.',
                    )
                  else
                    ResultCards(recipes: _parseRecipes(_resultText)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
