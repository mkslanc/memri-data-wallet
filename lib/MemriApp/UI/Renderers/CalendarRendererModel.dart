import 'dart:math';

import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Helpers/CalendarHelper.dart';

/// This struct is used to create and hold a pre-processed representation of data for the calendar view (eg. grouped by day)
class CalendarCalculations {
  late Map<DateTime, List<ItemRecord>> datesWithItems = {};
  late DateTime start;
  late DateTime end;

  init(
      {required CalendarHelper calendarHelper,
      required List<ItemRecord> data,
      required Future<DateTime?> Function(ItemRecord) dateResolver}) async {
    await Future.forEach(data, (ItemRecord item) async {
      var dateTime = await dateResolver(item);
      if (dateTime == null) {
        return;
      }
      var date = calendarHelper.startOfDay(dateTime).dateTime;

      if (datesWithItems.containsKey(date)) {
        datesWithItems[date]!.add(item);
      } else {
        datesWithItems[date] = [item];
      }
    });
    int minDate, maxDate;
    if (datesWithItems.isNotEmpty) {
      var datesWithItemsKeys = datesWithItems.keys;
      minDate = datesWithItemsKeys.map((el) => el.millisecondsSinceEpoch).reduce(min);
      maxDate = datesWithItemsKeys.map((el) => el.millisecondsSinceEpoch).reduce(max);
    } else {
      minDate = DateTime.now().millisecondsSinceEpoch;
      maxDate = DateTime.now().millisecondsSinceEpoch;
    }
    this.start =
        CalendarHelper().startOfMonth(DateTime.fromMillisecondsSinceEpoch(minDate)).dateTime;
    this.end = CalendarHelper().endOfMonth(DateTime.fromMillisecondsSinceEpoch(maxDate)).dateTime;
  }

  bool hasItemOnDay(DateTime day) {
    return datesWithItems.keys.contains(day);
  }

  List<ItemRecord> itemsOnDay(DateTime day) {
    return datesWithItems[day] ?? [];
  }
}
