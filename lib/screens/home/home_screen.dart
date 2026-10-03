import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_image.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _OrdersSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(stringsProvider);
    final promos = ref.watch(promosProvider).valueOrNull ?? const <Promo>[];
    final coffees = ref.watch(coffeesProvider).valueOrNull ?? const <Coffee>[];
    final featured = coffees.where((c) => c.featured).toList();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 110),
        children: [
          Row(
            children: [
              Text('grind', style: AppText.s(32, weight: FontWeight.w700, color: AppColors.charcoal)),
              const Spacer(),
              IconButton(
                onPressed: () => _openNotifications(context),
                icon: const Icon(Icons.notifications_active, color: AppColors.charcoal, size: 30),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (promos.isNotEmpty)
            GestureDetector(
              onTap: () {
                final p = promos.first;
                final c = coffees.where((e) => e.id == p.coffeeId).firstOrNull;
                if (c != null) context.push('/product', extra: c);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AspectRatio(
                  aspectRatio: 367 / 204,
                  child: AppImage(promos.first.image, fit: BoxFit.cover),
                ),
              ),
            ),
          const SizedBox(height: 22),
          Text(t('whatWeHave'), style: AppText.s(20, weight: FontWeight.w300)),
          const SizedBox(height: 4),
          if (featured.isNotEmpty) _FeaturedCarousel(items: featured),
          const SizedBox(height: 20),
          Text(t('customYourCoffee'), style: AppText.s(20, weight: FontWeight.w300)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              ref.read(customCoffeeProvider.notifier).state = const CustomCoffeeOrder();
              context.push('/custom-coffee');
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 368 / 177,
                child: Image.asset('assets/images/tutorial.png', fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCarousel extends StatefulWidget {
  final List<Coffee> items;
  const _FeaturedCarousel({required this.items});

  @override
  State<_FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<_FeaturedCarousel> {
  late final PageController _controller;
  double _page = 1;

  @override
  void initState() {
    super.initState();
    final start = widget.items.length > 1 ? 1 : 0;
    _page = start.toDouble();
    _controller = PageController(viewportFraction: 0.36, initialPage: start)
      ..addListener(() => setState(() => _page = _controller.page ?? _page));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 236,
      child: PageView.builder(
        controller: _controller,
        clipBehavior: Clip.none,
        itemCount: widget.items.length,
        itemBuilder: (context, i) {
          final c = widget.items[i];
          final d = (_page - i).abs().clamp(0.0, 1.0);
          final scale = 1 - d * 0.32;
          return GestureDetector(
            onTap: () {
              if (d < 0.2) {
                context.push('/product', extra: c);
              } else {
                _controller.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
              }
            },
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: 140,
                  height: 236,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 6,
                        height: 146,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(c.color),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(color: Color(0x40000000), blurRadius: 6, offset: Offset(0, 4)),
                            ],
                          ),
                          padding: const EdgeInsets.fromLTRB(14, 0, 8, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Center(
                                child: Text(
                                  c.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.s(14, color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(child: Text(rating(c.rating), style: AppText.s(10, color: Colors.white))),
                              const SizedBox(height: 10),
                              Text(money(c.price), style: AppText.s(18, weight: FontWeight.w600, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 10,
                        right: 10,
                        height: 112,
                        child: AppImage(c.image, fit: BoxFit.contain),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrdersSheet extends ConsumerWidget {
  const _OrdersSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(stringsProvider);
    final orders = ref.watch(ordersProvider);
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(color: AppColors.sand, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 14),
          Text(t('notifications'), style: AppText.s(20, weight: FontWeight.w600)),
          const SizedBox(height: 10),
          Expanded(
            child: orders.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brown)),
              error: (e, _) => Center(child: Text(t('genericError'))),
              data: (list) {
                if (list.isEmpty) {
                  return Center(child: Text(t('noOrders'), style: AppText.s(16, color: AppColors.textGrey)));
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final o = list[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.receipt_long, color: AppColors.brown),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  o.itemNames.join(', '),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.s(14, weight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${t('status_${o.status}')} · ${fmt.format(o.createdAt)}',
                                  style: AppText.s(12, color: AppColors.textGrey),
                                ),
                              ],
                            ),
                          ),
                          Text(money(o.total), style: AppText.s(14, weight: FontWeight.w600, color: AppColors.terracotta)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
