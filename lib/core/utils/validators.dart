class Validators {
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static bool isValidEmail(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    return _emailRegex.hasMatch(value.trim());
  }

  static bool isValidPassword(String? value) {
    if (value == null || value.length < 8) {
      return false;
    }
    final bool hasUppercase = value.contains(RegExp('[A-Z]'));
    final bool hasNumber = value.contains(RegExp('[0-9]'));
    return hasUppercase && hasNumber;
  }

  static bool isValidKeyword(String? value) {
    if (value == null) {
      return false;
    }
    final String trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > 100) {
      return false;
    }
    return RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(trimmed);
  }
}
