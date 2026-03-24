import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BreathingWidget extends StatelessWidget {
  final Widget child;

  const BreathingWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.04, 1.04),
          duration: 1500.ms,
          curve: Curves.easeInOutSine,
        );
  }
}
