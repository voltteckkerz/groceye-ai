# Model Files Directory

This directory contains TensorFlow Lite models used for a **hierarchical multi-stage recognition pipeline**.

---

## 📁 Model Structure Overview

The system uses:
1. **One object detection model** for product type recognition
2. **Multiple category-specific brand classification models**

This design improves accuracy and scalability by limiting brand recognition to relevant product categories.

---

## 🔹 Stage 1: Product Type Detection (Global Model)

### Files
- **grocery_type_yolo.tflite**  
  Object detection model for identifying product categories.
- **grocery_type_labels.txt**  
  Product type labels (one per line).

### Output
- Product type
- Bounding box
- Confidence score

---

## 🔹 Stage 2: Brand Recognition (Category-Specific Models)

After detecting the product type, the system loads the corresponding brand model.

### Available Brand Models

#### Beverages
- **beverages_brand_cnn.tflite**
- **beverages_labels.txt**

#### Bread
- **bread_brand_cnn.tflite**
- **bread_labels.txt**

#### Canned Food
- **canned_food_brand_cnn.tflite**
- **canned_food_labels.txt**

#### Chili Sauce
- **chili_sauce_brand_cnn.tflite**
- **chili_sauce_labels.txt**

#### Soy Sauce
- **soy_sauce_brand_cnn.tflite**
- **soy_sauce_labels.txt**

---

## 🔄 Inference Workflow

1. Capture image from camera
2. Run **product type detection**
3. Crop detected region
4. Select appropriate brand model based on detected type
5. Run **brand classification**
6. Output final result: **Product Type + Brand**

---

## 🚀 System Behavior

- Models are loaded dynamically based on detection results
- Only one brand model is active at a time
- This reduces memory usage and improves classification accuracy
