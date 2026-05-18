import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/splash/splash_screen.dart';
import 'app_transitions.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return buildSlideFadeRoute(const SplashScreen());
      case onboarding:
        return buildSlideFadeRoute(const OnboardingScreen());
      case login:
        return buildSlideFadeRoute(const LoginScreen());
      case register:
        return buildSlideFadeRoute(const RegisterScreen());
      case home:
        return buildSlideFadeRoute(const HomeScreen());
      default:
        return buildSlideFadeRoute(const SplashScreen());
    }
  }
}
