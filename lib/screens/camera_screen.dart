import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../config/app_config.dart';
import '../models/detection.dart';
import '../models/recognized_text.dart';
import '../models/scan_mode.dart';
import '../models/saved_item.dart';
import '../services/tflite_service.dart';
import '../services/text_recognition_service.dart';
import '../services/audio_service.dart';
import '../services/language_service.dart';
import '../services/settings_service.dart';
import '../services/favorites_service.dart';
import '../widgets/control_button.dart';
import '../widgets/detection_overlay.dart';
import '../widgets/text_overlay.dart';
import '../widgets/mode_toggle_switch.dart';
import 'package:uuid/uuid.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  final LanguageService languageService;
  final SettingsService settingsService;
  final FavoritesService favoritesService;
  
  const CameraScreen({
    super.key,
    required this.camera,
    required this.languageService,
    required this.settingsService,
    required this.favoritesService,
  });
  
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  Timer? _detectionTimer;
  bool _isPaused = false;
  List<Detection> _detections = [];
  List<RecognizedText> _recognizedTexts = [];
  bool _isProcessing = false;
  ScanMode _currentMode = ScanMode.item;
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
    AudioService.initialize(speechRate: widget.settingsService.speechRate);
    TFLiteService.initialize();
    _startDetectionLoop();
    _applyWakeLock();
  }
  
  void _applyWakeLock() {
    if (widget.settingsService.keepScreenOn) {
      WakelockPlus.enable();
    }
  }
  
  void _initializeCamera() async {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    
    _initializeControllerFuture = _controller.initialize().then((_) async {
      // Disable flash to prevent it from turning on during takePicture()
      await _controller.setFlashMode(FlashMode.off);
      print('✅ Camera initialized with flash disabled');
    });
  }
  
  void _startDetectionLoop() {
    debugPrint('🔄 _startDetectionLoop called');
    _detectionTimer?.cancel();
    
    debugPrint('⏰ Setting up timer with interval: ${widget.settingsService.detectionIntervalDuration}');
    _detectionTimer = Timer.periodic(widget.settingsService.detectionIntervalDuration, (timer) {
      debugPrint('⏰ Timer tick! isPaused: $_isPaused, isProcessing: $_isProcessing');
      if (!_isPaused && !_isProcessing) {
        debugPrint('✅ Calling _detectObjects from timer');
        _detectObjects();
      } else {
        debugPrint('⏭️ Skipping detection - paused: $_isPaused, processing: $_isProcessing');
      }
    });
    
    // Call immediately for testing
    debugPrint('🚀 Calling _detectObjects immediately for testing');
    Future.delayed(Duration(seconds: 2), () {
      debugPrint('🎬 2 second delay complete, calling _detectObjects now');
      _detectObjects();
    });
  }
  
  Future<void> _detectObjects() async {
    if (_isProcessing || !_controller.value.isInitialized) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      // Capture image
      final image = await _controller.takePicture();
      
      // Run detection based on selected mode
      if (_currentMode == ScanMode.item) {
        // Object detection using TFLite
        final detections = await TFLiteService.detect(image.path);
        
        // Filter by confidence threshold
        final filteredDetections = detections
            .where((d) => d.confidence >= widget.settingsService.confidenceThreshold)
            .toList();
        
        setState(() {
          _detections = filteredDetections;
          _recognizedTexts = [];
        });
        
        // Announce detections
        if (filteredDetections.isNotEmpty) {
          await AudioService.playBeep();
          final objectNames = filteredDetections
              .map((d) => AppConfig.labelMapping[d.name] ?? d.name)
              .toList();
          await AudioService.announceDetections(objectNames);
          
          // Auto-save detected items to favorites
          final savedItem = SavedItem(
            id: const Uuid().v4(),
            name: objectNames.first,
            allLabels: objectNames,
            mode: ScanMode.item,
            confidence: filteredDetections.first.confidence,
            allConfidences: filteredDetections.map((d) => d.confidence).toList(),
            timestamp: DateTime.now(),
          );
          await widget.favoritesService.saveItem(savedItem);
          print('💾 Auto-saved ${objectNames.length} detected item(s)');
        }

      } else {
        // Text recognition mode
        final recognizedTexts = await TextRecognitionService.recognizeText(image.path);
        
        setState(() {
          _detections = [];
          _recognizedTexts = recognizedTexts;
        });
        
        // Announce text
        if (recognizedTexts.isNotEmpty) {
          await AudioService.playBeep();
          final textLines = recognizedTexts.take(3).map((t) => t.text).toList();
          await AudioService.speak('Text: ${textLines.join(", ")}');
          
          // Auto-save recognized text to favorites
          final allTextLines = recognizedTexts.map((t) => t.text).toList();
          final savedItem = SavedItem(
            id: const Uuid().v4(),
            name: allTextLines.first,
            allLabels: allTextLines,
            mode: ScanMode.label,
            timestamp: DateTime.now(),
          );
          await widget.favoritesService.saveItem(savedItem);
          print('💾 Auto-saved ${allTextLines.length} recognized text(s)');
        }

      }
    } catch (e) {
      print('Error during detection: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
  
  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    AudioService.speak(_isPaused ? 'Paused' : 'Resumed');
  }
  
  void _switchMode(ScanMode mode) {
    setState(() {
      _currentMode = mode;
      _detections = [];
      _recognizedTexts = [];
    });
    AudioService.speak('${mode.displayName} mode');
  }
  
  @override
  void dispose() {
    _detectionTimer?.cancel();
    _controller.dispose();
    AudioService.dispose();
    TextRecognitionService.dispose();
    TFLiteService.dispose();
    if (widget.settingsService.keepScreenOn) {
      WakelockPlus.disable();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final size = MediaQuery.of(context).size;
            
            return Stack(
              children: [
                // Camera Preview
                SizedBox(
                  width: size.width,
                  height: size.height,
                  child: CameraPreview(_controller),
                ),
                
                // Status Indicator
                Positioned(
                  top: 50,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _isPaused ? Colors.red : Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isPaused 
                            ? widget.languageService.translate('paused') 
                            : _currentMode.statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Mode Selector (Swipeable Toggle)
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ModeToggleSwitch(
                      currentMode: _currentMode,
                      onModeChanged: _switchMode,
                    ),
                  ),
                ),
                
                // Detection Overlays (only show in item mode)
                if (_currentMode == ScanMode.item)
                  DetectionOverlay(
                    detections: _detections,
                    screenSize: size,
                  ),
                
                // Text Recognition Overlays (only show in label mode)
                if (_currentMode == ScanMode.label)
                  TextOverlay(
                    recognizedTexts: _recognizedTexts,
                    screenSize: size,
                  ),
                
                // Control Button
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ControlButton(
                      isPaused: _isPaused,
                      onPressed: _togglePause,
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }
  
  Widget _buildModeButton(ScanMode mode, IconData icon) {
    final isSelected = _currentMode == mode;
    return GestureDetector(
      onTap: () => _switchMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFF73C1B), Color(0xFFFF6B4A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? Colors.white.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFF73C1B).withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: const Color(0xFFFF6B4A).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              child: AnimatedRotation(
                turns: isSelected ? 0.03 : 0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutBack,
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              style: TextStyle(
                color: Colors.white,
                fontSize: isSelected ? 15 : 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                letterSpacing: isSelected ? 0.8 : 0,
              ),
              child: Text(mode.displayName),
            ),
          ],
        ),
      ),
    );
  }
}
