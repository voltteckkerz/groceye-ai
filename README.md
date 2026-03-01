# 🛒 GrocEye – Grocery Items Identifier for Blind People

GrocEye is an AI-powered mobile application designed to assist visually impaired individuals in identifying grocery items through real-time object detection and text recognition.

Built using **Flutter**, **TensorFlow Lite**, and **Text-to-Speech (TTS)**, the app enables users to scan products and receive instant audio feedback — helping them shop more independently.

---

## 📱 Key Features

### 🔍 Dual Detection Mode
- **Item Mode** – Detects grocery products using object recognition.
- **Label Mode** – Reads product labels using OCR text detection.

Users can switch modes using gestures:
- Swipe Right → Item Mode
- Swipe Left → Label Mode

---

### 🧠 AI-Powered Recognition
- Uses TensorFlow Lite models for:
  - Grocery type detection
  - Brand identification
- Real-time camera processing

---

### 🔊 Audio Feedback
- Identified items are spoken aloud using Text-to-Speech
- Adjustable speech rate available in Settings

---

### ✋ Accessibility Gesture Controls
- Double tap → Pause / Resume detection
- Swipe gestures → Mode switching
- Designed for blind-friendly interaction

---

### 🌐 Multi-Language Support
Users can change language directly from the Home Page.

---

### 💾 Saved Items
Detected items can be stored and reviewed later via the Saved Page.

---

### 📖 Built-in Tutorial
Step-by-step guidance available for first-time users.

---

## 🏗️ Tech Stack

| Technology | Usage |
|---|---|
| Flutter | Mobile UI Framework |
| TensorFlow Lite | Object Detection |
| OCR | Text Recognition |
| Text-to-Speech | Audio Output |

---

## 📂 Project Structure

```
lib/
 ├── models/
 │   ├── detection.dart
 │   ├── recognized_text.dart
 │   ├── saved_item.dart
 │   └── scan_mode.dart
 │
 ├── screens/
 │   ├── camera_screen.dart
 │   ├── home_screen.dart
 │   ├── favorites_screen.dart
 │   ├── info_screen.dart
 │   ├── item_detail_screen.dart
 │   ├── onboarding_screen.dart
 │   └── settings_screen.dart
 │
 ├── services/
 │   ├── audio_service.dart
 │   ├── favorites_service.dart
 │   ├── language_service.dart
 │   ├── settings_service.dart
 │   ├── text_recognition_service.dart
 │   └── tflite_service.dart
 │
 ├── widgets/
 │   ├── control_button.dart
 │   ├── detection_overlay.dart
 │   ├── mode_toggle_switch.dart
 │   └── text_overlay.dart
 │
 └── main.dart
```

```
assets/
 ├── icons/
 │   └── app_icon.png
 │
 └── models/
     ├── grocery_type_yolo.tflite
     ├── bread_brand_cnn.tflite
     ├── canned_food_brand_cnn.tflite
     ├── chili_sauce_brand_cnn.tflite
     ├── ketchup_brand_cnn.tflite
     ├── soy_sauce_brand_cnn.tflite
     └── labels.txt files
```

---

## 🚀 How It Works

1. User opens Scanner
2. Select detection mode (Item / Label)
3. Camera analyzes object
4. AI processes image
5. System identifies item
6. Audio feedback announces result

---

## 🎯 Project Objective

To enhance independence and accessibility for visually impaired individuals by providing a smart grocery identification assistant powered by AI.

---

## 👨‍💻 Developed As

Final Year Project  
Bachelor of Information Technology

---

## 🔮 Future Improvements
- Barcode scanning
- Expiry date detection
- Nutrition label reading
- Cloud-based model updates

---

## 📌 License
This project is developed for academic purposes.
