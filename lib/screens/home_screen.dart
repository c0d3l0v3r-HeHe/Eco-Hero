import 'package:flutter/material.dart';
import 'dart:async';
import 'carbon_calculator_screen.dart';
import 'news_screen_enhanced.dart';
import 'tasks_screen.dart';
import 'waste_scanner_screen_enhanced.dart';
import 'profile_screen.dart';
import 'leaderboard_screen.dart';
import 'rewards_screen.dart';
import 'settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';
import '../services/theme_service.dart';
import '../models/app_theme.dart';
import '../widgets/animated_grass_background.dart';
import '../widgets/animated_marine_background.dart';
import '../widgets/animated_vine_background.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final ThemeService _themeService = ThemeService();
  late AnimationController _welcomeController;
  late AnimationController _contentController;
  late AnimationController _pageTransitionController;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeUserProfile();
    _initializeTheme();
  }

  void _initializeAnimations() {
    // Welcome message animation
    _welcomeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Content animation (slides up from bottom)
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );

    // Page transition animation
    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );

    // Start animations immediately when app opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _selectedIndex == 0) {
        // Start animations immediately so content appears
        _welcomeController.forward();
        _contentController.forward();
      }
    });
  }

  @override
  void dispose() {
    _welcomeController.dispose();
    _contentController.dispose();
    _pageTransitionController.dispose();
    super.dispose();
  }

  Future<void> _initializeUserProfile() async {
    try {
      await UserService.createOrUpdateUserProfile();
    } catch (e) {
      debugPrint('Error initializing user profile: $e');
    }
  }

  Future<void> _initializeTheme() async {
    try {
      await _themeService.initialize();
    } catch (e) {
      debugPrint('Error initializing theme: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeService,
      builder: (context, child) {
        final isGrassTheme = _themeService.isGrassTheme;
        final mainColor = isGrassTheme ? Colors.green : Colors.blue;
        final flowerType = _themeService.currentTheme.flowerType;

        return PopScope(
          canPop: _selectedIndex == 0, // Only allow popping when on home tab
          onPopInvoked: (didPop) {
            if (!didPop && _selectedIndex != 0) {
              // If not on home tab and back is pressed, go to home tab
              setState(() {
                _selectedIndex = 0;
              });
              // Restart animations when returning to home
              _welcomeController.reset();
              _contentController.reset();
              _welcomeController.forward();
              _contentController.forward();
            }
          },
          child: Scaffold(
            backgroundColor:
                isGrassTheme ? Colors.green.shade50 : Colors.blue.shade50,
            drawer: _buildProfileDrawer(isGrassTheme, mainColor, flowerType),
            appBar: _buildAppBar(isGrassTheme, mainColor, flowerType),
            body: _buildBody(),
            bottomNavigationBar: _buildBottomNavigationBar(mainColor),
          ), // Close PopScope
        ); // Close build method
      },
    );
  }

  AppBar _buildAppBar(
    bool isGrassTheme,
    MaterialColor mainColor,
    FlowerType flowerType,
  ) {
    return AppBar(
      title: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: mainColor.shade300,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.eco, color: mainColor.shade700, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'EcoHero',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: mainColor.shade700,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            _showNotificationComingSoonDialog();
          },
        ),
        // EnvPoints Display with themed flower icon
        StreamBuilder<UserProfile?>(
          stream: UserService.getUserProfileStream(),
          builder: (context, snapshot) {
            final envPoints = snapshot.data?.envPoints ?? 0;
            return Container(
              margin: const EdgeInsets.only(right: 15, top: 12, bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFlowerIcon(flowerType, 16, mainColor),
                  const SizedBox(width: 4),
                  Text(
                    snapshot.hasError ? '0' : '$envPoints',
                    style: TextStyle(
                      color: mainColor.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFlowerIcon(
    FlowerType flowerType,
    double size,
    MaterialColor mainColor,
  ) {
    if (!_themeService.isGrassTheme) {
      return Icon(Icons.eco, color: mainColor.shade700, size: size);
    }

    switch (flowerType) {
      case FlowerType.redRose:
        return Icon(
          Icons.local_florist,
          size: size,
          color: Colors.red.shade600,
        );
      case FlowerType.tulip:
        return Icon(Icons.eco, size: size, color: Colors.pink.shade400);
      case FlowerType.lotus:
        return Icon(Icons.spa, size: size, color: Colors.purple.shade400);
    }
  }

  BottomNavigationBar _buildBottomNavigationBar(MaterialColor mainColor) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        if (index != _selectedIndex) {
          _pageTransitionController.reset();
          setState(() {
            _selectedIndex = index;
          });
          _pageTransitionController.forward();

          // When returning to home, restart the animations
          if (index == 0) {
            _welcomeController.reset();
            _contentController.reset();
            _welcomeController.forward();
            _contentController.forward();
          }
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: mainColor.shade700,
      unselectedItemColor: Colors.grey.shade600,
      backgroundColor: _themeService.isGrassTheme
          ? Colors.green.shade100
          : Colors.blue.shade100,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment),
          label: 'Tasks',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.eco_outlined),
          activeIcon: Icon(Icons.eco),
          label: 'Carbon',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.delete_outline),
          activeIcon: Icon(Icons.delete),
          label: 'Waste',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.article_outlined),
          activeIcon: Icon(Icons.article),
          label: 'News',
        ),
      ],
    );
  }

  Widget _buildBody() {
    final isGrassTheme = _themeService.isGrassTheme;
    final flowerType = _themeService.currentTheme.flowerType;

    Widget bodyContent;
    switch (_selectedIndex) {
      case 0:
        bodyContent = _buildDashboard();
        break;
      case 1:
        bodyContent = const TasksScreen();
        break;
      case 2:
        bodyContent = const CarbonCalculatorScreen();
        break;
      case 3:
        bodyContent = const WasteScannerScreen();
        break;
      case 4:
        bodyContent = const NewsScreenEnhanced();
        break;
      default:
        bodyContent = _buildDashboard();
    }

    // Wrap with themed background
    Widget themedContent;
    if (_selectedIndex == 0) {
      // Dashboard gets the full background treatment
      if (isGrassTheme) {
        themedContent = AnimatedGrassBackground(
          flowerType: flowerType,
          child: bodyContent,
        );
      } else {
        themedContent = AnimatedMarineBackground(child: bodyContent);
      }
    } else {
      themedContent = bodyContent;
    }

    // Add animated vine background for grass theme on all screens
    if (isGrassTheme) {
      return AnimatedVineBackground(isVisible: true, child: themedContent);
    }

    return themedContent;
  }

  Widget _buildDashboard() {
    final isGrassTheme = _themeService.isGrassTheme;
    final mainColor = isGrassTheme ? Colors.green : Colors.blue;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          _buildThemedContainer(
            isGrassTheme: isGrassTheme,
            mainColor: mainColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGrassTheme
                      ? 'Welcome back, Eco Hero! 🌱'
                      : 'Welcome back, Eco Hero! 🌊',
                  style: TextStyle(
                    color: isGrassTheme
                        ? Colors.white
                        : _themeService.currentTheme.onPrimaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isGrassTheme
                      ? 'Ready to make a positive impact today?'
                      : 'Dive into ocean conservation today!',
                  style: TextStyle(
                    color: isGrassTheme
                        ? Colors.white70
                        : _themeService.currentTheme.onPrimaryColor
                            .withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow.shade300, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      '1,250 Eco Points',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Animated Content Section
          SlideTransition(
            position: _contentSlideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isGrassTheme
                          ? mainColor.shade800
                          : Colors.white, // White for marine theme
                    ),
                  ),
                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio:
                        1.1, // Increased aspect ratio to give more height
                    children: [
                      _buildActionCard(
                        icon: Icons.assignment_add,
                        title: 'Log Activity',
                        subtitle: 'Submit eco task',
                        color: mainColor,
                        isGrassTheme: isGrassTheme,
                        onTap: () {
                          _pageTransitionController.reset();
                          setState(() {
                            _selectedIndex = 1;
                          });
                          _pageTransitionController.forward();
                        },
                      ),
                      _buildActionCard(
                        icon: Icons.calculate,
                        title: 'Carbon Check',
                        subtitle: 'Calculate footprint',
                        color: Colors.orange,
                        isGrassTheme: isGrassTheme,
                        onTap: () {
                          _pageTransitionController.reset();
                          setState(() {
                            _selectedIndex = 2;
                          });
                          _pageTransitionController.forward();
                        },
                      ),
                      _buildActionCard(
                        icon: Icons.camera_alt,
                        title: 'Scan Waste',
                        subtitle: 'Classify waste',
                        color: Colors.purple,
                        isGrassTheme: isGrassTheme,
                        onTap: () {
                          _pageTransitionController.reset();
                          setState(() {
                            _selectedIndex = 3;
                          });
                          _pageTransitionController.forward();
                        },
                      ),
                      _buildActionCard(
                        icon: Icons.article,
                        title: 'Read News',
                        subtitle: 'Eco updates',
                        color: Colors.teal,
                        isGrassTheme: isGrassTheme,
                        onTap: () {
                          _pageTransitionController.reset();
                          setState(() {
                            _selectedIndex = 4;
                          });
                          _pageTransitionController.forward();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Recent Activity
                  Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: mainColor.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildThemedContainer(
                    isGrassTheme: isGrassTheme,
                    mainColor: mainColor,
                    child: const Column(
                      children: [
                        Icon(Icons.eco, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No activities yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start logging your eco-friendly activities to see them here',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemedContainer({
    required bool isGrassTheme,
    required MaterialColor mainColor,
    required Widget child,
  }) {
    final theme = _themeService.currentTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGrassTheme
              ? [mainColor.shade600, mainColor.shade800]
              : theme.primaryGradient, // Use the beautiful ocean gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: isGrassTheme
            ? Border.all(color: Colors.green.shade400, width: 2)
            : Border.all(
                color: theme.bioluminescenceColor.withOpacity(0.5),
                width: 2), // Glowing border for marine
        boxShadow: [
          BoxShadow(
            color: isGrassTheme
                ? mainColor.shade200
                : theme.bioluminescenceColor
                    .withOpacity(0.3), // Glowing shadow for marine
            blurRadius: isGrassTheme ? 10 : 20,
            offset: const Offset(0, 5),
            spreadRadius: isGrassTheme ? 0 : 3,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isGrassTheme,
  }) {
    final theme = _themeService.currentTheme;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: GestureDetector(
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isGrassTheme
                        ? [Colors.white, color.withOpacity(0.05)]
                        : [
                            theme.cardColor,
                            theme.primaryColor.withOpacity(0.1),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isGrassTheme
                        ? color.withOpacity(0.3)
                        : theme.bioluminescenceColor.withOpacity(0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isGrassTheme
                          ? color.withOpacity(0.15)
                          : theme.bioluminescenceColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                      spreadRadius: 2,
                    ),
                    if (!isGrassTheme) ...[
                      // Add extra glow for marine theme
                      BoxShadow(
                        color: theme.bioluminescenceColor.withOpacity(0.2),
                        blurRadius: 25,
                        offset: const Offset(0, 0),
                        spreadRadius: 5,
                      ),
                    ] else ...[
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                        spreadRadius: -2,
                      ),
                    ],
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isGrassTheme
                              ? [
                                  color.withOpacity(0.8),
                                  color.withOpacity(0.6),
                                ]
                              : [
                                  theme.accentColor.withOpacity(0.9),
                                  theme.secondaryColor.withOpacity(0.7),
                                ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isGrassTheme
                                ? color.withOpacity(0.3)
                                : theme.bioluminescenceColor.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                          if (!isGrassTheme) ...[
                            // Extra glow for marine theme
                            BoxShadow(
                              color:
                                  theme.bioluminescenceColor.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 0),
                              spreadRadius: 3,
                            ),
                          ],
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: 24,
                        color:
                            isGrassTheme ? Colors.white : theme.onPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isGrassTheme
                            ? Colors.grey.shade800
                            : theme.textColor,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // Handle overflow
                    ),
                    const SizedBox(height: 2), // Reduced from 4
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: isGrassTheme
                            ? Colors.grey.shade600
                            : theme.textColor.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileDrawer(
    bool isGrassTheme,
    MaterialColor mainColor,
    FlowerType flowerType,
  ) {
    return Drawer(
      child: Column(
        children: [
          // Profile Header - Clickable to open profile screen
          StreamBuilder<UserProfile?>(
            stream: UserService.getUserProfileStream(),
            builder: (context, snapshot) {
              final userProfile = snapshot.data;
              final user = FirebaseAuth.instance.currentUser;

              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 40,
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [mainColor.shade600, mainColor.shade800],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Profile Image
                          GestureDetector(
                            onTap: () => _showProfilePictureDialog(
                              userProfile?.profileImageUrl,
                            ),
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white,
                              backgroundImage: userProfile?.profileImageUrl !=
                                      null
                                  ? (userProfile!.profileImageUrl!
                                          .startsWith('http')
                                      ? NetworkImage(
                                          userProfile.profileImageUrl!,
                                        ) as ImageProvider
                                      : FileImage(
                                          File(userProfile.profileImageUrl!),
                                        ))
                                  : null,
                              child: userProfile?.profileImageUrl == null
                                  ? Icon(
                                      Icons.person,
                                      size: 35,
                                      color: mainColor.shade600,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userProfile?.displayName ??
                                      user?.displayName ??
                                      'EcoHero User',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  user?.email ?? 'No email',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildFlowerIcon(
                                        flowerType,
                                        16,
                                        mainColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${userProfile?.envPoints ?? 0} EnvPoints',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.edit,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.touch_app,
                              color: Colors.white70,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Tap to edit profile',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Menu items
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 10),
                ListTile(
                  leading: Icon(Icons.favorite, color: Colors.pink.shade400),
                  title: const Text(
                    'Donate',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text('Support environmental causes'),
                  onTap: () {
                    Navigator.pop(context);
                    _showDonateDialog();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.card_giftcard,
                    color: Colors.purple.shade400,
                  ),
                  title: const Text(
                    'Rewards',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text('Redeem your EnvPoints'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RewardsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings, color: Colors.grey.shade600),
                  title: const Text(
                    'Settings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text('Theme and preferences'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                const Spacer(),
                // Logout at bottom
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    _showLogoutConfirmation();
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDonateDialog() {
    showDialog(context: context, builder: (context) => const DonateDialog());
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logged out successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error signing out: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showNotificationComingSoonDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications,
                  color: Colors.blue.shade600,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Notifications',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Notifications will be available in the next version! Stay tuned for updates.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it!'),
            ),
          ],
        );
      },
    );
  }

  void _showProfilePictureDialog(String? profileImageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (BuildContext context) {
        return ProfilePictureDialog(profileImageUrl: profileImageUrl);
      },
    );
  }
}

class DonateDialog extends StatefulWidget {
  const DonateDialog({super.key});

  @override
  State<DonateDialog> createState() => _DonateDialogState();
}

class _DonateDialogState extends State<DonateDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _currentSlideAnimation;
  late Animation<Offset> _nextSlideAnimation;

  int _currentTextIndex = 0;
  int _nextTextIndex = 1;
  final List<String> _texts = [
    'Help Save Our Planet 🌍',
    'Support Green Initiatives 🌱',
    'Fund Ocean Cleanup 🌊',
    'Plant More Trees 🌳',
    'Renewable Energy Projects ⚡',
    'Protect Wildlife 🦋',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _currentSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );

    _nextSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );

    _controller.forward();
    _startTextCycle();
  }

  void _startTextCycle() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        _slideToNextText();
      } else {
        timer.cancel();
      }
    });
  }

  void _slideToNextText() {
    _nextTextIndex = (_currentTextIndex + 1) % _texts.length;
    _slideController.forward().then((_) {
      setState(() {
        _currentTextIndex = _nextTextIndex;
      });
      _slideController.reset();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: SizedBox(
              width: 300, // Fixed width
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.pink.shade400, Colors.red.shade400],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 60, // Fixed height for text area
                    child: AnimatedBuilder(
                      animation: _slideController,
                      builder: (context, child) {
                        return Stack(
                          children: [
                            // Current text sliding out to the left
                            if (_slideController.value < 1.0)
                              SlideTransition(
                                position: _currentSlideAnimation,
                                child: Opacity(
                                  opacity:
                                      _slideController.value < 0.5 ? 1.0 : 0.0,
                                  child: Center(
                                    child: Text(
                                      _texts[_currentTextIndex],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            // Next text sliding in from the right
                            if (_slideController.value > 0.0)
                              SlideTransition(
                                position: _nextSlideAnimation,
                                child: Opacity(
                                  opacity:
                                      _slideController.value > 0.5 ? 1.0 : 0.0,
                                  child: Center(
                                    child: Text(
                                      _texts[_nextTextIndex],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.construction,
                          color: Colors.amber.shade700,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Coming Soon!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sorry for the inconvenience.',
                          style: TextStyle(color: Colors.amber.shade700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Donate by your talent, every penny is appreciated but that is not all we care about! 💚',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Follow us on social media:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                // TODO: Add Facebook link
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Facebook link coming soon!'),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1877F2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.facebook,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // TODO: Add Instagram link
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Instagram link coming soon!',
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFE4405F),
                                      Color(0xFFFCAF45),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // TODO: Add X (Twitter) link
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'X (Twitter) link coming soon!',
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '𝕏',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Thank you for your interest! 💚'),
                      backgroundColor: Colors.green.shade600,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                ),
                child: const Text('Notify Me'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProfilePictureDialog extends StatefulWidget {
  final String? profileImageUrl;

  const ProfilePictureDialog({super.key, this.profileImageUrl});

  @override
  State<ProfilePictureDialog> createState() => _ProfilePictureDialogState();
}

class _ProfilePictureDialogState extends State<ProfilePictureDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              alignment: Alignment.center,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Stack(
                    children: [
                      // Profile Picture
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: widget.profileImageUrl != null
                              ? (widget.profileImageUrl!.startsWith('http')
                                  ? Image.network(
                                      widget.profileImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Icon(
                                          Icons.person,
                                          size: 120,
                                          color: Colors.green.shade600,
                                        );
                                      },
                                    )
                                  : Image.file(
                                      File(widget.profileImageUrl!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Icon(
                                          Icons.person,
                                          size: 120,
                                          color: Colors.green.shade600,
                                        );
                                      },
                                    ))
                              : Icon(
                                  Icons.person,
                                  size: 120,
                                  color: Colors.green.shade600,
                                ),
                        ),
                      ),
                      // Edit button only
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
