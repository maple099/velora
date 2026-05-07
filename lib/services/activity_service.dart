import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityService {
  static final CollectionReference _activities = FirebaseFirestore.instance
      .collection('activities');

  static Future<void> addActivity({
    required String type,
    required String title,
    String subtitle = '',
  }) async {
    await _activities.add({
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'createdAt': Timestamp.now(),
    });
  }
}
