import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';

class CustomCoffeeScreen extends ConsumerStatefulWidget {
  const CustomCoffeeScreen({super.key});

  @override
  ConsumerState<CustomCoffeeScreen> createState() => _CustomCoffeeScreenState();
}

class _CustomCoffeeScreenState extends ConsumerState<CustomCoffeeScreen>
    with TickerProviderStateMixin {
  int _step = 0;
  final int _totalSteps = 6;

  late AnimationController _slideCtrl;
  late AnimationController _cupAnimCtrl;

  late Animation<Offset> _slideIn;

  final _coffeeTypes = ['Arabica', 'Liberica', 'Robusta', 'Excelsa'];
  final _coffeeTypeColors = [
    const Color(0xFFD9C9A3),
    const Color(0xFF6B4226),
    const Color(0xFFD9C9A3),
    const Color(0xFFD9C9A3),
  ];

  final _toppings = ['Pudding', 'Pearl', 'Caramel', 'Cream'];
  final _toppingIcons = [
    Icons.cake_outlined,
    Icons.circle,
    Icons.star_outline,
    Icons.icecream_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _cupAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _slideIn = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

    _slideCtrl.forward();
    _cupAnimCtrl.forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _cupAnimCtrl.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_step < _totalSteps - 1) {
      _slideCtrl.reset();
      _cupAnimCtrl.reset();
      setState(() => _step++);
      _slideCtrl.forward();
      _cupAnimCtrl.forward();
    }
  }

  void _goBack() {
    if (_step > 0) {
      _slideCtrl.reset();
      _cupAnimCtrl.reset();
      setState(() => _step--);
      _slideCtrl.forward();
      _cupAnimCtrl.forward();
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(customCoffeeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: List.generate(_totalSteps, (i) {
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= _step
                            ? AppColors.primary
                            : AppColors.textLight.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: SlideTransition(
                position: _slideIn,
                child: _buildStep(order),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: _step == _totalSteps - 1
                  ? ElevatedButton(
                      onPressed: () => context.go('/cart'),
                      child: const Text('Order'),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _goBack,
                            child: Text(_step == 0 ? 'Back' : 'Previous'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _goNext,
                            child: const Text('Next'),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(CustomCoffeeOrder order) {
    switch (_step) {
      case 0:
        return _TypeStep(order: order, pourAnim: _cupAnimCtrl);
      case 1:
        return _CoffeeTypeStep(
          order: order,
          pourAnim: _cupAnimCtrl,
          coffeeTypes: _coffeeTypes,
          coffeeTypeColors: _coffeeTypeColors,
        );
      case 2:
        return _CupSizeStep(order: order, pourAnim: _cupAnimCtrl);
      case 3:
        return _SugarStep(order: order, pourAnim: _cupAnimCtrl);
      case 4:
        return _ToppingStep(
          order: order,
          pourAnim: _cupAnimCtrl,
          toppings: _toppings,
          toppingIcons: _toppingIcons,
          onSelect: (t) {
            ref.read(customCoffeeProvider.notifier).setTopping(t);
          },
        );
      case 5:
        return _ResultStep(order: order, pourAnim: _cupAnimCtrl);
      default:
        return const SizedBox();
    }
  }
}

double _sugarFillLevel(SugarLevel level) {
  switch (level) {
    case SugarLevel.less:
      return 0.35;
    case SugarLevel.normal:
      return 0.55;
    case SugarLevel.high:
      return 0.75;
  }
}

class _CupVisual extends StatelessWidget {
  final double height;
  final double fillLevel;
  final Color fillColor;
  final Animation<double>? pourAnim;

  const _CupVisual({
    this.height = 240,
    this.fillLevel = 0,
    this.fillColor = const Color(0xFFD4A574),
    this.pourAnim,
  });

  @override
  Widget build(BuildContext context) {
    if (pourAnim == null) {
      return SizedBox(
        height: height,
        child: CustomPaint(
          painter: _CupPainter(
            fillLevel: fillLevel,
            fillColor: fillColor,
            pourProgress: 1,
          ),
          size: Size(height * 0.6, height),
        ),
      );
    }
    return AnimatedBuilder(
      animation: pourAnim!,
      builder: (context, child) {
        final curved = Curves.easeOutCubic.transform(pourAnim!.value);
        return SizedBox(
          height: height,
          child: CustomPaint(
            painter: _CupPainter(
              fillLevel: fillLevel * curved,
              fillColor: fillColor,
              pourProgress: pourAnim!.value,
            ),
            size: Size(height * 0.6, height),
          ),
        );
      },
    );
  }
}

class _CupPainter extends CustomPainter {
  final double fillLevel;
  final Color fillColor;
  final double pourProgress;

  const _CupPainter({
    required this.fillLevel,
    required this.fillColor,
    required this.pourProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final topW = w * 0.98;
    final botW = w * 0.62;
    final rimH = h * 0.04;

    final bodyPath = Path()
      ..moveTo((w - topW) / 2, rimH)
      ..lineTo((w - botW) / 2, h * 0.94)
      ..quadraticBezierTo(w / 2, h, (w + botW) / 2, h * 0.94)
      ..lineTo((w + topW) / 2, rimH)
      ..close();

    final baseShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, h + 4),
        width: botW * 0.9,
        height: 8,
      ),
      baseShadow,
    );

    if (fillLevel > 0.01) {
      final fillTop = rimH + (h - rimH) * (1 - fillLevel);
      final fillPath = Path()
        ..moveTo((w - topW) / 2 + (topW - botW) / 2 * (1 - fillLevel), fillTop)
        ..lineTo((w - botW) / 2, h * 0.94)
        ..quadraticBezierTo(w / 2, h, (w + botW) / 2, h * 0.94)
        ..lineTo((w + topW) / 2 - (topW - botW) / 2 * (1 - fillLevel), fillTop)
        ..close();

      final fillPaint = Paint()..color = fillColor.withValues(alpha: 0.75);
      canvas.save();
      canvas.clipPath(bodyPath);
      canvas.drawPath(fillPath, fillPaint);

      final surfacePaint = Paint()
        ..color = fillColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final leftX = (w - topW) / 2 + (topW - botW) / 2 * (1 - fillLevel);
      final rightX = (w + topW) / 2 - (topW - botW) / 2 * (1 - fillLevel);
      canvas.drawOval(
        Rect.fromLTRB(leftX, fillTop - 3, rightX, fillTop + 3),
        surfacePaint,
      );
      canvas.restore();

      if (pourProgress < 0.98) {
        final splashPaint = Paint()
          ..color = fillColor.withValues(alpha: (1 - pourProgress) * 0.6);
        final centerX = (leftX + rightX) / 2;
        canvas.drawCircle(
          Offset(centerX, fillTop),
          8 * (1 - pourProgress) + 2,
          splashPaint,
        );
        canvas.drawCircle(
          Offset(centerX - 14, fillTop + 2),
          4 * (1 - pourProgress),
          splashPaint,
        );
        canvas.drawCircle(
          Offset(centerX + 14, fillTop + 2),
          4 * (1 - pourProgress),
          splashPaint,
        );
      }
    }

    if (pourProgress < 0.98) {
      final fillTop = rimH + (h - rimH) * (1 - fillLevel);
      final streamPaint = Paint()
        ..color = fillColor.withValues(
          alpha: (1 - pourProgress * 0.3).clamp(0.0, 1.0),
        )
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, fillTop), streamPaint);
    }

    final ribPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final frac in [0.28, 0.5, 0.72]) {
      final topX = (w - topW) / 2 + topW * frac;
      final botX = (w - botW) / 2 + botW * frac;
      canvas.drawLine(Offset(topX, rimH + 4), Offset(botX, h * 0.92), ribPaint);
    }

    final cupPaint = Paint()
      ..color = const Color(0xFFCCCCCC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(bodyPath, cupPaint);

    final rimPaint = Paint()
      ..color = const Color(0xFFAAAAAA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, rimH),
        width: topW,
        height: rimH * 1.4,
      ),
      rimPaint,
    );

    final glossPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final glossPath = Path()
      ..moveTo(w * 0.28, rimH + h * 0.1)
      ..quadraticBezierTo(w * 0.24, h * 0.5, w * 0.3, h * 0.85);
    canvas.drawPath(glossPath, glossPaint);
  }

  @override
  bool shouldRepaint(_CupPainter old) =>
      old.fillLevel != fillLevel || old.pourProgress != pourProgress;
}

class _TypeStep extends ConsumerWidget {
  final CustomCoffeeOrder order;
  final Animation<double> pourAnim;
  const _TypeStep({required this.order, required this.pourAnim});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Text(
          'Type',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () {
            final newTemp = order.temp == CoffeeTemp.iced
                ? CoffeeTemp.hot
                : CoffeeTemp.iced;
            ref.read(customCoffeeProvider.notifier).setTemp(newTemp);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: order.temp == CoffeeTemp.iced
                  ? AppColors.primaryDark
                  : AppColors.secondary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: order.temp == CoffeeTemp.iced
                        ? Colors.white.withValues(alpha: 0.2)
                        : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  order.temp == CoffeeTemp.iced ? 'Iced' : 'Hot',
                  style: TextStyle(
                    color: order.temp == CoffeeTemp.iced
                        ? Colors.white
                        : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        _CupVisual(fillLevel: 0.15, pourAnim: pourAnim),
        const Spacer(),
      ],
    );
  }
}

class _CoffeeTypeStep extends ConsumerWidget {
  final CustomCoffeeOrder order;
  final Animation<double> pourAnim;
  final List<String> coffeeTypes;
  final List<Color> coffeeTypeColors;

  const _CoffeeTypeStep({
    required this.order,
    required this.pourAnim,
    required this.coffeeTypes,
    required this.coffeeTypeColors,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Text(
          'Coffee Type',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(coffeeTypes.length, (i) {
            final active = coffeeTypes[i] == order.coffeeType;
            return GestureDetector(
              onTap: () => ref
                  .read(customCoffeeProvider.notifier)
                  .setCoffeeType(coffeeTypes[i]),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active
                            ? AppColors.primaryDark
                            : AppColors.cardBg,
                      ),
                      child: Icon(
                        Icons.grain,
                        color: active ? Colors.white : AppColors.textSecondary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      coffeeTypes[i],
                      style: TextStyle(
                        fontSize: 12,
                        color: active
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const Spacer(),
        _CupVisual(fillLevel: 0.3, pourAnim: pourAnim),
        const Spacer(),
      ],
    );
  }
}

class _CupSizeStep extends ConsumerWidget {
  final CustomCoffeeOrder order;
  final Animation<double> pourAnim;
  const _CupSizeStep({required this.order, required this.pourAnim});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const sizes = ['S', 'M', 'L'];
    final cupHeight = order.cupSize == 'L'
        ? 260.0
        : order.cupSize == 'M'
        ? 220.0
        : 180.0;

    return Column(
      children: [
        const SizedBox(height: 24),
        const Text(
          'Cup Size',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: sizes.map((s) {
            final active = s == order.cupSize;
            return GestureDetector(
              onTap: () =>
                  ref.read(customCoffeeProvider.notifier).setCupSize(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: active ? AppColors.primary : const Color(0xFFCCBBA0),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    s,
                    style: TextStyle(
                      color: active ? Colors.white : AppColors.textSecondary,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const Spacer(),
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          child: _CupVisual(
            height: cupHeight,
            fillLevel: 0.3,
            pourAnim: pourAnim,
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class _SugarStep extends ConsumerWidget {
  final CustomCoffeeOrder order;
  final Animation<double> pourAnim;
  const _SugarStep({required this.order, required this.pourAnim});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sliderVal = order.sugarLevel == SugarLevel.less
        ? 0.0
        : order.sugarLevel == SugarLevel.normal
        ? 0.5
        : 1.0;
    final fillLevel = _sugarFillLevel(order.sugarLevel);

    return Column(
      children: [
        const SizedBox(height: 24),
        const Text(
          'Sugar',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.secondary,
                  thumbColor: AppColors.primaryDark,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 18,
                  ),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: sliderVal,
                  onChanged: (v) {
                    final level = v < 0.33
                        ? SugarLevel.less
                        : v < 0.66
                        ? SugarLevel.normal
                        : SugarLevel.high;
                    ref
                        .read(customCoffeeProvider.notifier)
                        .setSugarLevel(level);
                  },
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Less',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Normal',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'High',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        _CupVisual(
          fillLevel: fillLevel,
          fillColor: Color.fromRGBO(212, 165, 116, 0.5 + sliderVal * 0.5),
          pourAnim: pourAnim,
        ),
        const Spacer(),
      ],
    );
  }
}

class _ToppingStep extends StatelessWidget {
  final CustomCoffeeOrder order;
  final Animation<double> pourAnim;
  final List<String> toppings;
  final List<IconData> toppingIcons;
  final ValueChanged<String> onSelect;

  const _ToppingStep({
    required this.order,
    required this.pourAnim,
    required this.toppings,
    required this.toppingIcons,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Text(
          'Topping',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(toppings.length, (i) {
            final active = toppings[i] == order.topping;
            return GestureDetector(
              onTap: () => onSelect(toppings[i]),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active ? AppColors.primary : AppColors.cardBg,
                        border: Border.all(
                          color: active
                              ? AppColors.primary
                              : const Color(0xFFCCBBA0),
                        ),
                      ),
                      child: Icon(
                        toppingIcons[i],
                        color: active ? Colors.white : AppColors.textSecondary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      toppings[i],
                      style: TextStyle(
                        fontSize: 11,
                        color: active
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const Spacer(),
        _CupVisual(fillLevel: 0.6, pourAnim: pourAnim),
        const Spacer(),
      ],
    );
  }
}

class _ResultStep extends StatelessWidget {
  final CustomCoffeeOrder order;
  final Animation<double> pourAnim;

  const _ResultStep({required this.order, required this.pourAnim});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Text(
          'Result',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        _CupVisual(
          fillLevel: 0.75,
          fillColor: const Color(0xFFC8864A),
          pourAnim: pourAnim,
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Price',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                '\$ ${order.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
