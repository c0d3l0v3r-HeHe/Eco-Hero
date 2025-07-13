import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/eco_task.dart';
import '../services/user_service.dart';

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
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid,
        description: description,
        category: category,
        pointsEarned: pointsEarned,
        aiScore: aiScore,
        createdAt: DateTime.now(),
      );

      // Try to save task to Firestore
      try {
        await _firestore.collection('tasks').doc(task.id).set(task.toMap());
      } catch (e) {
        debugPrint('Warning: Could not save task to Firestore: $e');
      }

      // Try to add points to user
      try {
        await UserService.addPoints(pointsEarned);
      } catch (e) {
        debugPrint('Warning: Could not update EnvPoints in Firestore: $e');
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
          .limit(50)
          .snapshots()
          .map((snapshot) {
        final tasks = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return EcoTask.fromMap(data, doc.id);
        }).toList();

        // Sort by createdAt descending (newest first)
        tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return tasks;
      });
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
      return Stream.value(<EcoTask>[]);
    }
  }

  /// AI evaluation of eco tasks
  static Future<double> _evaluateTaskWithAI(
    String description,
    String category,
  ) async {
    try {
      // Fallback to simple scoring for now
      return _calculateTaskScore(description, category);
    } catch (e) {
      return _calculateTaskScore(description, category);
    }
  }

  /// Simple task scoring algorithm
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
      case 'waste_reduction':
        baseScore += 1.2;
        break;
      case 'sustainable_living':
        baseScore += 1.3;
        break;
    }

    // Description analysis (simple keyword matching)
    final keywords = description.toLowerCase();
    if (keywords.contains('reduce') || keywords.contains('save')) {
      baseScore += 0.5;
    }
    if (keywords.contains('recycle') || keywords.contains('reuse')) {
      baseScore += 0.5;
    }
    if (keywords.contains('solar') || keywords.contains('renewable')) {
      baseScore += 1.0;
    }
    if (keywords.contains('walk') ||
        keywords.contains('bike') ||
        keywords.contains('public transport')) {
      baseScore += 1.0;
    }
    if (keywords.contains('plastic') || keywords.contains('waste')) {
      baseScore += 0.5;
    }

    // Length bonus
    if (description.length > 20) baseScore += 0.5;
    if (description.length > 50) baseScore += 0.5;

    // Add some randomness (±0.3)
    final random = Random();
    baseScore += (random.nextDouble() - 0.5) * 0.6;

    return baseScore.clamp(1.0, 10.0);
  }
}
