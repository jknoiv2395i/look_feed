import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/storage_keys.dart';
import '../../data/datasources/local/storage_service.dart';
import '../../data/services/native_service.dart';

class KeywordProvider extends ChangeNotifier {
  KeywordProvider()
      : _storageService = StorageService(),
        _nativeService = NativeService();

  final StorageService _storageService;
  final NativeService _nativeService;

  final List<String> positiveKeywords = <String>[];
  final List<String> negativeKeywords = <String>[];
  
  bool isLoading = false;

  Future<void> fetchKeywords() async {
    isLoading = true;
    notifyListeners();

    try {
      // Load Positive
      final String? rawPos = await _storageService.getString('positive_keywords');
      if (rawPos != null) {
        final List<dynamic> decoded = jsonDecode(rawPos) as List<dynamic>;
        positiveKeywords
          ..clear()
          ..addAll(decoded.cast<String>());
      }

      // Load Negative
      final String? rawNeg = await _storageService.getString('negative_keywords');
      if (rawNeg != null) {
        final List<dynamic> decoded = jsonDecode(rawNeg) as List<dynamic>;
        negativeKeywords
          ..clear()
          ..addAll(decoded.cast<String>());
      }
      
      // Sync with Native on load
      await _syncToNative();
      
    } catch (_) {
      // Ignore errors
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _saveKeywords() async {
    try {
      await _storageService.saveString(
        'positive_keywords',
        jsonEncode(positiveKeywords),
      );
      await _storageService.saveString(
        'negative_keywords',
        jsonEncode(negativeKeywords),
      );
      await _syncToNative();
    } catch (_) {
      // Ignore errors
    }
  }
  
  Future<void> _syncToNative() async {
    await _nativeService.updateKeywords(
      positive: positiveKeywords, 
      negative: negativeKeywords
    );
  }

  void addKeyword(String keyword, {bool isPositive = false}) {
    if (isPositive) {
       if (!positiveKeywords.contains(keyword)) positiveKeywords.add(keyword);
    } else {
       if (!negativeKeywords.contains(keyword)) negativeKeywords.add(keyword);
    }
    _saveKeywords();
    notifyListeners();
  }

  void removeKeyword(String keyword, {bool isPositive = false}) {
    if (isPositive) {
      positiveKeywords.remove(keyword);
    } else {
      negativeKeywords.remove(keyword);
    }
    _saveKeywords();
    notifyListeners();
  }
}
