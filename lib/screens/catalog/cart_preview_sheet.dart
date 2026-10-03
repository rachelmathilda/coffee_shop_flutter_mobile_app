import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_image.dart';

class CartPreviewSheet extends ConsumerWidget {
  final String itemKey;
  const CartPreviewSheet({super.key, required this.itemKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(stringsProvider);
    final item = ref.watch(cartProvider.select((c) => c.where((i) => i.key == itemKey).firstOrNull));
    if (item == null) return const SizedBox.shrink();
    final cart = ref.read(cartProvider.notifier);
    final bottom = MediaQuery.of(context).padding.bottom;

    void dismiss() => ref.read(lastCartKeyProvider.notifier).state = null;

    return GestureDetector(
      onVerticalDragEnd: (d) {
        if ((d.primaryVelocity ?? 0) > 200) dismiss();
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(22, 10, 22, 16 + bottom),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFAF5EC), Color(0xFFE9D9C4), Color(0xFFB79572)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: dismiss,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 4),
                child: Container(
                  width: 46,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 114,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Stack(
                children: [
                  Positioned(
                    left: 4,
                    top: 4,
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        cart.remove(itemKey);
                        dismiss();
                      },
                      icon: const Icon(Icons.close, size: 20, color: Colors.black),
                    ),
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 34),
                      SizedBox(width: 100, height: 90, child: AppImage(item.image)),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.s(20)),
                            Text(
                              money(item.unitPrice),
                              style: AppText.s(16, weight: FontWeight.w500, color: const Color(0xFFB8906E)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 92,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => cart.decrement(itemKey),
                                child: const Center(child: Icon(Icons.remove, size: 22)),
                              ),
                            ),
                            Container(height: 1, color: Colors.black),
                            Expanded(child: Center(child: Text('${item.quantity}', style: AppText.s(16)))),
                            Container(height: 1, color: Colors.black),
                            Expanded(
                              child: InkWell(
                                onTap: () => cart.increment(itemKey),
                                child: const Center(child: Icon(Icons.add, size: 22)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: Material(
                color: AppColors.brownDark,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => context.push('/cart'),
                  child: Center(
                    child: Text(t('checkout'), style: AppText.s(20, color: Colors.white)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
