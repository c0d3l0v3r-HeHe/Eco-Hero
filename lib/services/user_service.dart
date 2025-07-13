import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/user_profile.dart';
import '../models/news_article.dart';
import 'news_service.dart';

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
            final publicUsers =
                snapshot.docs
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

class TaskService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Submit a new eco task for AI evaluation
  static Future<EcoTask> submitTask({
    required String description,
    required String category,
    String? imageUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      // Get AI score for the task
      final aiScore = await _evaluateTaskWithAI(description, category);
      final pointsEarned =
          (aiScore * 10).round(); // Convert 0-10 score to points

      final task = EcoTask(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Fallback ID
        userId: user.uid,
        description: description,
        category: category,
        pointsEarned: pointsEarned,
        aiScore: aiScore,
        completedAt: DateTime.now(),
        imageUrl: imageUrl,
      );

      // Try to save task to Firestore
      try {
        await _firestore.collection('tasks').doc(task.id).set(task.toJson());
      } catch (e) {
        debugPrint('Warning: Could not save task to Firestore: $e');
        // Continue anyway - task still works offline
      }

      // Try to add points to user
      try {
        await UserService.addEnvPoints(pointsEarned);
      } catch (e) {
        debugPrint('Warning: Could not update EnvPoints in Firestore: $e');
        // Continue anyway - points can be synced later
      }

      return task;
    } catch (e) {
      throw Exception('Error submitting task: $e');
    }
  }

  /// Get user's tasks
  static Stream<List<EcoTask>> getUserTasks([String? userId]) {
    final uid = userId ?? _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    try {
      return _firestore
          .collection('tasks')
          .where('userId', isEqualTo: uid)
          .snapshots()
          .map((snapshot) {
            final tasks =
                snapshot.docs
                    .map((doc) => EcoTask.fromJson(doc.data()))
                    .toList();

            // Sort locally by completedAt (most recent first)
            tasks.sort((a, b) => b.completedAt.compareTo(a.completedAt));
            return tasks;
          });
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
      // Return empty stream if Firestore fails
      return Stream.value(<EcoTask>[]);
    }
  }

  /// AI evaluation of eco tasks
  static Future<double> _evaluateTaskWithAI(
    String description,
    String category,
  ) async {
    try {
      // Use the existing AI service from news_service.dart
      final prompt = '''
You are an environmental expert evaluating eco-friendly actions. Rate this activity on a scale of 0-10 based on its environmental impact, effort required, and sustainability benefits.

Category: $category
Description: $description

Consider:
- Environmental impact (CO2 reduction, waste prevention, resource conservation)
- Effort and accessibility
- Long-term sustainability benefits
- Scalability and repeatability

Return only a single number between 0 and 10 (decimals allowed).
''';

      // Create a mock news article for the AI service
      final mockArticle = NewsArticle(
        title: 'Eco Task Evaluation',
        description: prompt,
        content: '',
        url: '',
        urlToImage: '',
        author: 'EcoHero AI',
        publishedAt: DateTime.now(),
        source: 'EcoHero',
      );

      final aiService = AIService();
      final response = await aiService.summarizeArticle(mockArticle);

      // Extract number from AI response
      final scoreMatch = RegExp(r'(\d+\.?\d*)').firstMatch(response);
      if (scoreMatch != null) {
        final score = double.tryParse(scoreMatch.group(1)!) ?? 5.0;
        return score.clamp(0.0, 10.0);
      }

      return _calculateTaskScore(description, category);
    } catch (e) {
      // Fallback scoring if AI fails
      return _calculateTaskScore(description, category);
    }
  }

  /// Simple task scoring algorithm (can be enhanced with actual AI)
  static double _calculateTaskScore(String description, String category) {
    double baseScore = 5.0; // Start with middle score

    // Category bonuses
    switch (category.toLowerCase()) {
      case 'recycling':
        baseScore += 1.0;
        break;
      case 'energy':
        baseScore += 1.5;
        break;
      case 'transportation':
        baseScore += 2.0;
        break;
      case 'water':
        baseScore += 1.0;
        break;
    }

    // Description analysis (simple keyword matching)
    final keywords = description.toLowerCase();
    if (keywords.contains('reduce') || keywords.contains('save'))
      baseScore += 0.5;
    if (keywords.contains('recycle') || keywords.contains('reuse'))
      baseScore += 0.5;
    if (keywords.contains('solar') || keywords.contains('renewable'))
      baseScore += 1.0;
    if (keywords.contains('walk') ||
        keywords.contains('bike') ||
        keywords.contains('public transport'))
      baseScore += 1.0;
    if (keywords.contains('plastic') || keywords.contains('waste'))
      baseScore += 0.5;

    // Ensure score is within 0-10 range
    return baseScore.clamp(0.0, 10.0);
  }
}

class WasteService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Upload and classify waste image
  static Future<WasteClassification> classifyWaste(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      // Upload image
      final imageUrl = await _uploadWasteImage(imageFile);

      // Classify waste (simplified - would use actual AI/ML service)
      final classification = await _classifyWasteImage(imageFile);

      final wasteClassification = WasteClassification(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Fallback ID
        userId: user.uid,
        imageUrl: imageUrl,
        classification: classification['classification'],
        wasteType: classification['wasteType'],
        disposalAdvice: classification['disposalAdvice'],
        confidence: classification['confidence'],
        createdAt: DateTime.now(),
      );

      // Try to save to Firestore, but don't fail if offline
      try {
        await _firestore
            .collection('waste_classifications')
            .doc(wasteClassification.id)
            .set(wasteClassification.toJson());
      } catch (e) {
        debugPrint('Warning: Could not save to Firestore: $e');
        // Continue anyway - the classification still works offline
      }

      return wasteClassification;
    } catch (e) {
      throw Exception('Error classifying waste: $e');
    }
  }

  /// Save waste image locally (no Firebase Storage needed)
  static Future<String> _uploadWasteImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final wasteImagesDir = Directory('${directory.path}/waste_images');

      if (!await wasteImagesDir.exists()) {
        await wasteImagesDir.create(recursive: true);
      }

      // Create unique filename
      final fileName =
          'waste_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final localFile = File('${wasteImagesDir.path}/$fileName');

      // Copy the image to local storage
      await imageFile.copy(localFile.path);

      debugPrint('Waste image saved locally: ${localFile.path}');
      return localFile.path;
    } catch (e) {
      debugPrint('Error saving waste image locally: $e');
      // Return the original file path as fallback
      return imageFile.path;
    }
  }

  /// Simple waste classification (would be replaced with actual AI/ML)
  static Future<Map<String, dynamic>> _classifyWasteImage(
    File imageFile,
  ) async {
    // This is a placeholder - in a real app, you'd use ML Kit, TensorFlow Lite,
    // or a cloud-based image classification service

    // Simulate AI processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Return mock classification based on simple logic
    // In reality, this would analyze the image
    final classifications = [
      {
        'classification': 'Plastic Bottle',
        'wasteType': 'plastic',
        'disposalAdvice':
            'Remove cap and label, rinse, and place in recycling bin.',
        'confidence': 0.85,
      },
      {
        'classification': 'Paper Document',
        'wasteType': 'paper',
        'disposalAdvice':
            'Remove any plastic components and place in paper recycling.',
        'confidence': 0.92,
      },
      {
        'classification': 'Glass Container',
        'wasteType': 'glass',
        'disposalAdvice': 'Rinse thoroughly and place in glass recycling bin.',
        'confidence': 0.78,
      },
      {
        'classification': 'Food Waste',
        'wasteType': 'organic',
        'disposalAdvice':
            'Compost if possible, otherwise dispose in organic waste bin.',
        'confidence': 0.89,
      },
      {
        'classification': 'Electronic Device',
        'wasteType': 'electronic',
        'disposalAdvice':
            'Take to electronic waste recycling center. Do not put in regular trash.',
        'confidence': 0.94,
      },
    ];

    // Return random classification for demo
    classifications.shuffle();
    return classifications.first;
  }

  /// Get user's waste classifications
  static Stream<List<WasteClassification>> getUserWasteClassifications([
    String? userId,
  ]) {
    final uid = userId ?? _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('waste_classifications')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => WasteClassification.fromJson(doc.data()))
                  .toList(),
        );
  }
}
