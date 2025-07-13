import 'package:flutter/material.dart';
import '../models/app_theme.dart';

class AnimatedGrassBackground extends StatefulWidget {
  final Widget child;
  final FlowerType flowerType;

  const AnimatedGrassBackground({
    super.key,
    required this.child,
    required this.flowerType,
  });

  @override
  State<AnimatedGrassBackground> createState() =>
      _AnimatedGrassBackgroundState();
}

class _AnimatedGrassBackgroundState extends State<AnimatedGrassBackground>
    with TickerProviderStateMixin {
  late List<AnimationController> _flowerControllers;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Flower bloom animations
    _flowerControllers = List.generate(8, (index) {
      return AnimationController(
        duration: Duration(seconds: 2 + (index % 3)),
        vsync: this,
      );
    });

    // Start flower animations with delays
    for (int i = 0; i < _flowerControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 500), () {
        if (mounted) {
          _flowerControllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _flowerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.green.shade50, Colors.green.shade100],
            ),
          ),
        ),

        // Animated background flowers
        ...List.generate(8, (index) {
          return AnimatedBuilder(
            animation: _flowerControllers[index],
            builder: (context, child) {
              final scale = 0.8 + _flowerControllers[index].value * 0.4;
              return Positioned(
                top: (index * 80.0) % MediaQuery.of(context).size.height,
                left: (index * 120.0) % MediaQuery.of(context).size.width,
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: 0.1 + _flowerControllers[index].value * 0.1,
                    child: _buildFlowerIcon(
                      widget.flowerType,
                      40 + (index % 3) * 10,
                    ),
                  ),
                ),
              );
            },
          );
        }),

        // Content (child) - removed wobbling animation per user request
        widget.child,
      ],
    );
  }

  Widget _buildFlowerIcon(FlowerType flowerType, double size) {
    switch (flowerType) {
      case FlowerType.redRose:
        return Icon(
          Icons.local_florist,
          size: size,
          color: Colors.red.shade300,
        );
      case FlowerType.tulip:
        return Icon(Icons.eco, size: size, color: Colors.pink.shade200);
      case FlowerType.lotus:
        return Icon(Icons.spa, size: size, color: Colors.purple.shade200);
    }
  }
}
