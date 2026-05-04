import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/inventory_item.dart';

class AiCacheService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔍 GET CACHE
  Future<String?> getCachedResult({
    required String type,
    required List<InventoryItem> items,
  }) async {
    final key = _buildCacheKey(type, items);

    final doc = await _firestore.collection('ai_cache').doc(key).get();

    if (!doc.exists) return null;

    final data = doc.data();
    if (data == null) return null;

    final createdAt = data['createdAt'];
    if (createdAt is! Timestamp) return null;

    final age = DateTime.now().difference(createdAt.toDate());

    /// ⏱️ EXPIRE AFTER 24 HOURS
    if (age.inHours > 24) return null;

    final result = data['result'];

    /// 🚫 DON'T RETURN BAD RESULT
    if (result == null || _isBadResult(result.toString())) {
      return null;
    }

    return result;
  }

  /// 💾 SAVE CACHE
  Future<void> saveResult({
    required String type,
    required List<InventoryItem> items,
    required String result,
  }) async {
    /// 🚫 DON'T SAVE FAILED RESULT
    if (_isBadResult(result)) {
      return;
    }

    final key = _buildCacheKey(type, items);

    await _firestore.collection('ai_cache').doc(key).set({
      'type': type,
      'result': result,
      'signature': _buildSignature(items),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// 🚫 CHECK BAD RESULT
  bool _isBadResult(String text) {
    final lower = text.toLowerCase();

    return lower.contains('failed to generate') ||
        lower.contains('something went wrong') ||
        lower.contains('no ai suggestion') ||
        lower.contains('permission_denied') ||
        lower.contains('api key') ||
        lower.contains('quota');
  }

  /// 🔑 BUILD CACHE KEY
  String _buildCacheKey(String type, List<InventoryItem> items) {
    final signature = '$type-${_buildSignature(items)}';
    return _simpleHash(signature);
  }

  /// 📦 BUILD SIGNATURE
  String _buildSignature(List<InventoryItem> items) {
    final sortedItems = [...items]..sort((a, b) => a.name.compareTo(b.name));

    return sortedItems
        .map((item) {
          final date = item.expiryDate.toIso8601String().split('T').first;
          return '${item.name}_${item.quantity}_$date';
        })
        .join('|');
  }

  /// 🔢 SIMPLE HASH
  String _simpleHash(String input) {
    var hash = 5381;

    for (final codeUnit in input.codeUnits) {
      hash = ((hash << 5) + hash) + codeUnit;
      hash = hash & 0x7fffffff;
    }

    return hash.toString();
  }
}
