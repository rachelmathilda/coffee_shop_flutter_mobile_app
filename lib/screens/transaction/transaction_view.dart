import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';

class TransactionView extends ConsumerWidget {
  final bool success;
  const TransactionView({super.key, required this.success});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(stringsProvider);
    final bg = success ? Colors.white : AppColors.failBg;
    final fg = success ? Colors.black : Colors.white;
    final rings = success
        ? const [Color(0xFFF8F5EE), Color(0xFFD6D0B5), Color(0xFFB3AD94)]
        : const [Color(0xFFD8D3BC), Color(0xFFF7F4EC), Colors.white];

    void goHome() {
      ref.read(tabIndexProvider.notifier).state = 0;
      context.go('/home');
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) goHome();
      },
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 5),
              Text(
                success ? t('successTransaction') : t('failTransaction'),
                textAlign: TextAlign.center,
                style: AppText.s(32, color: fg, height: 1.2),
              ),
              const SizedBox(height: 40),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(shape: BoxShape.circle, color: rings[0]),
                alignment: Alignment.center,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: rings[1]),
                  alignment: Alignment.center,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: rings[2]),
                    alignment: Alignment.center,
                    child: Icon(
                      success ? Icons.check : Icons.close,
                      size: 46,
                      color: success ? AppColors.charcoal : const Color(0xFF1E1E1E),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 34),
              Text(
                success ? t('successMessage') : t('failMessage'),
                textAlign: TextAlign.center,
                style: AppText.s(20, color: fg),
              ),
              const Spacer(flex: 3),
              IconButton(
                onPressed: goHome,
                iconSize: 40,
                icon: Icon(Icons.home_rounded, color: success ? AppColors.charcoal : Colors.white),
              ),
              const Spacer(flex: 4),
            ],
          ),
        ),
      ),
    );
  }
}
