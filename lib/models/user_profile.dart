import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String? profileImageUrl;
  final int envPoints;
  final DateTime createdAt;
  final DateTime lastUpdated;

  UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.profileImageUrl,
    this.envPoints = 0,
    required this.createdAt,
    required this.lastUpdated,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      envPoints: json['envPoints'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastUpdated: json['lastUpdated'] != null 
          ? (json['lastUpdated'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'envPoints': envPoints,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? profileImageUrl,
    int? envPoints,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      envPoints: envPoints ?? this.envPoints,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class EcoTask {
  final String id;
  final String userId;
  final String description;
  final String category; // e.g., 'recycling', 'energy', 'transportation', 'water'
  final int pointsEarned;
  final double aiScore; // 0-10 rating from AI
  final DateTime completedAt;
  final String? imageUrl; // Optional proof image

  EcoTask({
    required this.id,
    required this.userId,
    required this.description,
    required this.category,
    required this.pointsEarned,
    required this.aiScore,
    required this.completedAt,
    this.imageUrl,
  });

  factory EcoTask.fromJson(Map<String, dynamic> json) {
    return EcoTask(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      pointsEarned: json['pointsEarned'] ?? 0,
      aiScore: (json['aiScore'] ?? 0.0).toDouble(),
      completedAt: json['completedAt'] != null 
          ? (json['completedAt'] as Timestamp).toDate()
          : DateTime.now(),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'description': description,
      'category': category,
      'pointsEarned': pointsEarned,
      'aiScore': aiScore,
      'completedAt': Timestamp.fromDate(completedAt),
      'imageUrl': imageUrl,
    };
  }
}

class WasteClassification {
  final String id;
  final String userId;
  final String imageUrl;
  final String classification;
  final String wasteType; // e.g., 'plastic', 'paper', 'glass', 'organic', 'electronic'
  final String disposalAdvice;
  final double confidence;
  final DateTime createdAt;

  WasteClassification({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.classification,
    required this.wasteType,
    required this.disposalAdvice,
    required this.confidence,
    required this.createdAt,
  });

  factory WasteClassification.fromJson(Map<String, dynamic> json) {
    return WasteClassification(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      classification: json['classification'] ?? '',
      wasteType: json['wasteType'] ?? '',
      disposalAdvice: json['disposalAdvice'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'classification': classification,
      'wasteType': wasteType,
      'disposalAdvice': disposalAdvice,
      'confidence': confidence,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
