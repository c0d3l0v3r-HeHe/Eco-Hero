import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_theme.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  AppTheme _currentTheme = AppTheme.defaultTheme;
  AppTheme get currentTheme => _currentTheme;

  static const String _themeKey = 'app_theme';
  static const String _flowerKey = 'flower_type';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    final themeString = prefs.getString(_themeKey);
    final flowerString = prefs.getString(_flowerKey);

    if (themeString != null && flowerString != null) {
      _currentTheme = AppTheme.fromMap({
        'themeType': themeString,
        'flowerType': flowerString,
      });
    }

    notifyListeners();
  }

  Future<void> setTheme(ThemeType themeType) async {
    final prefs = await SharedPreferences.getInstance();
    _currentTheme = _currentTheme.copyWith(themeType: themeType);
    await prefs.setString(_themeKey, themeType.name);
    notifyListeners();
  }

  Future<void> setFlowerType(FlowerType flowerType) async {
    final prefs = await SharedPreferences.getInstance();
    _currentTheme = _currentTheme.copyWith(flowerType: flowerType);
    await prefs.setString(_flowerKey, flowerType.name);
    notifyListeners();
  }

  bool get isGrassTheme => _currentTheme.themeType == ThemeType.grass;
  bool get isMarineTheme => _currentTheme.themeType == ThemeType.marine;
}
