import 'package:cloud_firestore/cloud_firestore.dart';

class CarbonFootprint {
  final String id;
  final String userId;
  final DateTime date;
  final double transportation;
  final double energy;
  final double food;
  final double waste;
  final double total;
  final Map<String, dynamic> details;

  CarbonFootprint({
    required this.id,
    required this.userId,
    required this.date,
    required this.transportation,
    required this.energy,
    required this.food,
    required this.waste,
    required this.total,
    required this.details,
  });

  factory CarbonFootprint.fromMap(Map<String, dynamic> map, String id) {
    return CarbonFootprint(
      id: id,
      userId: map['userId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      transportation: (map['transportation'] ?? 0.0).toDouble(),
      energy: (map['energy'] ?? 0.0).toDouble(),
      food: (map['food'] ?? 0.0).toDouble(),
      waste: (map['waste'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
      details: Map<String, dynamic>.from(map['details'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'transportation': transportation,
      'energy': energy,
      'food': food,
      'waste': waste,
      'total': total,
      'details': details,
    };
  }

  CarbonFootprint copyWith({
    String? id,
    String? userId,
    DateTime? date,
    double? transportation,
    double? energy,
    double? food,
    double? waste,
    double? total,
    Map<String, dynamic>? details,
  }) {
    return CarbonFootprint(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      transportation: transportation ?? this.transportation,
      energy: energy ?? this.energy,
      food: food ?? this.food,
      waste: waste ?? this.waste,
      total: total ?? this.total,
      details: details ?? this.details,
    );
  }
}

class CarbonCalculationInput {
  // Transportation
  final double carKm;
  final double bikeKm;
  final double walkKm;
  final double publicTransportKm;
  final double flightKm;

  // Energy
  final double electricityKwh;
  final double gasKwh;
  final double heatingOilLiters;

  // Food
  final double meatMeals;
  final double vegetarianMeals;
  final double localFood;
  final double processedFood;

  // Waste
  final double recycledWaste;
  final double generalWaste;
  final double compostWaste;

  CarbonCalculationInput({
    this.carKm = 0,
    this.bikeKm = 0,
    this.walkKm = 0,
    this.publicTransportKm = 0,
    this.flightKm = 0,
    this.electricityKwh = 0,
    this.gasKwh = 0,
    this.heatingOilLiters = 0,
    this.meatMeals = 0,
    this.vegetarianMeals = 0,
    this.localFood = 0,
    this.processedFood = 0,
    this.recycledWaste = 0,
    this.generalWaste = 0,
    this.compostWaste = 0,
  });
}
