import 'package:flutter/material.dart';

class AnimatedCounterText extends StatelessWidget {
  final num value;
  final String prefix;
  final String suffix;
  final TextStyle? style;
  final int decimals;

  const AnimatedCounterText({
    super.key,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.style,
    this.decimals = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutExpo,
      builder: (context, val, child) {
        String display = decimals == 0 ? val.toInt().toString() : val.toStringAsFixed(decimals);
        return Text('$prefix$display$suffix', style: style);
      },
    );
  }
}
