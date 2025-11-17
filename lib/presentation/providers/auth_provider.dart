import 'package:flutter/foundation.dart';

import '../../domain/entities/user_entity.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  UserEntity? currentUser;
  AuthStatus authStatus = AuthStatus.initial;
  String? errorMessage;

  Future<void> login(String email, String password) async {
    authStatus = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 500));

    currentUser = UserEntity(id: 'demo', email: email);
    authStatus = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> register(String email, String password, String? name) async {
    await login(email, password);
  }

  Future<void> logout() async {
    currentUser = null;
    authStatus = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    authStatus = currentUser == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    notifyListeners();
  }
}
