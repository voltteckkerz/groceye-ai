enum ScanMode {
  item,  // Object detection with Roboflow
  label  // Text recognition with OCR
}

extension ScanModeExtension on ScanMode {
  String get displayName {
    switch (this) {
      case ScanMode.item:
        return 'Item';
      case ScanMode.label:
        return 'Label';
    }
  }
  
  String get statusText {
    switch (this) {
      case ScanMode.item:
        return 'Detecting Objects';
      case ScanMode.label:
        return 'Reading Text';
    }
  }
}
