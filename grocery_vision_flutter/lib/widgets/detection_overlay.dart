import 'package:flutter/material.dart';
import '../models/detection.dart';

class DetectionOverlay extends StatelessWidget {
  final List<Detection> detections;
  final Size screenSize;
  final Size imageDimensions;  // Add image dimensions for scaling
  
  const DetectionOverlay({
    super.key,
    required this.detections,
    required this.screenSize,
    required this.imageDimensions,
  });
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: detections.map((detection) {
        final bbox = detection.bbox;
        
        // Calculate scale factors accounting for aspect ratio
        // The camera preview maintains aspect ratio, so we need to find
        // how it's actually displayed on screen
        final imageAspectRatio = imageDimensions.width / imageDimensions.height;
        final screenAspectRatio = screenSize.width / screenSize.height;
        
        double scaleX, scaleY, offsetX = 0, offsetY = 0;
        
        if (imageAspectRatio > screenAspectRatio) {
          // Image is wider - will have top/bottom letterboxing
          scaleX = screenSize.width / imageDimensions.width;
          scaleY = scaleX; // Maintain aspect ratio
          final displayedHeight = imageDimensions.height * scaleY;
          offsetY = (screenSize.height - displayedHeight) / 2;
        } else {
          // Image is taller - will have left/right letterboxing
          scaleY = screenSize.height / imageDimensions.height;
          scaleX = scaleY; // Maintain aspect ratio
          final displayedWidth = imageDimensions.width * scaleX;
          offsetX = (screenSize.width - displayedWidth) / 2;
        }
        
        // Scale bbox coordinates from image space to screen space
        final x = (bbox[0] * scaleX) + offsetX;
        final y = (bbox[1] * scaleY) + offsetY;
        final width = bbox[2] * scaleX;
        final height = bbox[3] * scaleY;
        
        return Positioned(
          left: x,
          top: y,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.green,
                width: 2,
              ),
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Transform.translate(
                offset: const Offset(0, -25),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${detection.name} ${(detection.confidence * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
