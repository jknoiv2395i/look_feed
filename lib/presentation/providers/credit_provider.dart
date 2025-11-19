import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/constants/storage_keys.dart';
import '../../data/datasources/local/storage_service.dart';

class CreditProvider extends ChangeNotifier {
  CreditProvider() : _storageService = StorageService();

  final StorageService _storageService;

  int totalCredits = 0;
  bool isLoading = false;
  final List<int> transactions = <int>[];

  Timer? _countdownTimer;

  Future<void> fetchCredits() async {
    isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic>? json = await _storageService.getObject(
        StorageKeys.credits,
      );
      if (json != null) {
        totalCredits = (json['totalCredits'] as int?) ?? 0;
        final List<dynamic>? rawTx = json['transactions'] as List<dynamic>?;
        if (rawTx != null) {
          transactions
            ..clear()
            ..addAll(rawTx.cast<int>());
        }
      }
    } catch (_) {
      // Ignore corrupted storage and fall back to defaults.
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _saveCredits() async {
    try {
      await _storageService.saveObject(StorageKeys.credits, <String, dynamic>{
        'totalCredits': totalCredits,
        'transactions': transactions,
      });
    } catch (_) {
      // Ignore storage errors for now.
    }
  }

  void addCredits(int amount) {
    totalCredits += amount;
    transactions.insert(0, amount);
    _saveCredits();
    notifyListeners();
  }

  void startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (totalCredits > 0) {
        totalCredits--;
        _saveCredits();
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
