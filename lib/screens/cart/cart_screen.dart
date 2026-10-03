import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_image.dart';
import '../../widgets/buttons.dart';
import '../../widgets/simple_app_bar.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(stringsProvider);
    final items = ref.watch(cartProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SimpleTopBar(title: t('order')),
            Expanded(
              child: items.isEmpty
                  ? Center(child: Text(t('emptyCart'), style: AppText.s(16, color: AppColors.textGrey)))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(21, 4, 21, 20),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 22),
                      itemBuilder: (_, i) => _CartTile(item: items[i]),
                    ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(37, 0, 40, 18),
              child: Row(
                children: [
                  Text(t('totalPrice'), style: AppText.s(20)),
                  const Spacer(),
                  Text(money(subtotal), style: AppText.s(22, weight: FontWeight.w500)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(21, 0, 21, 18 + bottom),
              child: PrimaryButton(
                label: t('continueLabel'),
                onTap: items.isEmpty ? null : () => context.push('/delivery'),
                color: items.isEmpty ? AppColors.sandDark : AppColors.brown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartTile extends ConsumerWidget {
  final CartItem item;
  const _CartTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartProvider.notifier);
    final summary = item.optionSummary;
    return Dismissible(
      key: ValueKey(item.key),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => cart.remove(item.key),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 4),
        child: const Icon(Icons.delete_outline, size: 26, color: Colors.black),
      ),
      child: Container(
        height: 128,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(color: const Color(0xFFEBE2D2), borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Container(
              width: 122,
              decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.all(8),
              child: AppImage(item.image),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.s(20)),
                  Text(
                    money(item.unitPrice),
                    style: AppText.s(16, weight: FontWeight.w500, color: const Color(0xFFC4956C)),
                  ),
                  if (summary.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      child: Text(
                        summary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.s(11, color: AppColors.textGrey),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleIconButton(icon: Icons.remove, onTap: () => cart.decrement(item.key)),
                      SizedBox(
                        width: 44,
                        child: Center(child: Text('${item.quantity}', style: AppText.s(16))),
                      ),
                      CircleIconButton(icon: Icons.add, onTap: () => cart.increment(item.key)),
                    ],
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
