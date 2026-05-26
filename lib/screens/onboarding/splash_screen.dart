import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotateController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  late Animation<double> _rotateAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _textFadeAnim;

  @override
  void initState() {
    super.initState();

    // Mug slow rotate
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _rotateAnim = Tween<double>(begin: 0, end: 0.08).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );
    // Override with pendulum
    _rotateAnim =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: -0.05, end: 0.05), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.05, end: -0.05), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
        );

    // Fade in
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    // Scale bounce
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _scaleAnim = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _textFadeAnim = CurvedAnimation(
      parent: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..forward(from: 0),
      curve: Curves.easeOut,
    );

    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_seen') ?? false;
    if (!mounted) return;
    if (seen) {
      context.go('/auth/sign-in');
    } else {
      await prefs.setBool('onboarding_seen', true);
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnim,
                child: AnimatedBuilder(
                  animation: _rotateAnim,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotateAnim.value,
                      child: child,
                    );
                  },
                  child: Image.asset(
                    'assets/images/mug.png',
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeTransition(
                opacity: _fadeAnim,
                child: Image.asset(
                  'assets/images/splash_title.png',
                  width: 180,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
