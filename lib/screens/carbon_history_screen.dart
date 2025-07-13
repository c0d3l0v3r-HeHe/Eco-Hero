import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/carbon_footprint.dart';
import '../services/carbon_calculator_service.dart';

class CarbonHistoryScreen extends StatefulWidget {
  const CarbonHistoryScreen({super.key});

  @override
  State<CarbonHistoryScreen> createState() => _CarbonHistoryScreenState();
}

class _CarbonHistoryScreenState extends State<CarbonHistoryScreen> {
  final CarbonCalculatorService _calculatorService = CarbonCalculatorService();
  List<CarbonFootprint> _history = [];
  double _averageFootprint = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCarbonHistory();
  }

  Future<void> _loadCarbonHistory() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final history = await _calculatorService.getUserCarbonHistory(userId);
      final average = await _calculatorService.getAverageDailyCarbonFootprint(
        userId,
      );

      if (mounted) {
        setState(() {
          _history = history;
          _averageFootprint = average;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading carbon history: $e');
      if (mounted) {
        setState(() {
          _history = [];
          _averageFootprint = 0.0;
          _isLoading = false;
        });
        // Don't show error snackbar for Firestore index issues
        if (!e.toString().contains('failed-precondition') &&
            !e.toString().contains('index')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading history: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text(
          'Carbon History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadCarbonHistory,
                child:
                    _history.isEmpty
                        ? _buildEmptyState()
                        : Column(
                          children: [
                            _buildStatsCard(),
                            Expanded(child: _buildHistoryList()),
                          ],
                        ),
              ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No Carbon Footprint Data',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your carbon footprint\nto see your progress here',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.calculate),
            label: const Text('Calculate Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.green.shade600, size: 28),
              const SizedBox(width: 8),
              const Text(
                'Your Carbon Stats',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Records',
                  _history.length.toString(),
                  Icons.assessment,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '7-Day Average',
                  '${_averageFootprint.toStringAsFixed(1)} kg CO₂',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Last Calculation',
                  _history.isNotEmpty
                      ? _formatDate(_history.first.date)
                      : 'None',
                  Icons.schedule,
                  Colors.purple,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Best Day',
                  _history.isNotEmpty
                      ? '${_history.map((e) => e.total).reduce((a, b) => a < b ? a : b).toStringAsFixed(1)} kg CO₂'
                      : 'None',
                  Icons.eco,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final footprint = _history[index];
        return _buildHistoryCard(footprint);
      },
    );
  }

  Widget _buildHistoryCard(CarbonFootprint footprint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getCarbonLevelColor(footprint.total).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.eco,
            color: _getCarbonLevelColor(footprint.total),
            size: 24,
          ),
        ),
        title: Text(
          _formatDate(footprint.date),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${footprint.total.toStringAsFixed(2)} kg CO₂ • ${_getCarbonLevel(footprint.total)}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: Icon(Icons.expand_more, color: Colors.grey.shade600),
        children: [
          Row(
            children: [
              Expanded(
                child: _buildEmissionBreakdown(
                  '🚗 Transport',
                  footprint.transportation,
                  footprint.total,
                ),
              ),
              Expanded(
                child: _buildEmissionBreakdown(
                  '⚡ Energy',
                  footprint.energy,
                  footprint.total,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildEmissionBreakdown(
                  '🍽️ Food',
                  footprint.food,
                  footprint.total,
                ),
              ),
              Expanded(
                child: _buildEmissionBreakdown(
                  '🗑️ Waste',
                  footprint.waste,
                  footprint.total,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmissionBreakdown(String category, double value, double total) {
    final percentage = total > 0 ? (value / total * 100) : 0.0;

    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(1)} kg',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getCarbonLevel(double total) {
    if (total < 5) return 'Excellent';
    if (total < 10) return 'Good';
    if (total < 15) return 'Fair';
    return 'High';
  }

  Color _getCarbonLevelColor(double total) {
    if (total < 5) return Colors.green;
    if (total < 10) return Colors.lightGreen;
    if (total < 15) return Colors.orange;
    return Colors.red;
  }
}
