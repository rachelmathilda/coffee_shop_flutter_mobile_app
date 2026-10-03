import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_image.dart';
import '../../widgets/buttons.dart';
import '../../widgets/painters.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Coffee coffee;
  const ProductDetailScreen({super.key, required this.coffee});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  static const _sizes = ['S', 'M', 'L'];
  static const _types = ['Arabica', 'Liberica', 'Robusta'];
  static const _addIns = ['Milk', 'Sugar', 'Cream', 'Cocoa', 'Vanilla', 'Salt'];

  String _size = 'S';
  String _type = 'Arabica';
  final Set<String> _selectedAddIns = {};

  void _addToCart() {
    final s = ref.read(appSettingsProvider);
    final c = widget.coffee;
    final addIns = _addIns.where(_selectedAddIns.contains).toList();
    final unit = c.price + s.sizeExtra(_size) + addIns.length * s.addInPrice;
    final key = ref.read(cartProvider.notifier).add(
          coffeeId: c.id,
          name: c.name,
          image: c.image,
          unitPrice: double.parse(unit.toStringAsFixed(2)),
          options: {'size': _size, 'type': _type, 'addIns': addIns},
        );
    ref.read(lastCartKeyProvider.notifier).state = key;
    ref.read(tabIndexProvider.notifier).state = 2;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(stringsProvider);
    final s = ref.watch(appSettingsProvider);
    final c = widget.coffee;
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    final price = c.price + s.sizeExtra(_size);
    final addInTotal = _selectedAddIns.length * s.addInPrice;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: top + 340,
            child: const PatternBackground(),
          ),
          Positioned(
            top: top + 6,
            left: 0,
            right: 0,
            height: 270,
            child: Hero(tag: 'coffee_${c.id}', child: AppImage(c.image, fit: BoxFit.contain)),
          ),
          Positioned(
            top: top + 8,
            left: 16,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
            ),
          ),
          Positioned.fill(
            top: top + 300,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: ListView(
                padding: EdgeInsets.fromLTRB(36, 32, 36, 100 + bottom),
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(c.name, style: AppText.s(22, weight: FontWeight.w500))),
                      Text('${rating(c.rating)}/5', style: AppText.s(18)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(money(price), style: AppText.s(30, weight: FontWeight.w500, color: AppColors.terracotta)),
                  const SizedBox(height: 10),
                  Text(t('size'), style: AppText.s(20)),
                  const SizedBox(height: 12),
                  Row(
                    children: _sizes
                        .map((e) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: e == 'L' ? 0 : 10),
                                child: _Pill(
                                  label: e,
                                  selected: _size == e,
                                  outlined: true,
                                  fontSize: 22,
                                  onTap: () => setState(() => _size = e),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(t('coffeeType'), style: AppText.s(20)),
                  const SizedBox(height: 12),
                  Row(
                    children: _types
                        .map((e) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: e == 'Robusta' ? 0 : 10),
                                child: _Pill(
                                  label: e,
                                  selected: _type == e,
                                  outlined: false,
                                  fontSize: 16,
                                  onTap: () => setState(() => _type = e),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Text(t('addIns'), style: AppText.s(20))),
                      Text('+ ${money(addInTotal)}', style: AppText.s(20, weight: FontWeight.w300, color: const Color(0xFF555555))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 10,
                    childAspectRatio: 105 / 48,
                    children: _addIns.map((e) {
                      final sel = _selectedAddIns.contains(e);
                      return InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => setState(() => sel ? _selectedAddIns.remove(e) : _selectedAddIns.add(e)),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: sel ? AppColors.terracotta : const Color(0xFFEADFC9),
                              width: sel ? 1.2 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(e, style: AppText.s(14, weight: FontWeight.w300)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            bottom: 18 + bottom,
            child: PrimaryButton(label: t('addToCart'), onTap: _addToCart, fontSize: 22),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final bool outlined;
  final double fontSize;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.selected,
    required this.outlined,
    required this.fontSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = outlined ? Colors.white : (selected ? AppColors.terracotta : AppColors.beige);
    final Color border = outlined ? (selected ? AppColors.terracotta : const Color(0xFFEADFC9)) : Colors.transparent;
    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 50,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: border),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppText.s(fontSize, weight: FontWeight.w300, color: const Color(0xFF3A3A3A)),
        ),
      ),
    );
  }
}
