import 'package:flutter/material.dart';
import '../models/app_theme.dart';
import '../services/theme_service.dart';
import '../config/app_theme_config.dart';

class ThemedContainer extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final bool showVineBorder;
  final bool animateOnLoad;
  final Duration animationDuration;

  const ThemedContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.showVineBorder = true,
    this.animateOnLoad = true,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  @override
  State<ThemedContainer> createState() => _ThemedContainerState();
}

class _ThemedContainerState extends State<ThemedContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.animateOnLoad) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeService,
      builder: (context, _) {
        final colors = AppThemeConfig.getColors(_themeService.currentTheme);
        final isGrass = _themeService.currentTheme.themeType == ThemeType.grass;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Container(
                  width: widget.width,
                  height: widget.height,
                  margin: widget.margin,
                  padding: widget.padding ?? const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        widget.showVineBorder && isGrass
                            ? Border.all(
                              color: colors.vineGreen ?? colors.accent,
                              width: 3,
                            )
                            : Border.all(
                              color: colors.accent.withOpacity(0.3),
                              width: 2,
                            ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isGrass
                                ? colors.primary.withOpacity(0.1)
                                : colors.primary.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child:
                      widget.showVineBorder && isGrass
                          ? Stack(
                            children: [
                              widget.child,
                              if (widget.showVineBorder) _buildVineDecoration(),
                            ],
                          )
                          : widget.child,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVineDecoration() {
    final colors = AppThemeConfig.getColors(_themeService.currentTheme);

    return Positioned.fill(
      child: CustomPaint(
        painter: VineBorderPainter(
          vineColor: colors.vineGreen ?? colors.accent,
          leafColor: colors.leafGreen ?? colors.secondary,
        ),
      ),
    );
  }
}

class VineBorderPainter extends CustomPainter {
  final Color vineColor;
  final Color leafColor;

  VineBorderPainter({required this.vineColor, required this.leafColor});

  @override
  void paint(Canvas canvas, Size size) {
    final vinePaint =
        Paint()
          ..color = vineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    final leafPaint =
        Paint()
          ..color = leafColor
          ..style = PaintingStyle.fill;

    // Draw vine along the border
    final path = Path();

    // Top border vine
    _drawVinePath(canvas, path, vinePaint, leafPaint, size);
  }

  void _drawVinePath(
    Canvas canvas,
    Path path,
    Paint vinePaint,
    Paint leafPaint,
    Size size,
  ) {
    const double leafSize = 8.0;
    const double waveHeight = 6.0;

    // Top border with wave pattern
    path.moveTo(10, 10);
    for (double x = 10; x < size.width - 10; x += 20) {
      path.quadraticBezierTo(x + 10, 10 - waveHeight, x + 20, 10);
      // Add small leaf at wave peak
      _drawLeaf(
        canvas,
        leafPaint,
        Offset(x + 10, 10 - waveHeight),
        leafSize * 0.6,
      );
    }

    // Right border
    for (double y = 10; y < size.height - 10; y += 25) {
      path.lineTo(size.width - 10 + (y % 30 == 0 ? 3 : -3), y);
      if (y % 40 == 0) {
        _drawLeaf(
          canvas,
          leafPaint,
          Offset(size.width - 10, y),
          leafSize * 0.7,
        );
      }
    }

    // Bottom border
    for (double x = size.width - 10; x > 10; x -= 20) {
      path.quadraticBezierTo(
        x - 10,
        size.height - 10 + waveHeight,
        x - 20,
        size.height - 10,
      );
      if ((size.width - x) % 30 == 0) {
        _drawLeaf(
          canvas,
          leafPaint,
          Offset(x - 10, size.height - 10 + waveHeight),
          leafSize * 0.6,
        );
      }
    }

    // Left border
    for (double y = size.height - 10; y > 10; y -= 25) {
      path.lineTo(10 + (y % 30 == 0 ? -3 : 3), y);
      if (y % 40 == 0) {
        _drawLeaf(canvas, leafPaint, Offset(10, y), leafSize * 0.7);
      }
    }

    path.close();
    canvas.drawPath(path, vinePaint);

    // Add corner decorative elements
    _drawCornerLeaves(canvas, leafPaint, size);
  }

  void _drawLeaf(Canvas canvas, Paint paint, Offset position, double size) {
    final leafPath = Path();
    leafPath.moveTo(position.dx, position.dy);
    leafPath.quadraticBezierTo(
      position.dx + size,
      position.dy - size / 2,
      position.dx + size / 2,
      position.dy - size,
    );
    leafPath.quadraticBezierTo(
      position.dx,
      position.dy - size / 2,
      position.dx,
      position.dy,
    );
    canvas.drawPath(leafPath, paint);
  }

  void _drawCornerLeaves(Canvas canvas, Paint paint, Size size) {
    const double cornerLeafSize = 12.0;

    // Top-left corner
    _drawLeaf(canvas, paint, const Offset(15, 15), cornerLeafSize);

    // Top-right corner
    _drawLeaf(canvas, paint, Offset(size.width - 15, 15), cornerLeafSize);

    // Bottom-left corner
    _drawLeaf(canvas, paint, Offset(15, size.height - 15), cornerLeafSize);

    // Bottom-right corner
    _drawLeaf(
      canvas,
      paint,
      Offset(size.width - 15, size.height - 15),
      cornerLeafSize,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class ThemedDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final bool showVineBorder;

  const ThemedDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.showVineBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();

    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        final colors = AppThemeConfig.getColors(themeService.currentTheme);
        final isGrass = themeService.currentTheme.themeType == ThemeType.grass;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: ThemedContainer(
            showVineBorder: showVineBorder && isGrass,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                content,
                if (actions != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions!,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
