import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../screens/onboarding/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/auth/sign_up_screen.dart';
import '../screens/auth/email_recovery_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/change_password_screen.dart';
import '../screens/catalog/catalog_screen.dart';
import '../screens/product/product_detail_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/custom_coffee/custom_coffee_screen.dart';
import '../screens/transaction/success_screen.dart';
import '../screens/transaction/fail_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/language_screen.dart';
import '../screens/discount/discount_screen.dart';
import '../models/models.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute =
          state.matchedLocation.startsWith('/auth') ||
          state.matchedLocation == '/splash' ||
          state.matchedLocation == '/onboarding';
      if (!isLoggedIn && !isAuthRoute) return '/auth/sign-in';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(path: '/auth/sign-in', builder: (_, __) => const SignInScreen()),
      GoRoute(path: '/auth/sign-up', builder: (_, __) => const SignUpScreen()),
      GoRoute(
        path: '/auth/recovery',
        builder: (_, __) => const EmailRecoveryScreen(),
      ),
      GoRoute(path: '/auth/otp', builder: (_, __) => const OtpScreen()),
      GoRoute(
        path: '/auth/change-password',
        builder: (_, __) => const ChangePasswordScreen(),
      ),
      GoRoute(path: '/catalog', builder: (_, __) => const CatalogScreen()),
      GoRoute(
        path: '/product/:id',
        builder: (_, state) {
          final coffee = state.extra as Coffee;
          return ProductDetailScreen(coffee: coffee);
        },
      ),
      GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
      GoRoute(
        path: '/custom-coffee',
        builder: (_, __) => const CustomCoffeeScreen(),
      ),
      GoRoute(
        path: '/transaction/success',
        builder: (_, __) => const SuccessScreen(),
      ),
      GoRoute(
        path: '/transaction/fail',
        builder: (_, __) => const FailScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/language',
        builder: (_, __) => const LanguageScreen(),
      ),
      GoRoute(path: '/discount', builder: (_, __) => const DiscountScreen()),
    ],
  );
});
