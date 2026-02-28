import 'package:flutter/material.dart';

class LanguageService extends ChangeNotifier {
  String _currentLanguage = 'en'; // 'en' or 'ms' (Bahasa Melayu)

  String get currentLanguage => _currentLanguage;
  
  bool get isEnglish => _currentLanguage == 'en';
  bool get isMalay => _currentLanguage == 'ms';

  void setLanguage(String langCode) {
    if (langCode == 'en' || langCode == 'ms') {
      _currentLanguage = langCode;
      notifyListeners();
    }
  }

  void toggleLanguage() {
    _currentLanguage = _currentLanguage == 'en' ? 'ms' : 'en';
    notifyListeners();
  }

  // Translations
  String translate(String key) {
    return _translations[_currentLanguage]?[key] ?? key;
  }

  static final Map<String, Map<String, String>> _translations = {
    'en': {
      'app_name': 'Groceye',
      'scanner': 'Scanner',
      'information': 'Information',
      'language': 'Language',
      'english': 'English',
      'bahasa_melayu': 'Bahasa Melayu',
      'how_to_use': 'How to Use',
      'detecting': 'DETECTING',
      'paused': 'PAUSED',
      'objects': 'Objects',
      'text': 'Text',
      'recognized_text': 'Recognized Text',
      
      // Information screen
      'info_title': 'How to Use Grocery Vision',
      'info_step1': '1. Tap Scanner to start',
      'info_step2': '2. Point camera at products',
      'info_step3': '3. App will detect objects and read text',
      'info_step4': '4. Listen to voice announcements',
      'info_step5': '5. Tap pause button to stop',
      'info_features': 'Features:',
      'info_feature1': '• Object detection',
      'info_feature2': '• Text recognition',
      'info_feature3': '• Voice announcements',
      'info_feature4': '• 3-second scanning',
      'back': 'Back',
    },
    'ms': {
      'app_name': 'Groceye',
      'scanner': 'Pengimbas',
      'information': 'Maklumat',
      'language': 'Bahasa',
      'english': 'English',
      'bahasa_melayu': 'Bahasa Melayu',
      'how_to_use': 'Cara Menggunakan',
      'detecting': 'MENGESAN',
      'paused': 'DIJEDA',
      'objects': 'Objek',
      'text': 'Teks',
      'recognized_text': 'Teks Dikenal Pasti',
      
      // Information screen
      'info_title': 'Cara Menggunakan Penglihatan Barangan',
      'info_step1': '1. Tekan Pengimbas untuk mula',
      'info_step2': '2. Arahkan kamera ke produk',
      'info_step3': '3. Aplikasi akan mengesan objek dan membaca teks',
      'info_step4': '4. Dengar pengumuman suara',
      'info_step5': '5. Tekan butang jeda untuk berhenti',
      'info_features': 'Ciri-ciri:',
      'info_feature1': '• Pengesanan objek',
      'info_feature2': '• Pengecaman teks',
      'info_feature3': '• Pengumuman suara',
      'info_feature4': '• Pengimbasan 3 saat',
      'back': 'Kembali',
    },
  };
}
