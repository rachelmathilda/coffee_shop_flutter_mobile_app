import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../services/app_exception.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';

class DiscountScreen extends ConsumerWidget {
  const DiscountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(stringsProvider);
    final discounts = ref.watch(discountsProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;

    return SafeArea(
      bottom: false,
      child: discounts.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brown)),
        error: (e, _) => Center(child: Text(t('genericError'))),
        data: (list) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 110),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: 24),
          itemBuilder: (_, i) {
            final d = list[i];
            final used = user?.usedDiscounts.contains(d.id) ?? false;
            final claimed = user?.claimedDiscountId == d.id;
            return _Coupon(
              discount: d,
              used: used,
              claimed: claimed,
              onClaim: () async {
                if (user == null) return;
                try {
                  await ref.read(authServiceProvider).claimDiscount(user.uid, d.id);
                  if (context.mounted) showMessage(context, t('dealClaimed'));
                } catch (e) {
                  if (context.mounted) showMessage(context, errorText(e, t));
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class _Coupon extends ConsumerWidget {
  final Discount discount;
  final bool used;
  final bool claimed;
  final VoidCallback onClaim;

  const _Coupon({required this.discount, required this.used, required this.claimed, required this.onClaim});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(stringsProvider);
    final d = discount;
    final expired = d.isExpired;
    final disabled = used || expired || claimed;
    final label = used
        ? t('used')
        : expired
            ? t('expiredDeal')
            : claimed
                ? t('claimed')
                : t('getDeal');
    final valueText = d.value % 1 == 0 ? d.value.toStringAsFixed(0) : d.value.toString();
    final buyGet = t('buyGet').split('\n');

    return ClipPath(
      clipper: _NotchClipper(),
      child: Container(
        height: 176,
        color: AppColors.creamLight,
        child: Row(
          children: [
            SizedBox(
              width: 134,
              child: Center(
                child: d.isBogo
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(buyGet.first, style: AppText.s(24, weight: FontWeight.w700, color: AppColors.textBrown)),
                          if (buyGet.length > 1)
                            Text(buyGet[1], style: AppText.s(32, weight: FontWeight.w700, color: AppColors.textBrown)),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$valueText%', style: AppText.s(32, weight: FontWeight.w700, color: AppColors.textBrown)),
                          Text(t('off'), style: AppText.s(32, color: AppColors.textBrown, height: 1.1)),
                        ],
                      ),
              ),
            ),
            const SizedBox(width: 1, height: 160, child: CustomPaint(painter: _DashPainter())),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 30, right: 44),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t('validUntil'), style: AppText.s(16, color: AppColors.terracottaLight)),
                    Text(
                      DateFormat('dd/MM/yyyy').format(d.validUntil),
                      style: AppText.s(16, color: AppColors.terracottaLight),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 157,
                      height: 37,
                      child: Material(
                        color: disabled && !claimed ? AppColors.sandDark : AppColors.terracottaLight,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: disabled ? null : onClaim,
                          child: Center(
                            child: Text(label, style: AppText.s(16, color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final rect = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(10)));
    final notch = Path()..addOval(Rect.fromCircle(center: Offset(size.width + 2, size.height / 2), radius: 26));
    return Path.combine(PathOperation.difference, rect, notch);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _DashPainter extends CustomPainter {
  const _DashPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.terracottaLight
      ..strokeWidth = 2;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + 7), p);
      y += 12;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
