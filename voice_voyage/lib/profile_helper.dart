import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileHelper {
  static final _firestore = FirebaseFirestore.instance;

  /// Normalize avatar paths to ensure they're valid and match actual assets
  static String normalizeAvatarPath(dynamic avatarPath) {
    // Convert to string if not already, return default if null
    String path = avatarPath is String ? avatarPath : '';
    
    if (path.isEmpty) {
      return 'assets/images/prof.png';
    }

    // Map old prof1.png references to prof.png (which actually exists)
    if (path.contains('prof1.png')) {
      return 'assets/images/prof.png';
    }

    // Ensure the path doesn't have double 'assets/'
    if (path.startsWith('assets/assets/')) {
      return path.replaceFirst('assets/assets/', 'assets/');
    }

    // Validate that path starts with 'assets/'
    if (!path.startsWith('assets/')) {
      return 'assets/images/prof.png';
    }

    return path;
  }

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

  /// Save progress (score) for a specific profile, category and level.
  /// Document id format: `<category>-level<levelNumber>` (e.g. greetings-level1)
  static Future<void> saveProgress({
    required String profileId,
    required String category,
    required int level,
    required double score,
  }) async {
    try {
      final docId = '${profileId}_${category.toLowerCase()}_level$level';

      // Write into a dedicated top-level `progress` collection for easier queries
      final topRef = _firestore.collection('progress').doc(docId);
      await topRef.set({
        'profileId': profileId,
        'category': category,
        'level': level,
        'score': score,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Also keep a copy under the profile document for quick access (backwards compat)
      final profileRef = _firestore
          .collection('profiles')
          .doc(profileId)
          .collection('progress')
          .doc('${category.toLowerCase()}-level$level');
      await profileRef.set({
        'category': category,
        'level': level,
        'score': score,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving progress: $e');
      rethrow;
    }
  }

  /// Get progress entries for a profile (returns list of progress docs)
  static Future<List<Map<String, dynamic>>> getProgress(String profileId) async {
    try {
      // Query the top-level `progress` collection for entries belonging to this profile
      final snap = await _firestore
          .collection('progress')
          .where('profileId', isEqualTo: profileId)
          .get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      print('Error getting progress: $e');
      return [];
    }
  }
}
