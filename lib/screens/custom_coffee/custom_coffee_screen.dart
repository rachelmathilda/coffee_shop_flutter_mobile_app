import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/strings.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/painters.dart';

class CustomCoffeeScreen extends ConsumerStatefulWidget {
  const CustomCoffeeScreen({super.key});

  @override
  ConsumerState<CustomCoffeeScreen> createState() => _CustomCoffeeScreenState();
}

class _CustomCoffeeScreenState extends ConsumerState<CustomCoffeeScreen> {
  int _step = 0;

  static const _beans = ['Arabica', 'Liberica', 'Robusta', 'Excelsa'];
  static const _toppings = ['Pudding', 'Pearl', 'Caramel', 'Cream'];

  double _price(CustomCoffeeOrder o, AppSettings s) {
    final v = s.customBase + s.customSizeExtra(o.cupSize) + (o.topping.isEmpty ? 0 : s.toppingPrice);
    return double.parse(v.toStringAsFixed(2));
  }

  void _update(CustomCoffeeOrder Function(CustomCoffeeOrder) f) {
    final n = ref.read(customCoffeeProvider.notifier);
    n.state = f(n.state);
  }

  void _order() {
    final t = ref.read(stringsProvider);
    final o = ref.read(customCoffeeProvider);
    final s = ref.read(appSettingsProvider);
    final sugar = [t('less'), t('normal'), t('high')][o.sugar];
    final key = ref.read(cartProvider.notifier).add(
          coffeeId: 'custom',
          name: 'Custom ${o.coffeeType}',
          image: o.iced ? 'assets/images/coffee2.png' : 'assets/images/coffee4.png',
          unitPrice: _price(o, s),
          isCustom: true,
          options: {
            'temp': o.iced ? 'Iced' : 'Hot',
            'type': o.coffeeType,
            'size': o.cupSize,
            'sugar': sugar,
            'topping': o.topping,
          },
        );
    ref.read(lastCartKeyProvider.notifier).state = key;
    context.pushReplacement('/cart');
  }

  void _back() {
    if (_step == 0) {
      context.pop();
    } else {
      setState(() => _step--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(stringsProvider);
    final o = ref.watch(customCoffeeProvider);
    final s = ref.watch(appSettingsProvider);
    final titles = [t('type'), t('coffeeType'), t('cupSize'), t('sugar'), t('topping'), t('result')];
    final cupScale = o.cupSize == 'S' ? 0.82 : (o.cupSize == 'M' ? 0.91 : 1.0);

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 32),
              Text(titles[_step], style: AppText.s(22, weight: FontWeight.w500)),
              const SizedBox(height: 22),
              SizedBox(
                height: 110,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: KeyedSubtree(key: ValueKey(_step), child: _options(o, t)),
                ),
              ),
              Expanded(
                child: Center(child: PlasticCup(scale: _step >= 2 ? cupScale : 1)),
              ),
              if (_step == 5) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Row(
                    children: [
                      Text(t('price'), style: AppText.s(20)),
                      const Spacer(),
                      Text(
                        money(_price(o, s)),
                        style: AppText.s(32, weight: FontWeight.w700, color: AppColors.terracotta),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: PrimaryButton(label: t('order'), onTap: _order, radius: 16, fontSize: 20),
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 37),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlineButtonX(
                          label: _step == 0 ? t('back') : t('previous'),
                          onTap: _back,
                          radius: 16,
                          textColor: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: PrimaryButton(
                          label: t('next'),
                          onTap: () => setState(() => _step++),
                          radius: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 52),
            ],
          ),
        ),
      ),
    );
  }

  Widget _options(CustomCoffeeOrder o, Strings t) {
    switch (_step) {
      case 0:
        return Align(
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onTap: () => _update((x) => x.copyWith(iced: !x.iced)),
            child: Container(
              width: 138,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppColors.charcoal),
              ),
              child: Stack(
                children: [
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: o.iced ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(color: AppColors.charcoal, shape: BoxShape.circle),
                    ),
                  ),
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: o.iced ? const Alignment(0.45, 0) : const Alignment(-0.45, 0),
                    child: Text(o.iced ? t('iced') : t('hot'), style: AppText.s(20)),
                  ),
                ],
              ),
            ),
          ),
        );
      case 1:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _beans
              .map((b) => _CircleOption(
                    label: b,
                    selected: o.coffeeType == b,
                    onTap: () => _update((x) => x.copyWith(coffeeType: b)),
                    child: Image.asset('assets/images/${b.toLowerCase()}.png', width: 46, height: 46),
                  ))
              .toList(),
        );
      case 2:
        return Align(
          alignment: Alignment.topCenter,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: ['S', 'M', 'L']
                .map((e) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _update((x) => x.copyWith(cupSize: e)),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: o.cupSize == e ? AppColors.terracotta : const Color(0xFFD6CFC2),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(e, style: AppText.s(22)),
                        ),
                      ),
                    ))
                .toList(),
          ),
        );
      case 3:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 52),
          child: Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  activeTrackColor: AppColors.sliderTrack,
                  inactiveTrackColor: AppColors.sliderTrack,
                  thumbColor: AppColors.charcoal,
                  overlayColor: const Color(0x224A4846),
                  thumbShape: const _RectThumb(),
                  tickMarkShape: SliderTickMarkShape.noTickMark,
                  trackShape: const RectangularSliderTrackShape(),
                ),
                child: Slider(
                  value: o.sugar.toDouble(),
                  min: 0,
                  max: 2,
                  divisions: 2,
                  onChanged: (v) => _update((x) => x.copyWith(sugar: v.round())),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(t('less'), style: AppText.s(14, weight: FontWeight.w300)),
                    Text(t('normal'), style: AppText.s(14, weight: FontWeight.w300)),
                    Text(t('high'), style: AppText.s(14, weight: FontWeight.w300)),
                  ],
                ),
              ),
            ],
          ),
        );
      case 4:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _toppings
              .map((p) => _CircleOption(
                    label: p,
                    selected: o.topping == p,
                    onTap: () => _update((x) => x.copyWith(topping: x.topping == p ? '' : p)),
                    child: p == 'Pearl'
                        ? const PearlIcon(size: 40)
                        : Image.asset('assets/images/${p.toLowerCase()}.png', width: 44, height: 44),
                  ))
              .toList(),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _CircleOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  const _CircleOption({required this.label, required this.selected, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppColors.caramel : AppColors.sand,
            ),
            alignment: Alignment.center,
            child: child,
          ),
          const SizedBox(height: 4),
          Text(label, style: AppText.s(14, weight: FontWeight.w300, color: const Color(0xFF444444))),
        ],
      ),
    );
  }
}

class _RectThumb extends SliderComponentShape {
  const _RectThumb();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(14, 18);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final r = RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: 14, height: 18), const Radius.circular(3));
    context.canvas.drawRRect(r, Paint()..color = AppColors.charcoal);
  }
}
