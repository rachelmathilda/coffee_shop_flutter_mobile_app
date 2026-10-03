import 'dart:math';
import 'package:flutter/material.dart';

class FlagIcon extends StatelessWidget {
  final String code;
  final double width;
  final double height;

  const FlagIcon({super.key, required this.code, this.width = 58, this.height = 38});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, height: height, child: CustomPaint(painter: _FlagPainter(code)));
  }
}

class _FlagPainter extends CustomPainter {
  final String code;
  _FlagPainter(this.code);

  void _h(Canvas c, Size s, List<Color> colors) {
    final bh = s.height / colors.length;
    for (var i = 0; i < colors.length; i++) {
      c.drawRect(Rect.fromLTWH(0, i * bh, s.width, bh + 0.5), Paint()..color = colors[i]);
    }
  }

  void _v(Canvas c, Size s, List<Color> colors) {
    final bw = s.width / colors.length;
    for (var i = 0; i < colors.length; i++) {
      c.drawRect(Rect.fromLTWH(i * bw, 0, bw + 0.5, s.height), Paint()..color = colors[i]);
    }
  }

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    switch (code) {
      case 'id':
        _h(canvas, s, const [Color(0xFFFF0000), Colors.white]);
        canvas.drawRect(
          Offset.zero & s,
          Paint()
            ..color = const Color(0x22000000)
            ..style = PaintingStyle.stroke,
        );
        break;
      case 'pt':
        canvas.drawRect(Offset.zero & s, Paint()..color = const Color(0xFF009B3A));
        final d = Path()
          ..moveTo(w * 0.08, h / 2)
          ..lineTo(w / 2, h * 0.1)
          ..lineTo(w * 0.92, h / 2)
          ..lineTo(w / 2, h * 0.9)
          ..close();
        canvas.drawPath(d, Paint()..color = const Color(0xFFFEDF00));
        canvas.drawCircle(Offset(w / 2, h / 2), h * 0.24, Paint()..color = const Color(0xFF002776));
        canvas.drawArc(
          Rect.fromCircle(center: Offset(w / 2, h * 0.62), radius: h * 0.26),
          pi * 1.15,
          pi * 0.7,
          false,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = h * 0.05,
        );
        break;
      case 'en':
        canvas.drawRect(Offset.zero & s, Paint()..color = const Color(0xFF012169));
        final white = Paint()
          ..color = Colors.white
          ..strokeWidth = h * 0.2;
        canvas.drawLine(Offset.zero, Offset(w, h), white);
        canvas.drawLine(Offset(w, 0), Offset(0, h), white);
        final red = Paint()
          ..color = const Color(0xFFC8102E)
          ..strokeWidth = h * 0.07;
        canvas.drawLine(Offset.zero, Offset(w, h), red);
        canvas.drawLine(Offset(w, 0), Offset(0, h), red);
        canvas.drawRect(Rect.fromCenter(center: Offset(w / 2, h / 2), width: w, height: h * 0.33), Paint()..color = Colors.white);
        canvas.drawRect(Rect.fromCenter(center: Offset(w / 2, h / 2), width: h * 0.33, height: h), Paint()..color = Colors.white);
        canvas.drawRect(Rect.fromCenter(center: Offset(w / 2, h / 2), width: w, height: h * 0.2), Paint()..color = const Color(0xFFC8102E));
        canvas.drawRect(Rect.fromCenter(center: Offset(w / 2, h / 2), width: h * 0.2, height: h), Paint()..color = const Color(0xFFC8102E));
        break;
      case 'fr':
        _v(canvas, s, const [Color(0xFF0055A4), Colors.white, Color(0xFFEF4135)]);
        break;
      case 'de':
        _h(canvas, s, const [Colors.black, Color(0xFFDD0000), Color(0xFFFFCE00)]);
        break;
      case 'it':
        _v(canvas, s, const [Color(0xFF009246), Colors.white, Color(0xFFCE2B37)]);
        break;
      case 'hi':
        _h(canvas, s, const [Color(0xFFFF9933), Colors.white, Color(0xFF138808)]);
        final c = Offset(w / 2, h / 2);
        final navy = Paint()
          ..color = const Color(0xFF000080)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        canvas.drawCircle(c, h * 0.14, navy);
        for (var i = 0; i < 12; i++) {
          final a = i * pi / 6;
          canvas.drawLine(c, c + Offset(cos(a), sin(a)) * h * 0.14, navy..strokeWidth = 0.6);
        }
        break;
      case 'ko':
        canvas.drawRect(Offset.zero & s, Paint()..color = Colors.white);
        final c = Offset(w / 2, h / 2);
        final r = h * 0.25;
        final circle = Rect.fromCircle(center: c, radius: r);
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.rotate(pi / 5.5);
        canvas.translate(-c.dx, -c.dy);
        canvas.drawArc(circle, pi, pi, true, Paint()..color = const Color(0xFFCD2E3A));
        canvas.drawArc(circle, 0, pi, true, Paint()..color = const Color(0xFF0047A0));
        canvas.drawCircle(c.translate(-r / 2, 0), r / 2, Paint()..color = const Color(0xFFCD2E3A));
        canvas.drawCircle(c.translate(r / 2, 0), r / 2, Paint()..color = const Color(0xFF0047A0));
        canvas.restore();
        final bar = Paint()
          ..color = Colors.black
          ..strokeWidth = 1.6;
        void tri(Offset o, double angle) {
          canvas.save();
          canvas.translate(o.dx, o.dy);
          canvas.rotate(angle);
          for (var i = -1; i <= 1; i++) {
            canvas.drawLine(Offset(-h * 0.08, i * 2.6), Offset(h * 0.08, i * 2.6), bar);
          }
          canvas.restore();
        }
        tri(Offset(w * 0.22, h * 0.2), -pi / 3.2);
        tri(Offset(w * 0.78, h * 0.8), -pi / 3.2);
        tri(Offset(w * 0.78, h * 0.2), pi / 3.2);
        tri(Offset(w * 0.22, h * 0.8), pi / 3.2);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _FlagPainter old) => old.code != code;
}
