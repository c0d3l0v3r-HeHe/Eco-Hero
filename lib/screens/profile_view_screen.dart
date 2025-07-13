import 'package:flutter/material.dart';
import 'dart:io';
import '../models/user_profile.dart';

class ProfileViewScreen extends StatefulWidget {
  final UserProfile user;

  const ProfileViewScreen({super.key, required this.user});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _heartController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _heartAnimation;

  bool _isLiked = false;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heartController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _heartAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with close button
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Profile',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(
                                Icons.close,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Profile Content
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              // Profile Image and Basic Info
                              Column(
                                children: [
                                  // Profile Image
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.green.shade300,
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.shade100,
                                          blurRadius: 15,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child:
                                          widget.user.profileImageUrl != null
                                              ? widget.user.profileImageUrl!
                                                      .startsWith('http')
                                                  ? Image.network(
                                                    widget
                                                        .user
                                                        .profileImageUrl!,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return _buildAvatarPlaceholder();
                                                    },
                                                  )
                                                  : Image.file(
                                                    File(
                                                      widget
                                                          .user
                                                          .profileImageUrl!,
                                                    ),
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return _buildAvatarPlaceholder();
                                                    },
                                                  )
                                              : _buildAvatarPlaceholder(),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Name
                                  Text(
                                    widget.user.displayName,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  const SizedBox(height: 8),

                                  // Email
                                  Text(
                                    widget.user.email,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Stats Section
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStatItem(
                                      icon: Icons.eco,
                                      label: 'EnvPoints',
                                      value: '${widget.user.envPoints}',
                                      color: Colors.green.shade600,
                                    ),
                                    Container(
                                      width: 1,
                                      height: 40,
                                      color: Colors.green.shade200,
                                    ),
                                    _buildStatItem(
                                      icon: Icons.calendar_today,
                                      label: 'Joined',
                                      value: _formatDate(widget.user.createdAt),
                                      color: Colors.blue.shade600,
                                    ),
                                  ],
                                ),
                              ),

                              // Bio Section
                              if (widget.user.bio != null &&
                                  widget.user.bio!.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'About',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        widget.user.bio!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 30),

                              // Action Buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Like Button
                                  ScaleTransition(
                                    scale: _heartAnimation,
                                    child: GestureDetector(
                                      onTap: _toggleLike,
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color:
                                              _isLiked
                                                  ? Colors.red.shade100
                                                  : Colors.grey.shade100,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color:
                                                _isLiked
                                                    ? Colors.red.shade300
                                                    : Colors.grey.shade300,
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          _isLiked
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color:
                                              _isLiked
                                                  ? Colors.red.shade600
                                                  : Colors.grey.shade600,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Bookmark Button
                                  GestureDetector(
                                    onTap: _toggleBookmark,
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color:
                                            _isBookmarked
                                                ? Colors.blue.shade100
                                                : Colors.grey.shade100,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color:
                                              _isBookmarked
                                                  ? Colors.blue.shade300
                                                  : Colors.grey.shade300,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        _isBookmarked
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        color:
                                            _isBookmarked
                                                ? Colors.blue.shade600
                                                : Colors.grey.shade600,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: Colors.green.shade100,
      child: Center(
        child: Text(
          widget.user.displayName.isNotEmpty
              ? widget.user.displayName[0].toUpperCase()
              : 'E',
          style: TextStyle(
            color: Colors.green.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 40,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });

    if (_isLiked) {
      _heartController.forward().then((_) {
        _heartController.reverse();
      });
    }

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isLiked
              ? '💚 You liked ${widget.user.displayName}\'s profile!'
              : 'Removed like from ${widget.user.displayName}\'s profile',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor:
            _isLiked ? Colors.green.shade600 : Colors.grey.shade600,
      ),
    );
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isBookmarked
              ? '📌 Bookmarked ${widget.user.displayName}\'s profile!'
              : 'Removed bookmark from ${widget.user.displayName}\'s profile',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor:
            _isBookmarked ? Colors.blue.shade600 : Colors.grey.shade600,
      ),
    );
  }
}
