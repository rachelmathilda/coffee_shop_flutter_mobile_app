import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Coffee coffee;
  const ProductDetailScreen({super.key, required this.coffee});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  String _selectedSize = 'S';
  String _selectedType = 'Liberica';
  final List<String> _selectedAddIns = [];

  @override
  Widget build(BuildContext context) {
    final coffee = widget.coffee;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Hero image with patterned bg
          Stack(
            children: [
              Container(
                height: 280,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.3),
                ),
                child: CustomPaint(
                  painter: _PatternPainter(),
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: coffee.imageUrl,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 44,
                left: 16,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Details
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          coffee.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.star, color: AppColors.star, size: 14),
                        Text(
                          ' ${coffee.rating}/5',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$ ${coffee.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Size',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: coffee.sizes.map((s) {
                        final active = s == _selectedSize;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedSize = s),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 12),
                            width: 56,
                            height: 40,
                            decoration: BoxDecoration(
                              color: active ? Colors.white : Colors.transparent,
                              border: Border.all(
                                color: active
                                    ? AppColors.primary
                                    : const Color(0xFFDDD0C0),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                s,
                                style: TextStyle(
                                  color: active
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontWeight: active
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Coffee Type',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: coffee.coffeeTypes.map((t) {
                        final active = t == _selectedType;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedType = t),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.primary
                                  : AppColors.cardBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              t,
                              style: TextStyle(
                                color: active
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Add-ins',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        if (_selectedAddIns.isNotEmpty)
                          Text(
                            '+ \$ 0.80',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: coffee.addIns.map((a) {
                        final active = _selectedAddIns.contains(a);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (active)
                                _selectedAddIns.remove(a);
                              else
                                _selectedAddIns.add(a);
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.secondary
                                  : Colors.transparent,
                              border: Border.all(
                                color: active
                                    ? AppColors.primary
                                    : const Color(0xFFDDD0C0),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              a,
                              style: TextStyle(
                                color: active
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
          // Add to Cart button
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: ElevatedButton(
              onPressed: () {
                ref
                    .read(cartProvider.notifier)
                    .addItem(
                      coffee,
                      size: _selectedSize,
                      coffeeType: _selectedType,
                      addIns: List.from(_selectedAddIns),
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${coffee.name} added to cart'),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                context.pop();
              },
              child: const Text('Add to Cart'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: 18, height: 18),
          paint,
        );
        canvas.drawCircle(Offset(x + spacing / 2, y + spacing / 2), 6, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_PatternPainter old) => false;
}
