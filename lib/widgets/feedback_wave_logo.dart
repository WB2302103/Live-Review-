import 'dart:math' as math;
import 'package:flutter/material.dart';

/// "The Feedback Wave" Custom Logo Widget
/// Merges QR finder eyes with an ECG live heartbeat pulse wave.
class FeedbackWaveLogo extends StatefulWidget {
  final double size;
  final bool animated;

  const FeedbackWaveLogo({
    super.key,
    this.size = 120,
    this.animated = true,
  });

  @override
  State<FeedbackWaveLogo> createState() => _FeedbackWaveLogoState();
}

class _FeedbackWaveLogoState extends State<FeedbackWaveLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (widget.animated) {
      _controller.repeat(reverse: true);
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
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _FeedbackWavePainter(
            pulseProgress: widget.animated ? _controller.value : 0.5,
          ),
        );
      },
    );
  }
}

class _FeedbackWavePainter extends CustomPainter {
  final double pulseProgress;

  _FeedbackWavePainter({required this.pulseProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double scale = w / 100.0;

    const primaryMint = Color(0xFF34D399);
    const accentCyan = Color(0xFF38BDF8);
    const lightGlow = Color(0xFF6EE7B7);

    final Rect bounds = Rect.fromLTWH(0, 0, w, h);
    final Shader logoShader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primaryMint, accentCyan],
    ).createShader(bounds);

    final Paint mainStroke = Paint();
    mainStroke.shader = logoShader;
    mainStroke.style = PaintingStyle.stroke;
    mainStroke.strokeWidth = 3.5 * scale;
    mainStroke.strokeCap = StrokeCap.round;
    mainStroke.strokeJoin = StrokeJoin.round;

    final Paint mainFill = Paint();
    mainFill.shader = logoShader;
    mainFill.style = PaintingStyle.fill;

    final Paint glowStroke = Paint();
    glowStroke.shader = logoShader;
    glowStroke.style = PaintingStyle.stroke;
    glowStroke.strokeWidth = 6.0 * scale;
    glowStroke.strokeCap = StrokeCap.round;
    glowStroke.strokeJoin = StrokeJoin.round;
    glowStroke.maskFilter = MaskFilter.blur(BlurStyle.normal, 6 * scale);

    _drawFinderPattern(canvas, Offset(75 * scale, 25 * scale), scale, mainStroke, mainFill);
    _drawFinderPattern(canvas, Offset(25 * scale, 75 * scale), scale, mainStroke, mainFill);
    _drawInnerEye(canvas, Offset(25 * scale, 25 * scale), scale, mainFill);

    final Path wavePath = Path();

    wavePath.moveTo(14 * scale, 35 * scale);
    wavePath.lineTo(14 * scale, 18 * scale);
    wavePath.quadraticBezierTo(14 * scale, 14 * scale, 18 * scale, 14 * scale);
    wavePath.lineTo(33 * scale, 14 * scale);

    wavePath.cubicTo(
      42 * scale, 14 * scale,
      40 * scale, 45 * scale,
      48 * scale, 45 * scale,
    );

    wavePath.lineTo(52 * scale, 45 * scale);

    final double pulseMod = (math.sin(pulseProgress * math.pi * 2) * 3.5);

    wavePath.lineTo(55 * scale, (16 - pulseMod) * scale);
    wavePath.lineTo(61 * scale, (72 + pulseMod) * scale);
    wavePath.lineTo(66 * scale, (32 - pulseMod * 0.5) * scale);
    wavePath.lineTo(70 * scale, 48 * scale);

    wavePath.cubicTo(
      76 * scale, 48 * scale,
      80 * scale, 58 * scale,
      86 * scale, 58 * scale,
    );

    canvas.drawPath(wavePath, glowStroke);
    canvas.drawPath(wavePath, mainStroke);

    final Offset dotCenter = Offset(86 * scale, 58 * scale);
    final double dotRadius = 4.0 * scale;
    final double auraRadius = dotRadius + (pulseProgress * 6.0 * scale);

    final Paint auraPaint = Paint();
    final double auraAlpha = ((1.0 - pulseProgress) * 0.6).clamp(0.0, 1.0);
    auraPaint.color = lightGlow.withOpacity(auraAlpha);
    auraPaint.style = PaintingStyle.stroke;
    auraPaint.strokeWidth = 2.0 * scale;

    canvas.drawCircle(dotCenter, auraRadius, auraPaint);

    final Paint dotGlowPaint = Paint();
    dotGlowPaint.color = primaryMint;
    dotGlowPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, 4 * scale);
    canvas.drawCircle(dotCenter, dotRadius, dotGlowPaint);
    canvas.drawCircle(dotCenter, dotRadius, mainFill);
  }

  void _drawFinderPattern(
    Canvas canvas,
    Offset center,
    double scale,
    Paint strokePaint,
    Paint fillPaint,
  ) {
    final double outerSize = 22 * scale;
    final Rect outerRect = Rect.fromCenter(
      center: center,
      width: outerSize,
      height: outerSize,
    );
    final RRect outerRRect = RRect.fromRectAndRadius(
      outerRect,
      Radius.circular(5 * scale),
    );
    canvas.drawRRect(outerRRect, strokePaint);

    _drawInnerEye(canvas, center, scale, fillPaint);
  }

  void _drawInnerEye(
    Canvas canvas,
    Offset center,
    double scale,
    Paint fillPaint,
  ) {
    final double innerSize = 10 * scale;
    final Rect innerRect = Rect.fromCenter(
      center: center,
      width: innerSize,
      height: innerSize,
    );
    final RRect innerRRect = RRect.fromRectAndRadius(
      innerRect,
      Radius.circular(2.5 * scale),
    );
    canvas.drawRRect(innerRRect, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _FeedbackWavePainter oldDelegate) {
    return oldDelegate.pulseProgress != pulseProgress;
  }
}
