# Model Files Directory

## Required Files

Please place your TensorFlow Lite model files here:

1. **`model.tflite`** - Your trained object detection model
2. **`labels.txt`** - Class labels (one per line)

## Labels Format Example

```txt
beverages
bread
canned_food
chili_sauce
cooking_oil
fruit
instant_noodle
ketchup
snack
soy_sauce
```

## Model Requirements

- **Type**: Object detection model (SSD MobileNet, YOLO, etc.)
- **Input**: Image (typically 300x300 or 640x640)
- **Output**: Bounding boxes + class IDs + confidence scores

Once you've added these files, the app will automatically load them on startup.
