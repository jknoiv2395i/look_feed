import 'package:flutter/material.dart';

import '../presentation/screens/auth/forgot_password_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/exercise/exercise_screen.dart';
import '../presentation/screens/home/home_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String exercise = '/exercise';

  static Map<String, WidgetBuilder> get routes => <String, WidgetBuilder>{
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),
    home: (_) => const HomeScreen(),
    exercise: (_) => const ExerciseScreen(),
  };
}
