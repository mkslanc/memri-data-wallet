import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:jiffy/jiffy.dart';
import 'package:memri/MemriApp/CVU/actions/CVUAction.dart';
import 'package:memri/MemriApp/UI/CVUComponents/CVUElements/CVUTimelineItem.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/Helpers/CalendarHelper.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';
import 'package:memri/MemriApp/UI/Components/ShapesAndProgress/Circle.dart';
import 'package:memri/MemriApp/UI/Renderers/TimelineRendererModel.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/String.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';

import '../ViewContextController.dart';

/// The timeline renderer
/// This presents the data in chronological order in a vertically scrolling `timeline`
class TimelineRendererView extends StatelessWidget {
  final SceneController sceneController;
  final ViewContextController viewContext;

  TimelineRendererView(
      {required this.sceneController, required this.viewContext, this.minSectionHeight = 40});

  Future<TimelineRendererModel> generateModel() async {
    var timelineRendererModel = TimelineRendererModel();
    await timelineRendererModel.init(
        dataItems: viewContext.items,
        itemDateTimeResolver: (item) async {
          return await viewContext.nodePropertyResolver(item)?.dateTime("dateTime") ??
              item.dateModified;
        },
        detailLevel: await detailLevel,
        mostRecentFirst: await mostRecentFirst);
    return timelineRendererModel;
  }

  Future<TimelineDetailLevel> get detailLevel async {
    return TimelineDetailLevelExtension.init(
            await viewContext.rendererDefinitionPropertyResolver.string("detailLevel")) ??
        TimelineDetailLevel.hour;
  }

  Future<bool> get mostRecentFirst async {
    return (await viewContext.rendererDefinitionPropertyResolver.boolean("recentFirst", true))!;
  }

  final double minSectionHeight;

  List<List<Widget>> sections(TimelineRendererModel model) {
    List<List<Widget>> widgetSections = [];
    model.data.forEach((group) {
      List<Widget> widgetSection = [];
      widgetSection.add(header(model, group, TimelineRendererModel.calendarHelper));
      group.items.forEach((element) {
        widgetSection.add(
          SizedBox(
            child: Row(
              children: [
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      if (element.isGroup) {
                        CVUActionOpenView(
                                renderer: "list",
                                uids: Set.from(element.items.map((item) => item.uid)))
                            .execute(sceneController, viewContext.getCVUContext());
                      } else if (element.items.length > 0) {
                        var item = element.items.first;
                        var press = viewContext.nodePropertyResolver(item)?.action("onPress");
                        if (press != null) {
                          press.execute(sceneController, viewContext.getCVUContext(item: item));
                        }
                      }
                    },
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: minSectionHeight),
                      child: renderElement(element),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });
      widgetSections.add(widgetSection);
    });
    return widgetSections;
  }

  Widget renderElement(TimelineElement element) {
    if (element.isGroup) {
      return TimelineItemView(
          icon: Icons.subscriptions,
          title:
              "${element.items.length} ${element.itemType.titleCase()}${element.items.length != 1 ? "s" : ""}",
          backgroundColor: Colors.grey);
    } else if (element.items.length > 0) {
      var item = element.items.first;
      return viewContext.render(item: item);
    } else {
      return SizedBox.shrink();
    }
  }

  List<StaggeredTile> tiles(List<List<Widget>> widgetSections) => widgetSections
      .mapIndexed((i, widgetList) =>
          widgetList
              .mapIndexed((index, widget) =>
                  StaggeredTile.count(index == 0 ? 1 : 4, index == 0 ? widgetList.length - 1 : 1))
              .toList() +
          (i < widgetSections.length - 1 ? [StaggeredTile.count(5, 0.1)] : []))
      .expand((element) => element)
      .toList();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TimelineRendererModel>(
        future: generateModel(),
        builder: (BuildContext context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              TimelineRendererModel model = snapshot.data!;
              var padding = EdgeInsets.fromLTRB(0, 8, 10, 8);
              var widgetSections = sections(model);
              var children = widgetSections
                  .expand((element) => element + [Divider(height: 1)])
                  .toList()
                    ..removeLast();
              return Expanded(
                  child: StaggeredGridView.count(
                physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: padding,
                addRepaintBoundaries: false,
                crossAxisCount: 5,
                children: children,
                staggeredTiles: tiles(widgetSections),
              ));
            default:
              return Text("");
          }
        });
  }

  final double leadingInset = 60;

  // TODO: Clean up this function. Should probably define for each `DetailLevel` individually
  Widget header(TimelineRendererModel model, TimelineGroup group, CalendarHelper calendarHelper) {
    var matchesNow = calendarHelper.isSameAsNow(group.date, model.detailLevel.relevantComponents);

    bool flipOrder = () {
      switch (model.detailLevel) {
        case TimelineDetailLevel.hour:
          return true;
        default:
          return false;
      }
    }();

    CrossAxisAlignment alignment = () {
      switch (model.detailLevel) {
        case TimelineDetailLevel.year:
          return CrossAxisAlignment.start;
        case TimelineDetailLevel.day:
          return CrossAxisAlignment.center;
        default:
          return CrossAxisAlignment.center;
      }
    }();

    String? largeString = () {
      switch (model.detailLevel) {
        case TimelineDetailLevel.hour:
          if (group.isStartOf.contains(Units.DAY)) {
            return Jiffy(group.date).format("dd/MM");
          }
          break;
        case TimelineDetailLevel.day:
          return Jiffy(group.date).format("d");
        case TimelineDetailLevel.week:
          return Jiffy(group.date).format("EEEE"); //TODO
        case TimelineDetailLevel.month:
          return Jiffy(group.date).format("MMMM");
        case TimelineDetailLevel.year:
          return Jiffy(group.date).format("y");
      }
      return null;
    }();

    String? smallString = () {
      switch (model.detailLevel) {
        case TimelineDetailLevel.hour:
          return Jiffy(group.date).format("h a");
        case TimelineDetailLevel.day:
          return Jiffy(group.date)
              .format("MMMM"); //group.isStartOf.contains(Units.YEAR) ? "MMMM y" : "MMMM"
        case TimelineDetailLevel.week:
          return "Week"; //TODO
        case TimelineDetailLevel.month:
          if (group.isStartOf.contains(Units.YEAR)) {
            return Jiffy(group.date).format("y");
          }
          break;
        default:
          break;
      }
      return null;
    }();

    Widget small = Text(
      smallString ?? "",
      style: TextStyle(
        fontSize: 14,
        color: matchesNow ? Colors.red : CVUColor.system("secondaryLabel"),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          if (!flipOrder) small,
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: 30, minHeight: 30),
            child: Circle(
              color: useFillToIndicateNow(model) && matchesNow ? Colors.red : Colors.transparent,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: matchesNow ? 3 : 0),
                  child: Text(
                    largeString ?? "",
                    style: TextStyle(
                      fontSize: 20,
                      color: matchesNow
                          ? (useFillToIndicateNow(model) ? Colors.white : Colors.red)
                          : CVUColor.system("label"),
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ),
          if (flipOrder) small,
          Spacer()
        ],
      ),
    );
  }

  bool useFillToIndicateNow(TimelineRendererModel model) {
    switch (model.detailLevel) {
      case TimelineDetailLevel.day:
        return true;
      default:
        return false;
    }
  }
}
