import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/user_profile.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create or update user profile
  static Future<UserProfile> createOrUpdateUserProfile({
    String? displayName,
    String? profileImageUrl,
    String? bio,
    bool? isPublic,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (userDoc.exists) {
      // Update existing profile
      final currentProfile = UserProfile.fromJson(userDoc.data()!);
      final updatedProfile = currentProfile.copyWith(
        displayName: displayName ?? currentProfile.displayName,
        profileImageUrl: profileImageUrl ?? currentProfile.profileImageUrl,
        bio: bio ?? currentProfile.bio,
        isPublic: isPublic ?? currentProfile.isPublic,
        lastUpdated: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(updatedProfile.toJson());
      return updatedProfile;
    } else {
      // Create new profile
      final newProfile = UserProfile(
        id: user.uid,
        email: user.email ?? '',
        displayName: displayName ?? user.displayName ?? 'Eco Hero',
        profileImageUrl: profileImageUrl,
        bio: bio,
        isPublic: isPublic ?? true,
        envPoints: 0,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(newProfile.toJson());
      return newProfile;
    }
  }

  /// Get user profile
  static Future<UserProfile?> getUserProfile([String? userId]) async {
    final uid = userId ?? _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserProfile.fromJson(doc.data()!);
    }
    return null;
  }

  /// Stream user profile for real-time updates
  static Stream<UserProfile?> getUserProfileStream([String? userId]) {
    final uid = userId ?? _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);

    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserProfile.fromJson(doc.data()!);
      }
      return null;
    });
  }

  /// Save profile image locally (no Firebase Storage needed)
  static Future<String> uploadProfileImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final profileImagesDir = Directory('${directory.path}/profile_images');

      if (!await profileImagesDir.exists()) {
        await profileImagesDir.create(recursive: true);
      }

      // Create unique filename
      final fileName =
          'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final localFile = File('${profileImagesDir.path}/$fileName');

      // Copy the image to local storage
      await imageFile.copy(localFile.path);

      debugPrint('Profile image saved locally: ${localFile.path}');
      return localFile.path;
    } catch (e) {
      debugPrint('Error saving image locally: $e');
      throw Exception('Failed to save image: $e');
    }
  }

  /// Add EnvPoints to user
  static Future<void> addEnvPoints(int points) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    await _firestore.collection('users').doc(user.uid).update({
      'envPoints': FieldValue.increment(points),
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Add points to user's envPoints
  static Future<void> addPoints(int points) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    final userDoc = _firestore.collection('users').doc(user.uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userDoc);
      if (snapshot.exists) {
        final currentPoints = snapshot.data()?['envPoints'] ?? 0;
        transaction.update(userDoc, {
          'envPoints': currentPoints + points,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  /// Get current user's EnvPoints
  static Future<int> getCurrentEnvPoints() async {
    final profile = await getUserProfile();
    return profile?.envPoints ?? 0;
  }

  /// Get top users for leaderboard (only public profiles)
  static Stream<List<UserProfile>> getTopUsers({int limit = 100}) {
    try {
      return _firestore
          .collection('users')
          .orderBy('envPoints', descending: true)
          .limit(limit * 2) // Get more to filter client-side
          .snapshots()
          .map((snapshot) {
        // Filter for public profiles and apply limit client-side
        final publicUsers = snapshot.docs
            .map((doc) => UserProfile.fromJson(doc.data()))
            .where((user) => user.isPublic)
            .take(limit)
            .toList();
        return publicUsers;
      });
    } catch (e) {
      debugPrint('Error fetching top users: $e');
      // Return empty stream if Firestore fails
      return Stream.value(<UserProfile>[]);
    }
  }
}
