import 'package:flutter/foundation.dart';

import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  AuthProvider({required this.authRepository});

  final AuthRepository authRepository;

  UserEntity? currentUser;
  AuthStatus authStatus = AuthStatus.initial;
  String? errorMessage;

  Future<void> login(String email, String password) async {
    authStatus = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final UserEntity user = await authRepository.login(email, password);
      currentUser = user;
      authStatus = AuthStatus.authenticated;
    } catch (e) {
      errorMessage = e.toString();
      authStatus = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<void> register(String email, String password, String? name) async {
    authStatus = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final UserEntity user = await authRepository.register(
        email,
        password,
        name,
      );
      currentUser = user;
      authStatus = AuthStatus.authenticated;
    } catch (e) {
      errorMessage = e.toString();
      authStatus = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<void> logout() async {
    await authRepository.logout();
    currentUser = null;
    authStatus = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final UserEntity? user = await authRepository.getCurrentUser();
    currentUser = user;
    authStatus = user == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    notifyListeners();
  }
}
