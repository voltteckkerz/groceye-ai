class AppConfig {
  // Detection Settings
  static const double confidenceThreshold = 0.5;
  static const Duration detectionInterval = Duration(seconds: 3);
  
  // Audio Settings
  static const double speechRate = 1.0;
  static const Duration announcementCooldown = Duration(seconds: 3);
  
  // Label Mappings - Make names more natural for TTS
  static const Map<String, String> labelMapping = {
    'beverages': 'beverages',
    'bread': 'bread',
    'canned_food': 'canned food',
    'chili_sauce': 'chili sauce',
    'cooking_oil': 'cooking oil',
    'fruit': 'fruit',
    'instant_noodle': 'instant noodles',
    'ketchup': 'ketchup',
    'snack': 'snack',
    'soy_sauce': 'soy sauce',
  };
  
  // Priority Objects (announced first) - Common grocery items
  static const List<String> priorityObjects = [
    'fruit',
    'bread',
    'beverages',
    'instant noodles',
    'snack',
    'canned food',
    'cooking oil',
    'ketchup',
    'chili sauce',
    'soy sauce',
  ];
}
