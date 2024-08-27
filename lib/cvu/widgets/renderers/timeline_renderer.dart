import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:jiffy/jiffy.dart';
import 'package:memri/cvu/widgets/renderers/renderer.dart';
import 'package:memri/cvu/widgets/renderers/timeline_renderer_model.dart';
import 'package:memri/utilities/extensions/collection.dart';
import 'package:memri/utilities/extensions/string.dart';

import '../../../widgets/components/shapes/circle.dart';
import '../../../widgets/empty.dart';
import '../../constants/cvu_color.dart';
import '../../services/cvu_action.dart';
import '../components/elements/cvu_timeline_item.dart';

/// The timeline renderer
/// This presents the data in chronological order in a vertically scrolling `timeline`
class TimelineRendererView extends Renderer {
  TimelineRendererView({required viewContext, this.minSectionHeight = 40}) :
        super(viewContext: viewContext);

  final double minSectionHeight;

  @override
  _TimelineRendererViewState createState() => _TimelineRendererViewState();
}

class _TimelineRendererViewState extends RendererViewState<TimelineRendererView> {
  get viewContext => widget.viewContext;
  late TimelineRendererModel model;
  int cellCount = 9;

  init() {
    generateModel();
  }

  void generateModel() {
    model = TimelineRendererModel();
    model.init(
        dataItems: viewContext.items,
        itemDateTimeResolver: (item) =>
            viewContext.nodePropertyResolver(item)?.dateTime("dateTime") ?? item.dateModified,
        detailLevel: detailLevel,
        mostRecentFirst: mostRecentFirst);
  }

  TimelineDetailLevel get detailLevel =>
      TimelineDetailLevelExtension.init(
          viewContext.rendererDefinitionPropertyResolver.string("detailLevel")) ??
      TimelineDetailLevel.hour;

  bool get mostRecentFirst =>
      viewContext.rendererDefinitionPropertyResolver.boolean("recentFirst", true)!;

  selectElement(TimelineElement element) => () {
    print(element);
    if (element.isGroup) {
      CVUActionOpenView(
          renderer: "list",
          // uids: Set.from(element.items.map((item) => item.id))
      )
          .execute(viewContext.getCVUContext(), context);
    } else if (element.items.length > 0) {
      var item = element.items.first;
      var press = viewContext.nodePropertyResolver(item)?.action("onPress");
      if (press != null) {
        press.execute(viewContext.getCVUContext(item: item), context);
      }
    }
  };

  Widget renderElement(TimelineElement element) {
    if (element.isGroup) {
      return TimelineItemView(
          icon: Icons.subscriptions,
          title:
          "${element.items.length} "
              "${element.itemType.titleCase()}${element.items.length != 1 ? "s" : ""}",
          backgroundColor: Colors.grey
      );
    } else if (element.items.length > 0) {
      var item = element.items.first;
      return viewContext.render(item: item);
    } else {
      return Empty();
    }
  }

  Widget widgetSectionElement(TimelineElement element) => SizedBox(
    child: Row(
      children: [
        Flexible(
          child: GestureDetector(
            onTap: selectElement(element),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: widget.minSectionHeight),
              child: renderElement(element),
            ),
          ),
        ),
      ],
    ),
  );

  List<Widget> _widgetSection(TimelineGroup group) {
    List<Widget> widgetSection = group.items.map<Widget>(widgetSectionElement).toList();
    widgetSection.insert(0, TimelineHeader(group, model.detailLevel));
    return widgetSection;
  }

  Iterable<List<Widget>> get widgetSections => model.data.map((group) => _widgetSection(group));

  Iterable<StaggeredGridTile> sectionTiles(List<Widget> widgetSection) {
    return widgetSection.mapIndexed((index, widget) => StaggeredGridTile.count(
        crossAxisCellCount: index == 0 ? 1 : cellCount - 1,
        mainAxisCellCount: index == 0 ? widgetSection.length - 1 : 1,
        child: widget
    ));
  }

  Iterable<StaggeredGridTile> separator() => [StaggeredGridTile.fit(
    crossAxisCellCount: cellCount,
    child: Divider(height: 1),
  )];

  List<StaggeredGridTile> get tiles => widgetSections.map(sectionTiles)
      .toList()
      .addSeparator(separator)
      .expand((element) => element)
      .toList();

  @override
  Widget build(BuildContext context) {
    init();
    var padding = EdgeInsets.fromLTRB(0, 80, 10, 8);//TODO widget.sceneController.showTopBar ? 8 :

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: padding,
      child: StaggeredGrid.count(
        crossAxisCount: cellCount,
        mainAxisSpacing: 4, // Spacing between tiles vertically
        crossAxisSpacing: 4, // Spacing between tiles horizontally
        children: tiles,
      ),
    );
  }
}

class TimelineHeader extends StatelessWidget {
  final TimelineGroup group;
  final TimelineDetailLevel detailLevel;

  const TimelineHeader(this.group, this.detailLevel);

  bool get flipOrder {
    switch (detailLevel) {
      case TimelineDetailLevel.hour:
        return true;
      default:
        return false;
    }
  }

  CrossAxisAlignment get alignment {
    switch (detailLevel) {
      case TimelineDetailLevel.year:
        return CrossAxisAlignment.start;
      case TimelineDetailLevel.day:
        return CrossAxisAlignment.center;
      default:
        return CrossAxisAlignment.center;
    }
  }

  bool get useFillToIndicateNow {
    switch (detailLevel) {
      case TimelineDetailLevel.day:
        return true;
      default:
        return false;
    }
  }

  String get largeString {
    switch (detailLevel) {
      case TimelineDetailLevel.hour:
        if (group.isStartOf.contains(Unit.day)) {
          return Jiffy.parseFromDateTime(group.date).format(pattern: "dd/MM");
        }
        break;
      case TimelineDetailLevel.day:
        return Jiffy.parseFromDateTime(group.date).format(pattern: "d");
      case TimelineDetailLevel.week:
        return Jiffy.parseFromDateTime(group.date).format(pattern: "EEEE"); //TODO
      case TimelineDetailLevel.month:
        return Jiffy.parseFromDateTime(group.date).format(pattern: "MMMM");
      case TimelineDetailLevel.year:
        return Jiffy.parseFromDateTime(group.date).format(pattern: "y");
    }
    return "";
  }

  String get smallString {
    switch (detailLevel) {
      case TimelineDetailLevel.hour:
        return Jiffy.parseFromDateTime(group.date).format(pattern: "h a");
      case TimelineDetailLevel.day:
        return Jiffy.parseFromDateTime(group.date)
            .format(pattern: "MMMM"); //group.isStartOf.contains(Unit.YEAR) ? "MMMM y" : "MMMM"
      case TimelineDetailLevel.week:
        return "Week"; //TODO
      case TimelineDetailLevel.month:
        if (group.isStartOf.contains(Unit.year)) {
          return Jiffy.parseFromDateTime(group.date).format(pattern: "y");
        }
        break;
      default:
        break;
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    var matchesNow = TimelineRendererModel.calendarHelper.isSameAsNow(group.date, detailLevel.relevantComponents);

    List<Widget> children = [
      Text(
        smallString,
        style: TextStyle(
          fontSize: 14,
          color: matchesNow ? Colors.red : CVUColor.system("secondaryLabel"),
        ),
      ),
      ConstrainedBox(
        constraints: BoxConstraints(minWidth: 30, minHeight: 30),
        child: Circle(
          color: useFillToIndicateNow && matchesNow ? Colors.red : Colors.transparent,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: matchesNow ? 3 : 0),
              child: Text(
                largeString,
                style: TextStyle(
                  fontSize: 20,
                  color: matchesNow
                      ? (useFillToIndicateNow ? Colors.white : Colors.red)
                      : CVUColor.system("label"),
                ),
                maxLines: 1,
              ),
            ),
          ),
        ),
      ),
      Spacer()
    ];
    if (flipOrder)
      children.reverseRange(0, 2);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: children,
      ),
    );
  }
}
