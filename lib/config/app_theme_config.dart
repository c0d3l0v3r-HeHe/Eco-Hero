import 'package:flutter/material.dart';
import '../models/app_theme.dart';

class AppThemeConfig {
  static ThemeData getTheme(AppTheme appTheme) {
    switch (appTheme.themeType) {
      case ThemeType.grass:
        return _getGrassTheme();
      case ThemeType.marine:
        return _getMarineTheme();
    }
  }

  static dynamic getColors(AppTheme appTheme) {
    switch (appTheme.themeType) {
      case ThemeType.grass:
        return AppColors.grass;
      case ThemeType.marine:
        return AppColors.marine;
    }
  }

  static IconData getFlowerIcon(FlowerType flowerType) {
    switch (flowerType) {
      case FlowerType.redRose:
        return Icons.local_florist;
      case FlowerType.tulip:
        return Icons.spa;
      case FlowerType.lotus:
        return Icons.wb_sunny;
    }
  }

  static Color getFlowerColor(FlowerType flowerType) {
    switch (flowerType) {
      case FlowerType.redRose:
        return Colors.red.shade400;
      case FlowerType.tulip:
        return Colors.pink.shade300;
      case FlowerType.lotus:
        return Colors.purple.shade300;
    }
  }

  static String getFlowerName(FlowerType flowerType) {
    switch (flowerType) {
      case FlowerType.redRose:
        return 'Red Rose';
      case FlowerType.tulip:
        return 'Tulip';
      case FlowerType.lotus:
        return 'Lotus';
    }
  }

  static ThemeData _getGrassTheme() {
    return ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.green,
      primaryColor: AppColors.grass.primary,
      scaffoldBackgroundColor: AppColors.grass.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.grass.primary,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.grass.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: const CardTheme(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.grass.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData _getMarineTheme() {
    return ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.blue,
      primaryColor: AppColors.marine.primary,
      scaffoldBackgroundColor: AppColors.marine.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.marine.primary,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.marine.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: const CardTheme(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.marine.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class AppColors {
  static const grass = GrassColors();
  static const marine = MarineColors();
}

class GrassColors {
  const GrassColors();

  Color get primary => const Color(0xFF2E7D32);
  Color get primaryLight => const Color(0xFF4CAF50);
  Color get primaryDark => const Color(0xFF1B5E20);
  Color get accent => const Color(0xFF66BB6A);
  Color get secondary => const Color(0xFF8BC34A);
  Color get background => const Color(0xFFF1F8E9);
  Color get surface => const Color(0xFFFFFFFF);
  Color get onPrimary => Colors.white;
  Color get onBackground => const Color(0xFF1B5E20);
  Color get onSurface => const Color(0xFF2E7D32);
  Color get vineGreen => const Color(0xFF388E3C);
  Color get leafGreen => const Color(0xFF689F38);
  Color get flowerAccent => const Color(0xFFFFEB3B);
}

class MarineColors {
  const MarineColors();

  Color get primary => const Color(0xFF0277BD);
  Color get primaryLight => const Color(0xFF03A9F4);
  Color get primaryDark => const Color(0xFF01579B);
  Color get accent => const Color(0xFF29B6F6);
  Color get secondary => const Color(0xFF4FC3F7);
  Color get background => const Color(0xFFE1F5FE);
  Color get surface => const Color(0xFFFFFFFF);
  Color get onPrimary => Colors.white;
  Color get onBackground => const Color(0xFF01579B);
  Color get onSurface => const Color(0xFF0277BD);
  Color get deepBlue => const Color(0xFF1565C0);
  Color get aquaBlue => const Color(0xFF00BCD4);
  Color get lightBlue => const Color(0xFFB3E5FC);
}
