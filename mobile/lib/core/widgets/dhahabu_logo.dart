import 'package:flutter/material.dart';

/// A compact Dhahabu brand mark: a faceted gold ingot with an engraved D.
class DhahabuLogo extends StatelessWidget {
  final double size;

  const DhahabuLogo({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Dhahabu gold ingot logo',
        image: true,
        child: SizedBox.square(
          dimension: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF09182B),
              borderRadius: BorderRadius.circular(size * 0.23),
            ),
            child: CustomPaint(painter: _DhahabuMarkPainter()),
          ),
        ),
      );
}

class _DhahabuMarkPainter extends CustomPainter {
  static const _navy = Color(0xFF09182B);

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.shortestSide;
    Offset p(double x, double y) => Offset(x * unit, y * unit);
    Path polygon(List<Offset> points) => Path()
      ..moveTo(points.first.dx, points.first.dy)
      ..addPolygon(points.skip(1).toList(), true);
    final bounds = Rect.fromLTWH(0, 0, size.width, size.height);

    // Low, broad ingot silhouette stays legible at launcher-icon scale.
    final top = polygon([
      p(.19, .37), p(.34, .25), p(.70, .25), p(.83, .37),
      p(.72, .47), p(.28, .47),
    ]);
    canvas.drawPath(
      top,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE9A3), Color(0xFFE1B84C), Color(0xFFB77C19)],
        ).createShader(bounds),
    );

    final face = polygon([
      p(.28, .47), p(.72, .47), p(.67, .73), p(.34, .73),
    ]);
    canvas.drawPath(
      face,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEBC85F), Color(0xFFC28B27), Color(0xFF9B671A)],
        ).createShader(bounds),
    );

    final side = polygon([
      p(.72, .47), p(.83, .37), p(.78, .64), p(.67, .73),
    ]);
    canvas.drawPath(side, Paint()..color = const Color(0xFFB77A1B));

    // One restrained highlight gives the upper bevel a crafted metal edge.
    final edge = Paint()
      ..color = const Color(0xFFFFF2C5).withValues(alpha: .78)
      ..strokeWidth = unit * .018
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(p(.36, .29), p(.68, .29), edge);

    // Engraved D: a simple monoline, with enough weight to survive small sizes.
    final d = Path()
      ..moveTo(p(.43, .54).dx, p(.54, .54).dy)
      ..lineTo(p(.43, .66).dx, p(.66, .66).dy)
      ..cubicTo(
        p(.61, .66).dx, p(.66, .66).dy,
        p(.63, .54).dx, p(.54, .54).dy,
        p(.43, .54).dx, p(.54, .54).dy,
      );
    canvas.drawPath(
      d,
      Paint()
        ..color = _navy.withValues(alpha: .82)
        ..style = PaintingStyle.stroke
        ..strokeWidth = unit * .028
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
