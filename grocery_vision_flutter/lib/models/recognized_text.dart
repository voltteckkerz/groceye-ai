class RecognizedText {
  final String text;
  final double confidence;
  final Rect? boundingBox;

  RecognizedText({
    required this.text,
    required this.confidence,
    this.boundingBox,
  });

  @override
  String toString() {
    return 'RecognizedText(text: $text, confidence: ${confidence.toStringAsFixed(2)})';
  }
}

class Rect {
  final double left;
  final double top;
  final double right;
  final double bottom;

  Rect({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });
}
