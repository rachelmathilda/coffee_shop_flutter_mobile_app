import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _images = [
    'assets/images/onboarding1.png',
    'assets/images/onboarding2.png',
    'assets/images/onboarding3.png',
  ];

  Future<void> _next() async {
    if (_page < 2) {
      _controller.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
      return;
    }
    await ref.read(prefsProvider).setBool('onboarded', true);
    if (mounted) context.go('/auth/sign-in');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(stringsProvider);
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: 3,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  return Column(
                    children: [
                      const Spacer(flex: 3),
                      Image.asset(_images[i], width: w * 0.86),
                      const Spacer(flex: 3),
                      Text(
                        t('ob${i + 1}Title'),
                        style: AppText.s(16, weight: FontWeight.w700),
                      ),
                      const SizedBox(height: 26),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          t('ob${i + 1}Desc'),
                          textAlign: TextAlign.center,
                          style: AppText.s(18, weight: FontWeight.w300, color: const Color(0xFF6F6F6F), spacing: 0.5),
                        ),
                      ),
                      const Spacer(flex: 2),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 0, 46, 40),
              child: Row(
                children: [
                  ...List.generate(3, (i) {
                    final active = i == _page;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 10),
                      width: active ? 72 : 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: active ? AppColors.charcoal : AppColors.sand,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                  const Spacer(),
                  Material(
                    color: AppColors.charcoal,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _next,
                      child: SizedBox(
                        width: 112,
                        height: 36,
                        child: Center(
                          child: Text(
                            _page == 2 ? t('start') : t('next'),
                            style: AppText.s(18, weight: FontWeight.w300, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
