import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/recognized_text.dart' as model;

class TextRecognitionService {
  // TextRecognizer with Latin script - supports English, Malay (Bahasa Melayu), and other Latin-based languages
  static final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  static Future<List<model.RecognizedText>> recognizeText(String imagePath) async {
    try {
      print('📝 Processing image for text recognition...');
      
      // Create InputImage from file path
      final inputImage = InputImage.fromFilePath(imagePath);
      
      // Recognize text
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      print('✅ Text recognition complete');
      
      // Extract text blocks with confidence
      List<model.RecognizedText> results = [];
      
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          // Filter out empty text
          if (line.text.trim().isNotEmpty) {
            final boundingBox = line.boundingBox;
            results.add(model.RecognizedText(
              text: line.text,
              confidence: line.confidence ?? 0.0,
              boundingBox: boundingBox != null
                  ? model.Rect(
                      left: boundingBox.left.toDouble(),
                      top: boundingBox.top.toDouble(),
                      right: boundingBox.right.toDouble(),
                      bottom: boundingBox.bottom.toDouble(),
                    )
                  : null,
            ));
          }
        }
      }
      
      print('🎯 Found ${results.length} text lines');
      
      // Filter by confidence threshold
      final filteredResults = results.where((r) => r.confidence > 0.5).toList();
      print('✨ ${filteredResults.length} high-confidence text lines');
      
      return filteredResults;
    } catch (e) {
      print('❌ Text recognition error: $e');
      return [];
    }
  }

  static void dispose() {
    _textRecognizer.close();
  }
}
