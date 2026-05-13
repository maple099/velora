import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String username;
  final String email;
  final String photoUrl;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.uid,
    required this.username,
    required this.email,
    required this.photoUrl,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOwner => role == 'owner';
  bool get isStaff => role == 'staff';

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      username: data['username'] ?? 'Velora User',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      role: data['role'] ?? 'owner',
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
