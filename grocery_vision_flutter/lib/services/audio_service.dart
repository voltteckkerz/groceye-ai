import 'package:flutter_tts/flutter_tts.dart';
import '../config/app_config.dart';

class AudioService {
  static final FlutterTts _tts = FlutterTts();
  static final Map<String, DateTime> _lastAnnouncement = {};
  static String _currentLanguage = 'en-US';

  static Future<void> initialize({
    double speechRate = 1.0,
    String? languageCode,
  }) async {
    final locale = _getLocaleFromLanguageCode(languageCode ?? 'en');
    _currentLanguage = locale;
    await _tts.setLanguage(locale);
    await _tts.setSpeechRate(speechRate);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    print('🌐 TTS initialized with language: $locale');
  }

  static Future<void> updateSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate);
  }

  static Future<void> setLanguage(String languageCode) async {
    final locale = _getLocaleFromLanguageCode(languageCode);
    if (_currentLanguage != locale) {
      _currentLanguage = locale;
      await _tts.setLanguage(locale);
      print('🌐 TTS language changed to: $locale');
    }
  }

  static String _getLocaleFromLanguageCode(String code) {
    switch (code) {
      case 'ms':
        return 'ms-MY';  // Malay (Malaysia)
      case 'en':
      default:
        return 'en-US';  // English (US)
    }
  }

  static Future<void> speak(String text) async {
    try {
      print('🔊 Speaking: $text');
      await _tts.speak(text);
    } catch (e) {
      print('❌ TTS error: $e');
    }
  }

  static Future<void> announceDetections(List<String> objectNames) async {
    print('🔊 announceDetections called with: $objectNames');

    if (objectNames.isEmpty) {
      print('⚠️ No objects to announce (empty list)');
      return;
    }

    final now = DateTime.now();

    // ✅ Cooldown filter (unchanged)
    final toAnnounce = objectNames.where((name) {
      final lastTime = _lastAnnouncement[name];
      if (lastTime == null) return true;

      final timeDiff = now.difference(lastTime);
      print(
        '⏱️ $name was announced ${timeDiff.inSeconds}s ago '
        '(cooldown: ${AppConfig.announcementCooldown.inSeconds}s)',
      );

      return timeDiff > AppConfig.announcementCooldown;
    }).toList();

    if (toAnnounce.isEmpty) {
      print('⚠️ All objects filtered out by cooldown');
      return;
    }

    print('✅ Objects to announce after cooldown filter: $toAnnounce');

    // ✅ FAIR: keep order as provided (already sorted by confidence)
    final uniqueToAnnounce = <String>[];
    for (final name in toAnnounce) {
      if (!uniqueToAnnounce.contains(name)) {
        uniqueToAnnounce.add(name);
      }
    }

    // Update last announcement times
    for (final name in uniqueToAnnounce) {
      _lastAnnouncement[name] = now;
    }

    final announcement = uniqueToAnnounce.length == 1
        ? uniqueToAnnounce.first
        : '${uniqueToAnnounce.length} objects: ${uniqueToAnnounce.join(', ')}';

    print('🗣️ Final announcement: "$announcement"');
    await speak(announcement);
  }

  static Future<void> playBeep() async {
    // Beep functionality disabled - audioplayers removed
    print('🔔 Beep disabled (audioplayers removed)');
  }

  static void dispose() {
    _tts.stop();
  }
}
