import 'package:flutter/material.dart';
import 'package:memri/constants/cvu/cvu_color.dart';
import 'package:memri/core/cvu/cvu_action.dart';
import 'package:memri/models/database/item_record.dart';
import 'package:memri/models/ui/calendar_renderer_model.dart';
import 'package:memri/utils/calendar_helper.dart';
import 'package:memri/utils/extensions/collection.dart';
import 'package:memri/widgets/components/shapes/circle.dart';
import 'package:memri/widgets/empty.dart';
import 'package:memri/widgets/renderers/renderer.dart';

/// The calendar renderer
/// This presents the data in a month-style calendar view
/// Dots are used to represent days on which items fall
/// Pressing on a day will show a timeline view focused on that day
class CalendarRendererView extends Renderer {
  CalendarRendererView({required pageController, required viewContext})
      : super(pageController: pageController, viewContext: viewContext);

  @override
  _CalendarRendererViewState createState() => _CalendarRendererViewState();
}

class _CalendarRendererViewState extends RendererViewState {
  final calendarHelper = CalendarHelper();

  late final Color backgroundColor;

  late final Color primaryColor;

  late final CalendarCalculations model;

  late final Future _init;

  @override
  initState() {
    super.initState();
    _init = init();
  }

  init() async {
    backgroundColor = await widget.viewContext.rendererDefinitionPropertyResolver.backgroundColor ??
        CVUColor.system("systemBackground");
    primaryColor = await widget.viewContext.rendererDefinitionPropertyResolver.color() ??
        CVUColor.system("red");
    model = await calculateModel();
  }

  Future<CalendarCalculations> calculateModel() async {
    var calcs = CalendarCalculations();
    await calcs.init(
        calendarHelper: calendarHelper,
        data: widget.viewContext.items,
        dateResolver: (ItemRecord item) async =>
            (await widget.viewContext.nodePropertyResolver(item)?.dateTime("dateTime") ??
                item.dateModified));
    return calcs;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
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
                  .execute(widget.pageController, widget.viewContext.getCVUContext());
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
