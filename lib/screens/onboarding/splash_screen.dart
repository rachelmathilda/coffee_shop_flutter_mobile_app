import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final prefs = ref.read(prefsProvider);
    await Future.delayed(const Duration(milliseconds: 1800));
    final onboarded = prefs.getBool('onboarded') ?? false;
    final user = FirebaseAuth.instance.currentUser;
    String target;
    if (!onboarded) {
      target = '/onboarding';
    } else if (user == null) {
      target = '/auth/sign-in';
    } else if (!(prefs.getBool('remember') ?? true)) {
      await ref.read(authServiceProvider).signOut();
      ref.read(cartProvider.notifier).clear();
      target = '/auth/sign-in';
    } else {
      try {
        await ref.read(authServiceProvider).syncAccount();
      } catch (_) {}
      target = '/home';
    }
    if (mounted) context.go(target);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/icon.png', width: w * 0.82),
            const SizedBox(height: 8),
            Text('grind', style: AppText.s(48, weight: FontWeight.w800, color: AppColors.charcoal, height: 1)),
            const SizedBox(height: 8),
            Text('have a coffee day', style: AppText.s(20, weight: FontWeight.w300, color: AppColors.charcoal)),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
