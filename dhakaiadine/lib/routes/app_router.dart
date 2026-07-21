import 'package:flutter/material.dart';

import '../features/cart/cart_screen.dart';
import '../features/checkout/checkout_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../features/menu/food_details_screen.dart';
import '../features/orders/order_confirmation_screen.dart';
import '../features/orders/order_tracking_screen.dart';
import '../features/search/search_screen.dart';
import '../models/food_model.dart';
import '../models/order_model.dart';
import '../features/admin/screens/admin_shell.dart';
import '../features/admin/screens/role_guard.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/screens/order_history_screen.dart';
import '../features/profile/screens/reviews_screen.dart';
import '../features/profile/screens/saved_addresses_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/profile/screens/notification_screen.dart';
import '../features/profile/screens/help_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/entryPoint/entry_point.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/error404_screen.dart';
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
  static const String favorites = '/favorites';
  static const String search = '/search';
  static const String profile = '/profile';
  static const String orderHistory = '/order-history';
  static const String reviews = '/reviews';
  static const String savedAddresses = '/saved-addresses';
  static const String editProfile = '/edit-profile';
  static const String notifications = '/notifications';
  static const String help = '/help';
  static const String adminDashboard = '/admin-dashboard';
  static const String error404 = '/404';

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
      case favorites:
        return buildFadeSlideRoute(const FavoritesScreen());
      case search:
        return buildFadeSlideRoute(const SearchScreen());
      case profile:
        return buildFadeSlideRoute(const ProfileScreen());
      case orderHistory:
        return buildFadeSlideRoute(const OrderHistoryScreen());
      case reviews:
        return buildFadeSlideRoute(const ReviewsScreen());
      case savedAddresses:
        return buildFadeSlideRoute(const SavedAddressesScreen());
      case editProfile:
        return buildFadeSlideRoute(const EditProfileScreen());
      case notifications:
        return buildFadeSlideRoute(const NotificationScreen());
      case help:
        return buildFadeSlideRoute(const HelpScreen());
      case adminDashboard:
        return buildFadeSlideRoute(const RoleGuard(child: AdminShell()));
      case error404:
        return buildFadeSlideRoute(const Error404Screen());
      default:
        return buildFadeSlideRoute(const Error404Screen());
    }
  }
}
