import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_wrapper.dart';
import 'config/app_config.dart';
import 'config/app_theme_config.dart';
import 'screens/home_screen.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables and configuration
  await AppConfig.initialize();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Theme Service
  await ThemeService().initialize();

  runApp(const EcoHeroApp());
}

class EcoHeroApp extends StatelessWidget {
  const EcoHeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();

    return ListenableBuilder(
      listenable: themeService,
      builder: (context, child) {
        return MaterialApp(
          title: 'EcoHero',
          theme: AppThemeConfig.getTheme(themeService.currentTheme),
          home: const AuthWrapper(),
          routes: {'/home': (context) => const HomeScreen()},
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
