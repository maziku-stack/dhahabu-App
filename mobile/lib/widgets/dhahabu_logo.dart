import 'package:flutter/material.dart';

/// A compact, scalable Dhahabu mark inspired by the gold bars in OIP.webp.
class DhahabuLogo extends StatelessWidget {
  final double size;

  const DhahabuLogo({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Dhahabu gold bar logo',
        image: true,
        child: SizedBox.square(
          dimension: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF0B1F3A),
              borderRadius: BorderRadius.circular(size * 0.24),
              border: Border.all(color: const Color(0xFFC9A227), width: 1.4),
            ),
            child: CustomPaint(painter: _GoldBarMarkPainter()),
          ),
        ),
      );
}

class _GoldBarMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide;
    Offset p(double x, double y) => Offset(x * scale, y * scale);
    Path polygon(List<Offset> points) => Path()
      ..moveTo(points.first.dx, points.first.dy)
      ..addPolygon(points.skip(1).toList(), true);

    final glow = Paint()
      ..color = const Color(0xFFC9A227).withValues(alpha: 0.14)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, scale * 0.12);
    canvas.drawCircle(p(0.5, 0.5), scale * 0.3, glow);

    final back = polygon([
      p(0.25, 0.36),
      p(0.38, 0.25),
      p(0.72, 0.25),
      p(0.82, 0.35),
      p(0.69, 0.47),
      p(0.34, 0.47),
    ]);
    canvas.drawPath(back, Paint()..color = const Color(0xFFE8BD4B));

    final top = polygon([
      p(0.18, 0.48),
      p(0.34, 0.34),
      p(0.79, 0.34),
      p(0.86, 0.46),
      p(0.70, 0.57),
      p(0.25, 0.57),
    ]);
    final topPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFE58A), Color(0xFFD4A52F)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(top, topPaint);

    final front = polygon([
      p(0.25, 0.57),
      p(0.70, 0.57),
      p(0.65, 0.75),
      p(0.30, 0.75),
    ]);
    canvas.drawPath(
      front,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD6A632), Color(0xFF9B6813)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    final side = polygon([
      p(0.70, 0.57),
      p(0.86, 0.46),
      p(0.80, 0.65),
      p(0.65, 0.75),
    ]);
    canvas.drawPath(side, Paint()..color = const Color(0xFFB77B16));

    final shine = Paint()
      ..color = const Color(0xFFFFF1B9)
      ..strokeWidth = scale * 0.018
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(p(0.36, 0.39), p(0.75, 0.39), shine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
