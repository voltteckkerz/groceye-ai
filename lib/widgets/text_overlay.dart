import 'package:flutter/material.dart';
import '../models/recognized_text.dart';

class TextOverlay extends StatelessWidget {
  final List<RecognizedText> recognizedTexts;
  final Size screenSize;

  const TextOverlay({
    super.key,
    required this.recognizedTexts,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Text overlay boxes
        ...recognizedTexts.map((text) {
          if (text.boundingBox == null) return const SizedBox.shrink();
          
          final box = text.boundingBox!;
          
          return Positioned(
            left: box.left,
            top: box.top,
            child: Container(
              width: box.right - box.left,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.3),
                border: Border.all(color: Colors.blue, width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                text.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          );
        }).toList(),
        
        // Text list at bottom
        if (recognizedTexts.isNotEmpty)
          Positioned(
            bottom: 120,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(maxHeight: 150),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.text_fields, color: Colors.blue, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Recognized Text',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...recognizedTexts.take(10).map((text) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        text.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
