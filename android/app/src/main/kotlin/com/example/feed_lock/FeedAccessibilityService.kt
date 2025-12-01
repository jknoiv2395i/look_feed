package com.example.feed_lock

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.SharedPreferences
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.util.Log

class FeedAccessibilityService : AccessibilityService() {

    private var negativeKeywords: Set<String> = emptySet()
    private var positiveKeywords: Set<String> = emptySet()
    
    private val handler = android.os.Handler(android.os.Looper.getMainLooper())
    private var checkContentRunnable: Runnable? = null

    private var lastReelsPositiveTime: Long = 0
    private val STICKY_REELS_DURATION_MS = 10000L // 10 seconds memory

    // AI Components
    private var tflite: org.tensorflow.lite.Interpreter? = null
    private val fitnessIndices = setOf(
        418, 424, 432, 446, 545, 604, 640, 673, 704, 724, 749, 754, 770, 772, 797, 798, 807, 844, 854, 892, 983, 985
    )
    private var imageProcessor: org.tensorflow.lite.support.image.ImageProcessor? = null

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d("FeedLock", "Accessibility Service Connected")
        loadKeywords()
        initAI()
    }

    private fun loadKeywords() {
        val sharedPref: SharedPreferences = getSharedPreferences("FeedLockPrefs", Context.MODE_PRIVATE)
        positiveKeywords = sharedPref.getStringSet("positive_keywords", emptySet()) ?: emptySet()
        negativeKeywords = sharedPref.getStringSet("negative_keywords", emptySet()) ?: emptySet()
        Log.d("FeedLock", "Loaded Keywords - Positive: $positiveKeywords, Negative: $negativeKeywords")
    }

    private fun initAI() {
        try {
            val assetManager = assets
            val modelDescriptor = assetManager.openFd("mobilenet_v1_1.0_224_quant.tflite")
            val inputStream = java.io.FileInputStream(modelDescriptor.fileDescriptor)
            val fileChannel = inputStream.channel
            val startOffset = modelDescriptor.startOffset
            val declaredLength = modelDescriptor.declaredLength
            val modelBuffer = fileChannel.map(java.nio.channels.FileChannel.MapMode.READ_ONLY, startOffset, declaredLength)
            
            tflite = org.tensorflow.lite.Interpreter(modelBuffer)
            
            imageProcessor = org.tensorflow.lite.support.image.ImageProcessor.Builder()
                .add(org.tensorflow.lite.support.image.ops.ResizeOp(224, 224, org.tensorflow.lite.support.image.ops.ResizeOp.ResizeMethod.BILINEAR))
                .build()
                
            Log.d("FeedLock", "AI Model Loaded Successfully")
        } catch (e: Exception) {
            Log.e("FeedLock", "Failed to load AI model: ${e.message}")
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        try {
            if (event == null) return

            if (event.packageName == "com.instagram.android") {
                loadKeywords()
                
                checkContentRunnable?.let { handler.removeCallbacks(it) }
                
                checkContentRunnable = Runnable {
                    try {
                        val currentRoot = rootInActiveWindow
                        if (currentRoot != null) {
                            if (isReelsSection(currentRoot)) {
                                checkForUnwantedContent(currentRoot)
                            } else {
                                Log.d("FeedLock", "Not in Reels section. Skipping.")
                            }
                        }
                    } catch (e: Exception) {
                        Log.e("FeedLock", "Error in checkContentRunnable: ${e.message}")
                    }
                }
                
                // Reduced delay to 300ms for turbo speed
                handler.postDelayed(checkContentRunnable!!, 300)
            }
        } catch (e: Exception) {
            Log.e("FeedLock", "Error in onAccessibilityEvent: ${e.message}")
        }
    }

    private fun checkForUnwantedContent(rootNode: AccessibilityNodeInfo) {
        // 1. Text-Based Check (Fastest)
        if (positiveKeywords.isNotEmpty()) {
            val allText = StringBuilder()
            collectAllText(rootNode, allText)
            
            val screenContent = allText.toString().lowercase()
            var hasMatch = false
            
            for (keyword in positiveKeywords) {
                if (screenContent.contains(keyword.lowercase())) {
                    hasMatch = true
                    break
                }
            }
            
            if (hasMatch) {
                Log.d("FeedLock", "Text Match Found! Keeping content.")
                tryLikeContent(rootNode)
                return
            }
        }
        
        // 2. AI Visual Check (Fallback if text fails)
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
            Log.d("FeedLock", "Text failed. Attempting AI Visual Analysis...")
            takeScreenshot(
                android.view.Display.DEFAULT_DISPLAY,
                java.util.concurrent.Executors.newSingleThreadExecutor(),
                object : AccessibilityService.TakeScreenshotCallback {
                    override fun onSuccess(screenshot: AccessibilityService.ScreenshotResult) {
                        val bitmap = android.graphics.Bitmap.wrapHardwareBuffer(
                            screenshot.hardwareBuffer,
                            screenshot.colorSpace
                        )
                        
                        if (bitmap != null) {
                            // Copy to software bitmap for TFLite
                            val softwareBitmap = bitmap.copy(android.graphics.Bitmap.Config.ARGB_8888, true)
                            screenshot.hardwareBuffer.close()
                            
                            if (analyzeImage(softwareBitmap)) {
                                Log.d("FeedLock", "AI Detected Fitness! Keeping content.")
                                // Run on main thread to interact with UI
                                handler.post { tryLikeContent(rootNode) }
                            } else {
                                Log.d("FeedLock", "AI did NOT detect fitness. Scrolling...")
                                handler.post { performScroll(rootNode) }
                            }
                        } else {
                            Log.e("FeedLock", "Screenshot bitmap is null")
                            handler.post { performScroll(rootNode) }
                        }
                    }

                    override fun onFailure(errorCode: Int) {
                        Log.e("FeedLock", "Screenshot failed. Error: $errorCode")
                        handler.post { performScroll(rootNode) }
                    }
                }
            )
        } else {
            // Fallback for older Android versions
            Log.d("FeedLock", "No niche content found (Text). Scrolling...")
            performScroll(rootNode)
        }
    }

    private fun analyzeImage(bitmap: android.graphics.Bitmap): Boolean {
        if (tflite == null || imageProcessor == null) return false
        
        try {
            var tImage = org.tensorflow.lite.support.image.TensorImage(org.tensorflow.lite.DataType.UINT8)
            tImage.load(bitmap)
            tImage = imageProcessor!!.process(tImage)
            
            val probabilityBuffer = org.tensorflow.lite.support.tensorbuffer.TensorBuffer.createFixedSize(intArrayOf(1, 1001), org.tensorflow.lite.DataType.UINT8)
            tflite!!.run(tImage.buffer, probabilityBuffer.buffer.rewind())
            
            val probabilities = probabilityBuffer.intArray
            
            // Check if any fitness index has high probability
            // Since it's quantized uint8, values are 0-255. 
            // Let's say threshold is 30% -> 255 * 0.3 = 76
            val threshold = 76 
            
            var maxScore = 0
            var maxIndex = -1
            
            for (i in probabilities.indices) {
                if (probabilities[i] > maxScore) {
                    maxScore = probabilities[i]
                    maxIndex = i
                }
            }
            
            Log.d("FeedLock", "AI Top Prediction: Index $maxIndex, Score $maxScore")
            
            if (fitnessIndices.contains(maxIndex) && maxScore > threshold) {
                return true
            }
            
            // Also check top 3 to be safe? For now top 1 is enough for speed.
            
        } catch (e: Exception) {
            Log.e("FeedLock", "AI Analysis Failed: ${e.message}")
        }
        return false
    }

    private fun tryLikeContent(node: AccessibilityNodeInfo) {
        // Search for the "Like" button
        // Instagram Like button usually has contentDescription "Like" or "Double tap to like"
        // IMPORTANT: Avoid "Unlike" or "Liked" to prevent unliking.
        
        val desc = node.contentDescription?.toString() ?: ""
        val text = node.text?.toString() ?: ""
        
        // Check if this node is the Like button
        if (desc.equals("Like", ignoreCase = true) || desc.contains("Double tap to like", ignoreCase = true)) {
             // Double check it's not already liked
             if (!desc.contains("Unlike", ignoreCase = true) && !desc.contains("Liked", ignoreCase = true)) {
                 Log.d("FeedLock", "Found Like button. Clicking!")
                 val clicked = node.performAction(AccessibilityNodeInfo.ACTION_CLICK)
                 if (clicked) return // Stop searching if we clicked
             }
        }

        for (i in 0 until node.childCount) {
            val child = node.getChild(i)
            if (child != null) {
                tryLikeContent(child)
                child.recycle()
            }
        }
    }

    private fun collectAllText(node: AccessibilityNodeInfo, sb: StringBuilder) {
        if (node.text != null) {
            sb.append(node.text).append(" ")
        }
        if (node.contentDescription != null) {
            sb.append(node.contentDescription).append(" ")
        }
        for (i in 0 until node.childCount) {
            val child = node.getChild(i)
            if (child != null) {
                collectAllText(child, sb)
                child.recycle()
            }
        }
    }

    private fun checkNodeForNegative(node: AccessibilityNodeInfo) {
        if (node.text != null) {
            val text = node.text.toString().lowercase()
            for (keyword in negativeKeywords) {
                if (text.contains(keyword.lowercase())) {
                    Log.d("FeedLock", "Blocked content found: $text (Keyword: $keyword)")
                    performScroll(node)
                    return
                }
            }
        }
        for (i in 0 until node.childCount) {
            val child = node.getChild(i)
            if (child != null) {
                checkNodeForNegative(child)
                child.recycle()
            }
        }
    }

    private fun performScroll(rootNode: AccessibilityNodeInfo) {
        // Find the scrollable node (RecyclerView, ListView, ScrollView, etc.)
        // We search from the root down to find the first scrollable container.
        val scrollableNode = findScrollableNode(rootNode)
        
        if (scrollableNode != null) {
            Log.d("FeedLock", "Found scrollable node: ${scrollableNode.className}. Performing scroll.")
            scrollableNode.performAction(AccessibilityNodeInfo.ACTION_SCROLL_FORWARD)
            scrollableNode.recycle()
        } else {
            Log.d("FeedLock", "No scrollable node found!")
        }
    }

    private fun findScrollableNode(node: AccessibilityNodeInfo): AccessibilityNodeInfo? {
        if (node.isScrollable) {
            return node // Found it!
        }

        for (i in 0 until node.childCount) {
            val child = node.getChild(i)
            if (child != null) {
                val result = findScrollableNode(child)
                if (result != null) {
                    return result
                }
                child.recycle()
            }
        }
        return null
    }

    private fun isReelsSection(rootNode: AccessibilityNodeInfo): Boolean {
        val queue = java.util.ArrayDeque<AccessibilityNodeInfo>()
        queue.add(rootNode)
        
        var iterations = 0
        val maxIterations = 100
        
        var detectedHomeOrSearch = false
        
        while (!queue.isEmpty() && iterations < maxIterations) {
            val node = queue.poll() ?: continue
            iterations++
            
            val text = node.text?.toString() ?: ""
            val desc = node.contentDescription?.toString() ?: ""
            val isSelected = node.isSelected
            
            if (isSelected) {
                // Stricter checks for Home/Search to avoid false positives from captions
                if (text.equals("Home", ignoreCase = true) || desc.equals("Home", ignoreCase = true)) {
                    detectedHomeOrSearch = true
                }
                if (text.equals("Search", ignoreCase = true) || desc.equals("Search", ignoreCase = true) || desc.equals("Explore", ignoreCase = true)) {
                    detectedHomeOrSearch = true
                }
                
                if (text.equals("Reels", ignoreCase = true) || desc.equals("Reels", ignoreCase = true)) {
                    Log.d("FeedLock", "Detected Reels Section.")
                    lastReelsPositiveTime = System.currentTimeMillis()
                    return true
                }
            }
            
            for (i in 0 until node.childCount) {
                val child = node.getChild(i)
                if (child != null) {
                    queue.add(child)
                }
            }
        }
        
        // Sticky Logic: If we were in Reels recently, ignore Home/Search detection (assume flickering)
        if (System.currentTimeMillis() - lastReelsPositiveTime < STICKY_REELS_DURATION_MS) {
            Log.d("FeedLock", "Sticky Reels: Assuming still in Reels despite indicators.")
            return true
        }
        
        if (detectedHomeOrSearch) {
            Log.d("FeedLock", "Detected Home/Search and no sticky Reels state. Skipping.")
            return false
        }
        
        Log.d("FeedLock", "Could not detect specific section. Defaulting to TRUE (Reels).")
        return true
    }

    override fun onInterrupt() {
        Log.d("FeedLock", "Accessibility Service Interrupted")
    }
}
