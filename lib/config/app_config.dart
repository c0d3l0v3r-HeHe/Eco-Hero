import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Private constructor
  AppConfig._();
  
  // Singleton instance
  static final AppConfig _instance = AppConfig._();
  static AppConfig get instance => _instance;
  
  // API Keys
  static String get newsApiKey => dotenv.env['NEWS_API_KEY'] ?? '';
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  
  // App Configuration
  static String get appName => dotenv.env['APP_NAME'] ?? 'EcoHero';
  static bool get debugMode => dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  
  // Validation methods
  static bool get hasNewsApiKey => newsApiKey.isNotEmpty;
  static bool get hasGeminiApiKey => geminiApiKey.isNotEmpty && geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE';
  
  // Get all missing API keys
  static List<String> get missingApiKeys {
    final missing = <String>[];
    if (!hasNewsApiKey) missing.add('NEWS_API_KEY');
    if (!hasGeminiApiKey) missing.add('GEMINI_API_KEY');
    return missing;
  }
  
  // Check if all required API keys are present
  static bool get isConfigured => hasNewsApiKey;
  
  // Initialize and validate configuration
  static Future<bool> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
      
      if (debugMode) {
        print('🔧 AppConfig: Environment loaded');
        print('📰 News API: ${hasNewsApiKey ? "✅ Configured" : "❌ Missing"}');
        print('🤖 Gemini AI: ${hasGeminiApiKey ? "✅ Configured" : "❌ Missing"}');
        
        if (missingApiKeys.isNotEmpty) {
          print('⚠️  Missing API keys: ${missingApiKeys.join(", ")}');
        }
      }
      
      return true;
    } catch (e) {
      print('❌ Failed to load environment variables: $e');
      return false;
    }
  }
}
