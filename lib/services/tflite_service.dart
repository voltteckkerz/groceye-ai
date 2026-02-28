import 'package:flutter/services.dart';
import '../models/detection.dart';
import '../config/app_config.dart';

class TFLiteService {
  static const platform = MethodChannel('com.groceye/tflite');
  static bool _isInitialized = false;
  
  /// Initialize the TFLite model via native code
  static Future<void> initialize() async {
    if (_isInitialized) {
      print('✅ TFLite already initialized');
      return;
    }
    
    try {
      print('📦 Initializing TFLite via Platform Channel...');
      
      final result = await platform.invokeMethod('initialize');
      print('📥 Native initialization result: $result');
      
      if (result == null) {
        throw Exception('Initialization returned null');
      }
      
      final success = result['success'] as bool? ?? false;
      
      if (success) {
        final inputSize = result['inputSize'];
        final numLabels = result['numLabels'];
        
        print('✅ Model loaded successfully');
        print('📏 Input size: ${inputSize}x$inputSize');
        print('✅ Loaded $numLabels labels');
        
        _isInitialized = true;
        print('✅ TFLite initialization complete');
      } else {
        throw Exception('Initialization failed - success=false');
      }
    } on PlatformException catch (e) {
      print('❌ Platform Exception: ${e.code} - ${e.message}');
      print('📚 Details: ${e.details}');
      rethrow;
    } catch (e, stackTrace) {
      print('❌ TFLite initialization error: $e');
      print('📚 Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  /// Run object detection via native code
  static Future<List<Detection>> detect(String imagePath) async {
    if (!_isInitialized) {
      print('⚠️ TFLite not initialized, initializing now...');
      await initialize();
    }
    
    try {
      print('📸 Running YOLO inference via Platform Channel: $imagePath');
      
      final stopwatch = Stopwatch()..start();
      
      // Call native Android code
      final result = await platform.invokeMethod('detectObjects', {
        'imagePath': imagePath,
        'threshold': AppConfig.confidenceThreshold,
      });
      
      stopwatch.stop();
      print('✅ Inference complete in ${stopwatch.elapsedMilliseconds}ms');
      
      // Parse detections from native code
      final detections = <Detection>[];
      
      if (result is List) {
        for (var item in result) {
          final detection = Detection(
            name: item['name'] as String,
            confidence: (item['confidence'] as num).toDouble(),
            bbox: [
              (item['x'] as num).toDouble(),
              (item['y'] as num).toDouble(),
              (item['width'] as num).toDouble(),
              (item['height'] as num).toDouble(),
            ],
          );
          
          print('🎯 Detection: ${detection.name} @ (${detection.bbox[0].toStringAsFixed(1)}, ${detection.bbox[1].toStringAsFixed(1)}) '
              '[${detection.bbox[2].toStringAsFixed(1)}x${detection.bbox[3].toStringAsFixed(1)}] '
              'conf: ${(detection.confidence * 100).toStringAsFixed(1)}%');
          
          detections.add(detection);
        }
      }
      
      print('✅ Returning ${detections.length} detections');
      return detections;
      
    } on PlatformException catch (e) {
      print('❌ Platform channel error: ${e.code} - ${e.message}');
      return [];
    } catch (e, stackTrace) {
      print('❌ TFLite detection error: $e');
      print('📚 Stack trace: $stackTrace');
      return [];
    }
  }
  
  /// Dispose resources
  static Future<void> dispose() async {
    try {
      await platform.invokeMethod('dispose');
      _isInitialized = false;
      print('✅ TFLite resources disposed');
    } catch (e) {
      print('⚠️ Error disposing TFLite: $e');
    }
  }
}
