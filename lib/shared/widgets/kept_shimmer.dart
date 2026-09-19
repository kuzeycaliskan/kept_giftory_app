import 'package:flutter/material.dart';

/// A slow highlight sweep over [child] — the "something's glowing" cue for
/// the surprise teaser. Subtle by design: low-alpha band, long period.
class KeptShimmer extends StatefulWidget {
  const KeptShimmer({required this.child, super.key});

  final Widget child;

  @override
  State<KeptShimmer> createState() => _KeptShimmerState();
}

class _KeptShimmerState extends State<KeptShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highlight = Theme.of(context).colorScheme.onPrimaryContainer;
    return AnimatedBuilder(
      animation: _sweep,
      child: widget.child,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) {
          // Band travels from left of the box to right of it, then rests.
          final t = _sweep.value * 1.6 - 0.3;
          return LinearGradient(
            colors: [
              Colors.transparent,
              highlight.withValues(alpha: 0.18),
              Colors.transparent,
            ],
            stops: [
              (t - 0.2).clamp(0.0, 1.0),
              t.clamp(0.0, 1.0),
              (t + 0.2).clamp(0.0, 1.0),
            ],
          ).createShader(bounds);
        },
        child: child,
      ),
    );
  }
}
