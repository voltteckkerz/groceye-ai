package com.groceryvision.grocery_vision_flutter

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.tensorflow.lite.Interpreter
import java.io.FileInputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.MappedByteBuffer
import java.nio.channels.FileChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.groceye/tflite"
    private var interpreter: Interpreter? = null
    private var labels: List<String> = emptyList()
    private var inputSize = 640 // Default YOLO size
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Set up MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    try {
                        // Load model
                        val modelBuffer = loadModelFile("models/model.tflite")
                        interpreter = Interpreter(modelBuffer)
                        
                        // Get input size from model
                        val inputShape = interpreter!!.getInputTensor(0).shape()
                        inputSize = inputShape[1] // Assuming square input
                        
                        // Load labels
                        labels = loadLabels("models/labels.txt")
                        
                        result.success(mapOf(
                            "success" to true,
                            "inputSize" to inputSize,
                            "numLabels" to labels.size
                        ))
                    } catch (e: Exception) {
                        result.error("INIT_ERROR", "Failed to initialize: ${e.message}", null)
                    }
                }
                
                "detectObjects" -> {
                    val imagePath = call.argument<String>("imagePath")
                    val threshold = call.argument<Double>("threshold") ?: 0.5
                    
                    if (imagePath == null) {
                        result.error("INVALID_ARGUMENT", "Image path is required", null)
                        return@setMethodCallHandler
                    }
                    
                    try {
                        val detections = runInference(imagePath, threshold)
                        result.success(detections)
                    } catch (e: Exception) {
                        result.error("INFERENCE_ERROR", "Detection failed: ${e.message}", null)
                    }
                }
                
                "dispose" -> {
                    interpreter?.close()
                    interpreter = null
                    result.success(true)
                }
                
                else -> result.notImplemented()
            }
        }
    }
    
    private fun loadModelFile(modelPath: String): MappedByteBuffer {
        val assetFileDescriptor = assets.openFd(modelPath)
        val inputStream = FileInputStream(assetFileDescriptor.fileDescriptor)
        val fileChannel = inputStream.channel
        val startOffset = assetFileDescriptor.startOffset
        val declaredLength = assetFileDescriptor.declaredLength
        return fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength)
    }
    
    private fun loadLabels(labelPath: String): List<String> {
        return assets.open(labelPath).bufferedReader().use { it.readText() }
            .split("\n")
            .map { it.trim() }
            .filter { it.isNotEmpty() }
    }
    
    private fun runInference(imagePath: String, threshold: Double): List<Map<String, Any>> {
        if (interpreter == null) {
            throw Exception("Model not initialized")
        }
        
        // Load and preprocess image
        val bitmap = BitmapFactory.decodeFile(imagePath)
        val resizedBitmap = Bitmap.createScaledBitmap(bitmap, inputSize, inputSize, true)
        val input = preprocessImage(resizedBitmap)
        
        // Prepare output buffer
        // YOLO output shape: [1, num_predictions, num_classes + 5]
        val outputShape = interpreter!!.getOutputTensor(0).shape()
        val numPredictions = outputShape[1]
        val numValues = outputShape[2]
        
        val output = Array(1) { Array(numPredictions) { FloatArray(numValues) } }
        
        // Run inference
        interpreter!!.run(input, output)
        
        // Parse results
        return parseYOLOOutput(output[0], threshold, bitmap.width, bitmap.height)
    }
    
    private fun preprocessImage(bitmap: Bitmap): ByteBuffer {
        val byteBuffer = ByteBuffer.allocateDirect(4 * inputSize * inputSize * 3)
        byteBuffer.order(ByteOrder.nativeOrder())
        
        val intValues = IntArray(inputSize * inputSize)
        bitmap.getPixels(intValues, 0, bitmap.width, 0, 0, bitmap.width, bitmap.height)
        
        var pixel = 0
        for (i in 0 until inputSize) {
            for (j in 0 until inputSize) {
                val value = intValues[pixel++]
                // Normalize to 0-1
                byteBuffer.putFloat(((value shr 16) and 0xFF) / 255.0f)
                byteBuffer.putFloat(((value shr 8) and 0xFF) / 255.0f)
                byteBuffer.putFloat((value and 0xFF) / 255.0f)
            }
        }
        
        return byteBuffer
    }
    
    private fun parseYOLOOutput(
        output: Array<FloatArray>,
        threshold: Double,
        imageWidth: Int,
        imageHeight: Int
    ): List<Map<String, Any>> {
        val detections = mutableListOf<Map<String, Any>>()
        
        for (prediction in output) {
            // YOLO format: [x_center, y_center, width, height, objectness, class_scores...]
            val xCenter = prediction[0]
            val yCenter = prediction[1]
            val width = prediction[2]
            val height = prediction[3]
            val objectness = prediction[4]
            
            // Find class with highest score
            var maxScore = 0f
            var maxClassId = 0
            
            for (i in 5 until prediction.size) {
                if (prediction[i] > maxScore) {
                    maxScore = prediction[i]
                    maxClassId = i - 5
                }
            }
            
            // Overall confidence = objectness * class_score
            val confidence = objectness * maxScore
            
            if (confidence >= threshold) {
                // Convert normalized coordinates to pixel coordinates
                val xCenterPx = xCenter * imageWidth
                val yCenterPx = yCenter * imageHeight
                val widthPx = width * imageWidth
                val heightPx = height * imageHeight
                
                // Convert to top-left coordinates
                val xLeft = xCenterPx - (widthPx / 2)
                val yTop = yCenterPx - (heightPx / 2)
                
                val label = if (maxClassId < labels.size) labels[maxClassId] else "unknown"
                
                detections.add(mapOf(
                    "name" to label,
                    "confidence" to confidence.toDouble(),
                    "x" to xLeft.toDouble(),
                    "y" to yTop.toDouble(),
                    "width" to widthPx.toDouble(),
                    "height" to heightPx.toDouble()
                ))
            }
        }
        
        return detections
    }
}
