import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/actions/CVUAction.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/Helpers/CalendarHelper.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';
import 'package:memri/MemriApp/UI/Components/ShapesAndProgress/Circle.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import '../ViewContextController.dart';
import 'CalendarRendererModel.dart';

/// The calendar renderer
/// This presents the data in a month-style calendar view
/// Dots are used to represent days on which items fall
/// Pressing on a day will show a timeline view focused on that day
class CalendarRendererView extends StatelessWidget {
  final SceneController sceneController;
  final ViewContextController viewContext;
  final calendarHelper = CalendarHelper();
  late final Color backgroundColor;
  late final Color primaryColor;
  late final CalendarCalculations model;

  CalendarRendererView({required this.sceneController, required this.viewContext});

  init() async {
    backgroundColor = await viewContext.rendererDefinitionPropertyResolver.backgroundColor ??
        CVUColor.system("systemBackground");
    primaryColor =
        await viewContext.rendererDefinitionPropertyResolver.color() ?? CVUColor.system("red");
    model = await calculateModel();
  }

  Future<CalendarCalculations> calculateModel() async {
    var calcs = CalendarCalculations();
    await calcs.init(
        calendarHelper: calendarHelper,
        data: viewContext.items,
        dateResolver: (ItemRecord item) async =>
            (await viewContext.nodePropertyResolver(item)?.dateTime("dateTime") ??
                item.dateModified));
    return calcs;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: init(),
        builder: (BuildContext context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Expanded(
                  child: Column(
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
              ));
            default:
              return Empty();
          }
        });
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
                  .execute(sceneController, viewContext.getCVUContext());
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
