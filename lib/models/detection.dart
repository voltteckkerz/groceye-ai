class Detection {
  final String name;
  final double confidence;
  final List<double> bbox; // [x, y, width, height]
  
  Detection({
    required this.name,
    required this.confidence,
    required this.bbox,
  });
  
  factory Detection.fromJson(Map<String, dynamic> json) {
    // Parse Roboflow API response
    final predictions = json['predictions'] as Map<String, dynamic>?;
    
    if (predictions == null || predictions.isEmpty) {
      throw Exception('No predictions in response');
    }
    
    // Get first prediction class
    final firstClass = predictions.keys.first;
    final prediction = predictions[firstClass] as Map<String, dynamic>;
    
    return Detection(
      name: firstClass,
      confidence: (prediction['confidence'] as num?)?.toDouble() ?? 0.0,
      bbox: [
        (prediction['x'] as num?)?.toDouble() ?? 0.0,
        (prediction['y'] as num?)?.toDouble() ?? 0.0,
        (prediction['width'] as num?)?.toDouble() ?? 0.0,
        (prediction['height'] as num?)?.toDouble() ?? 0.0,
      ],
    );
  }
  
  static List<Detection> fromJsonList(Map<String, dynamic> json) {
    final predictions = json['predictions'] as Map<String, dynamic>?;
    
    if (predictions == null || predictions.isEmpty) {
      print('⚠️ No predictions in API response');
      return [];
    }
    
    print('📦 Processing ${predictions.length} predictions from API');
    
    return predictions.entries.map((entry) {
      final prediction = entry.value as Map<String, dynamic>;
      
      // Roboflow returns center-based coordinates: [x_center, y_center, width, height]
      // We need to convert to top-left based: [x_left, y_top, width, height]
      final xCenter = (prediction['x'] as num?)?.toDouble() ?? 0.0;
      final yCenter = (prediction['y'] as num?)?.toDouble() ?? 0.0;
      final width = (prediction['width'] as num?)?.toDouble() ?? 0.0;
      final height = (prediction['height'] as num?)?.toDouble() ?? 0.0;
      
      // Transform to top-left coordinates
      final xLeft = xCenter - (width / 2);
      final yTop = yCenter - (height / 2);
      
      final confidence = (prediction['confidence'] as num?)?.toDouble() ?? 0.0;
      
      print('🎯 Detection: ${entry.key} @ ($xCenter, $yCenter) -> ($xLeft, $yTop) [${width}x${height}] conf: ${(confidence * 100).toStringAsFixed(1)}%');
      
      return Detection(
        name: entry.key,
        confidence: confidence,
        bbox: [xLeft, yTop, width, height],
      );
    }).where((d) => d.confidence >= 0.5).toList();
  }
}
