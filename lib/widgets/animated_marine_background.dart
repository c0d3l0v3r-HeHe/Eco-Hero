import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedMarineBackground extends StatefulWidget {
  final Widget child;

  const AnimatedMarineBackground({super.key, required this.child});

  @override
  State<AnimatedMarineBackground> createState() =>
      _AnimatedMarineBackgroundState();
}

class _AnimatedMarineBackgroundState extends State<AnimatedMarineBackground>
    with TickerProviderStateMixin {
  late List<AnimationController> _fishControllers;
  late List<Animation<Offset>> _fishAnimations;
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Slower wave animation for underwater light effect
    _waveController = AnimationController(
      duration: const Duration(seconds: 8), // Slower from 3 to 8 seconds
      vsync: this,
    );
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );
    _waveController.repeat(reverse: true);

    // Fish animations - more fish with varied speeds
    _fishControllers = List.generate(8, (index) {
      // Increased from 5 to 8 fish
      return AnimationController(
        duration: Duration(
            seconds: 12 + (index % 4) * 3), // Slower movement: 12-24 seconds
        vsync: this,
      );
    });

    _fishAnimations = _fishControllers.asMap().entries.map((entry) {
      final index = entry.key;
      final controller = entry.value;

      // More varied starting positions for natural look
      final startOffset =
          Offset(-0.3, 0.15 + (index * 0.1) + (index % 2) * 0.05);
      final endOffset = Offset(1.3, 0.2 + (index * 0.08) + (index % 3) * 0.03);

      return Tween<Offset>(
        begin: startOffset,
        end: endOffset,
      ).animate(CurvedAnimation(
          parent: controller, curve: Curves.easeInOut)); // Smoother movement
    }).toList();

    // Start fish animations with delays
    for (int i = 0; i < _fishControllers.length; i++) {
      Future.delayed(Duration(seconds: i * 2), () {
        if (mounted) {
          _fishControllers[i].repeat();
        }
      });
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    for (final controller in _fishControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base background with deep ocean gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(
                    0xFF001C1F), // Deep ocean darkness (like the depths in your image)
                const Color(
                    0xFF003D40), // Deep blue-green (like whale environment)
                const Color(0xFF006064), // Ocean teal (mid-water)
                const Color(0xFF00838F), // Bright ocean blue (surface light)
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),

        // Underwater light waves
        AnimatedBuilder(
          animation: _waveAnimation,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: UnderwaterLightPainter(_waveAnimation.value),
            );
          },
        ),

        // Swimming fish
        ...List.generate(_fishAnimations.length, (index) {
          return AnimatedBuilder(
            animation: _fishAnimations[index],
            builder: (context, child) {
              return Positioned(
                left: _fishAnimations[index].value.dx *
                    MediaQuery.of(context).size.width,
                top: _fishAnimations[index].value.dy *
                    MediaQuery.of(context).size.height,
                child: Transform.scale(
                  scale: 0.8 + (index % 3) * 0.2,
                  child: Opacity(
                    opacity: 0.4,
                    child: Icon(
                      _getFishIcon(index),
                      color: const Color(0xFF26C6DA), // Cyan marine color
                      size: 30 + (index % 2) * 10,
                    ),
                  ),
                ),
              );
            },
          );
        }),

        // Child content
        widget.child,
      ],
    );
  }

  IconData _getFishIcon(int index) {
    final icons = [
      Icons.phishing, // Fish shape
      Icons.waves, // Fish swimming
      Icons.water_drop, // Small fish/tadpole
      Icons.bubble_chart, // Fish bubbles
      Icons.star, // Starfish
      Icons.circle, // Fish silhouette
      Icons.lens, // Round fish
      Icons.location_on, // Jellyfish shape
    ];
    return icons[index % icons.length];
  }
}

class UnderwaterLightPainter extends CustomPainter {
  final double animationValue;

  UnderwaterLightPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Bioluminescent light rays (like sunlight filtering through water)
    final lightPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF00E5FF).withOpacity(0.15), // Electric blue glow
          const Color(0xFF26C6DA).withOpacity(0.1), // Cyan glow
          const Color(0xFF00BCD4).withOpacity(0.05), // Turquoise
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create multiple light rays with slower oceanic movement
    for (int i = 0; i < 8; i++) {
      final path = Path();
      final waveOffset = math.sin(animationValue * 0.5 * math.pi + i * 0.3) *
          20; // Much slower movement
      final x = size.width * (i / 8) + waveOffset;

      path.moveTo(x, 0);
      path.quadraticBezierTo(
        x + 40 + waveOffset * 0.7,
        size.height * 0.25,
        x + 70 + waveOffset * 0.5,
        size.height * 0.5,
      );
      path.quadraticBezierTo(
        x + 100 + waveOffset * 0.3,
        size.height * 0.75,
        x + 130 + waveOffset * 0.2,
        size.height,
      );
      path.lineTo(x - 40, size.height);
      path.lineTo(x - 20, 0);
      path.close();

      canvas.drawPath(path, lightPaint);
    }

    // Add floating bioluminescent particles
    _drawBioluminescentParticles(canvas, size);

    // Add glowing orbs (like jellyfish or plankton)
    _drawGlowingOrbs(canvas, size);
  }

  void _drawBioluminescentParticles(Canvas canvas, Size size) {
    final random = math.Random(42); // Fixed seed for consistent particles

    for (int i = 0; i < 60; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      // Animate particles floating with slower ocean currents
      final currentOffset =
          math.sin(animationValue * 0.8 * math.pi + i * 0.05) *
              30; // Slower movement
      final y = baseY + currentOffset;

      final opacity = (0.3 + 0.7 * math.sin(animationValue * 1.5 * math.pi + i))
          .clamp(0.0, 1.0); // Slower pulse
      final particleSize = 1.0 + random.nextDouble() * 4.0;

      final paint = Paint()
        ..color = const Color(0xFF00E5FF).withOpacity(opacity * 0.8)
        ..style = PaintingStyle.fill;

      // Add glow effect
      final glowPaint = Paint()
        ..color = const Color(0xFF00E5FF).withOpacity(opacity * 0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), particleSize * 2, glowPaint);
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  void _drawGlowingOrbs(Canvas canvas, Size size) {
    final random = math.Random(123); // Fixed seed for consistent orbs

    for (int i = 0; i < 12; i++) {
      final x = size.width * (0.1 + random.nextDouble() * 0.8);
      final y = size.height * (0.2 + random.nextDouble() * 0.6);

      final pulseOffset = i * 0.2;
      final pulse = 0.4 +
          0.6 *
              math.sin((animationValue + pulseOffset) *
                  0.8 *
                  math.pi); // Slower pulse
      final orbSize = (8 + random.nextDouble() * 25) * pulse;

      // Create layered glowing effect (like bioluminescent creatures)
      final glowLayers = [
        (const Color(0xFF00E5FF).withOpacity(0.4 * pulse), orbSize * 1.5),
        (const Color(0xFF26C6DA).withOpacity(0.6 * pulse), orbSize * 1.0),
        (const Color(0xFF00BCD4).withOpacity(0.8 * pulse), orbSize * 0.6),
      ];

      for (final (color, size_layer) in glowLayers) {
        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(x, y), size_layer, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant UnderwaterLightPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
