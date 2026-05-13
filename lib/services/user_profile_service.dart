import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersRef {
    return _firestore.collection('users');
  }

  Future<void> createUserProfileIfNeeded(User user) async {
    final docRef = _usersRef.doc(user.uid);
    final doc = await docRef.get();

    if (doc.exists) return;

    await docRef.set({
      'username': user.displayName ?? 'Velora User',
      'email': user.email ?? '',
      'photoUrl': user.photoURL ?? '',
      'role': 'owner',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<UserProfile?> getUserProfileStream(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;

      return UserProfile.fromMap(doc.id, doc.data()!);
    });
  }

  Future<void> updateUserProfile({
    required String uid,
    required String username,
    required String photoUrl,
  }) async {
    await _usersRef.doc(uid).update({
      'username': username,
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
