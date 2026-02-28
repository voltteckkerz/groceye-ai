# 📱 Grocery Vision Flutter

A native Flutter object detection app with real-time camera processing and accessibility features.

## ✨ Features

- 📷 **Real-time Object Detection** using Roboflow API
- 🎯 **Visual Overlays** with bounding boxes and confidence scores
- 🔊 **Text-to-Speech** announcements for detected objects
- ⏸️ **Pause/Resume** controls for detection
- ♿ **Accessibility** features with screen reader support
- 🌙 **Dark Mode** UI

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Android Studio / Xcode
- Android device or iOS device

### Installation

1. **Clone or navigate to the project**:
   ```bash
   cd grocery_vision_flutter
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   # On connected Android device
   flutter run
   
   # On iOS device (macOS only)
   flutter run --device-id=<your-device-id>
   ```

## 📱 How to Use

1. **Grant Camera Permission** when prompted
2. **Point camera** at objects (controllers, groceries, etc.)
3. **Wait ~10 seconds** for detection to run
4. **Listen** for voice announcements
5. **Tap PAUSE** to stop detection temporarily
6. **Tap RESUME** to continue

## 🏗️ Project Structure

```
lib/
├── main.dart                    # App entry point
├── config/
│   └── app_config.dart         # Configuration & API keys
├── models/
│   └── detection.dart          # Detection data model
├── screens/
│   └── camera_screen.dart      # Main camera & detection screen
├── services/
│   ├── audio_service.dart      # TTS & audio feedback
│   └── roboflow_service.dart   # Roboflow API integration
└── widgets/
    ├── control_button.dart     # Pause/Resume button
    └── detection_overlay.dart  # Bounding box overlays
```

## 🔧 Configuration

Edit `lib/config/app_config.dart` to customize:

- **Detection interval** (default: 10 seconds)
- **Confidence threshold** (default: 0.5)
- **Speech rate** and cooldown
- **Roboflow API** credentials

## 📦 Dependencies

- **camera**: Camera preview and image capture
- **http**: API requests to Roboflow
- **flutter_tts**: Text-to-speech announcements
- **audioplayers**: Sound effects
- **permission_handler**: Runtime permissions

## 🎯 Roboflow Integration

This app uses Roboflow's Workflow API for object detection:

- **Workspace**: test-ix1ql
- **Workflow**: find-controllers
- **API**: Processes images and returns detections with bounding boxes

## 🚧 Future Enhancements

- [ ] On-device TensorFlow Lite models (offline detection)
- [ ] Custom object training
- [ ] Detection history
- [ ] Export detection logs
- [ ] Multiple language support

## 📄 License

This project is open source.

## 🙏 Credits

- Built with Flutter
- Object detection by Roboflow
