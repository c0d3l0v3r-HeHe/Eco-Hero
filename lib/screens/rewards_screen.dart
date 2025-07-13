import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user_profile.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with TickerProviderStateMixin {
  UserProfile? _userProfile;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<RewardItem> _badges = [
    RewardItem(
      id: 'eco_warrior',
      name: 'Eco Warrior',
      description: 'Complete 10 eco tasks',
      cost: 100,
      icon: Icons.eco,
      color: Colors.green,
      type: RewardType.badge,
    ),
    RewardItem(
      id: 'tree_lover',
      name: 'Tree Lover',
      description: 'Plant 5 trees',
      cost: 150,
      icon: Icons.nature,
      color: Colors.brown,
      type: RewardType.badge,
    ),
    RewardItem(
      id: 'waste_reducer',
      name: 'Waste Reducer',
      description: 'Log 20 waste items',
      cost: 120,
      icon: Icons.recycling,
      color: Colors.blue,
      type: RewardType.badge,
    ),
  ];

  final List<RewardItem> _medals = [
    RewardItem(
      id: 'carbon_hero',
      name: 'Carbon Hero',
      description: 'Reduce carbon by 100kg',
      cost: 300,
      icon: Icons.emoji_events,
      color: const Color(0xFFFFD700), // Gold
      type: RewardType.medal,
    ),
    RewardItem(
      id: 'green_champion',
      name: 'Green Champion',
      description: 'Reach 500 EnvPoints',
      cost: 250,
      icon: Icons.workspace_premium,
      color: const Color(0xFFC0C0C0), // Silver
      type: RewardType.medal,
    ),
  ];

  final List<RewardItem> _titles = [
    RewardItem(
      id: 'earth_guardian',
      name: 'Earth Guardian',
      description: 'Ultimate eco title',
      cost: 500,
      icon: Icons.shield,
      color: Colors.purple,
      type: RewardType.title,
    ),
    RewardItem(
      id: 'nature_protector',
      name: 'Nature Protector',
      description: 'Advanced eco title',
      cost: 400,
      icon: Icons.security,
      color: Colors.indigo,
      type: RewardType.title,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await UserService.getUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _redeemReward(RewardItem reward) {
    if (_userProfile == null) return;

    if (_userProfile!.envPoints < reward.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Not enough EnvPoints! You need ${reward.cost} points.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Redemption'),
            content: Text(
              'Redeem "${reward.name}" for ${reward.cost} EnvPoints?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _processRedemption(reward);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                ),
                child: const Text('Redeem'),
              ),
            ],
          ),
    );
  }

  Future<void> _processRedemption(RewardItem reward) async {
    try {
      // Deduct points (in a real app, this would be handled server-side)
      await UserService.addEnvPoints(-reward.cost);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Congratulations! You redeemed "${reward.name}"!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Reload user profile
        _loadUserProfile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error redeeming reward: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: CustomScrollView(
                    slivers: [
                      // Header with EnvPoints
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade600,
                                Colors.green.shade400,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.shade200,
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.stars,
                                size: 60,
                                color: Colors.yellow.shade300,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Rewards Store',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_userProfile?.envPoints ?? 0} EnvPoints',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Badges Section
                      _buildRewardSection('🏆 Badges', _badges),

                      // Medals Section
                      _buildRewardSection('🥇 Medals', _medals),

                      // Titles Section
                      _buildRewardSection('👑 Titles', _titles),

                      const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildRewardSection(String title, List<RewardItem> rewards) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ),
            ...rewards.map((reward) => _buildRewardCard(reward)),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard(RewardItem reward) {
    final canAfford = (_userProfile?.envPoints ?? 0) >= reward.cost;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                reward.color.withOpacity(0.1),
                reward.color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: reward.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(reward.icon, color: reward.color, size: 30),
            ),
            title: Text(
              reward.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  reward.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        canAfford ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${reward.cost} EnvPoints',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color:
                          canAfford
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: canAfford ? () => _redeemReward(reward) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canAfford ? reward.color : Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Redeem'),
            ),
          ),
        ),
      ),
    );
  }
}

class RewardItem {
  final String id;
  final String name;
  final String description;
  final int cost;
  final IconData icon;
  final Color color;
  final RewardType type;

  RewardItem({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.icon,
    required this.color,
    required this.type,
  });
}

enum RewardType { badge, medal, title }
