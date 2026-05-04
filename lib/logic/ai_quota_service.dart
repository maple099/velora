import 'package:cloud_firestore/cloud_firestore.dart';

class AiQuotaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const int dailyLimit = 20;

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  Future<int> getUsedToday() async {
    final doc = await _firestore.collection('ai_quota').doc(_todayKey).get();

    if (!doc.exists) return 0;

    final data = doc.data();
    return (data?['used'] as num?)?.toInt() ?? 0;
  }

  Future<void> addUsage() async {
    final ref = _firestore.collection('ai_quota').doc(_todayKey);

    await _firestore.runTransaction((transaction) async {
      final snap = await transaction.get(ref);
      final current = snap.exists
          ? (snap.data()?['used'] as num?)?.toInt() ?? 0
          : 0;

      transaction.set(ref, {
        'used': current + 1,
        'limit': dailyLimit,
        'date': _todayKey,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  int remaining(int used) {
    final left = dailyLimit - used;
    return left < 0 ? 0 : left;
  }
}
