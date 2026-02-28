import 'package:flutter/material.dart';
import '../models/detection.dart';

class DetectionOverlay extends StatelessWidget {
  final List<Detection> detections;
  final Size screenSize;
  
  const DetectionOverlay({
    super.key,
    required this.detections,
    required this.screenSize,
  });
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: detections.map((detection) {
        final bbox = detection.bbox;
        final x = bbox[0];
        final y = bbox[1];
        final width = bbox[2];
        final height = bbox[3];
        
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
