import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AuthWave extends StatelessWidget {
  final bool signUp;
  const AuthWave({super.key, this.signUp = false});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = (signUp ? 216 : 272) * w / 412;
    return SizedBox(
      width: double.infinity,
      height: h,
      child: CustomPaint(painter: signUp ? _SignUpWave() : _SignInWave()),
    );
  }
}

Paint _fill(Color c) => Paint()..color = c;

void _shadowed(Canvas canvas, Path p, Color c) {
  canvas.drawShadow(p, Colors.black, 3, false);
  canvas.drawPath(p, _fill(c));
}

class _SignInWave extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 412;
    final beige = Path()
      ..moveTo(0, 0)
      ..lineTo(0, 270 * s)
      ..cubicTo(30 * s, 240 * s, 80 * s, 214 * s, 150 * s, 218 * s)
      ..cubicTo(250 * s, 224 * s, 330 * s, 262 * s, 412 * s, 268 * s)
      ..lineTo(412 * s, 0)
      ..close();
    _shadowed(canvas, beige, AppColors.sand);
    final terra = Path()
      ..moveTo(0, 0)
      ..lineTo(0, 190 * s)
      ..cubicTo(90 * s, 188 * s, 160 * s, 178 * s, 220 * s, 152 * s)
      ..cubicTo(275 * s, 128 * s, 330 * s, 170 * s, 412 * s, 186 * s)
      ..lineTo(412 * s, 0)
      ..close();
    _shadowed(canvas, terra, AppColors.terracotta);
    final dark = Path()
      ..moveTo(0, 0)
      ..lineTo(0, 94 * s)
      ..cubicTo(50 * s, 82 * s, 110 * s, 124 * s, 220 * s, 124 * s)
      ..lineTo(412 * s, 124 * s)
      ..lineTo(412 * s, 0)
      ..close();
    _shadowed(canvas, dark, AppColors.charcoal);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SignUpWave extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 412;
    final beige = Path()
      ..moveTo(0, 0)
      ..lineTo(0, 214 * s)
      ..cubicTo(60 * s, 214 * s, 70 * s, 140 * s, 110 * s, 138 * s)
      ..cubicTo(190 * s, 134 * s, 330 * s, 180 * s, 412 * s, 212 * s)
      ..lineTo(412 * s, 0)
      ..close();
    _shadowed(canvas, beige, AppColors.sand);
    final terra = Path()
      ..moveTo(0, 0)
      ..lineTo(0, 150 * s)
      ..cubicTo(60 * s, 152 * s, 110 * s, 120 * s, 170 * s, 120 * s)
      ..cubicTo(260 * s, 122 * s, 330 * s, 150 * s, 412 * s, 152 * s)
      ..lineTo(412 * s, 0)
      ..close();
    _shadowed(canvas, terra, AppColors.terracotta);
    final dark = Path()
      ..moveTo(0, 0)
      ..lineTo(0, 92 * s)
      ..cubicTo(70 * s, 80 * s, 120 * s, 60 * s, 200 * s, 66 * s)
      ..cubicTo(280 * s, 72 * s, 340 * s, 96 * s, 412 * s, 92 * s)
      ..lineTo(412 * s, 0)
      ..close();
    _shadowed(canvas, dark, AppColors.charcoal);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
