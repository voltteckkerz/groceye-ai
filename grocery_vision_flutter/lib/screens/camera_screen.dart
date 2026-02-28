import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:image/image.dart' as img;

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
  bool _isModelLoaded = false;
  bool _isProcessing = false;
  
  ScanMode _currentMode = ScanMode.item;
  List<Detection> _detections = [];
  List<RecognizedText> _recognizedTexts = [];
  Size _lastImageSize = const Size(640, 640);  // Track actual captured image size

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    AudioService.initialize(
      speechRate: widget.settingsService.speechRate,
      languageCode: widget.languageService.currentLanguage,
    );
    
    Future.microtask(() async {
      await TFLiteService.initialize();
      if (!mounted) return;
      setState(() => _isModelLoaded = true);
      _startDetectionLoop();
    });
    
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
      await _controller.setFlashMode(FlashMode.off);
      print('✅ Camera initialized');
    });
  }

  void _startDetectionLoop() {
    debugPrint('🔄 Starting detection loop');
    _detectionTimer?.cancel();
    
    _detectionTimer = Timer.periodic(
      widget.settingsService.detectionIntervalDuration,
      (timer) {
        if (!_isPaused && !_isProcessing && _isModelLoaded) {
          _detectObjects();
        }
      },
    );
  }



  Future<void> _detectObjects() async {
    if (_isProcessing || !_controller.value.isInitialized) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Capture image
      print('📸 Capturing image...');
      final image = await _controller.takePicture();
      print('✅ Image captured: ${image.path}');

      // Run detection based on selected mode
      if (_currentMode == ScanMode.item) {
        // Object detection using TFLite
        print('🔍 Running TFLite detection...');
        
        // Get actual image dimensions from captured photo
        final bytes = await File(image.path).readAsBytes();
        final imageLib = img.decodeImage(bytes);
        if (imageLib != null) {
          setState(() {
            _lastImageSize = Size(imageLib.width.toDouble(), imageLib.height.toDouble());
          });
          print('📐 Captured image size: ${imageLib.width}x${imageLib.height}');
        }
        
        final detections = await TFLiteService.detect(image.path);
        
        print('✅ Got ${detections.length} detections');

        // ✅ FAIR SORTING: highest confidence first
        detections.sort(
        (a, b) => b.confidence.compareTo(a.confidence),
);
        
        // Keep only the highest confidence detection (detections are already sorted by confidence)
        final bestDetection = detections.isNotEmpty ? [detections.first] : <Detection>[];
        
        if (bestDetection.isNotEmpty) {
          print('🎯 Best detection: ${bestDetection.first.name} (${(bestDetection.first.confidence * 100).toStringAsFixed(1)}%)');
        }
        
        if (mounted) {
          setState(() {
            _detections = bestDetection;  // Show only the best detection
            _recognizedTexts = [];
          });
        }

        // Announce only the best detection (type only)
        if (bestDetection.isNotEmpty) {
          await AudioService.playBeep();
          
          final detection = bestDetection.first;
          final typeName = AppConfig.labelMapping[detection.name] ?? detection.name;
          
          print('🗣️ Announcing: $typeName');
          await AudioService.speak(typeName);
          
          // Auto-save detected item
          final savedItem = SavedItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: typeName,
            mode: ScanMode.item,
            confidence: detection.confidence,
            timestamp: DateTime.now(),
          );
          await widget.favoritesService.saveItem(savedItem);
          print('💾 Saved item: $typeName');
        }
      } else {
        // Text recognition mode
        print('🔍 [TEXT] Running text recognition...');
        
        final recognizedTexts = await TextRecognitionService.recognizeText(image.path);
        print('📊 [TEXT] Got ${recognizedTexts.length} text blocks from service');
        
        // Sort recognized texts by bounding box area in descending order
        recognizedTexts.sort((a, b) {
          final areaA = a.boundingBox != null 
              ? (a.boundingBox!.right - a.boundingBox!.left) * (a.boundingBox!.bottom - a.boundingBox!.top)
              : 0.0;
          final areaB = b.boundingBox != null
              ? (b.boundingBox!.right - b.boundingBox!.left) * (b.boundingBox!.bottom - b.boundingBox!.top)
              : 0.0;
          return areaB.compareTo(areaA); // Descending order
        });

        if (mounted) {
          setState(() {
            // Limit to top 3 largest text blocks
            if (recognizedTexts.length > 3) {
              _recognizedTexts = recognizedTexts.sublist(0, 3);
              print('📝 [TEXT] Limited to top 3 texts (from ${recognizedTexts.length})');
            } else {
              _recognizedTexts = recognizedTexts;
            }
            _detections = [];
          });
        }

        // Announce top 3 texts
        if (_recognizedTexts.isNotEmpty) {
          await AudioService.playBeep();
          final textsToSpeak = _recognizedTexts.map((t) => t.text).join(', ');
          print('🗣️ [TEXT] Announcing ${_recognizedTexts.length} texts: $textsToSpeak');
          await AudioService.speak(textsToSpeak);
          
          // Auto-save recognized texts
          final savedItem = SavedItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: _recognizedTexts.first.text,
            allLabels: _recognizedTexts.map((t) => t.text).toList(),
            mode: ScanMode.label,
            timestamp: DateTime.now(),
          );
          await widget.favoritesService.saveItem(savedItem);
          print('💾 Saved text: ${_recognizedTexts.first.text}');
        } else {
          print('⚠️ [TEXT] No text detected');
        }
      }
    } catch (e) {
      print('❌ Detection error: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
    AudioService.speak(_isPaused ? 'Paused' : 'Resumed');
  }

  void _switchMode(ScanMode mode) {
    print('🔄 [MODE] Switching to ${mode.displayName}');
    
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
            
            return GestureDetector(
              // Swipe gestures for mode switching
              onHorizontalDragEnd: (details) {
                // Swipe right = item detection, Swipe left = text recognition
                if (details.primaryVelocity! > 0) {
                  // Swipe right
                  if (_currentMode != ScanMode.item) {
                    _switchMode(ScanMode.item);
                  }
                } else if (details.primaryVelocity! < 0) {
                  // Swipe left
                  if (_currentMode != ScanMode.label) {
                    _switchMode(ScanMode.label);
                  }
                }
              },
              // Double-tap for pause/resume
              onDoubleTap: _togglePause,
              child: Stack(
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
                
                // Mode Indicator (display-only, no interaction)
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Center(
                      child: ModeToggleSwitch(
                        currentMode: _currentMode,
                        onModeChanged: (_) {}, // No-op callback (indicator only)
                      ),
                    ),
                  ),
                ),
                
                // Detection Overlays (only show in item mode)
                if (_currentMode == ScanMode.item)
                  DetectionOverlay(
                    detections: _detections,
                    screenSize: size,
                    imageDimensions: _lastImageSize,  // Use actual captured image size
                  ),
                
                // Text Recognition Overlays (only show in label mode)
                if (_currentMode == ScanMode.label)
                  TextOverlay(
                    recognizedTexts: _recognizedTexts,
                    screenSize: size,
                  ),
                ],
              ),
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
}
