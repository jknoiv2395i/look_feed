import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _checkAuthStatus();
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  UserEntity? currentUser;
  AuthStatus authStatus = AuthStatus.initial;
  String? errorMessage;

  // Get the current token for API calls if needed (though we are moving to Firestore)
  String? get token => null; // Not needed for Firestore direct access

  Future<void> login(String email, String password) async {
    authStatus = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _updateUser(credential.user);
      authStatus = AuthStatus.authenticated;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      authStatus = AuthStatus.unauthenticated;
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
      final UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (name != null && credential.user != null) {
        await credential.user!.updateDisplayName(name);
        await credential.user!.reload();
        _updateUser(_firebaseAuth.currentUser);
      } else {
        _updateUser(credential.user);
      }
      
      authStatus = AuthStatus.authenticated;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      authStatus = AuthStatus.unauthenticated;
    } catch (e) {
      errorMessage = e.toString();
      authStatus = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    currentUser = null;
    authStatus = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void _checkAuthStatus() {
    _firebaseAuth.authStateChanges().listen((User? user) {
      _updateUser(user);
      authStatus = user == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated;
      notifyListeners();
    });
  }

  void _updateUser(User? firebaseUser) {
    if (firebaseUser == null) {
      currentUser = null;
    } else {
      currentUser = UserEntity(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName,
      );
    }
  }
}
