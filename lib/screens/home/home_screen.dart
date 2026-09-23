import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 0;

  static const _background = Color(0xFFF7F1E7);
  static const _dark = Color(0xFF2E241C);
  static const _brown = Color(0xFF6B4226);

  static const _cardPalette = [
    Color(0xFFD9C9A3),
    Color(0xFF6B4226),
    Color(0xFF4B5D3A),
  ];

  @override
  Widget build(BuildContext context) {
    final promos = ref.watch(promoCatalogProvider);
    final catalog = ref.watch(coffeeCatalogProvider);

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(promoCatalogProvider);
            ref.invalidate(coffeeCatalogProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildPromoBanner(promos),
                const SizedBox(height: 28),
                const Text(
                  'what we have',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 16),
                _buildCatalog(context, catalog),
                const SizedBox(height: 28),
                const Text(
                  'custom your coffee',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 16),
                _buildCustomCoffeeCard(context),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'grind',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: _dark,
          ),
        ),
        IconButton(
          onPressed: () {
            context.push('/notifications');
          },
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: _dark,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildPromoBanner(AsyncValue<List<Promo>> promos) {
    return promos.when(
      data: (items) {
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }
        return _PromoBanner(promo: items.first);
      },
      loading: () => Container(
        height: 220,
        decoration: BoxDecoration(
          color: _brown.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Container(
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _brown.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Text('couldn\'t load promo'),
      ),
    );
  }

  Widget _buildCatalog(BuildContext context, AsyncValue<List<Coffee>> catalog) {
    return catalog.when(
      data: (coffees) {
        if (coffees.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(child: Text('no coffee yet')),
          );
        }
        return SizedBox(
          height: 230,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: coffees.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final coffee = coffees[index];
              final featured = index % 3 == 1;
              final color = _cardPalette[index % _cardPalette.length];
              return _CoffeeCard(
                coffee: coffee,
                color: color,
                featured: featured,
                onTap: () {
                  context.push('/product/${coffee.id}', extra: coffee);
                },
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(
        height: 230,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => SizedBox(
        height: 230,
        child: Center(child: Text('couldn\'t load coffee: $err')),
      ),
    );
  }

  Widget _buildCustomCoffeeCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/custom-coffee');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardPalette[0],
          borderRadius: BorderRadius.circular(24),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset('assets/images/tutorial.png', fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.home_rounded, label: 'home'),
      _NavItem(icon: Icons.local_offer_outlined, label: 'discount'),
      _NavItem(icon: Icons.add_rounded, label: 'order'),
      _NavItem(icon: Icons.person_outline_rounded, label: 'profile'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final selected = _navIndex == index;
          final isOrder = index == 2;

          return GestureDetector(
            onTap: () {
              setState(() => _navIndex = index);
              switch (index) {
                case 1:
                  context.push('/discount');
                  break;
                case 2:
                  context.push('/cart');
                  break;
                case 3:
                  context.push('/profile/edit');
                  break;
              }
            },
            child: isOrder
                ? Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _dark,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(item.icon, color: Colors.white),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        color: selected ? _dark : _dark.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: selected
                              ? _dark
                              : _dark.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}

class _PromoBanner extends StatelessWidget {
  final Promo promo;

  const _PromoBanner({required this.promo});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFF6B4226),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _promoImage(promo.imageUrl),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.05),
                  Colors.black.withValues(alpha: 0.45),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            top: 20,
            child: Text(
              promo.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '\$ ${promo.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: Text(
              promo.ctaLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _promoImage(String url) {
    if (url.isEmpty) {
      return Image.asset('assets/images/ad.png', fit: BoxFit.cover);
    }
    if (url.startsWith('http')) {
      return Image.network(url, fit: BoxFit.cover);
    }
    return Image.asset(url, fit: BoxFit.cover);
  }
}

class _CoffeeCard extends StatelessWidget {
  final Coffee coffee;
  final Color color;
  final bool featured;
  final VoidCallback onTap;

  const _CoffeeCard({
    required this.coffee,
    required this.color,
    required this.featured,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF2E241C);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: featured ? 150 : 130,
        margin: EdgeInsets.only(top: featured ? 0 : 24),
        padding: const EdgeInsets.fromLTRB(12, 44, 12, 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -44,
              left: 0,
              right: 0,
              child: SizedBox(height: 90, child: _coffeeImage(coffee.imageUrl)),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 46),
                Text(
                  coffee.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Colors.amber.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      coffee.rating.toStringAsFixed(1),
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '\$ ${coffee.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _coffeeImage(String url) {
    if (url.isEmpty) {
      return const Icon(Icons.local_cafe_outlined, size: 60);
    }
    if (url.startsWith('http')) {
      return Image.network(url, fit: BoxFit.contain);
    }
    return Image.asset(url, fit: BoxFit.contain);
  }
}
