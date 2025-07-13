import 'package:flutter/material.dart';
import '../models/app_theme.dart';
import '../services/theme_service.dart';
import '../widgets/animated_vine_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ThemeService _themeService = ThemeService();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeService,
      builder: (context, child) {
        final currentTheme = _themeService.currentTheme;
        final isGrass = _themeService.isGrassTheme;

        return Scaffold(
          backgroundColor: isGrass ? Colors.green.shade50 : Colors.blue.shade50,
          appBar: AppBar(
            title: const Text(
              'Settings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor:
                isGrass ? Colors.green.shade700 : Colors.blue.shade700,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: AnimatedVineBackground(
            isVisible: isGrass,
            child: Stack(
              children: [
                // Background decoration
                if (isGrass)
                  _buildGrassBackground()
                else
                  _buildMarineBackground(),

                // Content
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Theme Selection
                      _buildThemeSection(currentTheme, isGrass),

                      const SizedBox(height: 24),

                      // Flower Selection (only for Grass theme)
                      if (isGrass) _buildFlowerSection(currentTheme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrassBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.green.shade50, Colors.green.shade100],
        ),
      ),
      child: Stack(
        children: [
          // Scattered flowers in background
          ...List.generate(8, (index) {
            return Positioned(
              top: (index * 100.0) % MediaQuery.of(context).size.height,
              left: (index * 80.0) % MediaQuery.of(context).size.width,
              child: Opacity(
                opacity: 0.1,
                child: _buildFlowerIcon(
                  _themeService.currentTheme.flowerType,
                  40,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMarineBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade100, Colors.blue.shade200],
        ),
      ),
      child: Stack(
        children: [
          // Water surface light effect
          ...List.generate(6, (index) {
            return Positioned(
              top: (index * 150.0) % MediaQuery.of(context).size.height,
              left:
                  -50 +
                  (index * 100.0) % (MediaQuery.of(context).size.width + 100),
              child: Container(
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            );
          }),

          // Swimming fish
          ...List.generate(5, (index) {
            return Positioned(
              top: (index * 120.0) % MediaQuery.of(context).size.height,
              left: (index * 150.0) % MediaQuery.of(context).size.width,
              child: Opacity(
                opacity: 0.15,
                child: Icon(
                  Icons.phishing,
                  size: 30,
                  color: Colors.blue.shade600,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildThemeSection(AppTheme currentTheme, bool isGrass) {
    return _buildDecoratedContainer(
      isGrass: isGrass,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Theme Selection',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Grass Theme Option
          _buildThemeOption(
            title: 'Grass Theme 🌱',
            subtitle: 'Green nature-inspired theme with flowers',
            isSelected: currentTheme.themeType == ThemeType.grass,
            onTap: () => _themeService.setTheme(ThemeType.grass),
            color: Colors.green,
            isGrass: isGrass,
          ),

          const SizedBox(height: 12),

          // Marine Theme Option
          _buildThemeOption(
            title: 'Marine Theme 🌊',
            subtitle: 'Blue underwater theme with swimming fish',
            isSelected: currentTheme.themeType == ThemeType.marine,
            onTap: () => _themeService.setTheme(ThemeType.marine),
            color: Colors.blue,
            isGrass: isGrass,
          ),
        ],
      ),
    );
  }

  Widget _buildFlowerSection(AppTheme currentTheme) {
    return _buildDecoratedContainer(
      isGrass: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Flower Selection',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Flower options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFlowerOption(
                flowerType: FlowerType.redRose,
                label: 'Red Rose',
                currentTheme: currentTheme,
              ),
              _buildFlowerOption(
                flowerType: FlowerType.tulip,
                label: 'Tulip',
                currentTheme: currentTheme,
              ),
              _buildFlowerOption(
                flowerType: FlowerType.lotus,
                label: 'Lotus',
                currentTheme: currentTheme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDecoratedContainer({
    required Widget child,
    required bool isGrass,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            isGrass
                ? Border.all(color: Colors.green.shade300, width: 2)
                : Border.all(color: Colors.blue.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: (isGrass ? Colors.green : Colors.blue).shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildThemeOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
    required bool isGrass,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.transparent,
                border: Border.all(color: color, width: 2),
              ),
              child:
                  isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowerOption({
    required FlowerType flowerType,
    required String label,
    required AppTheme currentTheme,
  }) {
    final isSelected = currentTheme.flowerType == flowerType;

    return GestureDetector(
      onTap: () => _themeService.setFlowerType(flowerType),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.green.shade100 : Colors.grey.shade100,
              border: Border.all(
                color:
                    isSelected ? Colors.green.shade600 : Colors.grey.shade400,
                width: 3,
              ),
            ),
            child: Center(child: _buildFlowerIcon(flowerType, 30)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.green.shade700 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowerIcon(FlowerType flowerType, double size) {
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
}

class VinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final vinePaint =
        Paint()
          ..color = Colors.green.shade400.withOpacity(0.6)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final leafPaint =
        Paint()
          ..color = Colors.green.shade300.withOpacity(0.7)
          ..style = PaintingStyle.fill;

    final flowerPaint =
        Paint()
          ..color = Colors.pink.shade300.withOpacity(0.8)
          ..style = PaintingStyle.fill;

    // Draw decorative border vines
    _drawBorderVines(canvas, size, vinePaint, leafPaint, flowerPaint);
  }

  void _drawBorderVines(
    Canvas canvas,
    Size size,
    Paint vinePaint,
    Paint leafPaint,
    Paint flowerPaint,
  ) {
    const double borderOffset = 8.0;
    const double waveHeight = 4.0;
    const double leafSize = 6.0;

    // Top border with wavy vine
    final topPath = Path();
    topPath.moveTo(borderOffset, borderOffset + waveHeight);

    for (double x = borderOffset; x < size.width - borderOffset; x += 15) {
      final nextX = x + 15;
      final controlY = borderOffset + (x % 30 == 0 ? 0 : waveHeight);
      topPath.quadraticBezierTo(
        x + 7.5,
        controlY,
        nextX,
        borderOffset + waveHeight,
      );

      // Add leaves at wave peaks
      if (x % 25 == 0) {
        _drawLeaf(
          canvas,
          leafPaint,
          Offset(x + 7.5, borderOffset + controlY),
          leafSize,
        );
      }
    }
    canvas.drawPath(topPath, vinePaint);

    // Bottom border with wavy vine
    final bottomPath = Path();
    final bottomY = size.height - borderOffset;
    bottomPath.moveTo(borderOffset, bottomY - waveHeight);

    for (double x = borderOffset; x < size.width - borderOffset; x += 15) {
      final nextX = x + 15;
      final controlY = bottomY - (x % 30 == 0 ? 0 : waveHeight);
      bottomPath.quadraticBezierTo(
        x + 7.5,
        controlY,
        nextX,
        bottomY - waveHeight,
      );

      // Add leaves at wave peaks
      if (x % 25 == 0) {
        _drawLeaf(canvas, leafPaint, Offset(x + 7.5, controlY), leafSize);
      }
    }
    canvas.drawPath(bottomPath, vinePaint);

    // Left border with curved vine
    final leftPath = Path();
    leftPath.moveTo(borderOffset + waveHeight, borderOffset);

    for (double y = borderOffset; y < size.height - borderOffset; y += 15) {
      final nextY = y + 15;
      final controlX = borderOffset + (y % 30 == 0 ? 0 : waveHeight);
      leftPath.quadraticBezierTo(
        controlX,
        y + 7.5,
        borderOffset + waveHeight,
        nextY,
      );

      // Add leaves
      if (y % 25 == 0) {
        _drawLeaf(canvas, leafPaint, Offset(controlX, y + 7.5), leafSize * 0.8);
      }
    }
    canvas.drawPath(leftPath, vinePaint);

    // Right border with curved vine
    final rightPath = Path();
    final rightX = size.width - borderOffset;
    rightPath.moveTo(rightX - waveHeight, borderOffset);

    for (double y = borderOffset; y < size.height - borderOffset; y += 15) {
      final nextY = y + 15;
      final controlX = rightX - (y % 30 == 0 ? 0 : waveHeight);
      rightPath.quadraticBezierTo(
        controlX,
        y + 7.5,
        rightX - waveHeight,
        nextY,
      );

      // Add leaves
      if (y % 25 == 0) {
        _drawLeaf(canvas, leafPaint, Offset(controlX, y + 7.5), leafSize * 0.8);
      }
    }
    canvas.drawPath(rightPath, vinePaint);

    // Add corner decorations
    _drawCornerDecorations(canvas, size, leafPaint, flowerPaint, borderOffset);
  }

  void _drawLeaf(Canvas canvas, Paint paint, Offset position, double size) {
    final leafPath = Path();
    leafPath.moveTo(position.dx, position.dy);
    leafPath.quadraticBezierTo(
      position.dx + size * 0.6,
      position.dy - size * 0.4,
      position.dx + size * 0.3,
      position.dy - size,
    );
    leafPath.quadraticBezierTo(
      position.dx - size * 0.3,
      position.dy - size * 0.4,
      position.dx,
      position.dy,
    );
    canvas.drawPath(leafPath, paint);
  }

  void _drawCornerDecorations(
    Canvas canvas,
    Size size,
    Paint leafPaint,
    Paint flowerPaint,
    double offset,
  ) {
    const double decorSize = 10.0;

    // Top-left corner cluster
    _drawLeafCluster(
      canvas,
      leafPaint,
      Offset(offset + 5, offset + 5),
      decorSize,
    );

    // Top-right corner cluster
    _drawLeafCluster(
      canvas,
      leafPaint,
      Offset(size.width - offset - 5, offset + 5),
      decorSize,
    );

    // Bottom-left corner cluster
    _drawLeafCluster(
      canvas,
      leafPaint,
      Offset(offset + 5, size.height - offset - 5),
      decorSize,
    );

    // Bottom-right corner cluster
    _drawLeafCluster(
      canvas,
      leafPaint,
      Offset(size.width - offset - 5, size.height - offset - 5),
      decorSize,
    );

    // Add small flowers at corners
    _drawSmallFlower(
      canvas,
      flowerPaint,
      Offset(offset + 15, offset + 15),
      4.0,
    );
    _drawSmallFlower(
      canvas,
      flowerPaint,
      Offset(size.width - offset - 15, offset + 15),
      4.0,
    );
    _drawSmallFlower(
      canvas,
      flowerPaint,
      Offset(offset + 15, size.height - offset - 15),
      4.0,
    );
    _drawSmallFlower(
      canvas,
      flowerPaint,
      Offset(size.width - offset - 15, size.height - offset - 15),
      4.0,
    );
  }

  void _drawLeafCluster(
    Canvas canvas,
    Paint paint,
    Offset center,
    double size,
  ) {
    for (int i = 0; i < 3; i++) {
      final offset = Offset(
        center.dx + (size * 0.3) * (i == 0 ? 0 : (i == 1 ? 1 : -1)),
        center.dy + (size * 0.3) * (i == 0 ? -1 : 0.5),
      );
      _drawLeaf(canvas, paint, offset, size * 0.6);
    }
  }

  void _drawSmallFlower(
    Canvas canvas,
    Paint paint,
    Offset center,
    double radius,
  ) {
    // Draw simple flower with 5 petals
    for (int i = 0; i < 5; i++) {
      final petalCenter = Offset(
        center.dx + radius * 0.7 * (i % 2 == 0 ? 1 : 0.7) * (i < 2.5 ? 1 : -1),
        center.dy +
            radius * 0.7 * (i % 2 == 0 ? 1 : 0.7) * (i > 1 && i < 4 ? 1 : -1),
      );
      canvas.drawCircle(petalCenter, radius * 0.4, paint);
    }
    // Flower center
    canvas.drawCircle(
      center,
      radius * 0.3,
      Paint()..color = Colors.yellow.shade300,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
