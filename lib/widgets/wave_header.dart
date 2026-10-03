import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class WaveHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const WaveHeader({super.key, required this.title, this.onBack});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: top + 122,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _HeaderWavePainter(top)),
          ),
          Positioned(
            top: top + 22,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    title,
                    style: AppText.s(22, weight: FontWeight.w600, color: Colors.white, spacing: 0.4),
                  ),
                  Positioned(
                    left: 28,
                    child: IconButton(
                      onPressed: onBack ??
                          () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/home');
                            }
                          },
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderWavePainter extends CustomPainter {
  final double top;
  _HeaderWavePainter(this.top);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final sx = w / 412;
    double y(double v) => top + v;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, y(98))
      ..cubicTo(35 * sx, y(80), 90 * sx, y(80), 150 * sx, y(102))
      ..cubicTo(205 * sx, y(122), 300 * sx, y(112), w, y(100))
      ..lineTo(w, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.header);
  }

  @override
  bool shouldRepaint(covariant _HeaderWavePainter old) => old.top != top;
}
