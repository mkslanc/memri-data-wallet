import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../core/models/item.dart';
import '../../../utilities/helpers/calendar_helper.dart';
import '../../../widgets/components/shapes/circle.dart';
import '../../../widgets/empty.dart';
import '../../constants/cvu_color.dart';
import '../../controllers/view_context_controller.dart';
import '../../services/cvu_action.dart';

/// The calendar renderer
/// This presents the data in a month-style calendar view
/// Dots are used to represent days on which items fall
/// Pressing on a day will show a timeline view focused on that day
class CalendarRendererView extends StatefulWidget {
  final ViewContextController viewContext;

  CalendarRendererView({required this.viewContext});

  @override
  _CalendarRendererViewState createState() => _CalendarRendererViewState();
}

class _CalendarRendererViewState extends State<CalendarRendererView> {
  final calendarHelper = CalendarHelper();

  late final Color backgroundColor;

  late final Color primaryColor;

  late final CalendarCalculations model;

  @override
  initState() {
    super.initState();
    init();
  }

  init() {
    backgroundColor = widget.viewContext.rendererDefinitionPropertyResolver.backgroundColor ??
        CVUColor.system("systemBackground");
    primaryColor = widget.viewContext.rendererDefinitionPropertyResolver.color() ??
        CVUColor.system("red");
    model = calculateModel();
  }

  CalendarCalculations calculateModel() {
    var calcs = CalendarCalculations();
    calcs.init(
        calendarHelper: calendarHelper,
        data: widget.viewContext.items,
        dateResolver: (Item item) =>
            (widget.viewContext.nodePropertyResolver(item)?.dateTime("dateTime") ??
                item.dateModified));
    return calcs;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ColoredBox(
          color: Colors.grey.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: calendarHelper.daysInWeek
                  .map((dayString) => Text(
                dayString,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ))
                  .toList(),
            ),
          ),
        ),
        Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ColoredBox(
                color: backgroundColor,
                child: GridView.count(
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    crossAxisCount: 7,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    children: sections(model)),
              ),
            ))
      ],
    );
  }

  List<Widget> sections(CalendarCalculations calcs) {
    return calendarHelper
        .getMonths(calcs.start, calcs.end)
        .map((el) => section(el, calcs))
        .expand((element) => element)
        .toList();
  }

  List<Widget> section(DateTime month, CalendarCalculations calcs) {
    List<dynamic> days = [
      Text(
        calendarHelper.monthYearString(month),
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      )
    ];
    days.addAll(List.generate(6, (index) => null));
    days.addAll(calendarHelper.getPaddedDays(month));
    days.addAll(calendarHelper.getPaddedDaysEnd(month));
    return days.mapIndexed((index, day) {
      if (day != null && day is DateTime) {
        return GestureDetector(
          onTap: () {
            if (calcs.hasItemOnDay(day)) {
              CVUActionOpenView(
                      viewName: "calendarDayView",
                      renderer: "timeline",
                      dateRange: calendarHelper.wholeDay(day))
                  .execute(widget.viewContext.getCVUContext(), context);
            } else {
              return;
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),
              Text(
                calendarHelper.dayString(day),
                style: TextStyle(
                    color: calendarHelper.isToday(day) ? primaryColor : CVUColor.system("label")),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: SizedBox(
                      width: 10,
                      height: 10,
                      child: Circle(
                          color: calcs.itemsOnDay(day).isEmpty
                              ? CVUColor.system("clear")
                              : primaryColor),
                    ),
                  ),
                  calcs.itemsOnDay(day).length > 1
                      ? Text("x${calcs.itemsOnDay(day).length}")
                      : Empty()
                ],
              ),
              Spacer(),
              Divider(
                height: 1,
              )
            ],
          ),
        );
      } else {
        if (day is Widget) {
          return day;
        }
        return Empty();
      }
    }).toList();
  }
}

/// This struct is used to create and hold a pre-processed representation of data for the calendar view (eg. grouped by day)
class CalendarCalculations {
  late Map<DateTime, List<Item>> datesWithItems = {};
  late DateTime start;
  late DateTime end;

  init(
      {required CalendarHelper calendarHelper,
        required List<Item> data,
        required DateTime? Function(Item) dateResolver}) {
    data.forEach((Item item) {
      var dateTime = dateResolver(item);
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

    var datesWithItemsKeys = datesWithItems.keys;
    var minDate = datesWithItemsKeys.map((el) => el.millisecondsSinceEpoch).reduce(min);
    var maxDate = datesWithItemsKeys.map((el) => el.millisecondsSinceEpoch).reduce(max);
    this.start =
        CalendarHelper().startOfMonth(DateTime.fromMillisecondsSinceEpoch(minDate)).dateTime;
    this.end = CalendarHelper().endOfMonth(DateTime.fromMillisecondsSinceEpoch(maxDate)).dateTime;
  }

  bool hasItemOnDay(DateTime day) {
    return datesWithItems.keys.contains(day);
  }

  List<Item> itemsOnDay(DateTime day) {
    return datesWithItems[day] ?? [];
  }
}
