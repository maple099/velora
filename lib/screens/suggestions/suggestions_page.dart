import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/inventory_item.dart';
import '../../logic/gemini_service.dart';

class SuggestionsPage extends StatefulWidget {
  const SuggestionsPage({super.key});

  @override
  State<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  final GeminiService _gemini = GeminiService();

  bool _isLoading = false;
  String _resultText = '';

  /// 🔥 CALL GEMINI
  Future<void> _generateSuggestions(List<InventoryItem> items) async {
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

  /// 🔥 FIXED CONVERT FUNCTION (NO ERROR)
  List<InventoryItem> _convertDocs(List<QueryDocumentSnapshot> docs) {
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      return InventoryItem(
        id: doc.id,
        name: data['name'] ?? '',
        category: data['category'] ?? '',
        quantity: data['quantity'] ?? 0,
        expiryDate: (data['expiryDate'] as Timestamp).toDate(),

        // ✅ FIX HERE
        imageUrl: data['imageUrl'] ?? '',
        createdAt: data['createdAt'] is Timestamp
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      /// APPBAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'AI Suggestions',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
      ),

      /// BODY
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('inventory').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = _convertDocs(snapshot.data!.docs);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// 🔥 GENERATE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => _generateSuggestions(items),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Generate Recipe Suggestions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔄 LOADING
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),

                /// 📦 RESULT CARD
                if (!_isLoading && _resultText.isNotEmpty)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Text(
                          _resultText,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
