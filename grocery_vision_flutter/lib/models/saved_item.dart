import '../models/scan_mode.dart';

class SavedItem {
  final String id;
  final String name; // Primary label (first item)
  final List<String> allLabels; // All detected labels from the scan
  final ScanMode mode;
  final double? confidence; // Confidence for primary item (null for label mode)
  final List<double>? allConfidences; // Confidences for all items (null for label mode)
  final DateTime timestamp;
  bool isFavorite;

  SavedItem({
    required this.id,
    required this.name,
    List<String>? allLabels,
    required this.mode,
    this.confidence,
    this.allConfidences,
    required this.timestamp,
    this.isFavorite = false,
  }) : allLabels = allLabels ?? [name];

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'allLabels': allLabels,
      'mode': mode.name,
      'confidence': confidence,
      'allConfidences': allConfidences,
      'timestamp': timestamp.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  // JSON deserialization
  factory SavedItem.fromJson(Map<String, dynamic> json) {
    return SavedItem(
      id: json['id'],
      name: json['name'],
      allLabels: json['allLabels'] != null 
          ? List<String>.from(json['allLabels'])
          : [json['name']], // Backward compatibility
      mode: ScanMode.values.firstWhere((e) => e.name == json['mode']),
      confidence: json['confidence'],
      allConfidences: json['allConfidences'] != null
          ? List<double>.from(json['allConfidences'])
          : null,
      timestamp: DateTime.parse(json['timestamp']),
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  // Copy with
  SavedItem copyWith({
    String? id,
    String? name,
    List<String>? allLabels,
    ScanMode? mode,
    double? confidence,
    List<double>? allConfidences,
    DateTime? timestamp,
    bool? isFavorite,
  }) {
    return SavedItem(
      id: id ?? this.id,
      name: name ?? this.name,
      allLabels: allLabels ?? this.allLabels,
      mode: mode ?? this.mode,
      confidence: confidence ?? this.confidence,
      allConfidences: allConfidences ?? this.allConfidences,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
