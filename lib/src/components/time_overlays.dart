import 'package:flutter/material.dart';
import 'package:remind_timetable/src/time/controller.dart';

import '../event/event.dart';
import '../time/overlay.dart';
import '../utils.dart';
import 'date_content.dart';

/// A widget that displays the given [TimeOverlay]s.
///
/// This widget doesn't honor [TimeOverlay]'s `position` by itself, so you might
/// have to split your [TimeOverlay]s and display them in two separate widgets.
///
/// See also:
///
/// * [DateContent], which displays [Event]s and [TimeOverlay]s and also honors
///   the `position`s.
class TimeOverlays extends StatelessWidget {
  const TimeOverlays({required this.overlays});

  final List<TimeOverlay> overlays;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final height = constraints.maxHeight;
      
      final controller = DefaultTimeController.of(context)!;

      return Stack(children: [
        for (final overlay in overlays)
          Positioned.fill(
            top: (overlay.start / controller.maxRange.duration) * height,
            bottom: (1 - overlay.end / controller.maxRange.duration) * height,
            child: overlay.widget,
          ),
      ]);
    });
  }
}
