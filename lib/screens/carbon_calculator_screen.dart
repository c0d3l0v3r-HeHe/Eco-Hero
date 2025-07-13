import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/carbon_footprint.dart';
import '../services/carbon_calculator_service.dart';
import '../services/theme_service.dart';
import 'carbon_history_screen.dart';

class CarbonCalculatorScreen extends StatefulWidget {
  const CarbonCalculatorScreen({super.key});

  @override
  State<CarbonCalculatorScreen> createState() => _CarbonCalculatorScreenState();
}

class _CarbonCalculatorScreenState extends State<CarbonCalculatorScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final CarbonCalculatorService _calculatorService = CarbonCalculatorService();
  final ThemeService _themeService = ThemeService();

  // Form controllers
  final _transportationFormKey = GlobalKey<FormState>();
  final _energyFormKey = GlobalKey<FormState>();
  final _foodFormKey = GlobalKey<FormState>();
  final _wasteFormKey = GlobalKey<FormState>();

  // Transportation controllers
  final _carKmController = TextEditingController();
  final _bikeKmController = TextEditingController();
  final _walkKmController = TextEditingController();
  final _publicTransportKmController = TextEditingController();
  final _flightKmController = TextEditingController();

  // Energy controllers
  final _electricityController = TextEditingController();
  final _gasController = TextEditingController();
  final _heatingOilController = TextEditingController();

  // Food controllers
  final _meatMealsController = TextEditingController();
  final _vegetarianMealsController = TextEditingController();
  final _localFoodController = TextEditingController();
  final _processedFoodController = TextEditingController();

  // Waste controllers
  final _recycledWasteController = TextEditingController();
  final _generalWasteController = TextEditingController();
  final _compostWasteController = TextEditingController();

  CarbonFootprint? _calculationResult;
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Dispose all controllers
    _carKmController.dispose();
    _bikeKmController.dispose();
    _walkKmController.dispose();
    _publicTransportKmController.dispose();
    _flightKmController.dispose();
    _electricityController.dispose();
    _gasController.dispose();
    _heatingOilController.dispose();
    _meatMealsController.dispose();
    _vegetarianMealsController.dispose();
    _localFoodController.dispose();
    _processedFoodController.dispose();
    _recycledWasteController.dispose();
    _generalWasteController.dispose();
    _compostWasteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeService,
      builder: (context, child) {
        final isGrassTheme = _themeService.isGrassTheme;
        final mainColor = isGrassTheme ? Colors.green : Colors.blue;

        return Scaffold(
          backgroundColor:
              isGrassTheme ? Colors.green.shade50 : Colors.blue.shade50,
          appBar: AppBar(
            title: const Text(
              'Carbon Calculator',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: mainColor.shade600,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CarbonHistoryScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.history),
                tooltip: 'View History',
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(icon: Icon(Icons.directions_car), text: 'Transport'),
                Tab(icon: Icon(Icons.bolt), text: 'Energy'),
                Tab(icon: Icon(Icons.restaurant), text: 'Food'),
                Tab(icon: Icon(Icons.delete), text: 'Waste'),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTransportationTab(mainColor),
                    _buildEnergyTab(mainColor),
                    _buildFoodTab(mainColor),
                    _buildWasteTab(mainColor),
                  ],
                ),
              ),
              _buildCalculateButton(mainColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransportationTab(MaterialColor mainColor) {
    return Form(
      key: _transportationFormKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(
            '🚗 Transportation',
            'Track your daily travel',
            mainColor,
          ),
          _buildNumberField(
            _carKmController,
            'Car/Motorcycle (km)',
            Icons.directions_car,
            mainColor,
          ),
          _buildNumberField(
            _bikeKmController,
            'Bicycle (km)',
            Icons.directions_bike,
            mainColor,
          ),
          _buildNumberField(
            _walkKmController,
            'Walking (km)',
            Icons.directions_walk,
            mainColor,
          ),
          _buildNumberField(
            _publicTransportKmController,
            'Public Transport (km)',
            Icons.train,
            mainColor,
          ),
          _buildNumberField(
            _flightKmController,
            'Flight (km)',
            Icons.flight,
            mainColor,
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyTab(MaterialColor mainColor) {
    return Form(
      key: _energyFormKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(
            '⚡ Energy Usage',
            'Your daily energy consumption',
            mainColor,
          ),
          _buildNumberField(
            _electricityController,
            'Electricity (kWh)',
            Icons.bolt,
            mainColor,
          ),
          _buildNumberField(
            _gasController,
            'Natural Gas (kWh)',
            Icons.local_fire_department,
            mainColor,
          ),
          _buildNumberField(
            _heatingOilController,
            'Heating Oil (liters)',
            Icons.oil_barrel,
            mainColor,
          ),
        ],
      ),
    );
  }

  Widget _buildFoodTab(MaterialColor mainColor) {
    return Form(
      key: _foodFormKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(
            '🍽️ Food Consumption',
            'Your daily food choices',
            mainColor,
          ),
          _buildNumberField(
            _meatMealsController,
            'Meat Meals',
            Icons.restaurant,
            mainColor,
          ),
          _buildNumberField(
            _vegetarianMealsController,
            'Vegetarian Meals',
            Icons.eco,
            mainColor,
          ),
          _buildNumberField(
            _localFoodController,
            'Local Food (kg)',
            Icons.agriculture,
            mainColor,
          ),
          _buildNumberField(
            _processedFoodController,
            'Processed Food (kg)',
            Icons.inventory,
            mainColor,
          ),
        ],
      ),
    );
  }

  Widget _buildWasteTab(MaterialColor mainColor) {
    return Form(
      key: _wasteFormKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(
            '🗑️ Waste Production',
            'Your daily waste output',
            mainColor,
          ),
          _buildNumberField(
            _recycledWasteController,
            'Recycled Waste (kg)',
            Icons.recycling,
            mainColor,
          ),
          _buildNumberField(
            _generalWasteController,
            'General Waste (kg)',
            Icons.delete,
            mainColor,
          ),
          _buildNumberField(
            _compostWasteController,
            'Compost Waste (kg)',
            Icons.compost,
            mainColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String subtitle,
    MaterialColor mainColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: mainColor,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField(
    TextEditingController controller,
    String label,
    IconData icon,
    MaterialColor mainColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: mainColor.shade600),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: mainColor.shade600, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            if (double.parse(value) < 0) {
              return 'Please enter a positive number';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCalculateButton(MaterialColor mainColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _isCalculating ? null : _calculateCarbonFootprint,
        style: ElevatedButton.styleFrom(
          backgroundColor: mainColor.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child:
            _isCalculating
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : const Text(
                  'Calculate Carbon Footprint',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
      ),
    );
  }

  void _showResultBottomSheet(MaterialColor mainColor) {
    if (_calculationResult == null) return;

    final result = _calculationResult!;
    final tips = _calculatorService.getCarbonReductionTips(result);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.eco,
                                  color: mainColor.shade600,
                                  size: 28,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Your Carbon Footprint',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildEmissionItem(
                              '🚗 Transportation',
                              result.transportation,
                              mainColor,
                            ),
                            _buildEmissionItem(
                              '⚡ Energy',
                              result.energy,
                              mainColor,
                            ),
                            _buildEmissionItem(
                              '🍽️ Food',
                              result.food,
                              mainColor,
                            ),
                            _buildEmissionItem(
                              '🗑️ Waste',
                              result.waste,
                              mainColor,
                            ),
                            const Divider(thickness: 2),
                            _buildEmissionItem(
                              '🌍 Total Daily Emissions',
                              result.total,
                              mainColor,
                              isTotal: true,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '💡 Reduction Tips:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: mainColor.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...tips
                                .take(3)
                                .map(
                                  (tip) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      '• $tip',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close modal
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey.shade600,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Close'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _saveCarbonFootprint();
                                      Navigator.pop(
                                        context,
                                      ); // Close modal after saving
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: mainColor.shade600,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Save Result'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ), // Extra padding at bottom
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildEmissionItem(
    String label,
    double value,
    MaterialColor mainColor, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${value.toStringAsFixed(2)} kg CO₂',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? mainColor.shade700 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _calculateCarbonFootprint() {
    // Validate all forms
    bool isValid = true;
    isValid &= _transportationFormKey.currentState?.validate() ?? true;
    isValid &= _energyFormKey.currentState?.validate() ?? true;
    isValid &= _foodFormKey.currentState?.validate() ?? true;
    isValid &= _wasteFormKey.currentState?.validate() ?? true;

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the form'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCalculating = true;
    });

    try {
      final input = CarbonCalculationInput(
        carKm: double.tryParse(_carKmController.text) ?? 0,
        bikeKm: double.tryParse(_bikeKmController.text) ?? 0,
        walkKm: double.tryParse(_walkKmController.text) ?? 0,
        publicTransportKm:
            double.tryParse(_publicTransportKmController.text) ?? 0,
        flightKm: double.tryParse(_flightKmController.text) ?? 0,
        electricityKwh: double.tryParse(_electricityController.text) ?? 0,
        gasKwh: double.tryParse(_gasController.text) ?? 0,
        heatingOilLiters: double.tryParse(_heatingOilController.text) ?? 0,
        meatMeals: double.tryParse(_meatMealsController.text) ?? 0,
        vegetarianMeals: double.tryParse(_vegetarianMealsController.text) ?? 0,
        localFood: double.tryParse(_localFoodController.text) ?? 0,
        processedFood: double.tryParse(_processedFoodController.text) ?? 0,
        recycledWaste: double.tryParse(_recycledWasteController.text) ?? 0,
        generalWaste: double.tryParse(_generalWasteController.text) ?? 0,
        compostWaste: double.tryParse(_compostWasteController.text) ?? 0,
      );

      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final result = _calculatorService.calculateCarbonFootprint(userId, input);

      setState(() {
        _calculationResult = result;
        _isCalculating = false;
      });

      // Show result in a modal bottom sheet
      _showResultBottomSheet(
        _themeService.isGrassTheme ? Colors.green : Colors.blue,
      );
    } catch (e) {
      setState(() {
        _isCalculating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error calculating carbon footprint: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _saveCarbonFootprint() async {
    if (_calculationResult == null) return;

    try {
      await _calculatorService.saveCarbonFootprint(_calculationResult!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Carbon footprint saved successfully!'),
          backgroundColor:
              _themeService.isGrassTheme ? Colors.green : Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving carbon footprint: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
