import 'dart:math';
import 'package:flutter/material.dart';

class PlasticCup extends StatelessWidget {
  final double scale;
  const PlasticCup({super.key, this.scale = 1});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: const SizedBox(
        width: 240,
        height: 312,
        child: CustomPaint(painter: _CupPainter()),
      ),
    );
  }
}

class _CupPainter extends CustomPainter {
  const _CupPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final topL = 4.0;
    final topR = w - 4;
    final botL = w * 0.17;
    final botR = w * 0.83;
    final rimY = 12.0;
    final botY = h - 18;

    final body = Path()
      ..moveTo(topL + 6, rimY + 8)
      ..lineTo(botL, botY)
      ..quadraticBezierTo(w / 2, botY + 14, botR, botY)
      ..lineTo(topR - 6, rimY + 8)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0x18000000), Color(0x05FFFFFF), Color(0x08000000), Color(0x1A000000)],
          stops: [0, 0.35, 0.7, 1],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
    final edge = Paint()
      ..color = const Color(0x55808080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawPath(body, edge);

    final rim = Rect.fromLTRB(topL, rimY - 6, topR, rimY + 14);
    canvas.drawOval(rim, Paint()..color = const Color(0x10000000));
    canvas.drawOval(rim, edge..strokeWidth = 1.6);
    final rim2 = Rect.fromLTRB(topL + 4, rimY + 2, topR - 4, rimY + 20);
    canvas.drawArc(rim2, 0, pi, false, edge..strokeWidth = 1);

    final bottom = Rect.fromLTRB(botL + 2, botY - 12, botR - 2, botY + 10);
    canvas.drawOval(bottom, Paint()..color = const Color(0x14000000));
    canvas.drawOval(bottom, edge..strokeWidth = 1.2);

    final shine = Paint()
      ..color = const Color(0x66FFFFFF)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.2, rimY + 40), Offset(w * 0.27, botY - 30), shine);
    canvas.drawLine(
      Offset(w * 0.76, rimY + 40),
      Offset(w * 0.71, botY - 40),
      shine..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PatternBackground extends StatelessWidget {
  final Widget? child;
  const PatternBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _PatternPainter(), child: child);
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFBA8C6D));
    final line = Paint()
      ..color = const Color(0xFFCBA083)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    const tile = 72.0;
    for (double y = -tile / 2; y < size.height + tile; y += tile) {
      for (double x = -tile / 2; x < size.width + tile; x += tile) {
        final odd = ((x / tile).floor() + (y / tile).floor()).isOdd;
        final c = Offset(x + tile / 2, y + tile / 2);
        if (odd) {
          for (int i = 1; i <= 4; i++) {
            final r = i * 8.0;
            canvas.drawRect(Rect.fromCenter(center: c, width: r * 2, height: r * 2), line);
          }
        } else {
          for (int i = 1; i <= 4; i++) {
            final r = i * 9.0;
            canvas.drawArc(
              Rect.fromCircle(center: Offset(x, y), radius: r),
              0,
              pi / 2,
              false,
              line,
            );
            canvas.drawArc(
              Rect.fromCircle(center: Offset(x + tile, y + tile), radius: r),
              pi,
              pi / 2,
              false,
              line,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PearlIcon extends StatelessWidget {
  final double size;
  const PearlIcon({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: size, height: size * 0.7, child: CustomPaint(painter: _PearlPainter()));
  }
}

class _PearlPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 9;
    final pts = <Offset>[
      Offset(r * 1.2, r * 2.2),
      Offset(r * 3.2, r * 1.6),
      Offset(r * 5.2, r * 2.0),
      Offset(r * 7.4, r * 1.4),
      Offset(r * 2.2, r * 4.0),
      Offset(r * 4.2, r * 3.8),
      Offset(r * 6.4, r * 3.6),
      Offset(r * 8.0, r * 3.2),
    ];
    for (final p in pts) {
      canvas.drawCircle(p, r, Paint()..color = const Color(0xFF1E1E26));
      canvas.drawCircle(p.translate(-r * 0.35, -r * 0.35), r * 0.3, Paint()..color = const Color(0x88FFFFFF));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
