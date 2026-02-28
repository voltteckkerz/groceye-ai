import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/audio_service.dart';
import '../services/language_service.dart';
import '../services/favorites_service.dart';
import 'onboarding_screen.dart';
import 'package:camera/camera.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsService settingsService;
  final FavoritesService favoritesService;
  final CameraDescription camera;

  const SettingsScreen({
    super.key,
    required this.settingsService,
    required this.favoritesService,
    required this.camera,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _speechRate;
  late bool _keepScreenOn;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _speechRate = widget.settingsService.speechRate;
      _keepScreenOn = widget.settingsService.keepScreenOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD1C9),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),

            // Settings List
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // Speech Rate Slider
                    _buildSettingCard(
                      title: 'Speech Rate',
                      subtitle: '${_speechRate.toStringAsFixed(1)}x',
                      icon: Icons.speed,
                      color: const Color(0xFFF73C1B),
                      child: Column(
                        children: [
                          Slider(
                            value: _speechRate,
                            min: 0.5,
                            max: 2.0,
                            divisions: 15,
                            activeColor: const Color(0xFFF73C1B),
                            inactiveColor: Colors.grey.withOpacity(0.3),
                            onChanged: (value) {
                              setState(() {
                                _speechRate = value;
                              });
                            },
                            onChangeEnd: (value) async {
                              await widget.settingsService.setSpeechRate(value);
                              await AudioService.updateSpeechRate(value);
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Slow',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => AudioService.speak('Testing voice at ${_speechRate.toStringAsFixed(1)}x speed'),
                                icon: const Icon(Icons.play_arrow, size: 16),
                                label: const Text('Test Voice'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF73C1B),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                              ),
                              Text(
                                'Fast',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),



                    // Keep Screen On Toggle
                    _buildSettingCard(
                      title: 'Keep Screen On',
                      subtitle: _keepScreenOn ? 'Enabled' : 'Disabled',
                      icon: Icons.phone_android,
                      color: const Color(0xFFFFB3D9),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Prevent screen from turning off during scanning',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),
                          ),
                          Switch(
                            value: _keepScreenOn,
                            activeColor: const Color(0xFFFFB3D9),
                            onChanged: (value) async {
                              setState(() {
                                _keepScreenOn = value;
                              });
                              await widget.settingsService.setKeepScreenOn(value);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Show Onboarding Button
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OnboardingScreen(
                              camera: widget.camera,
                              languageService: LanguageService(),
                              settingsService: widget.settingsService,
                              favoritesService: widget.favoritesService,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF73C1B), Color(0xFFFF6B4A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF73C1B).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.play_circle_outline,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Show Tutorial Again',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
