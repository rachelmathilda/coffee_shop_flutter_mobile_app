import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_image.dart';

const defaultOptions = <String, dynamic>{
  'size': 'S',
  'type': 'Arabica',
  'addIns': <String>[],
};

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(stringsProvider);
    final coffees = ref.watch(filteredCoffeesProvider);
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
            sliver: SliverList.list(
              children: [
                Container(
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.searchBg,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        size: 30,
                        color: AppColors.charcoal,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (v) =>
                              ref.read(searchQueryProvider.notifier).state = v,
                          style: AppText.s(20),
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isCollapsed: true,
                            hintText: t('search'),
                            hintStyle: AppText.s(20),
                          ),
                        ),
                      ),
                      if (_searchCtrl.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            ref.read(searchQueryProvider.notifier).state = '';
                            setState(() {});
                          },
                          child: const Icon(
                            Icons.close,
                            color: AppColors.charcoal,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    ref.read(customCoffeeProvider.notifier).state =
                        const CustomCoffeeOrder();
                    context.push('/custom-coffee');
                  },
                  child: Container(
                    height: 94,
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(11),
                    child: Row(
                      children: [
                        Container(
                          width: 108,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.coffee_rounded,
                            size: 52,
                            color: Colors.black,
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              t('customMyOwnCoffee'),
                              style: AppText.s(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          coffees.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.brown),
                ),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Center(child: Text(t('genericError'))),
              ),
            ),
            data: (list) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 240),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 177 / 212,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) => CoffeeCard(coffee: list[i]),
                  childCount: list.length,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CoffeeCard extends ConsumerWidget {
  final Coffee coffee;
  const CoffeeCard({super.key, required this.coffee});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = CartNotifier.buildKey(coffee.id, defaultOptions);
    final item = ref.watch(
      cartProvider.select((c) => c.where((i) => i.key == key).firstOrNull),
    );
    final cart = ref.read(cartProvider.notifier);

    void add() {
      final k = cart.add(
        coffeeId: coffee.id,
        name: coffee.name,
        image: coffee.image,
        unitPrice: coffee.price,
        options: Map<String, dynamic>.from(defaultOptions),
      );
      ref.read(lastCartKeyProvider.notifier).state = k;
    }

    return GestureDetector(
      onTap: () => context.push('/product', extra: coffee),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 11, 11, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 113,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Hero(
                        tag: 'coffee_${coffee.id}',
                        child: AppImage(coffee.image),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          coffee.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.s(16),
                        ),
                      ),
                      const Icon(Icons.star, size: 15, color: AppColors.star),
                      const SizedBox(width: 3),
                      Text('${rating(coffee.rating)}/5', style: AppText.s(12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    money(coffee.price),
                    style: AppText.s(
                      16,
                      weight: FontWeight.w500,
                      color: AppColors.textBrown,
                    ),
                  ),
                  const Spacer(flex: 40),
                ],
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: item == null
                  ? _CornerPlus(onTap: add)
                  : Padding(
                      padding: const EdgeInsets.only(right: 0, bottom: 0),
                      child: Row(
                        children: [
                          _OutlineSquare(
                            icon: Icons.remove,
                            onTap: () => cart.decrement(key),
                          ),
                          SizedBox(
                            width: 40,
                            child: Center(
                              child: Text(
                                '${item.quantity}',
                                style: AppText.s(16),
                              ),
                            ),
                          ),
                          _CornerPlus(
                            onTap: () {
                              cart.increment(key);
                              ref.read(lastCartKeyProvider.notifier).state =
                                  key;
                            },
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

class _CornerPlus extends StatelessWidget {
  final VoidCallback onTap;
  const _CornerPlus({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.terracotta,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(10),
        bottomRight: Radius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        child: const SizedBox(
          width: 34,
          height: 34,
          child: Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}

class _OutlineSquare extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _OutlineSquare({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColors.terracotta),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(icon, color: AppColors.terracotta, size: 26),
          ),
        ),
      ),
    );
  }
}
