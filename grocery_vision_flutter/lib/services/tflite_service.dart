import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/detection.dart';

class TFLiteService {
  static Interpreter? _yoloInterpreter;
  static List<String> _yoloLabels = [];
  static int _inputSize = 416;  // Runtime input size
  static const int _modelTrainedSize = 640;  // Size model was trained on

  static bool _initialized = false;

  // =========================
  // INIT
  // =========================
  static Future<void> initialize() async {
    if (_initialized) return;

    print('📦 Initializing TFLite…');

    _yoloInterpreter =
        await Interpreter.fromAsset('assets/models/grocery_type_yolo.tflite');

    final inputTensor = _yoloInterpreter!.getInputTensor(0);
    _inputSize = inputTensor.shape[1];

    final labels =
        await rootBundle.loadString('assets/models/grocery_type_labels.txt');
    _yoloLabels = labels
        .split('\n')
        .where((e) => e.trim().isNotEmpty)
        .toList();

    print('✅ YOLO input: $_inputSize x $_inputSize');
    print('🧾 YOLO labels: $_yoloLabels');

    _initialized = true;
  }

  // =========================
  // MAIN DETECT FUNCTION
  // =========================
  static Future<List<Detection>> detect(String imagePath) async {
    if (_yoloInterpreter == null) await initialize();

    print('📸 Image path: $imagePath');
    print('📏 Exists: ${File(imagePath).existsSync()}');
    print('📦 Size: ${File(imagePath).lengthSync()} bytes');

    final bytes = await File(imagePath).readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) return [];

    final resized =
        img.copyResize(original, width: _inputSize, height: _inputSize);
    final input = _preprocess(resized);

    final shape = _yoloInterpreter!.getOutputTensor(0).shape; // [1, 9, 8400]
    print('🧠 YOLO output shape: $shape');

    final output = List.generate(
      1,
      (_) => List.generate(shape[1], (_) => List.filled(shape[2], 0.0)),
    );

    _yoloInterpreter!.run(input, output);

    // TRANSPOSE → [8400, 9]
    final predictions = <List<double>>[];
    for (int i = 0; i < shape[2]; i++) {
      final row = <double>[];
      for (int j = 0; j < shape[1]; j++) {
        row.add(output[0][j][i]);
      }
      predictions.add(row);
    }

    // Parse YOLO detections (type only, no brand classification)
    return _parseYOLO(
      predictions,
      0.35,
      original.width,
      original.height,
    );
  }

  // =========================
  // YOLO PARSER (TYPE)
  // =========================
  static List<Detection> _parseYOLO(
    List<List<double>> preds,
    double threshold,
    int imgW,
    int imgH,
  ) {
    final detections = <Detection>[];

    for (final p in preds) {
      final cx = p[0];
      final cy = p[1];
      final w = p[2];
      final h = p[3];

      double bestScore = 0;
      int bestClass = -1;

      for (int i = 0; i < _yoloLabels.length; i++) {
        final score = p[4 + i];
        if (score > bestScore) {
          bestScore = score;
          bestClass = i;
        }
      }

      if (bestScore < threshold) continue;

      // Apply scaling correction if using different input size than training size
      final scaleFactor = _modelTrainedSize / _inputSize;  // 640 / 416 = ~1.538
      
      final bw = (w * imgW) * scaleFactor;
      final bh = (h * imgH) * scaleFactor;
      final left = (cx * imgW) - bw / 2;
      final top = (cy * imgH) - bh / 2;

      final label = _yoloLabels[bestClass];

      print('🔍 Type: $label conf=${bestScore.toStringAsFixed(2)}');
      print('📐 Raw: cx=$cx cy=$cy w=$w h=$h (scale: ${scaleFactor.toStringAsFixed(2)})');
      print('📏 Calc: left=${left.toStringAsFixed(1)} top=${top.toStringAsFixed(1)} width=${bw.toStringAsFixed(1)} height=${bh.toStringAsFixed(1)}');
      print('📷 Image: ${imgW}x$imgH');

      detections.add(
        Detection(
          name: label,
          confidence: bestScore,
          bbox: [left, top, bw, bh],
        ),
      );
    }

    detections.sort((a, b) => b.confidence.compareTo(a.confidence));

    final result = <Detection>[];
    for (final d in detections) {
      bool keep = true;
      for (final r in result) {
        if (_iou(d.bbox, r.bbox) > 0.4) {
          keep = false;
          break;
        }
      }
      if (keep) result.add(d);
    }

    return result;
  }

  // =========================
  // PREPROCESS
  // =========================
  static List<List<List<List<double>>>> _preprocess(img.Image image) {
    return [
      List.generate(
        image.height,
        (y) => List.generate(
          image.width,
          (x) {
            final p = image.getPixel(x, y);
            return [p.r / 255, p.g / 255, p.b / 255];
          },
        ),
      )
    ];
  }

  static double _iou(List<double> a, List<double> b) {
    final x1 = max(a[0], b[0]);
    final y1 = max(a[1], b[1]);
    final x2 = min(a[0] + a[2], b[0] + b[2]);
    final y2 = min(a[1] + a[3], b[1] + b[3]);

    if (x2 < x1 || y2 < y1) return 0;

    final inter = (x2 - x1) * (y2 - y1);
    final union = (a[2] * a[3]) + (b[2] * b[3]) - inter;
    return inter / union;
  }

  static void dispose() {
    _yoloInterpreter?.close();
  }
}
