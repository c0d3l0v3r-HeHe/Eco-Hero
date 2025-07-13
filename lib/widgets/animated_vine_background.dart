import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedVineBackground extends StatefulWidget {
  final Widget child;
  final bool isVisible;

  const AnimatedVineBackground({
    super.key,
    required this.child,
    this.isVisible = true,
  });

  @override
  State<AnimatedVineBackground> createState() => _AnimatedVineBackgroundState();
}

class _AnimatedVineBackgroundState extends State<AnimatedVineBackground>
    with TickerProviderStateMixin {
  late AnimationController _windController;
  late AnimationController _swayController;
  late AnimationController _leafController;
  late Animation<double> _windAnimation;
  late Animation<double> _swayAnimation;
  late Animation<double> _leafAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Wind movement animation - continuous gentle movement
    _windController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _windAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _windController, curve: Curves.easeInOut),
    );

    // Sway animation - vines swaying back and forth
    _swayController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _swayAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _swayController, curve: Curves.easeInOut),
    );

    // Leaf flutter animation
    _leafController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _leafAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _leafController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    if (widget.isVisible) {
      _windController.repeat();
      _swayController.repeat(reverse: true);
      _leafController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedVineBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _startAnimations();
      } else {
        _windController.stop();
        _swayController.stop();
        _leafController.stop();
      }
    }
  }

  @override
  void dispose() {
    _windController.dispose();
    _swayController.dispose();
    _leafController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return widget.child;
    }

    return Stack(
      children: [
        // Animated vine background
        Positioned.fill(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _windAnimation,
              _swayAnimation,
              _leafAnimation,
            ]),
            builder: (context, child) {
              return CustomPaint(
                painter: AnimatedVinePainter(
                  windProgress: _windAnimation.value,
                  swayProgress: _swayAnimation.value,
                  leafProgress: _leafAnimation.value,
                ),
              );
            },
          ),
        ),
        // Content on top
        widget.child,
      ],
    );
  }
}

class AnimatedVinePainter extends CustomPainter {
  final double windProgress;
  final double swayProgress;
  final double leafProgress;

  AnimatedVinePainter({
    required this.windProgress,
    required this.swayProgress,
    required this.leafProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final vineBaseColor = Colors.green.shade400.withOpacity(0.15);
    final leafColor = Colors.green.shade300.withOpacity(0.12);

    final vinePaint =
        Paint()
          ..color = vineBaseColor
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

    final leafPaint =
        Paint()
          ..color = leafColor
          ..style = PaintingStyle.fill;

    // Draw multiple vine strands across the screen
    _drawVineStrand(canvas, size, vinePaint, leafPaint, 0, 0.1);
    _drawVineStrand(canvas, size, vinePaint, leafPaint, 1, 0.3);
    _drawVineStrand(canvas, size, vinePaint, leafPaint, 2, 0.7);
    _drawVineStrand(canvas, size, vinePaint, leafPaint, 3, 0.9);
    _drawVineStrand(canvas, size, vinePaint, leafPaint, 4, 0.5);
  }

  void _drawVineStrand(
    Canvas canvas,
    Size size,
    Paint vinePaint,
    Paint leafPaint,
    int strandIndex,
    double verticalPosition,
  ) {
    final path = Path();
    final strandHeight = size.height * 0.6; // Vines cover 60% of screen height
    final startY = size.height * verticalPosition;

    // Calculate wind effect
    final windOffset = math.sin(windProgress * 2 * math.pi + strandIndex) * 10;
    final swayOffset = swayProgress * 15 * (strandIndex % 2 == 0 ? 1 : -1);

    // Start position with wind effect
    final startX = windOffset + swayOffset;
    path.moveTo(startX, startY);

    // Create flowing vine path across the screen
    final segmentWidth = size.width / 8;
    for (int i = 0; i < 9; i++) {
      final x = i * segmentWidth + windOffset + swayOffset * (i * 0.1);
      final baseY = startY + (i * strandHeight / 8);

      // Add gentle sine wave for natural vine movement
      final waveY = baseY + math.sin(windProgress * 2 * math.pi + i * 0.5) * 8;
      final swayY = waveY + swayProgress * 5 * math.sin(i * 0.3);

      if (i == 0) {
        path.moveTo(x, swayY);
      } else {
        // Create smooth curves between points
        final prevX =
            (i - 1) * segmentWidth + windOffset + swayOffset * ((i - 1) * 0.1);
        final controlX1 = prevX + segmentWidth * 0.3;
        final controlX2 = x - segmentWidth * 0.3;

        path.cubicTo(controlX1, swayY, controlX2, swayY, x, swayY);
      }

      // Add leaves at certain intervals
      if (i % 2 == 0 && i > 0) {
        _drawLeafCluster(
          canvas,
          leafPaint,
          Offset(x, swayY),
          leafProgress,
          strandIndex + i,
        );
      }
    }

    // Draw the vine strand
    canvas.drawPath(path, vinePaint);

    // Add small connecting branches
    _drawBranches(
      canvas,
      size,
      vinePaint,
      strandIndex,
      startY,
      windOffset,
      swayOffset,
    );
  }

  void _drawLeafCluster(
    Canvas canvas,
    Paint leafPaint,
    Offset position,
    double animationProgress,
    int leafIndex,
  ) {
    final leafSize =
        6.0 + math.sin(animationProgress * 2 * math.pi + leafIndex) * 2;
    final rotation =
        math.sin(animationProgress * 2 * math.pi + leafIndex * 0.5) * 0.2;

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotation);

    // Draw leaf shape
    final leafPath = Path();
    leafPath.moveTo(0, 0);
    leafPath.quadraticBezierTo(
      leafSize * 0.7,
      -leafSize * 0.3,
      leafSize,
      -leafSize * 0.1,
    );
    leafPath.quadraticBezierTo(leafSize * 0.5, leafSize * 0.2, 0, 0);

    canvas.drawPath(leafPath, leafPaint);

    // Draw second leaf
    canvas.rotate(math.pi * 0.3);
    leafPath.reset();
    leafPath.moveTo(0, 0);
    leafPath.quadraticBezierTo(
      leafSize * 0.6,
      -leafSize * 0.4,
      leafSize * 0.8,
      -leafSize * 0.2,
    );
    leafPath.quadraticBezierTo(leafSize * 0.4, leafSize * 0.1, 0, 0);

    canvas.drawPath(leafPath, leafPaint);

    canvas.restore();
  }

  void _drawBranches(
    Canvas canvas,
    Size size,
    Paint vinePaint,
    int strandIndex,
    double startY,
    double windOffset,
    double swayOffset,
  ) {
    final branchPaint =
        Paint()
          ..color = vinePaint.color.withOpacity(0.08)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

    // Draw small side branches
    for (int i = 1; i < 6; i++) {
      final branchX =
          i * (size.width / 6) + windOffset + swayOffset * (i * 0.1);
      final branchY =
          startY + (i * 60) + math.sin(windProgress * 2 * math.pi + i) * 5;

      final branchPath = Path();
      branchPath.moveTo(branchX, branchY);

      // Short branch extending up and to the side
      final branchEndX =
          branchX + (strandIndex % 2 == 0 ? 20 : -20) + swayProgress * 8;
      final branchEndY =
          branchY - 15 + math.sin(leafProgress * 2 * math.pi + i) * 3;

      branchPath.quadraticBezierTo(
        branchX + (branchEndX - branchX) * 0.5,
        branchY - 8,
        branchEndX,
        branchEndY,
      );

      canvas.drawPath(branchPath, branchPaint);
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedVinePainter oldDelegate) {
    return oldDelegate.windProgress != windProgress ||
        oldDelegate.swayProgress != swayProgress ||
        oldDelegate.leafProgress != leafProgress;
  }
}
