import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileHelper {
  static final _firestore = FirebaseFirestore.instance;

  /// Normalize avatar paths to ensure they're valid and match actual assets
  static String normalizeAvatarPath(dynamic avatarPath) {
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

      final profiles =
          snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

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

  // =========================
  // PROGRESS (matches your screenshot fields) [attached_image:1]
  // docId format: <profileId>_<category>_level<level>
  // =========================

  static String _progressDocId(String profileId, String category, int level) {
    return '${profileId}_${category.toLowerCase()}_level$level';
  }

  /// Save progress (score) for a specific profile, category and level.
  /// Writes into:
  /// - Top-level `progress` collection (required)
  /// - Also under `profiles/<profileId>/progress` (optional compatibility)
  static Future<void> saveProgress({
    required String profileId,
    required String category,
    required int level,
    required double score,
  }) async {
    try {
      final docId = _progressDocId(profileId, category, level);

      // Top-level progress collection (this is what your screenshot shows) [attached_image:1]
      await _firestore.collection('progress').doc(docId).set({
        'profileId': profileId,
        'category': category,
        'level': level,
        'score': score,
        'updated_at': FieldValue.serverTimestamp(), // server timestamp [web:640]
      }, SetOptions(merge: true)); // merge behavior supported by FlutterFire [web:645]

      // Optional copy under profile
      await _firestore
          .collection('profiles')
          .doc(profileId)
          .collection('progress')
          .doc('${category.toLowerCase()}-level$level')
          .set({
        'profileId': profileId,
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

  /// Get ALL progress entries for a profile (top-level progress docs)
  static Future<List<Map<String, dynamic>>> getProgress(String profileId) async {
    try {
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

  /// Get progress doc for ONE level (null if not done yet)
  static Future<Map<String, dynamic>?> getProgressForLevel({
    required String profileId,
    required String category,
    required int level,
  }) async {
    try {
      final docId = _progressDocId(profileId, category, level);
      final doc = await _firestore.collection('progress').doc(docId).get();
      if (!doc.exists) return null;
      return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
    } catch (e) {
      print('Error getting progress for level: $e');
      return null;
    }
  }

  /// Current unlocked level = highest completed + 1 (if none, 1)
  static Future<int> getCurrentLevel({
    required String profileId,
    required String category,
  }) async {
    try {
      final snap = await _firestore
          .collection('progress')
          .where('profileId', isEqualTo: profileId)
          .where('category', isEqualTo: category)
          .get();

      int highest = 0;
      for (final d in snap.docs) {
        final lvl = (d.data()['level'] as num?)?.toInt() ?? 0;
        if (lvl > highest) highest = lvl;
      }
      return highest + 1;
    } catch (e) {
      print('Error getting current level: $e');
      return 1;
    }
  }

  /// Access rule:
  /// - Level 1 always open
  /// - Level N requires Level N-1 exists
  static Future<bool> canAccessLevel({
    required String profileId,
    required String category,
    required int level,
  }) async {
    if (level <= 1) return true;

    final prev = await getProgressForLevel(
      profileId: profileId,
      category: category,
      level: level - 1,
    );
    return prev != null;
  }
}
