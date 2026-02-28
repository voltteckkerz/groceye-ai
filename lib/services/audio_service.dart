import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../config/app_config.dart';

class AudioService {
  static final FlutterTts _tts = FlutterTts();
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static final Map<String, DateTime> _lastAnnouncement = {};
  
  static Future<void> initialize({double speechRate = 1.0}) async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(speechRate);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }
  
  static Future<void> updateSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate);
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
    
    // Filter out recently announced objects
    final now = DateTime.now();
    final toAnnounce = objectNames.where((name) {
      final lastTime = _lastAnnouncement[name];
      if (lastTime == null) return true;
      final timeDiff = now.difference(lastTime);
      print('⏱️ $name was announced ${timeDiff.inSeconds}s ago (cooldown: ${AppConfig.announcementCooldown.inSeconds}s)');
      return timeDiff > AppConfig.announcementCooldown;
    }).toList();
    
    if (toAnnounce.isEmpty) {
      print('⚠️ All objects filtered out by cooldown');
      return;
    }
    
    print('✅ Objects to announce after cooldown filter: $toAnnounce');
    
    // Sort by priority
    toAnnounce.sort((a, b) {
      final aPriority = AppConfig.priorityObjects.contains(a);
      final bPriority = AppConfig.priorityObjects.contains(b);
      if (aPriority && !bPriority) return -1;
      if (!aPriority && bPriority) return 1;
      return 0;
    });
    
    print('📋 After priority sort: $toAnnounce');
    
    // Update last announcement times
    for (final name in toAnnounce) {
      _lastAnnouncement[name] = now;
    }
    
    // Play beep BEFORE announcement
    await playBeep();
    
    // Announce
    final announcement = toAnnounce.length == 1
        ? toAnnounce.first
        : '${toAnnounce.length} objects: ${toAnnounce.join(', ')}';
    
    print('🗣️ Final announcement: "$announcement"');
    await speak(announcement);
  }
  
  static Future<void> playBeep() async {
    try {
      print('🔔 Playing beep sound...');
      // Use a simple URL-based tone (440Hz beep)
      // This requires internet but provides immediate feedback
      await _audioPlayer.play(UrlSource('https://www.soundjay.com/button/sounds/beep-07.mp3'));
      await Future.delayed(const Duration(milliseconds: 200)); // Short beep
      await _audioPlayer.stop();
      print('✅ Beep played successfully');
    } catch (e) {
      print('❌ Audio playback error: $e');
    }
  }
  
  static void dispose() {
    _tts.stop();
    _audioPlayer.dispose();
  }
}
