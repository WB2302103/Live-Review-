import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConfettiParticleBurst extends StatefulWidget {
  final Widget child;

  const ConfettiParticleBurst({super.key, required this.child});

  @override
  State<ConfettiParticleBurst> createState() => _ConfettiParticleBurstState();
}

class _ConfettiParticleBurstState extends State<ConfettiParticleBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    final random = math.Random();
    const colors = [
      Color(0xFF34D399), // Mint
      Color(0xFF38BDF8), // Cyan
      Color(0xFFF59E0B), // Amber
      Color(0xFFEC4899), // Pink
      Color(0xFF8B5CF6), // Purple
      Color(0xFF10B981), // Emerald
    ];

    _particles = List.generate(45, (i) {
      final angle = random.nextDouble() * 2 * math.pi;
      final speed = 80 + random.nextDouble() * 220;
      return _Particle(
        color: colors[random.nextInt(colors.length)],
        angle: angle,
        speed: speed,
        size: 5 + random.nextDouble() * 7,
        rotationSpeed: (random.nextDouble() - 0.5) * 8,
        isCircle: random.nextBool(),
      );
    });

    _controller.forward();
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
          foregroundPainter: _ParticlePainter(
            progress: _controller.value,
            particles: _particles,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _Particle {
  final Color color;
  final double angle;
  final double speed;
  final double size;
  final double rotationSpeed;
  final bool isCircle;

  _Particle({
    required this.color,
    required this.angle,
    required this.speed,
    required this.size,
    required this.rotationSpeed,
    required this.isCircle,
  });
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;

  _ParticlePainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0 || progress == 1.0) return;

    final Offset center = Offset(size.width / 2, size.height / 2 - 40);
    final double opacity = (1.0 - progress).clamp(0.0, 1.0);

    for (var p in particles) {
      final double distance = p.speed * progress;
      final double gravity = 180 * progress * progress;

      final double dx = center.dx + math.cos(p.angle) * distance;
      final double dy = center.dy + math.sin(p.angle) * distance + gravity;

      final Paint paint = Paint()
        ..color = p.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(progress * p.rotationSpeed);

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          paint,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
