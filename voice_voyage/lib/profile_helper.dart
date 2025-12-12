import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileHelper {
  static final _firestore = FirebaseFirestore.instance;

  /// Create a new profile for a user
  static Future<String> createProfile({
    required String userId,
    required String profileName,
    required String avatarPath,
  }) async {
    final docRef = await _firestore.collection('profiles').add({
      'userId': userId,
      'name': profileName,
      'avatar': avatarPath,
      'created_at': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// Get all profiles for a user
  static Future<List<Map<String, dynamic>>> getUserProfiles(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('profiles')
          .where('userId', isEqualTo: userId)
          .get();

      // Sort in memory instead of using orderBy to avoid Firestore index requirement
      final profiles = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
      
      // Sort by created_at descending (newest first)
      profiles.sort((a, b) {
        final aTime = a['created_at'] as Timestamp?;
        final bTime = b['created_at'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });
      
      return profiles;
    } catch (e) {
      print('Error fetching profiles: $e');
      return [];
    }
  }

  /// Update a profile
  static Future<void> updateProfile({
    required String profileId,
    required String profileName,
    required String avatarPath,
  }) async {
    await _firestore.collection('profiles').doc(profileId).update({
      'name': profileName,
      'avatar': avatarPath,
    });
  }

  /// Delete a profile
  static Future<void> deleteProfile(String profileId) async {
    await _firestore.collection('profiles').doc(profileId).delete();
  }

  /// Get a single profile by ID
  static Future<Map<String, dynamic>?> getProfile(String profileId) async {
    try {
      final doc = await _firestore.collection('profiles').doc(profileId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }
      return null;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }
}
