import 'dart:async';

import 'package:flutter/foundation.dart';

class CreditProvider extends ChangeNotifier {
  int totalCredits = 0;
  bool isLoading = false;
  final List<int> transactions = <int>[];

  Timer? _countdownTimer;

  Future<void> fetchCredits() async {
    isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    isLoading = false;
    notifyListeners();
  }

  void addCredits(int amount) {
    totalCredits += amount;
    transactions.insert(0, amount);
    notifyListeners();
  }

  void startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (totalCredits > 0) {
        totalCredits--;
        notifyListeners();
      }
    });
  }

  void stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
