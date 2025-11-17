import 'package:flutter/foundation.dart';

class KeywordProvider extends ChangeNotifier {
  final List<String> keywords = <String>[];
  bool isLoading = false;
  int keywordLimit = 1;

  Future<void> fetchKeywords() async {
    isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    isLoading = false;
    notifyListeners();
  }

  void addKeyword(String keyword) {
    if (keywords.length >= keywordLimit) {
      return;
    }
    keywords.add(keyword);
    notifyListeners();
  }

  void removeKeyword(String keyword) {
    keywords.remove(keyword);
    notifyListeners();
  }
}
