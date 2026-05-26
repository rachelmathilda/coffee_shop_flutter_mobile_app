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
  int _step = 0; // 0=type, 1=cupSize, 2=sugar, 3=topping, 4=result
  final int _totalSteps = 5;

  late AnimationController _slideCtrl;
  late AnimationController _cupAnimCtrl;
  late AnimationController _fillCtrl;

  late Animation<Offset> _slideIn;
  late Animation<double> _cupScale;
  late Animation<double> _fillAnim;

  // Topping selection
  String? _selectedTopping;
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
      duration: const Duration(milliseconds: 600),
    );
    _fillCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideIn = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _cupScale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _cupAnimCtrl, curve: Curves.elasticOut));
    _fillAnim = CurvedAnimation(parent: _fillCtrl, curve: Curves.easeInOut);

    _slideCtrl.forward();
    _cupAnimCtrl.forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _cupAnimCtrl.dispose();
    _fillCtrl.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_step < _totalSteps - 1) {
      _slideCtrl.reset();
      _cupAnimCtrl.reset();
      setState(() => _step++);
      _slideCtrl.forward();
      _cupAnimCtrl.forward();
      if (_step == 4) _fillCtrl.forward(); // result step
    }
  }

  void _goBack() {
    if (_step > 0) {
      setState(() => _step--);
      _slideCtrl.reset();
      _slideCtrl.forward();
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
            // Step indicator
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
                            : AppColors.textLight.withOpacity(0.3),
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
            // Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: _step == _totalSteps - 1
                  ? ElevatedButton(
                      onPressed: () {
                        context.go('/cart');
                      },
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
        return _TypeStep(order: order);
      case 1:
        return _CupSizeStep(order: order);
      case 2:
        return _SugarStep(order: order);
      case 3:
        return _ToppingStep(
          order: order,
          selectedTopping: _selectedTopping,
          toppings: _toppings,
          toppingIcons: _toppingIcons,
          onSelect: (t) {
            setState(() => _selectedTopping = t);
            ref.read(customCoffeeProvider.notifier).setTopping(t);
          },
        );
      case 4:
        return _ResultStep(order: order, fillAnim: _fillAnim);
      default:
        return const SizedBox();
    }
  }
}

// ── Step widgets ─────────────────────────────────────────────────

class _CupVisual extends StatelessWidget {
  final double height;
  final double fillLevel; // 0.0 - 1.0
  final Color fillColor;

  const _CupVisual({
    this.height = 220,
    this.fillLevel = 0,
    this.fillColor = const Color(0xFFD4A574),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _CupPainter(fillLevel: fillLevel, fillColor: fillColor),
        size: Size(height * 0.65, height),
      ),
    );
  }
}

class _CupPainter extends CustomPainter {
  final double fillLevel;
  final Color fillColor;

  const _CupPainter({required this.fillLevel, required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final topW = w * 0.95;
    final botW = w * 0.65;
    final rimH = h * 0.06;

    // Cup body path
    final bodyPath = Path()
      ..moveTo((w - topW) / 2, rimH)
      ..lineTo((w - botW) / 2, h * 0.95)
      ..quadraticBezierTo(w / 2, h, (w + botW) / 2, h * 0.95)
      ..lineTo((w + topW) / 2, rimH)
      ..close();

    // Fill
    if (fillLevel > 0) {
      final fillTop = rimH + (h - rimH) * (1 - fillLevel);
      final fillPath = Path()
        ..moveTo((w - topW) / 2 + (topW - botW) / 2 * (1 - fillLevel), fillTop)
        ..lineTo((w - botW) / 2, h * 0.95)
        ..quadraticBezierTo(w / 2, h, (w + botW) / 2, h * 0.95)
        ..lineTo((w + topW) / 2 - (topW - botW) / 2 * (1 - fillLevel), fillTop)
        ..close();

      final fillPaint = Paint()..color = fillColor.withOpacity(0.7);
      canvas.save();
      canvas.clipPath(bodyPath);
      canvas.drawPath(fillPath, fillPaint);
      canvas.restore();
    }

    // Cup outline
    final cupPaint = Paint()
      ..color = const Color(0xFFCCCCCC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(bodyPath, cupPaint);

    // Rim
    final rimPaint = Paint()
      ..color = const Color(0xFFBBBBBB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset((w - topW) / 2, rimH),
      Offset((w + topW) / 2, rimH),
      rimPaint,
    );
  }

  @override
  bool shouldRepaint(_CupPainter old) => old.fillLevel != fillLevel;
}

class _TypeStep extends ConsumerWidget {
  final CustomCoffeeOrder order;
  const _TypeStep({required this.order});

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
                        ? Colors.white.withOpacity(0.2)
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
        const _CupVisual(fillLevel: 0),
        const Spacer(),
      ],
    );
  }
}

class _CupSizeStep extends ConsumerWidget {
  final CustomCoffeeOrder order;
  const _CupSizeStep({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const sizes = ['S', 'M', 'L'];
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
            height: order.cupSize == 'L'
                ? 260
                : order.cupSize == 'M'
                ? 220
                : 180,
            fillLevel: 0,
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class _SugarStep extends ConsumerWidget {
  final CustomCoffeeOrder order;
  const _SugarStep({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double sliderVal = order.sugarLevel == SugarLevel.less
        ? 0
        : order.sugarLevel == SugarLevel.normal
        ? 0.5
        : 1.0;

    final fillLevel = 0.1 + sliderVal * 0.5;

    return StatefulBuilder(
      builder: (context, setLocal) {
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
                        setLocal(() => sliderVal = v);
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
              fillColor: const Color(
                0xFFD4A574,
              ).withOpacity(0.5 + sliderVal * 0.5),
            ),
            const Spacer(),
          ],
        );
      },
    );
  }
}

class _ToppingStep extends StatelessWidget {
  final CustomCoffeeOrder order;
  final String? selectedTopping;
  final List<String> toppings;
  final List<IconData> toppingIcons;
  final ValueChanged<String> onSelect;

  const _ToppingStep({
    required this.order,
    required this.selectedTopping,
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
            final active = toppings[i] == selectedTopping;
            return GestureDetector(
              onTap: () => onSelect(toppings[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 8),
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
        const _CupVisual(fillLevel: 0.6),
        const Spacer(),
      ],
    );
  }
}

class _ResultStep extends StatelessWidget {
  final CustomCoffeeOrder order;
  final Animation<double> fillAnim;

  const _ResultStep({required this.order, required this.fillAnim});

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
        AnimatedBuilder(
          animation: fillAnim,
          builder: (context, child) => _CupVisual(
            fillLevel: fillAnim.value * 0.75,
            fillColor: const Color(0xFFC8864A),
          ),
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
