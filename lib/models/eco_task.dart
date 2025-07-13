class EcoTask {
  final String id;
  final String description;
  final String category;
  final int pointsEarned;
  final double aiScore;
  final DateTime createdAt;
  final String userId;

  EcoTask({
    required this.id,
    required this.description,
    required this.category,
    required this.pointsEarned,
    required this.aiScore,
    required this.createdAt,
    required this.userId,
  });

  factory EcoTask.fromMap(Map<String, dynamic> map, String id) {
    return EcoTask(
      id: id,
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      pointsEarned: map['pointsEarned'] ?? 0,
      aiScore: (map['aiScore'] ?? 0.0).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      userId: map['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'category': category,
      'pointsEarned': pointsEarned,
      'aiScore': aiScore,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'userId': userId,
    };
  }
}
