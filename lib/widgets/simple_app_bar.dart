import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class SimpleTopBar extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onBack;

  const SimpleTopBar({super.key, required this.title, this.trailing, this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(title, style: AppText.s(22, weight: FontWeight.w500)),
          Positioned(
            left: 14,
            child: IconButton(
              onPressed: onBack ?? () => context.canPop() ? context.pop() : context.go('/home'),
              icon: const Icon(Icons.arrow_back_ios_new, size: 22, color: Colors.black),
            ),
          ),
          if (trailing != null) Positioned(right: 14, child: trailing!),
        ],
      ),
    );
  }
}
