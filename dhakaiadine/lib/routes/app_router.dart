import 'package:flutter/material.dart';

import '../features/cart/cart_screen.dart';
import '../features/checkout/checkout_screen.dart';
import '../features/menu/food_details_screen.dart';
import '../features/orders/order_confirmation_screen.dart';
import '../features/orders/order_tracking_screen.dart';
import '../models/food_model.dart';
import '../models/order_model.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/entryPoint/entry_point.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/splash/splash_screen.dart';
import 'app_transitions.dart';
import 'route_transitions.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String foodDetails = '/food-details';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderConfirmation = '/order-confirmation';
  static const String orderTracking = '/order-tracking';

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
        return buildSlideFadeRoute(const EntryPoint());
      case foodDetails:
        final food = settings.arguments;
        if (food is FoodModel) {
          return buildFadeSlideRoute(FoodDetailsScreen(food: food));
        }
        return buildSlideFadeRoute(const SplashScreen());
      case cart:
        return buildFadeSlideRoute(const CartScreen());
      case checkout:
        return buildFadeSlideRoute(const CheckoutScreen());
      case orderConfirmation:
        final order = settings.arguments;
        if (order is OrderModel) {
          return buildFadeSlideRoute(OrderConfirmationScreen(order: order));
        }
        return buildSlideFadeRoute(const SplashScreen());
      case orderTracking:
        final order = settings.arguments;
        if (order is OrderModel) {
          return buildFadeSlideRoute(OrderTrackingScreen(order: order));
        }
        return buildSlideFadeRoute(const SplashScreen());
      default:
        return buildSlideFadeRoute(const SplashScreen());
    }
  }
}
