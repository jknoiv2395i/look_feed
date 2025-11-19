import 'package:flutter/material.dart';

import '../presentation/screens/auth/forgot_password_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/exercise/exercise_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/keywords/keyword_manager_screen.dart';
import '../presentation/screens/onboarding/first_exercise_screen.dart';
import '../presentation/screens/onboarding/interests_screen.dart';
import '../presentation/screens/onboarding/onboarding_complete_screen.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String interests = '/interests';
  static const String firstExercise = '/first-exercise';
  static const String onboardingComplete = '/onboarding-complete';
  static const String home = '/home';
  static const String exercise = '/exercise';
  static const String keywords = '/keywords';

  static Map<String, WidgetBuilder> get routes => <String, WidgetBuilder>{
    splash: (_) => const SplashScreen(),
    onboarding: (_) => const OnboardingScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),
    interests: (_) => const InterestsScreen(),
    firstExercise: (_) => const FirstExerciseScreen(),
    onboardingComplete: (_) => const OnboardingCompleteScreen(),
    home: (_) => const HomeScreen(),
    exercise: (_) => const ExerciseScreen(),
    keywords: (_) => const KeywordManagerScreen(),
  };
}
