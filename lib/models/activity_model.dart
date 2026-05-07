import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  final String id;
  final String type;
  final String title;
  final String subtitle;
  final DateTime createdAt;

  ActivityModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.createdAt,
  });

  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ActivityModel(
      id: doc.id,
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
