import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../widgets/bottom_nav.dart';
import '../catalog/cart_preview_sheet.dart';
import '../catalog/catalog_screen.dart';
import '../discount/discount_screen.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(tabIndexProvider);
    final t = ref.watch(stringsProvider);
    final cart = ref.watch(cartProvider);
    final lastKey = ref.watch(lastCartKeyProvider);
    final showSheet = index == 2 && lastKey != null && cart.any((i) => i.key == lastKey);
    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) ref.read(tabIndexProvider.notifier).state = 0;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        body: IndexedStack(
          index: index,
          children: const [HomeScreen(), DiscountScreen(), CatalogScreen(), ProfileScreen()],
        ),
        bottomNavigationBar: showSheet
            ? CartPreviewSheet(itemKey: lastKey)
            : BottomNav(
                index: index,
                labels: [t('home'), t('discount'), t('order'), t('profile')],
                onTap: (i) {
                  ref.read(lastCartKeyProvider.notifier).state = null;
                  ref.read(tabIndexProvider.notifier).state = i;
                },
              ),
      ),
    );
  }
}
