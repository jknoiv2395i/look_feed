import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NativeService {
  static const MethodChannel _channel = MethodChannel('com.example.feed_lock/service');

  Future<void> updateKeywords({
    required List<String> positive,
    required List<String> negative,
  }) async {
    if (kIsWeb) return; // No-op on web
    try {
      await _channel.invokeMethod('updateKeywords', {
        'positive': positive,
        'negative': negative,
      });
    } on PlatformException catch (e) {
      print("Failed to update keywords: '${e.message}'.");
    }
  }

  Future<void> openAccessibilitySettings() async {
    if (kIsWeb) return; // No-op on web
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } on PlatformException catch (e) {
      print("Failed to open settings: '${e.message}'.");
    }
  }

  Future<bool> isServiceEnabled() async {
    if (kIsWeb) return false;
    try {
      final bool result = await _channel.invokeMethod('isAccessibilityServiceEnabled');
      return result;
    } on PlatformException catch (e) {
      print("Failed to check service status: '${e.message}'.");
      return false;
    }
  }

  Future<void> openUsageAccessSettings() async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod('openUsageAccessSettings');
    } on PlatformException catch (e) {
      print("Failed to open usage settings: '${e.message}'.");
    }
  }

  Future<bool> isUsageAccessGranted() async {
    if (kIsWeb) return false;
    try {
      final bool result = await _channel.invokeMethod('isUsageAccessGranted');
      return result;
    } on PlatformException catch (e) {
      print("Failed to check usage access: '${e.message}'.");
      return false;
    }
  }
}
