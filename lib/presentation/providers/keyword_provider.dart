import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/storage_keys.dart';
import '../../data/datasources/local/storage_service.dart';

class KeywordProvider extends ChangeNotifier {
  KeywordProvider() : _storageService = StorageService();

  final StorageService _storageService;

  final List<String> keywords = <String>[];
  bool isLoading = false;
  int keywordLimit = AppConstants.freeTierKeywordLimit;

  Future<void> fetchKeywords() async {
    isLoading = true;
    notifyListeners();

    try {
      final String? raw = await _storageService.getString(StorageKeys.keywords);
      if (raw != null) {
        final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
        keywords
          ..clear()
          ..addAll(decoded.cast<String>());
      }
    } catch (_) {
      // Ignore corrupted storage and fall back to empty list.
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _saveKeywords() async {
    try {
      await _storageService.saveString(
        StorageKeys.keywords,
        jsonEncode(keywords),
      );
    } catch (_) {
      // Ignore storage errors for now.
    }
  }

  void addKeyword(String keyword) {
    if (keywords.length >= keywordLimit) {
      return;
    }
    keywords.add(keyword);
    _saveKeywords();
    notifyListeners();
  }

  void removeKeyword(String keyword) {
    keywords.remove(keyword);
    _saveKeywords();
    notifyListeners();
  }
}
