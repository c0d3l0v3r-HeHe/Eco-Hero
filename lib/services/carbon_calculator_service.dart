import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/carbon_footprint.dart';

class CarbonCalculatorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Carbon emission factors (kg CO2 per unit)
  static const Map<String, double> _emissionFactors = {
    // Transportation (kg CO2 per km)
    'car_petrol': 0.21,
    'car_diesel': 0.17,
    'car_electric': 0.05,
    'bike': 0.0,
    'walk': 0.0,
    'bus': 0.08,
    'train': 0.04,
    'flight_domestic': 0.25,
    'flight_international': 0.3,

    // Energy (kg CO2 per kWh/liter)
    'electricity': 0.5,
    'natural_gas': 0.18,
    'heating_oil': 2.5,

    // Food (kg CO2 per meal/kg)
    'meat_meal': 3.5,
    'vegetarian_meal': 1.2,
    'local_food_bonus': -0.3,
    'processed_food_penalty': 0.8,

    // Waste (kg CO2 per kg)
    'general_waste': 0.5,
    'recycled_waste': 0.1,
    'compost_waste': 0.05,
  };

  /// Calculate carbon footprint from user inputs
  CarbonFootprint calculateCarbonFootprint(
    String userId,
    CarbonCalculationInput input,
  ) {
    final date = DateTime.now();

    // Calculate transportation emissions
    final transportationEmissions = _calculateTransportation(input);

    // Calculate energy emissions
    final energyEmissions = _calculateEnergy(input);

    // Calculate food emissions
    final foodEmissions = _calculateFood(input);

    // Calculate waste emissions
    final wasteEmissions = _calculateWaste(input);

    // Calculate total
    final total = transportationEmissions + energyEmissions + foodEmissions + wasteEmissions;

    // Create detailed breakdown
    final details = {
      'transportation_breakdown': {
        'car_km': input.carKm,
        'bike_km': input.bikeKm,
        'walk_km': input.walkKm,
        'public_transport_km': input.publicTransportKm,
        'flight_km': input.flightKm,
      },
      'energy_breakdown': {
        'electricity_kwh': input.electricityKwh,
        'gas_kwh': input.gasKwh,
        'heating_oil_liters': input.heatingOilLiters,
      },
      'food_breakdown': {
        'meat_meals': input.meatMeals,
        'vegetarian_meals': input.vegetarianMeals,
        'local_food_kg': input.localFood,
        'processed_food_kg': input.processedFood,
      },
      'waste_breakdown': {
        'recycled_kg': input.recycledWaste,
        'general_kg': input.generalWaste,
        'compost_kg': input.compostWaste,
      },
      'calculation_date': date.toIso8601String(),
    };

    return CarbonFootprint(
      id: '',
      userId: userId,
      date: date,
      transportation: transportationEmissions,
      energy: energyEmissions,
      food: foodEmissions,
      waste: wasteEmissions,
      total: total,
      details: details,
    );
  }

  double _calculateTransportation(CarbonCalculationInput input) {
    double total = 0;

    // Car emissions (assuming mixed petrol/diesel)
    total += input.carKm * _emissionFactors['car_petrol']!;

    // Public transport
    total += input.publicTransportKm * _emissionFactors['bus']!;

    // Flight emissions
    total += input.flightKm * _emissionFactors['flight_domestic']!;

    // Bike and walking are carbon neutral
    // But we can give bonus points for eco-friendly transport

    return total;
  }

  double _calculateEnergy(CarbonCalculationInput input) {
    double total = 0;

    total += input.electricityKwh * _emissionFactors['electricity']!;
    total += input.gasKwh * _emissionFactors['natural_gas']!;
    total += input.heatingOilLiters * _emissionFactors['heating_oil']!;

    return total;
  }

  double _calculateFood(CarbonCalculationInput input) {
    double total = 0;

    total += input.meatMeals * _emissionFactors['meat_meal']!;
    total += input.vegetarianMeals * _emissionFactors['vegetarian_meal']!;
    
    // Local food reduces emissions
    total += input.localFood * _emissionFactors['local_food_bonus']!;
    
    // Processed food increases emissions
    total += input.processedFood * _emissionFactors['processed_food_penalty']!;

    return total.abs(); // Ensure non-negative
  }

  double _calculateWaste(CarbonCalculationInput input) {
    double total = 0;

    total += input.generalWaste * _emissionFactors['general_waste']!;
    total += input.recycledWaste * _emissionFactors['recycled_waste']!;
    total += input.compostWaste * _emissionFactors['compost_waste']!;

    return total;
  }

  /// Save carbon footprint to Firestore
  Future<String> saveCarbonFootprint(CarbonFootprint footprint) async {
    try {
      final docRef = await _firestore
          .collection('carbon_footprints')
          .add(footprint.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save carbon footprint: $e');
    }
  }

  /// Get user's carbon footprint history
  Future<List<CarbonFootprint>> getUserCarbonHistory(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('carbon_footprints')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(30) // Last 30 entries
          .get();

      return querySnapshot.docs
          .map((doc) => CarbonFootprint.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get carbon history: $e');
    }
  }

  /// Get user's average daily carbon footprint
  Future<double> getAverageDailyCarbonFootprint(String userId, {int days = 7}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      
      final querySnapshot = await _firestore
          .collection('carbon_footprints')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThan: Timestamp.fromDate(startDate))
          .get();

      if (querySnapshot.docs.isEmpty) return 0.0;

      final footprints = querySnapshot.docs
          .map((doc) => CarbonFootprint.fromMap(doc.data(), doc.id))
          .toList();

      final totalEmissions = footprints.fold<double>(
        0.0,
        (sum, footprint) => sum + footprint.total,
      );

      return totalEmissions / footprints.length;
    } catch (e) {
      throw Exception('Failed to calculate average carbon footprint: $e');
    }
  }

  /// Get carbon footprint recommendations based on user's data
  List<String> getCarbonReductionTips(CarbonFootprint footprint) {
    final tips = <String>[];

    // Transportation tips
    if (footprint.transportation > 5.0) {
      tips.add('🚴‍♂️ Try cycling or walking for short distances');
      tips.add('🚌 Use public transport instead of driving');
      tips.add('🚗 Consider carpooling or ride-sharing');
    }

    // Energy tips
    if (footprint.energy > 3.0) {
      tips.add('💡 Switch to LED bulbs and energy-efficient appliances');
      tips.add('🌡️ Lower your thermostat by 1-2 degrees');
      tips.add('🔌 Unplug electronics when not in use');
    }

    // Food tips
    if (footprint.food > 4.0) {
      tips.add('🥗 Try having more plant-based meals');
      tips.add('🏪 Buy local and seasonal produce');
      tips.add('📦 Reduce processed and packaged foods');
    }

    // Waste tips
    if (footprint.waste > 2.0) {
      tips.add('♻️ Increase recycling and composting');
      tips.add('🛍️ Use reusable bags and containers');
      tips.add('🗑️ Reduce single-use items');
    }

    // General tips if overall footprint is high
    if (footprint.total > 15.0) {
      tips.add('🌱 Plant trees or support reforestation projects');
      tips.add('💚 Choose eco-friendly products and services');
    }

    return tips;
  }
}
