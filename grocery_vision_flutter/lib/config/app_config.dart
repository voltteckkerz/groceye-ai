class AppConfig {
  // Detection Settings
  static const double confidenceThreshold = 0.5;
  static const Duration detectionInterval = Duration(seconds: 3);
  
  // Audio Settings
  static const double speechRate = 1.0;
  static const Duration announcementCooldown = Duration(seconds: 3);
  
  // Label Mappings - Make names more natural for TTS
  static const Map<String, String> labelMapping = {
    'bread': 'bread',
    'canned_food': 'canned food',
    'chili_sauce': 'chili sauce',
    'ketchup': 'ketchup',
    'soy_sauce': 'soy sauce',
  };
}
