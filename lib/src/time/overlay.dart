// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:dart_date/dart_date.dart' as dd;
import 'package:flutter/widgets.dart';
import 'package:remind_timetable/src/utils.dart';

import '../event/event.dart';
import 'controller.dart';

@immutable
class TimeOverlay {
  TimeOverlay({
    required this.start,
    required this.end,
    required this.widget,
    this.position = TimeOverlayPosition.behindEvents,
  })  : assert(start.debugCheckIsValidTimetableTimeOfDay()),
        assert(end.debugCheckIsValidTimetableTimeOfDay()),
        assert(start < end);

  final Duration start;
  final Duration end;

  /// The widget that will be shown as an overlay.
  final Widget widget;

  /// Whether to paint this overlay behind or in front of events.
  final TimeOverlayPosition position;
}

enum TimeOverlayPosition { behindEvents, inFrontOfEvents }

/// Provides [TimeOverlay]s to Timetable widgets.
///
/// [TimeOverlayProvider]s may only return overlays for the given [date].
///
/// See also:
///
/// * [emptyTimeOverlayProvider], which returns an empty list for all dates.
/// * [mergeTimeOverlayProviders], which merges multiple [TimeOverlayProvider]s.
typedef TimeOverlayProvider = List<TimeOverlay> Function(
  BuildContext context,
  DateTime date,
);

List<TimeOverlay> emptyTimeOverlayProvider(
  // ignore: avoid-unused-parameters, To match [TimeOverlayProvider]
  BuildContext context,
  DateTime date,
) {
  assert(date.debugCheckIsValidTimetableDate());
  return [];
}

TimeOverlayProvider mergeTimeOverlayProviders(
  List<TimeOverlayProvider> overlayProviders,
) {
  return (context, date) => overlayProviders.expand((it) => it(context, date)).toList();
}

class DefaultTimeOverlayProvider extends InheritedWidget {
  const DefaultTimeOverlayProvider({
    required this.overlayProvider,
    required super.child,
  });

  final TimeOverlayProvider overlayProvider;

  @override
  bool updateShouldNotify(DefaultTimeOverlayProvider oldWidget) => overlayProvider != oldWidget.overlayProvider;

  static TimeOverlayProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DefaultTimeOverlayProvider>()?.overlayProvider;
  }
}

extension EventToTimeOverlay on Event {
  TimeOverlay? toTimeOverlay(
    BuildContext context, {
    required DateTime date,
    required Widget widget,
    TimeOverlayPosition position = TimeOverlayPosition.inFrontOfEvents,
  }) {
    assert(date.debugCheckIsValidTimetableDate());

    final controller = DefaultTimeController.of(context)!;
    final _start = controller.maxRange.startTime;
    final _end = controller.maxRange.endTime;

    final dateStart = date.add(_start);
    final dateEnd = date.add(_end);

    final intersects = start.isSameOrBefore(dateEnd) && endInclusive.isSameOrAfter(dateStart);

    // print("Timeoverlay: $start $end | $date => $intersects");
    if (!intersects) {
      return null;
    }

    // start=25. 12h, end=25. 13h
    // dateStart=24. 21h, dateEnd=26. 2h
    final deltaStart = start.difference(dateStart);
    final deltaEnd = endInclusive.difference(dateStart);
    // print("Timeoverlay: deltaStart: $deltaStart - $deltaEnd");

    return TimeOverlay(
      start: deltaStart,
      end: deltaEnd,
      widget: widget,
      position: position,
    );
  }
}
