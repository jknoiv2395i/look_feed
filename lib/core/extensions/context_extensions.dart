import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> showLoadingDialog({String message = 'Loading...'}) async {
    await showDialog<void>(
      context: this,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 16),
              Flexible(child: Text(message)),
            ],
          ),
        );
      },
    );
  }

  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }

  Future<T?> navigate<T>(Widget page) {
    return Navigator.of(
      this,
    ).push<T>(MaterialPageRoute<T>(builder: (_) => page));
  }
}
