import 'package:flutter/material.dart';

/// A skeleton loading grid with shimmer animation.
///
/// Displays [count] placeholder cards in a grid with [columnCount] columns.
/// Defaults to 6 cards in 2 columns.
class SkeletonGrid extends StatefulWidget {
  final int columnCount;
  final int count;

  const SkeletonGrid({super.key, this.columnCount = 2, this.count = 6})
      : assert(columnCount > 0, 'columnCount must be positive');

  @override
  State<SkeletonGrid> createState() => _SkeletonGridState();
}

class _SkeletonGridState extends State<SkeletonGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.grey[300]!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final animatedColor =
            baseColor.withAlpha((255 * _animation.value).round());
        return _ShimmerColor(
          color: animatedColor,
          child: child!,
        );
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(7.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.columnCount,
          childAspectRatio: 1.0,
          mainAxisSpacing: 7.0,
          crossAxisSpacing: 7.0,
        ),
        itemCount: widget.count,
        itemBuilder: (context, index) {
          final color = _ShimmerColor.of(context);
          return Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8.0),
            ),
          );
        },
      ),
    );
  }
}

/// Internal [InheritedWidget] that supplies the animated shimmer color
/// to placeholder cards without rebuilding the grid structure each frame.
class _ShimmerColor extends InheritedWidget {
  final Color color;

  const _ShimmerColor({required this.color, required super.child});

  static Color of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ShimmerColor>()!.color;

  @override
  bool updateShouldNotify(_ShimmerColor old) => old.color != color;
}
