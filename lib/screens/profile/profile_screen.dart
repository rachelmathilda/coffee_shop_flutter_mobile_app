import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/avatar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    ref.read(cartProvider.notifier).clear();
    ref.read(lastCartKeyProvider.notifier).state = null;
    ref.read(deliveryAddressProvider.notifier).state = null;
    ref.read(tabIndexProvider.notifier).state = 0;
    await ref.read(authServiceProvider).signOut();
    if (context.mounted) context.go('/auth/sign-in');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(stringsProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;
    final points = NumberFormat.decimalPattern('id').format(user?.points ?? 0);
    final top = MediaQuery.of(context).padding.top;

    final items = <_MenuItem>[
      _MenuItem(Icons.edit_note_outlined, t('editProfile'), AppColors.textBrown, () => context.push('/profile/edit')),
      _MenuItem(Icons.password_outlined, t('changePassword'), AppColors.textBrown, () => context.push('/profile/recovery')),
      _MenuItem(Icons.language, t('language'), AppColors.textBrown, () => context.push('/profile/language')),
      _MenuItem(Icons.logout, t('logOut'), AppColors.red, () => _logout(context, ref)),
    ];

    return Stack(
      children: [
        Positioned.fill(
          top: top + 300,
          child: CustomPaint(painter: _CreamWave()),
        ),
        ListView(
          padding: EdgeInsets.fromLTRB(26, top + 24, 26, 110),
          children: [
            Center(child: Avatar(data: user?.avatar ?? '', size: 120)),
            const SizedBox(height: 28),
            Container(
              height: 82,
              decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance_wallet, size: 42, color: Color(0xFFA9694B)),
                  const SizedBox(width: 30),
                  Text(points, style: AppText.s(28, weight: FontWeight.w700, color: AppColors.brownDark)),
                ],
              ),
            ),
            const SizedBox(height: 120),
            ...items.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: m.onTap,
                      child: SizedBox(
                        height: 62,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              Icon(m.icon, color: m.color, size: 26),
                              const SizedBox(width: 20),
                              Expanded(child: Text(m.label, style: AppText.s(20))),
                              const Icon(Icons.chevron_right, color: Colors.black),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  _MenuItem(this.icon, this.label, this.color, this.onTap);
}

class _CreamWave extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final s = w / 412;
    final p = Path()
      ..moveTo(0, 30 * s)
      ..cubicTo(80 * s, 10 * s, 200 * s, 0, 260 * s, 20 * s)
      ..cubicTo(310 * s, 40 * s, 360 * s, 60 * s, w, 50 * s)
      ..lineTo(w, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(p, Paint()..color = const Color(0xFFF8F5EE));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
