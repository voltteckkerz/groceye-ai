import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/recognized_text.dart' as model;

class TextRecognitionService {
  // ✅ FIX: nullable recognizer (re-initialized safely)
  static TextRecognizer? _textRecognizer;

  static Future<List<model.RecognizedText>> recognizeText(
    String imagePath,
  ) async {
    try {
      print('🔍 [TEXT_RECOGNITION] Starting text recognition...');
      print('📁 [TEXT_RECOGNITION] Image path: $imagePath');
      
      // ✅ Ensure fresh recognizer instance
      _textRecognizer ??=
          TextRecognizer(script: TextRecognitionScript.latin);
      print('✅ [TEXT_RECOGNITION] TextRecognizer initialized');

      final inputImage = InputImage.fromFilePath(imagePath);
      print('📸 [TEXT_RECOGNITION] InputImage created from path');
      
      print('⚙️ [TEXT_RECOGNITION] Calling ML Kit processImage...');
      final RecognizedText recognizedText =
          await _textRecognizer!.processImage(inputImage);
      print('✅ [TEXT_RECOGNITION] ML Kit processing complete');
      
      print('📊 [TEXT_RECOGNITION] Raw blocks detected: ${recognizedText.blocks.length}');

      final List<model.RecognizedText> results = [];
      int totalLines = 0;
      int filteredLines = 0;

      for (final block in recognizedText.blocks) {
        print('📦 [TEXT_RECOGNITION] Block has ${block.lines.length} lines');
        for (final line in block.lines) {
          totalLines++;
          print('📝 [TEXT_RECOGNITION] Line text: "${line.text}" (length: ${line.text.length})');
          if (line.text.length > 2) {
            filteredLines++;
            results.add(
              model.RecognizedText(
                text: line.text,
                confidence: 1.0, // ML Kit does not expose line confidence
                boundingBox: model.Rect(
                  left: line.boundingBox.left,
                  top: line.boundingBox.top,
                  right: line.boundingBox.right,
                  bottom: line.boundingBox.bottom,
                ),
              ),
            );
          } else {
            print('⏭️ [TEXT_RECOGNITION] Skipped (too short): "${line.text}"');
          }
        }
      }

      print('✅ [TEXT_RECOGNITION] Processing complete!');
      print('📊 [TEXT_RECOGNITION] Total lines: $totalLines, Filtered lines: $filteredLines, Final results: ${results.length}');
      return results;
    } catch (e, stackTrace) {
      print('❌ [TEXT_RECOGNITION] Error recognizing text: $e');
      print('📚 [TEXT_RECOGNITION] Stack trace: $stackTrace');
      return [];
    }
  }

  // ✅ Keep dispose() as-is (but null-safe)
  static void dispose() {
    _textRecognizer?.close();
    _textRecognizer = null;
  }
}
