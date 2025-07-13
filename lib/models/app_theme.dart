import 'package:flutter/material.dart';

enum ThemeType { grass, marine }

enum FlowerType { redRose, tulip, lotus }

class AppTheme {
  final ThemeType themeType;
  final FlowerType flowerType;

  const AppTheme({required this.themeType, required this.flowerType});

  AppTheme copyWith({ThemeType? themeType, FlowerType? flowerType}) {
    return AppTheme(
      themeType: themeType ?? this.themeType,
      flowerType: flowerType ?? this.flowerType,
    );
  }

  // Ocean-inspired colors with glowing effects
  Color get primaryColor {
    switch (themeType) {
      case ThemeType.grass:
        return const Color(0xFF2E7D32); // Forest green
      case ThemeType.marine:
        return const Color(0xFF006064); // Deep ocean teal
    }
  }

  Color get secondaryColor {
    switch (themeType) {
      case ThemeType.grass:
        return const Color(0xFF66BB6A); // Light green
      case ThemeType.marine:
        return const Color(0xFF00838F); // Ocean blue
    }
  }

  Color get accentColor {
    switch (themeType) {
      case ThemeType.grass:
        return const Color(0xFF81C784); // Soft green
      case ThemeType.marine:
        return const Color(0xFF26C6DA); // Bright cyan (like bioluminescence)
    }
  }

  // Gradient colors for ocean depth effect
  List<Color> get primaryGradient {
    switch (themeType) {
      case ThemeType.grass:
        return [
          const Color(0xFF1B5E20), // Dark forest green
          const Color(0xFF2E7D32), // Medium green
          const Color(0xFF43A047), // Light green
        ];
      case ThemeType.marine:
        return [
          const Color(0xFF001C1F), // Deep ocean darkness
          const Color(0xFF003D40), // Deep blue-green
          const Color(0xFF006064), // Ocean teal
          const Color(0xFF00838F), // Bright ocean blue
        ];
    }
  }

  // Glowing accent gradient (like marine bioluminescence)
  List<Color> get glowGradient {
    switch (themeType) {
      case ThemeType.grass:
        return [
          const Color(0xFF81C784).withOpacity(0.3),
          const Color(0xFF66BB6A).withOpacity(0.6),
          const Color(0xFF4CAF50).withOpacity(0.9),
        ];
      case ThemeType.marine:
        return [
          const Color(0xFF00E5FF).withOpacity(0.3), // Electric blue glow
          const Color(0xFF26C6DA).withOpacity(0.6), // Cyan glow
          const Color(0xFF00BCD4).withOpacity(0.9), // Turquoise glow
        ];
    }
  }

  // Background colors with depth
  Color get backgroundColor {
    switch (themeType) {
      case ThemeType.grass:
        return const Color(0xFFE8F5E8); // Very light green
      case ThemeType.marine:
        return const Color(0xFF0A1A1F); // Deep ocean background
    }
  }

  Color get surfaceColor {
    switch (themeType) {
      case ThemeType.grass:
        return Colors.white;
      case ThemeType.marine:
        return const Color(0xFF1A2F35); // Dark blue-green surface
    }
  }

  Color get cardColor {
    switch (themeType) {
      case ThemeType.grass:
        return Colors.white;
      case ThemeType.marine:
        return const Color(0xFF1E3A42); // Dark card with blue tint
    }
  }

  Color get textColor {
    switch (themeType) {
      case ThemeType.grass:
        return const Color(0xFF1B5E20); // Dark green text
      case ThemeType.marine:
        return const Color(0xFFE0F2F1); // Light cyan text
    }
  }

  Color get onPrimaryColor {
    switch (themeType) {
      case ThemeType.grass:
        return Colors.white;
      case ThemeType.marine:
        return const Color(0xFFE0F2F1); // Light cyan
    }
  }

  Color get shadowColor {
    switch (themeType) {
      case ThemeType.grass:
        return Colors.black26;
      case ThemeType.marine:
        return const Color(0xFF00E5FF).withOpacity(0.2); // Glowing shadow
    }
  }

  // Special glow effect color for marine theme
  Color get bioluminescenceColor {
    switch (themeType) {
      case ThemeType.grass:
        return const Color(0xFF81C784);
      case ThemeType.marine:
        return const Color(0xFF00E5FF); // Electric blue like jellyfish
    }
  }

  Map<String, dynamic> toMap() {
    return {'themeType': themeType.name, 'flowerType': flowerType.name};
  }

  factory AppTheme.fromMap(Map<String, dynamic> map) {
    return AppTheme(
      themeType: ThemeType.values.firstWhere(
        (e) => e.name == map['themeType'],
        orElse: () => ThemeType.grass,
      ),
      flowerType: FlowerType.values.firstWhere(
        (e) => e.name == map['flowerType'],
        orElse: () => FlowerType.redRose,
      ),
    );
  }

  static const AppTheme defaultTheme = AppTheme(
    themeType: ThemeType.grass,
    flowerType: FlowerType.redRose,
  );
}
