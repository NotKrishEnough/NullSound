import 'dart:ui';
import 'package:flutter/material.dart';

/// A reusable translucent surface for NullSound's dark glass UI.
class GlassPanel extends StatelessWidget {
  const GlassPanel({super.key, required this.child, this.padding, this.radius = 24, this.tint});
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint ?? scheme.surface.withValues(alpha: .58),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: scheme.onSurface.withValues(alpha: .10)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.onSurface.withValues(alpha: .075),
                scheme.onSurface.withValues(alpha: .018),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GlassBackground extends StatelessWidget {
  const GlassBackground({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Stack(children: [
    Positioned(top: -100, right: -80, child: _Glow(color: const Color(0xff8d65c7), size: 260)),
    Positioned(top: 280, left: -140, child: _Glow(color: const Color(0xffbd6c8a), size: 260)),
    Positioned(bottom: 80, right: -150, child: _Glow(color: const Color(0xff4e7b9c), size: 280)),
    Positioned.fill(child: child),
  ]);
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 65, sigmaY: 65),
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: .20)),
      ),
    ),
  );
}
