import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _speechRateKey = 'speech_rate';
  static const String _confidenceThresholdKey = 'confidence_threshold';
  static const String _detectionIntervalKey = 'detection_interval';
  static const String _keepScreenOnKey = 'keep_screen_on';
  static const String _isFirstLaunchKey = 'is_first_launch';
  
  // Default values
  static const double _defaultSpeechRate = 1.0;
  static const double _defaultConfidenceThreshold = 0.5;
  static const int _defaultDetectionInterval = 6;
  static const bool _defaultKeepScreenOn = false;
  
  late SharedPreferences _prefs;
  
  // Current values
  double _speechRate = _defaultSpeechRate;
  double _confidenceThreshold = _defaultConfidenceThreshold;
  int _detectionInterval = _defaultDetectionInterval;
  bool _keepScreenOn = _defaultKeepScreenOn;
  bool _isFirstLaunch = true;
  
  // Initialize and load settings
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }
  
  void _loadSettings() {
    _speechRate = _prefs.getDouble(_speechRateKey) ?? _defaultSpeechRate;
    _confidenceThreshold = _prefs.getDouble(_confidenceThresholdKey) ?? _defaultConfidenceThreshold;
    _detectionInterval = _prefs.getInt(_detectionIntervalKey) ?? _defaultDetectionInterval;
    _keepScreenOn = _prefs.getBool(_keepScreenOnKey) ?? _defaultKeepScreenOn;
    _isFirstLaunch = _prefs.getBool(_isFirstLaunchKey) ?? true;
  }
  
  // Speech Rate (0.5 - 2.0)
  double get speechRate => _speechRate;
  
  Future<void> setSpeechRate(double value) async {
    _speechRate = value.clamp(0.5, 2.0);
    await _prefs.setDouble(_speechRateKey, _speechRate);
  }
  
  // Confidence Threshold (0.3 - 0.9)
  double get confidenceThreshold => _confidenceThreshold;
  
  Future<void> setConfidenceThreshold(double value) async {
    _confidenceThreshold = value.clamp(0.3, 0.9);
    await _prefs.setDouble(_confidenceThresholdKey, _confidenceThreshold);
  }
  
  // Detection Interval in seconds (1, 3, 5, 10)
  int get detectionInterval => _detectionInterval;
  
  Duration get detectionIntervalDuration => Duration(seconds: _detectionInterval);
  
  Future<void> setDetectionInterval(int seconds) async {
    _detectionInterval = seconds;
    await _prefs.setInt(_detectionIntervalKey, _detectionInterval);
  }
  
  // Keep Screen On
  bool get keepScreenOn => _keepScreenOn;
  
  Future<void> setKeepScreenOn(bool value) async {
    _keepScreenOn = value;
    await _prefs.setBool(_keepScreenOnKey, _keepScreenOn);
  }
  
  // First Launch
  bool get isFirstLaunch => _isFirstLaunch;
  
  Future<void> markFirstLaunchComplete() async {
    _isFirstLaunch = false;
    await _prefs.setBool(_isFirstLaunchKey, false);
  }
  
  // Reset to defaults
  Future<void> resetToDefaults() async {
    await setSpeechRate(_defaultSpeechRate);
    await setConfidenceThreshold(_defaultConfidenceThreshold);
    await setDetectionInterval(_defaultDetectionInterval);
    await setKeepScreenOn(_defaultKeepScreenOn);
  }
}
