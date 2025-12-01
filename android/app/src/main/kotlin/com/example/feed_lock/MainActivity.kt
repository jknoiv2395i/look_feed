package com.example.feed_lock

import android.content.ComponentName
import android.content.Context
import android.content.SharedPreferences
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.feed_lock/service"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "updateKeywords") {
                val positive = call.argument<List<String>>("positive")
                val negative = call.argument<List<String>>("negative")
                
                if (positive != null && negative != null) {
                    saveKeywords(positive, negative)
                    result.success(true)
                } else {
                    result.error("INVALID_ARGS", "Keywords cannot be null", null)
                }
            } else if (call.method == "openAccessibilitySettings") {
                val intent = android.content.Intent(android.provider.Settings.ACTION_ACCESSIBILITY_SETTINGS)
                startActivity(intent)
                result.success(true)
            } else if (call.method == "isAccessibilityServiceEnabled") {
                result.success(isAccessibilityServiceEnabled(context))
            } else if (call.method == "openUsageAccessSettings") {
                val intent = android.content.Intent(android.provider.Settings.ACTION_USAGE_ACCESS_SETTINGS)
                startActivity(intent)
                result.success(true)
            } else if (call.method == "isUsageAccessGranted") {
                result.success(isUsageAccessGranted(context))
            } else {
                result.notImplemented()
            }
        }
    }

    private fun saveKeywords(positive: List<String>, negative: List<String>) {
        val sharedPref: SharedPreferences = getSharedPreferences("FeedLockPrefs", Context.MODE_PRIVATE)
        val editor = sharedPref.edit()
        editor.putStringSet("positive_keywords", positive.toSet())
        editor.putStringSet("negative_keywords", negative.toSet())
        editor.apply()
    }

    private fun isAccessibilityServiceEnabled(context: Context): Boolean {
        val expectedComponentName = ComponentName(context, FeedAccessibilityService::class.java)
        val enabledServicesSetting = android.provider.Settings.Secure.getString(
            context.contentResolver,
            android.provider.Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false

        val colonSplitter = android.text.TextUtils.SimpleStringSplitter(':')
        colonSplitter.setString(enabledServicesSetting)

        while (colonSplitter.hasNext()) {
            val componentNameString = colonSplitter.next()
            val enabledComponent = ComponentName.unflattenFromString(componentNameString)
            if (enabledComponent != null && enabledComponent == expectedComponentName) {
                return true
            }
        }
        return false
    }

    private fun isUsageAccessGranted(context: Context): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as android.app.AppOpsManager
        val mode = appOps.checkOpNoThrow(
            android.app.AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            context.packageName
        )
        return mode == android.app.AppOpsManager.MODE_ALLOWED
    }
}
