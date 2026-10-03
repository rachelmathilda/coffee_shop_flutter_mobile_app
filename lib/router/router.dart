import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/auth/sign_up_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/custom_coffee/custom_coffee_screen.dart';
import '../screens/delivery/address_detail_screen.dart';
import '../screens/delivery/delivery_screen.dart';
import '../screens/home/main_shell.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/onboarding/splash_screen.dart';
import '../screens/payment/payment_screen.dart';
import '../screens/product/product_detail_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/email_recovery_screen.dart';
import '../screens/profile/language_screen.dart';
import '../screens/profile/otp_screen.dart';
import '../screens/transaction/fail_screen.dart';
import '../screens/transaction/success_screen.dart';

class _AuthRefresh extends ChangeNotifier {
  late final StreamSubscription<User?> _sub;
  _AuthRefresh() {
    _sub = FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

const _publicPaths = {
  '/splash',
  '/onboarding',
  '/auth/sign-in',
  '/auth/sign-up',
  '/auth/recovery',
};

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefresh();
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final path = state.matchedLocation;
      if (!loggedIn && !_publicPaths.contains(path)) return '/auth/sign-in';
      if (loggedIn && (path == '/auth/sign-in' || path == '/auth/sign-up')) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/auth/sign-in', builder: (_, _) => const SignInScreen()),
      GoRoute(path: '/auth/sign-up', builder: (_, _) => const SignUpScreen()),
      GoRoute(
        path: '/auth/recovery',
        builder: (_, _) => const EmailRecoveryScreen(changeMode: false),
      ),
      GoRoute(path: '/home', builder: (_, _) => const MainShell()),
      GoRoute(
        path: '/product',
        builder: (_, state) => ProductDetailScreen(coffee: state.extra as Coffee),
      ),
      GoRoute(path: '/cart', builder: (_, _) => const CartScreen()),
      GoRoute(path: '/custom-coffee', builder: (_, _) => const CustomCoffeeScreen()),
      GoRoute(path: '/delivery', builder: (_, _) => const DeliveryScreen()),
      GoRoute(
        path: '/address-detail',
        builder: (_, state) => AddressDetailScreen(initial: state.extra as DeliveryAddress?),
      ),
      GoRoute(path: '/payment', builder: (_, _) => const PaymentScreen()),
      GoRoute(path: '/transaction/success', builder: (_, _) => const SuccessScreen()),
      GoRoute(path: '/transaction/fail', builder: (_, _) => const FailScreen()),
      GoRoute(path: '/profile/edit', builder: (_, _) => const EditProfileScreen()),
      GoRoute(path: '/profile/language', builder: (_, _) => const LanguageScreen()),
      GoRoute(
        path: '/profile/recovery',
        builder: (_, _) => const EmailRecoveryScreen(changeMode: true),
      ),
      GoRoute(path: '/profile/otp', builder: (_, _) => const OtpScreen()),
      GoRoute(
        path: '/profile/new-password',
        builder: (_, _) => const ChangePasswordScreen(),
      ),
    ],
  );
});
