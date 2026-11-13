import 'dart:math' as math;
import 'package:flutter/material.dart';

/// "LR" Negative-Space Checkmark Hexagon Logo Widget with Advanced Animations
class LiveReviewLogo extends StatefulWidget {
  final double size;
  final bool animated;

  const LiveReviewLogo({
    super.key,
    this.size = 120,
    this.animated = true,
  });

  @override
  State<LiveReviewLogo> createState() => _LiveReviewLogoState();
}

class _LiveReviewLogoState extends State<LiveReviewLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    if (widget.animated) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = widget.animated ? _controller.value : 0.5;
        // Subtle floating / breathing motion
        final floatOffset = math.sin(progress * math.pi * 2) * 5.0;

        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _LiveReviewLogoPainter(
              pulseProgress: progress,
            ),
          ),
        );
      },
    );
  }
}

class _LiveReviewLogoPainter extends CustomPainter {
  final double pulseProgress;

  _LiveReviewLogoPainter({required this.pulseProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double scale = w / 100.0;
    final Offset center = Offset(w / 2, h / 2);

    const primaryTeal = Color(0xFF0F766E);
    const neonMint = Color(0xFF34D399);
    const brightCyan = Color(0xFF38BDF8);

    final Rect bounds = Rect.fromLTWH(0, 0, w, h);
    final Shader hexShader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primaryTeal, Color(0xFF111827)],
    ).createShader(bounds);

    final Shader accentShader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [neonMint, brightCyan],
    ).createShader(bounds);

    // 1. Expanding Radar Pulse Waves (2 Outer Glowing Rings)
    for (int i = 0; i < 2; i++) {
      final double ringPhase = (pulseProgress + (i * 0.5)) % 1.0;
      final double ringRadius = (44 + ringPhase * 16) * scale;
      final double ringOpacity = ((1.0 - ringPhase) * 0.5).clamp(0.0, 1.0);

      final Path auraPath = _createRoundedHexagonPath(center, ringRadius, 10 * scale);
      final Paint auraPaint = Paint()
        ..color = neonMint.withOpacity(ringOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 * scale;

      canvas.drawPath(auraPath, auraPaint);
    }

    // 2. Base Hexagon Path
    final Path hexPath = _createRoundedHexagonPath(center, 44 * scale, 8 * scale);

    // Glowing Neon Shadow Pass
    final double pulseScale = math.sin(pulseProgress * math.pi * 2);
    final Paint glowPaint = Paint()
      ..shader = accentShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = (3.5 + pulseScale.abs() * 1.5) * scale
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, (6 + pulseScale.abs() * 4) * scale);

    canvas.drawPath(hexPath, glowPaint);

    // Fill Hexagon Background
    final Paint bgPaint = Paint()
      ..shader = hexShader
      ..style = PaintingStyle.fill;
    canvas.drawPath(hexPath, bgPaint);

    // Border Frame
    final Paint borderPaint = Paint()
      ..shader = accentShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * scale;
    canvas.drawPath(hexPath, borderPaint);

    // 3. Orbiting Shimmer Light Dot around Hexagon Border
    final double orbitAngle = pulseProgress * 2 * math.pi - (math.pi / 2);
    final Offset orbitDotPos = Offset(
      center.dx + 44 * scale * math.cos(orbitAngle),
      center.dy + 44 * scale * math.sin(orbitAngle),
    );

    final Paint orbitDotGlow = Paint()
      ..color = neonMint
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 * scale);
    canvas.drawCircle(orbitDotPos, 4.5 * scale, orbitDotGlow);

    final Paint orbitDot = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(orbitDotPos, 2.5 * scale, orbitDot);

    // 4. Draw "L" and "R" Monogram
    final Paint markPaint = Paint()
      ..shader = accentShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // "L" Left Bar
    final Path lPath = Path();
    lPath.moveTo(center.dx - 18 * scale, center.dy - 18 * scale);
    lPath.lineTo(center.dx - 18 * scale, center.dy + 16 * scale);
    lPath.lineTo(center.dx - 6 * scale, center.dy + 16 * scale);
    canvas.drawPath(lPath, markPaint);

    // "R" Right Stem & Loop
    final Path rPath = Path();
    rPath.moveTo(center.dx + 6 * scale, center.dy - 18 * scale);
    rPath.lineTo(center.dx + 6 * scale, center.dy + 16 * scale);
    rPath.moveTo(center.dx + 6 * scale, center.dy - 18 * scale);
    rPath.cubicTo(
      center.dx + 22 * scale, center.dy - 18 * scale,
      center.dx + 22 * scale, center.dy - 2 * scale,
      center.dx + 6 * scale, center.dy - 2 * scale,
    );
    rPath.lineTo(center.dx + 18 * scale, center.dy + 16 * scale);
    canvas.drawPath(rPath, markPaint);

    // 5. Animated Negative Space Checkmark (✓) with Glow & Pulsing Scale
    final double checkScale = 1.0 + (pulseScale * 0.08);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(checkScale);
    canvas.translate(-center.dx, -center.dy);

    final Path checkPath = Path();
    checkPath.moveTo(center.dx - 8 * scale, center.dy + 2 * scale);
    checkPath.lineTo(center.dx - 1 * scale, center.dy + 9 * scale);
    checkPath.lineTo(center.dx + 12 * scale, center.dy - 8 * scale);

    final Paint checkGlowPaint = Paint()
      ..color = neonMint
      ..style = PaintingStyle.stroke
      ..strokeWidth = (4.5 + pulseScale.abs() * 1.5) * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 * scale);

    final Paint checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.8 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(checkPath, checkGlowPaint);
    canvas.drawPath(checkPath, checkPaint);

    canvas.restore();
  }

  Path _createRoundedHexagonPath(Offset center, double radius, double cornerRadius) {
    final Path path = Path();
    final List<Offset> points = [];

    for (int i = 0; i < 6; i++) {
      final double angle = (i * 60 - 30) * math.pi / 180;
      points.add(Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      ));
    }

    path.moveTo(
      (points[0].dx + points[5].dx) / 2,
      (points[0].dy + points[5].dy) / 2,
    );

    for (int i = 0; i < 6; i++) {
      final Offset p1 = points[i];
      final Offset p2 = points[(i + 1) % 6];
      path.quadraticBezierTo(p1.dx, p1.dy, (p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _LiveReviewLogoPainter oldDelegate) {
    return oldDelegate.pulseProgress != pulseProgress;
  }
}
