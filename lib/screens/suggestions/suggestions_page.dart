import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SuggestionsPage extends StatelessWidget {
  const SuggestionsPage({super.key});

  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color purple = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'AI Suggestions',
          style: TextStyle(color: textDark, fontWeight: FontWeight.w800),
        ),
        iconTheme: const IconThemeData(color: textDark),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('inventory').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          final now = DateTime.now();

          final nearExpiryItems = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final expiry = data['expiryDate'];

            if (expiry is Timestamp) {
              final diff = expiry.toDate().difference(now).inDays;
              return diff >= 0 && diff <= 4;
            }

            return false;
          }).toList();

          final itemNames = nearExpiryItems
              .map((e) => (e['name'] ?? '').toString().toLowerCase())
              .toList();

          final suggestions = _generateSuggestions(itemNames);

          if (suggestions.isEmpty) {
            return const Center(
              child: Text(
                'No suggestions yet 🤔',
                style: TextStyle(color: textGrey, fontWeight: FontWeight.w600),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              return _suggestionCard(suggestions[index]);
            },
          );
        },
      ),
    );
  }

  List<RecipeSuggestion> _generateSuggestions(List<String> items) {
    final List<RecipeSuggestion> results = [];

    if (items.contains('bread') && items.contains('egg')) {
      results.add(
        const RecipeSuggestion(
          title: 'Make Sandwich 🥪',
          reason: 'Because you have bread and egg expiring soon.',
        ),
      );

      results.add(
        const RecipeSuggestion(
          title: 'Make French Toast 🍞',
          reason: 'Because bread and egg can be used before they expire.',
        ),
      );
    }

    if (items.contains('rice') && items.contains('egg')) {
      results.add(
        const RecipeSuggestion(
          title: 'Make Fried Rice 🍚',
          reason: 'Because rice and egg are available near expiry.',
        ),
      );
    }

    if (items.contains('chicken')) {
      results.add(
        const RecipeSuggestion(
          title: 'Cook Grilled Chicken 🍗',
          reason: 'Because chicken should be used before expiry.',
        ),
      );
    }

    if (items.contains('milk')) {
      results.add(
        const RecipeSuggestion(
          title: 'Make Pancakes 🥞',
          reason: 'Because milk can be used for a simple recipe.',
        ),
      );
    }

    if (items.contains('banana')) {
      results.add(
        const RecipeSuggestion(
          title: 'Make Banana Smoothie 🍌',
          reason: 'Because banana is near expiry and can be blended quickly.',
        ),
      );
    }

    return results;
  }

  Widget _suggestionCard(RecipeSuggestion suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lightbulb, color: purple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: textDark,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  suggestion.reason,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecipeSuggestion {
  final String title;
  final String reason;

  const RecipeSuggestion({required this.title, required this.reason});
}
