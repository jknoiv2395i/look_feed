import '../utils/validators.dart';

extension StringExtensions on String? {
  String capitalize() {
    final String? value = this;
    if (value == null || value.isEmpty) {
      return '';
    }
    return value[0].toUpperCase() + value.substring(1);
  }

  bool isValidEmail() {
    return Validators.isValidEmail(this);
  }

  String truncate([int maxLength = 30]) {
    final String? value = this;
    if (value == null || value.length <= maxLength) {
      return value ?? '';
    }
    return value.substring(0, maxLength - 1) + '…';
  }
}
