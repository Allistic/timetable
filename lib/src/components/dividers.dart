import 'package:flutter/material.dart';

import '../config.dart';
import '../theme.dart';
import '../utils.dart';

/// A widget that displays horizontal dividers for a day.
///
/// via the [DividersStyle.interval] you can adjust how these get drawn
///
/// See also:
///
/// * [DividersStyle], which defines visual properties for this widget.
/// * [TimetableTheme] (and [TimetableConfig]), which provide styles to
///   descendant Timetable widgets.
class Dividers extends StatelessWidget {
  const Dividers({
    super.key,
    required this.style,
    this.child,
  });

  final DividersStyle style;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DividersPainter(
        style: style,
      ),
      child: child,
    );
  }
}

/// Defines visual properties for [Dividers].
///
/// See also:
///
/// * [TimetableThemeData], which bundles the styles for all Timetable widgets.
@immutable
class DividersStyle {
  factory DividersStyle(
    BuildContext context, {
    Color? color,
    double? width,
    Duration? interval,
  }) {
    final dividerBorderSide = Divider.createBorderSide(context);
    return DividersStyle.raw(
      color: color ?? dividerBorderSide.color,
      width: width ?? dividerBorderSide.width,
      interval: interval ?? 1.hours,
    );
  }

  const DividersStyle.raw({
    required this.color,
    required this.width,
    required this.interval,
  }) : assert(width >= 0);

  final Color color;
  final double width;
  final Duration interval;

  DividersStyle copyWith({Color? color, double? width, Duration? interval}) {
    return DividersStyle.raw(
      color: color ?? this.color,
      width: width ?? this.width,
      interval: interval ?? this.interval,
    );
  }

  @override
  int get hashCode => Object.hash(color, width);
  @override
  bool operator ==(Object other) {
    return other is DividersStyle && color == other.color && width == other.width;
  }
}

class _DividersPainter extends CustomPainter {
  _DividersPainter({
    required this.style,
  }) : _paint = Paint()
          ..color = style.color
          ..strokeWidth = style.width;

  final DividersStyle style;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    final heightPerDivider = size.height / (1.days / style.interval);
    final strokes = size.height ~/ heightPerDivider;

    for (var dividerNumber = 0; dividerNumber < strokes; dividerNumber++) {
      final y = dividerNumber * heightPerDivider;
      canvas.drawLine(Offset(-8, y), Offset(size.width, y), _paint);
    }
  }

  @override
  bool shouldRepaint(_DividersPainter oldDelegate) => style != oldDelegate.style;
}
